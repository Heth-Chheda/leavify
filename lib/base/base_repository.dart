import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:leavify/core/utils/constants/enums/enums.dart';

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

  // ⚠️ DEVELOPMENT ONLY: Flag to enable/disable SSL certificate verification bypass
  static const bool _bypassSSLCertificate = true;

  // ⚠️ DEVELOPMENT ONLY: Custom HTTP client that bypasses SSL certificate verification
  // This is INSECURE and should NEVER be used in production!
  http.Client _getHttpClient() {
    if (_bypassSSLCertificate) {
      // Create an HTTP client that accepts all certificates (INSECURE!)
      final ioClient = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) {
              return true; // Accept all certificates
            };

      return IOClient(ioClient);
    } else {
      // Use default secure client
      return http.Client();
    }
  }

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

  /// Perform a request that returns a list of objects
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

    // ⚠️ Get custom HTTP client (with or without SSL bypass)
    final client = _getHttpClient();

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

          // ⚠️ Use custom client for multipart requests
          final streamedResponse = await client.send(request);
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

          // ⚠️ Use custom client for all requests
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

        // ⚠️ Clean up: Close the client after use
        client.close();

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        } else {
          if (response.statusCode == 500 && attempt < _maxRetries) {
            attempt++;
            continue;
          } else {
            // Improved error extraction
            String errorMessage = "Request failed (${response.statusCode})";

            try {
              if (response.body.isNotEmpty) {
                final decoded = jsonDecode(response.body);

                if (decoded is Map<String, dynamic>) {
                  if (decoded['error'] != null) {
                    errorMessage = decoded['error'].toString();
                  } else if (decoded['message'] != null) {
                    errorMessage = decoded['message'].toString();
                  } else {
                    errorMessage = response.body;
                  }
                } else {
                  errorMessage = response.body;
                }
              }
            } catch (_) {
              errorMessage = response.body;
            }

            throw ApiException(errorMessage, statusCode: response.statusCode);
          }
        }
      } on SocketException {
        client.close();
        if (attempt < _maxRetries) {
          attempt++;
          continue;
        } else {
          throw ApiException("No Internet connection");
        }
      } catch (e) {
        client.close();
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

  void printFullJson(String jsonStr) {
    const int chunkSize = 800;
    for (var i = 0; i < jsonStr.length; i += chunkSize) {
      final end = (i + chunkSize < jsonStr.length)
          ? i + chunkSize
          : jsonStr.length;
      print(jsonStr.substring(i, end));
    }
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
