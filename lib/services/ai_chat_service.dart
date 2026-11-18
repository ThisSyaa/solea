import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AiTurn {
  final bool isUser;
  final String text;
  const AiTurn({required this.isUser, required this.text});
}

class AiChatService {
  AiChatService._();
  static final AiChatService instance = AiChatService._();

  static const _geminiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const _groqKey = String.fromEnvironment('GROQ_API_KEY');

  static const _proxyUrl = String.fromEnvironment('AI_PROXY_URL');
  static bool get _useProxy => _proxyUrl.isNotEmpty;

  static const _primary =
      String.fromEnvironment('AI_PRIMARY', defaultValue: 'gemini');

  static const _geminiModel = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-3.5-flash-lite',
  );
  static const _groqModel = String.fromEnvironment(
    'GROQ_MODEL',
    defaultValue: 'openai/gpt-oss-120b',
  );

  static const _geminiFallbackModels = <String>[
    'gemini-2.5-flash-lite',
    'gemini-3.5-flash',
    'gemini-2.5-flash',
  ];

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 50),
    ),
  );

  bool get _hasGemini => _useProxy || _geminiKey.isNotEmpty;
  bool get _hasGroq => _useProxy || _groqKey.isNotEmpty;

  bool get isConfigured => _hasGemini || _hasGroq;

  Future<String> reply({
    required String systemPrompt,
    required List<AiTurn> history,
  }) async {
    debugPrint('[SOLEA AI] gemini key: ${_geminiKey.isNotEmpty}, '
        'groq key: ${_groqKey.isNotEmpty}, primary: $_primary');

    final order = _primary == 'groq' ? ['groq', 'gemini'] : ['gemini', 'groq'];

    for (final provider in order) {
      if (provider == 'gemini' && _hasGemini) {
        try {
          final r = await _askGemini(systemPrompt, history);
          debugPrint('[SOLEA AI] Dijawab oleh Gemini');
          return r;
        } catch (e) {
          _logError('Gemini', e);
        }
      }

      if (provider == 'groq' && _hasGroq) {
        try {
          final r = await _askGroq(systemPrompt, history);
          debugPrint('[SOLEA AI] Dijawab oleh Groq');
          return r;
        } catch (e) {
          _logError('Groq', e);
        }
      }
    }

    throw AiUnavailable();
  }

  void _logError(String name, Object e) {
    debugPrint('[SOLEA AI] $name gagal: $e');
    if (e is DioException) {
      debugPrint('[SOLEA AI] $name status: ${e.response?.statusCode}');
      debugPrint('[SOLEA AI] $name detail: ${e.response?.data}');
    }
  }

  Future<String> _askGemini(String system, List<AiTurn> history) async {
    final models = <String>{_geminiModel, ..._geminiFallbackModels}.toList();

    Object? lastError;
    for (final model in models) {
      for (var attempt = 1; attempt <= 2; attempt++) {
        try {
          final r = await _askGeminiModel(model, system, history);
          debugPrint('[SOLEA AI] Gemini model dipakai: $model');
          return r;
        } on DioException catch (e) {
          lastError = e;
          final code = e.response?.statusCode;
          debugPrint('[SOLEA AI] Gemini $model gagal (status: $code), '
              'percobaan $attempt');
          if (code == 503 || code == 429) {
            if (attempt < 2) {
              await Future.delayed(const Duration(seconds: 1));
            }
            continue;
          }
          break;
        } on AiUnavailable catch (e) {
          lastError = e;
          break;
        }
      }
    }
    throw lastError ?? AiUnavailable();
  }

  Future<String> _askGeminiModel(
    String model,
    String system,
    List<AiTurn> history,
  ) async {
    final res = await _dio.post(
      _useProxy
          ? '$_proxyUrl/gemini/$model'
          : 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
      options: Options(headers: {
        if (!_useProxy) 'x-goog-api-key': _geminiKey,
        'Content-Type': 'application/json',
      }),
      data: {
        'system_instruction': {
          'parts': [
            {'text': system}
          ]
        },
        'contents': [
          for (final t in history)
            {
              'role': t.isUser ? 'user' : 'model',
              'parts': [
                {'text': t.text}
              ],
            }
        ],
        'generationConfig': {'temperature': 0.6, 'maxOutputTokens': 1500},
      },
    );

    final dynamic candidates = res.data['candidates'];
    dynamic parts;
    if (candidates is List && candidates.isNotEmpty) {
      final dynamic content = candidates[0]['content'];
      if (content is Map) parts = content['parts'];
    }
    final text = (parts is List)
        ? parts.map((p) => (p['text'] ?? '').toString()).join().trim()
        : '';
    if (text.isEmpty) throw AiUnavailable();
    return text;
  }

  // ---- Groq ----
  Future<String> _askGroq(String system, List<AiTurn> history) async {
    final res = await _dio.post(
      _useProxy
          ? '$_proxyUrl/groq'
          : 'https://api.groq.com/openai/v1/chat/completions',
      options: Options(headers: {
        if (!_useProxy) 'Authorization': 'Bearer $_groqKey',
        'Content-Type': 'application/json',
      }),
      data: {
        'model': _groqModel,
        'temperature': 0.6,
        'max_tokens': 1500,
        'reasoning_effort': 'low',
        'messages': [
          {'role': 'system', 'content': system},
          for (final t in history)
            {'role': t.isUser ? 'user' : 'assistant', 'content': t.text},
        ],
      },
    );

    final dynamic choices = res.data['choices'];
    String text = '';
    if (choices is List && choices.isNotEmpty) {
      final dynamic message = choices[0]['message'];
      if (message is Map && message['content'] != null) {
        text = message['content'].toString().trim();
      }
    }
    if (text.isEmpty) throw AiUnavailable();
    return text;
  }
}

class AiUnavailable implements Exception {
  @override
  String toString() => 'AI tidak tersedia';
}