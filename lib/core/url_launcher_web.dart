import 'dart:js_interop';

@JS('window.open')
external JSObject? _windowOpen(
  String url,
  String target,
  String features,
);

Future<bool> openExternalUrlImpl(String url) async {
  try {
    // Membuka link di tab baru setara dengan target="_blank" rel="noopener"
    _windowOpen(url, '_blank', 'noopener,noreferrer');
    return true;
  } catch (_) {
    return false;
  }
}
