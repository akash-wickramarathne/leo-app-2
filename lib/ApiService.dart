import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:8080/api";

  static Future<bool> register(String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );
    return response.statusCode == 201;
  }

  static Future<Map<String, dynamic>?> login(
      String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<bool> sendMessage(
      int senderId, int receiverId, String content) async {
    final response = await http.post(
      Uri.parse("$baseUrl/message"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
          {"senderId": senderId, "receiverId": receiverId, "content": content}),
    );
    return response.statusCode == 201;
  }

  static Future<List<Map<String, dynamic>>> getMessages(
      int senderId, int receiverId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/messages?senderId=$senderId&receiverId=$receiverId"),
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }

  static Future<List> fetchUsers() async {
    final response = await http.get(Uri.parse("$baseUrl/users"));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List users = data.map((user) => user['name']).toList();
      return users;
    } else {
      throw Exception('Failed to fetch users');
    }
  }
}
