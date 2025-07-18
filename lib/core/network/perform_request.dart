import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
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
      return await _retry.retry(
        () async {
          switch (method) {
            case RequestType.get:
              return await http.get(Uri.parse(url), headers: headers);

            case RequestType.post:
              return await http.post(
                Uri.parse(url),
                headers: _defaultHeaders(headers),
                body: jsonEncode(body),
              );

            case RequestType.put:
              return await http.put(
                Uri.parse(url),
                headers: _defaultHeaders(headers),
                body: jsonEncode(body),
              );

            case RequestType.delete:
              return await http.delete(
                Uri.parse(url),
                headers: _defaultHeaders(headers),
              );

            case RequestType.urlEncoded:
              return await http.post(
                Uri.parse(url),
                headers: _urlEncodedHeaders(headers),
                body: urlEncodedBody,
              );

            case RequestType.multipart:
              var request = http.MultipartRequest("POST", Uri.parse(url));
              if (headers != null) request.headers.addAll(headers);
              if (multipartFields != null) {
                request.fields.addAll(multipartFields);
              }
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

  Map<String, String> _defaultHeaders(Map<String, String>? custom) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?custom,
    };
  }

  Map<String, String> _urlEncodedHeaders(Map<String, String>? custom) {
    return {'Content-Type': 'application/x-www-form-urlencoded', ...?custom};
  }
}
