import 'package:http/http.dart' as http;

/// Adds an `Authorization: Bearer` header when a token is available.
class AuthClient extends http.BaseClient {
  AuthClient(this._inner, {required String? Function() tokenProvider})
    : _tokenProvider = tokenProvider;

  final http.Client _inner;
  final String? Function() _tokenProvider;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final token = _tokenProvider();
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}
