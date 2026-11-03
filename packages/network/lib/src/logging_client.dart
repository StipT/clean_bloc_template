import 'package:http/http.dart' as http;

/// Logs request and response lines through `log` with URLs sanitized.
class LoggingClient extends http.BaseClient {
  LoggingClient(this._inner, {required void Function(String) log}) : _log = log;

  final http.Client _inner;
  final void Function(String) _log;

  static final _sensitiveQueryKey = RegExp(
    r'token|key|secret|password|authorization|credential|auth|signature|jwt|session|code|sig',
    caseSensitive: false,
  );

  Uri _redactUri(Uri uri) {
    final queryParameters = uri.queryParametersAll.map(
      (key, values) => MapEntry(
        key,
        _sensitiveQueryKey.hasMatch(key)
            ? List<String>.filled(values.length, '******')
            : values,
      ),
    );
    return uri.replace(userInfo: 'REDACTED', queryParameters: queryParameters);
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final url = _redactUri(request.url);
    _log('--> ${request.method} $url');
    final response = await _inner.send(request);
    _log('<-- ${response.statusCode} $url');
    return response;
  }

  @override
  void close() => _inner.close();
}
