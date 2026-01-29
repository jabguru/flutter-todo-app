import 'dart:convert';
import 'dart:io';

class FixtureHelper {
  static String loadJson(String name) {
    final file = File('test/fixtures/json/$name.json');
    return file.readAsStringSync();
  }

  static Map<String, dynamic> loadJsonMap(String name) {
    return jsonDecode(loadJson(name)) as Map<String, dynamic>;
  }

  static List<dynamic> loadJsonList(String name) {
    return jsonDecode(loadJson(name)) as List<dynamic>;
  }
}
