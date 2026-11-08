import 'url_launcher_stub.dart'
    if (dart.library.js_interop) 'url_launcher_web.dart';

/// Membuka URL eksternal di tab baru (`target="_blank" rel="noopener"` di Web).
Future<bool> openExternalUrl(String url) {
  return openExternalUrlImpl(url);
}
