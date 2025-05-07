import 'i_session_manager.dart';

class SessionManagerImpl implements SessionManager {
  // In-memory storage to hold session data
  final Map<String, String> _sessionData = {};

  @override
  Future<void> save(String key, String value) async {
    // Save data to the in-memory map
    _sessionData[key] = value;
  }

  @override
  Future<String?> load(String key) async {
    // Retrieve data from the in-memory map
    return _sessionData[key];
  }

  @override
  Future<void> clear(String key) async {
    // Remove data from the in-memory map
    _sessionData.remove(key);
  }

  void printPlatform() {
    print('Local');
  }
}
