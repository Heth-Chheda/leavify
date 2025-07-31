import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:leavify/core/storage/app_storage.dart';
import 'package:retry/retry.dart';

enum RequestType { get, post, put, delete, multipart, urlEncoded }

class PerformRequest {
  final _retry = RetryOptions(maxAttempts: 3);

  Future<http.Response> performRequest({
    required String url,
    RequestType method = RequestType.get,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, String>? urlEncodedBody,
    Map<String, String>? multipartFields,
    Map<String, String>? multipartFiles,
  }) async {
    try {
      final token = await AppStorage.getString('JWT_TOKEN');
      final authHeaders = await _buildHeaders(headers);

      return await _retry.retry(
        () async {
          switch (method) {
            case RequestType.get:
              return await http.get(Uri.parse(url), headers: authHeaders);

            case RequestType.post:
            case RequestType.put:
              final updatedJsonBody = _prepareJsonBody(
                body,
                token,
                key: 'jwtToken',
              );
              final requestFn = method == RequestType.post
                  ? http.post
                  : http.put;
              return await requestFn(
                Uri.parse(url),
                headers: authHeaders,
                body: jsonEncode(updatedJsonBody),
              );

            case RequestType.delete:
              return await http.delete(Uri.parse(url), headers: authHeaders);

            case RequestType.urlEncoded:
              final encodedHeaders = await _buildUrlEncodedHeaders(headers);
              final updatedFormBody = _prepareFormBody(urlEncodedBody, token);
              return await http.post(
                Uri.parse(url),
                headers: encodedHeaders,
                body: updatedFormBody,
              );

            case RequestType.multipart:
              var request = http.MultipartRequest("POST", Uri.parse(url));
              request.headers.addAll(authHeaders);

              final updatedFields = _prepareFormBody(multipartFields, token);
              request.fields.addAll(updatedFields);

              if (multipartFiles != null) {
                for (var entry in multipartFiles.entries) {
                  request.files.add(
                    await http.MultipartFile.fromPath(entry.key, entry.value),
                  );
                }
              }

              final streamed = await request.send();
              return await http.Response.fromStream(streamed);
          }
        },
        retryIf: (e) =>
            e is SocketException ||
            e is http.ClientException ||
            e is TimeoutException,
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> _prepareJsonBody(
    Map<String, dynamic>? original,
    String? token, {
    String key = 'token',
  }) {
    return {...?original, if (token != null && token.isNotEmpty) key: token};
  }

  Map<String, String> _prepareFormBody(
    Map<String, String>? original,
    String? token, {
    String key = 'token',
  }) {
    return {...?original, if (token != null && token.isNotEmpty) key: token};
  }

  Future<Map<String, String>> _buildHeaders(Map<String, String>? custom) async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?custom,
    };
  }

  Future<Map<String, String>> _buildUrlEncodedHeaders(
    Map<String, String>? custom,
  ) async {
    return {'Content-Type': 'application/x-www-form-urlencoded', ...?custom};
  }
}
