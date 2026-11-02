import 'package:http/http.dart' as http;

/// Logs request and response lines through `log` (headers/bodies are omitted
/// so secrets are never logged).
class LoggingClient extends http.BaseClient {
  LoggingClient(this._inner, {required void Function(String) log}) : _log = log;

  final http.Client _inner;
  final void Function(String) _log;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    _log('--> ${request.method} ${request.url}');
    final response = await _inner.send(request);
    _log('<-- ${response.statusCode} ${request.url}');
    return response;
  }

  @override
  void close() => _inner.close();
}
