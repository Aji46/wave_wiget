abstract class SessionManager {
  Future<void> save(String key, String value);
  Future<String?> load(String key);
  Future<void> clear(String key);
}
