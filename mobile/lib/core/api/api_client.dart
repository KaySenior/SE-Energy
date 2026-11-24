import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

/// Thin JSON client around `package:http`.
///
/// Keeps transport concerns in one place so repositories stay testable.
class ApiClient {
  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 10),
  }) : _http = httpClient ?? http.Client();

  final String baseUrl;
  final Duration timeout;
  final http.Client _http;

  Future<dynamic> getJson(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);

    try {
      final response = await _http
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          _errorMessage(response),
          statusCode: response.statusCode,
        );
      }
      if (response.body.isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('The API took too long to respond.');
    } on http.ClientException {
      throw ApiException('Could not reach the API at $baseUrl.');
    } on FormatException {
      throw ApiException('The API returned an unexpected response.');
    }
  }

  void close() => _http.close();

  String _errorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic> && body['detail'] is String) {
        return body['detail'] as String;
      }
    } on FormatException {
      // Fall through to the generic message.
    }
    return 'Request failed with status ${response.statusCode}.';
  }
}
