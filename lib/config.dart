import 'dart:convert';
import 'dart:html' as html;

class AppConfig {
  static late String baseUrl;

  static Future<void> loadConfig() async {
    final response = await html.HttpRequest.getString('config.json');
    final config = json.decode(response);
    baseUrl = config['baseUrl'];
  }
}
