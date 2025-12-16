import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:leavify/core/utils/constants/enums/enums.dart';

/// Global callback for session expiration (set from MyApp)
typedef SessionExpiredCallback = void Function(String msg);

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class BaseRepository {
  final int _maxRetries = 2;

  // DEVELOPMENT ONLY
  static const bool _bypassSSLCertificate = true;

  // 🔥 Global session expire callback
  static SessionExpiredCallback? onSessionExpired;

  http.Client _getHttpClient() {
    if (_bypassSSLCertificate) {
      final ioClient = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) {
              return true;
            };
      return IOClient(ioClient);
    } else {
      return http.Client();
    }
  }

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
        if (decoded.isEmpty) return [];

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

    // NOTE: client is NOT created here anymore.
    // It is created inside the loop to fix the "Client already closed" error.

    final headers = _headers();
    if (extraHeaders != null) headers.addAll(extraHeaders);

    final requestBody = body != null
        ? Map<String, dynamic>.from(body)
        : <String, dynamic>{};

    if (accessToken != null && accessToken.isNotEmpty) {
      requestBody['jwtToken'] = accessToken;
    }

    int attempt = 0;

    while (attempt <= _maxRetries) {
      // ✅ FIX: Create a fresh client for every attempt
      final client = _getHttpClient();

      try {
        http.Response response;

        if (bodyType == BodyType.multipart) {
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

          final streamedResponse = await client.send(request);
          response = await http.Response.fromStream(streamedResponse);
        } else {
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
              response = await client.get(uri, headers: headers);
              break;
            case HttpMethod.post:
              response = await client.post(
                uri,
                headers: headers,
                body: encodedBody,
              );
              break;
            case HttpMethod.put:
              response = await client.put(
                uri,
                headers: headers,
                body: encodedBody,
              );
              break;
            case HttpMethod.delete:
              response = await client.delete(uri, headers: headers);
              break;
          }
        }

        _logResponse(response);
        client.close(); // Safe to close here as loop will create a new one

        // 🔥🔥🔥 GLOBAL 401 JWT EXPIRED HANDLER
        if (response.statusCode == 401 || response.statusCode == 404) {
          String message = "Please login again.";

          if (BaseRepository.onSessionExpired != null) {
            BaseRepository.onSessionExpired!(message);
          }

          throw ApiException(message, statusCode: 401);
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        } else {
          if (response.statusCode == 500 && attempt < _maxRetries) {
            attempt++;
            continue;
          }

          String errorMessage = "Request failed (${response.statusCode})";

          try {
            if (response.body.isNotEmpty) {
              final decoded = jsonDecode(response.body);
              if (decoded is Map<String, dynamic>) {
                if (decoded['error'] != null)
                  errorMessage = decoded['error'];
                else if (decoded['message'] != null)
                  errorMessage = decoded['message'];
              } else {
                errorMessage = response.body;
              }
            }
          } catch (_) {
            errorMessage = response.body;
          }

          throw ApiException(errorMessage, statusCode: response.statusCode);
        }
      } on SocketException {
        client.close();
        if (attempt < _maxRetries) {
          attempt++;
          continue;
        }
        throw ApiException("No Internet connection");
      } catch (e) {
        client.close();
        if (e is ApiException) rethrow;

        if (attempt < _maxRetries) {
          attempt++;
          continue;
        }

        // Return a generic message here so the UI doesn't see "ClientException"
        throw ApiException("Something went wrong. Please try again.");
      }
    }

    throw ApiException("Max retries exceeded");
  }

  Map<String, String> _headers() => {"Content-Type": "application/json"};

  void printFullJson(String jsonStr) {
    const chunkSize = 800;
    for (var i = 0; i < jsonStr.length; i += chunkSize) {
      final end = (i + chunkSize < jsonStr.length)
          ? i + chunkSize
          : jsonStr.length;
      print(jsonStr.substring(i, end));
    }
  }

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

  void _logResponse(http.Response response) {
    debugPrint("-----------------------");
    debugPrint("----- API RESPONSE -----");
    debugPrint("Status Code: ${response.statusCode}");
    debugPrint("Headers: ${response.headers}");
    if (response.body.isNotEmpty) {
      try {
        final prettyBody = const JsonEncoder.withIndent(
          '  ',
        ).convert(jsonDecode(response.body));
        printFullJson(prettyBody);
      } catch (e) {
        printFullJson(response.body);
      }
    }
    debugPrint("------------------------");
  }
}
