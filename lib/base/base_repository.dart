import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Enum for supported HTTP methods
enum HttpMethod { get, post, put, delete }

/// Enum for body type
enum BodyType { json, formUrlEncoded, multipart }

/// Custom API exception for clarity
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Base repository to perform requests
class BaseRepository {
  final int _maxRetries = 2;

  /// Perform a generic request
  Future<T> performRequest<T>({
    required String url,
    required HttpMethod method,
    String? accessToken,
    Map<String, dynamic>? body,
    Map<String, String>? filePaths,
    List<http.MultipartFile>?
    files, // optional if caller wants to build manually
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, String>? extraHeaders,
    BodyType bodyType = BodyType.json,
  }) async {
    final uri = Uri.parse(url);

    // Default headers
    final headers = _headers(accessToken);
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    int attempt = 0;
    while (attempt <= _maxRetries) {
      try {
        http.Response response;

        if (bodyType == BodyType.multipart) {
          // Multipart request
          final request = http.MultipartRequest(method.name.toUpperCase(), uri);
          request.headers.addAll(headers);

          if (body != null) {
            request.fields.addAll(
              body.map((k, v) => MapEntry(k, v.toString())),
            );
          }

          if (filePaths != null) {
            for (final entry in filePaths.entries) {
              request.files.add(
                await http.MultipartFile.fromPath(entry.key, entry.value),
              );
            }
          }

          if (files != null && files.isNotEmpty) {
            request.files.addAll(files);
          }

          final streamedResponse = await request.send();
          response = await http.Response.fromStream(streamedResponse);
        } else {
          // Regular requests
          String? requestBody;
          if (body != null) {
            if (bodyType == BodyType.json) {
              requestBody = jsonEncode(body);
            } else if (bodyType == BodyType.formUrlEncoded) {
              requestBody = Uri(queryParameters: body).query;
              headers["Content-Type"] = "application/x-www-form-urlencoded";
            }
          }

          switch (method) {
            case HttpMethod.get:
              response = await http.get(uri, headers: headers);
              break;
            case HttpMethod.post:
              response = await http.post(
                uri,
                headers: headers,
                body: requestBody,
              );
              break;
            case HttpMethod.put:
              response = await http.put(
                uri,
                headers: headers,
                body: requestBody,
              );
              break;
            case HttpMethod.delete:
              response = await http.delete(uri, headers: headers);
              break;
          }
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          try {
            final decoded = jsonDecode(response.body);
            if (decoded is Map<String, dynamic>) {
              return fromJson(decoded);
            } else {
              throw ApiException(
                "Invalid JSON format",
                statusCode: response.statusCode,
              );
            }
          } catch (_) {
            throw ApiException(
              "Parsing error",
              statusCode: response.statusCode,
            );
          }
        } else {
          if (response.statusCode == 500 && attempt < _maxRetries) {
            attempt++;
            continue;
          } else {
            throw ApiException(
              response.body.isNotEmpty ? response.body : "Request failed",
              statusCode: response.statusCode,
            );
          }
        }
      } on SocketException {
        if (attempt < _maxRetries) {
          attempt++;
          continue;
        } else {
          throw ApiException("No Internet connection");
        }
      } catch (e) {
        if (attempt < _maxRetries) {
          attempt++;
          continue;
        } else {
          throw ApiException("Unknown error: $e");
        }
      }
    }

    throw ApiException("Max retries exceeded");
  }

  /// Default headers
  Map<String, String> _headers(String? accessToken) {
    final headers = {"Content-Type": "application/json"};
    if (accessToken != null && accessToken.isNotEmpty) {
      headers["Authorization"] = "Bearer $accessToken";
    }
    return headers;
  }
}
