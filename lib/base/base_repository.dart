import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
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

  /// Perform a request that returns a single object
  Future<T> performRequest<T>({
    required String url,
    required HttpMethod method,
    String? accessToken,
    Map<String, dynamic>? body,
    Map<String, String>? filePaths,
    List<http.MultipartFile>? files,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, String>? extraHeaders,
    BodyType bodyType = BodyType.json,
  }) async {
    final response = await _executeRequest(
      url: url,
      method: method,
      accessToken: accessToken,
      body: body,
      filePaths: filePaths,
      files: files,
      extraHeaders: extraHeaders,
      bodyType: bodyType,
    );

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return fromJson(decoded);
      } else {
        throw ApiException(
          "Expected object, got ${decoded.runtimeType}",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException("Parsing error: $e", statusCode: response.statusCode);
    }
  }

  /// 🆕 Perform a request that returns a list of objects
  Future<List<T>> performListRequest<T>({
    required String url,
    required HttpMethod method,
    String? accessToken,
    Map<String, dynamic>? body,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, String>? extraHeaders,
    BodyType bodyType = BodyType.json,
  }) async {
    final response = await _executeRequest(
      url: url,
      method: method,
      accessToken: accessToken,
      body: body,
      extraHeaders: extraHeaders,
      bodyType: bodyType,
    );

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        // Handle empty list
        if (decoded.isEmpty) {
          return [];
        }

        // Map each item to the model
        return decoded
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(
          "Expected array, got ${decoded.runtimeType}",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException("Parsing error: $e", statusCode: response.statusCode);
    }
  }

  /// Core request execution logic (shared by both methods)
  Future<http.Response> _executeRequest({
    required String url,
    required HttpMethod method,
    String? accessToken,
    Map<String, dynamic>? body,
    Map<String, String>? filePaths,
    List<http.MultipartFile>? files,
    Map<String, String>? extraHeaders,
    BodyType bodyType = BodyType.json,
  }) async {
    final uri = Uri.parse(url);

    // Default headers
    final headers = _headers();
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    // Add access token to body if provided
    final requestBody = body != null
        ? Map<String, dynamic>.from(body)
        : <String, dynamic>{};
    if (accessToken != null && accessToken.isNotEmpty) {
      requestBody['jwtToken'] = accessToken;
    }

    int attempt = 0;
    while (attempt <= _maxRetries) {
      try {
        http.Response response;

        if (bodyType == BodyType.multipart) {
          // Multipart request
          final request = http.MultipartRequest(method.name.toUpperCase(), uri);
          request.headers.addAll(headers);

          if (requestBody.isNotEmpty) {
            request.fields.addAll(
              requestBody.map((k, v) => MapEntry(k, v.toString())),
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

          _logRequest(
            method: method,
            url: url,
            headers: request.headers,
            body: requestBody,
            isMultipart: true,
          );

          final streamedResponse = await request.send();
          response = await http.Response.fromStream(streamedResponse);
        } else {
          // Regular requests
          String? encodedBody;
          if (requestBody.isNotEmpty) {
            if (bodyType == BodyType.json) {
              encodedBody = jsonEncode(requestBody);
            } else if (bodyType == BodyType.formUrlEncoded) {
              encodedBody = Uri(
                queryParameters: requestBody.map(
                  (k, v) => MapEntry(k, v.toString()),
                ),
              ).query;
              headers["Content-Type"] = "application/x-www-form-urlencoded";
            }
          }

          _logRequest(
            method: method,
            url: url,
            headers: headers,
            body: requestBody,
          );

          switch (method) {
            case HttpMethod.get:
              response = await http.get(uri, headers: headers);
              break;
            case HttpMethod.post:
              response = await http.post(
                uri,
                headers: headers,
                body: encodedBody,
              );
              break;
            case HttpMethod.put:
              response = await http.put(
                uri,
                headers: headers,
                body: encodedBody,
              );
              break;
            case HttpMethod.delete:
              response = await http.delete(uri, headers: headers);
              break;
          }
        }

        _logResponse(response);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
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
        if (e is ApiException) rethrow;

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
  Map<String, String> _headers() {
    return {"Content-Type": "application/json"};
  }

  /// Log request details
  void _logRequest({
    required HttpMethod method,
    required String url,
    required Map<String, String> headers,
    Map<String, dynamic>? body,
    bool isMultipart = false,
  }) {
    debugPrint("------------------------");
    debugPrint("----- API REQUEST -----");
    debugPrint("Method: ${method.name.toUpperCase()}");
    debugPrint("URL: $url");
    debugPrint("Headers: $headers");
    if (body != null && body.isNotEmpty) {
      debugPrint("Body: ${jsonEncode(body)}");
    } else if (isMultipart) {
      debugPrint("Multipart body (files included)");
    }
    debugPrint("-----------------------");
  }

  /// Log response details
  void _logResponse(http.Response response) {
    debugPrint("-----------------------");
    debugPrint("----- API RESPONSE -----");
    debugPrint("Status Code: ${response.statusCode}");
    debugPrint("Headers: ${response.headers}");
    debugPrint("Body: ${response.body}");
    debugPrint("------------------------");
  }
}
