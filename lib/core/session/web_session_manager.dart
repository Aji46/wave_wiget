import 'dart:html' as html;
import 'i_session_manager.dart';

class SessionManagerImpl implements SessionManager {
  static const _sessionCookieName = 'session_active';

  @override
  Future<void> save(String key, String value) async {
    // Store data in localStorage
    html.window.localStorage[key] = value;

    // Set a session cookie (expires when browser closes)
    html.document.cookie = '$_sessionCookieName=true; path=/';
  }

  @override
  Future<String?> load(String key) async {
    // Check if session cookie exists
    if (!_hasSessionCookie()) {
      await clear(key); // Clear localStorage if no session
      return null;
    }
    return html.window.localStorage[key];
  }

  @override
  Future<void> clear(String key) async {
    // Clear localStorage
    html.window.localStorage.remove(key);

    // Invalidate session cookie
    html.document.cookie = '$_sessionCookieName=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/';
  }

  bool _hasSessionCookie() {
    return html.document.cookie?.split(';').any((cookie) => cookie.trim().startsWith(_sessionCookieName)) ?? false;
  }

  void printPlatform(){ }
}
