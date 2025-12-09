import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:staffora/data/local/local_storage_service.dart';

class ApiClient {
  /// Common header builder depending on token usage
  Map<String, String> _buildHeaders({bool useToken = true}) {
    final headers = {
      "Content-Type": "application/json",
    };

    if (useToken) {
      final token = LocalStorage.token;
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }
    }

    return headers;
  }

  /// POST
  Future<dynamic> post(
    String url,
    Map<String, dynamic> body, {
    bool useToken = true,
  }) async {
    final response = await http.post(
      Uri.parse(url),
      headers: _buildHeaders(useToken: useToken),
      body: jsonEncode(body),
    );
    return _process(response);
  }

  /// GET
  Future<dynamic> get(
    String url, {
    bool useToken = true,
  }) async {
    final response = await http.get(
      Uri.parse(url),
      headers: _buildHeaders(useToken: useToken),
    );
    return _process(response);
  }

  /// PUT
  Future<dynamic> put(
    String url,
    Map<String, dynamic> body, {
    bool useToken = true,
  }) async {
    final response = await http.put(
      Uri.parse(url),
      headers: _buildHeaders(useToken: useToken),
      body: jsonEncode(body),
    );
    return _process(response);
  }

  /// DELETE
  Future<dynamic> delete(
    String url, {
    bool useToken = true,
  }) async {
    final response = await http.delete(
      Uri.parse(url),
      headers: _buildHeaders(useToken: useToken),
    );
    return _process(response);
  }

  /// Handle Response
  dynamic _process(http.Response response) {
    final code = response.statusCode;

    if (code >= 200 && code < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      throw Exception("API Error: $code → ${response.body}");
    }
  }
}
