import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:http/http.dart' as http;

/// Thin JSON client over `package:http` that never throws: every outcome is
/// a [Result], with failures mapped to a typed [Failure].
class ApiClient {
  ApiClient({
    required String baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : _baseUrl = baseUrl.endsWith('/')
           ? baseUrl.substring(0, baseUrl.length - 1)
           : baseUrl,
       _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;
  final Duration timeout;

  Future<Result<T>> get<T>(
    String path, {
    required T Function(Object? json) parse,
    Map<String, String>? query,
  }) => _send('GET', path, parse, query: query);

  Future<Result<T>> post<T>(
    String path, {
    required T Function(Object? json) parse,
    Object? body,
  }) => _send('POST', path, parse, body: body);

  Future<Result<T>> put<T>(
    String path, {
    required T Function(Object? json) parse,
    Object? body,
  }) => _send('PUT', path, parse, body: body);

  Future<Result<T>> delete<T>(
    String path, {
    required T Function(Object? json) parse,
  }) => _send('DELETE', path, parse);

  void close() => _client.close();

  Future<Result<T>> _send<T>(
    String method,
    String path,
    T Function(Object? json) parse, {
    Map<String, String>? query,
    Object? body,
  }) async {
    final http.Response response;
    try {
      final segment = path.startsWith('/') ? path : '/$path';
      final uri = Uri.parse(
        '$_baseUrl$segment',
      ).replace(queryParameters: query);
      final request = http.Request(method, uri)
        ..headers['Accept'] = 'application/json';
      if (body != null) {
        request
          ..headers['Content-Type'] = 'application/json'
          ..body = jsonEncode(body);
      }
      response = await http.Response.fromStream(
        await _client.send(request).timeout(timeout),
      ).timeout(timeout);
    } on TimeoutException {
      return const Err(TimeoutFailure());
    } on SocketException {
      return const Err(NetworkFailure());
    } on http.ClientException {
      return const Err(NetworkFailure());
    } on Object {
      return const Err(UnknownFailure());
    }

    final code = response.statusCode;
    if (code == 401 || code == 403) return const Err(UnauthorizedFailure());
    if (code < 200 || code >= 300) {
      return Err(
        response.body.isEmpty
            ? ServerFailure(statusCode: code)
            : ServerFailure(statusCode: code, message: response.body),
      );
    }
    try {
      final json = response.body.isEmpty ? null : jsonDecode(response.body);
      return Success(parse(json));
    } on Object {
      return const Err(ParsingFailure());
    }
  }
}
