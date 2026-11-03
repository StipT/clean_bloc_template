import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:network/network.dart';
import 'package:test/test.dart';

ApiClient build(
  Future<http.Response> Function(http.Request) handler, {
  Duration timeout = const Duration(seconds: 1),
}) => ApiClient(
  baseUrl: 'https://api.test/v1',
  client: MockClient(handler),
  timeout: timeout,
);

Object? identity(Object? j) => j;

void main() {
  group('ApiClient', () {
    test('GET decodes JSON, builds url with query', () async {
      late http.Request seen;
      final api = build((r) async {
        seen = r;
        return http.Response('{"a":1}', 200);
      });
      final r = await api.get('/posts', query: {'q': 'x'}, parse: identity);
      expect(r, const Success<Object?>({'a': 1}));
      expect(seen.url.toString(), 'https://api.test/v1/posts?q=x');
      expect(seen.headers['accept'], 'application/json');
    });

    test('POST/PUT/DELETE send JSON body and method', () async {
      final seen = <http.Request>[];
      final api = build((r) async {
        seen.add(r);
        return http.Response('', 204);
      });
      final a = await api.post('posts', body: {'k': 'v'}, parse: identity);
      final b = await api.put('posts/1', body: {'k': 'w'}, parse: identity);
      final c = await api.delete('posts/1', parse: identity);
      expect([a, b, c], everyElement(const Success<Object?>(null)));
      expect(seen.map((r) => r.method), ['POST', 'PUT', 'DELETE']);
      expect(jsonDecode(seen[0].body), {'k': 'v'});
      expect(seen[0].headers['content-type'], contains('application/json'));
      expect(seen[2].body, isEmpty);
    });

    test('maps status codes to failures', () async {
      Future<Result<Object?>> call(int code) => build(
        (_) async => http.Response('nope', code),
      ).get('x', parse: identity);
      expect((await call(401)).failureOrNull, isA<UnauthorizedFailure>());
      expect((await call(403)).failureOrNull, isA<UnauthorizedFailure>());
      expect(
        (await call(500)).failureOrNull,
        const ServerFailure(statusCode: 500, message: 'nope'),
      );
      expect(
        (await call(404)).failureOrNull,
        const ServerFailure(statusCode: 404, message: 'nope'),
      );
    });

    test('empty error body falls back to default message', () async {
      final r = await build(
        (_) async => http.Response('', 500),
      ).get('x', parse: identity);
      expect(r.failureOrNull, const ServerFailure(statusCode: 500));
    });

    test('invalid JSON and parse errors map to ParsingFailure', () async {
      final bad = await build(
        (_) async => http.Response('{oops', 200),
      ).get('x', parse: identity);
      expect(bad.failureOrNull, isA<ParsingFailure>());
      final thrown = await build(
        (_) async => http.Response('{}', 200),
      ).get<int>('x', parse: (_) => throw const FormatException());
      expect(thrown.failureOrNull, isA<ParsingFailure>());
    });

    test('maps transport errors', () async {
      final net = await build(
        (_) async => throw const SocketException('x'),
      ).get('x', parse: identity);
      expect(net.failureOrNull, isA<NetworkFailure>());
      final client = await build(
        (_) async => throw http.ClientException('x'),
      ).get('x', parse: identity);
      expect(client.failureOrNull, isA<NetworkFailure>());
      final other = await build(
        (_) async => throw StateError('x'),
      ).get('x', parse: identity);
      expect(other.failureOrNull, isA<UnknownFailure>());
    });

    test('times out', () async {
      final api = build(
        (_) => Completer<http.Response>().future,
        timeout: const Duration(milliseconds: 10),
      );
      final r = await api.get('x', parse: identity);
      expect(r.failureOrNull, isA<TimeoutFailure>());
    });

    test('trims trailing slash from base url', () async {
      late Uri seen;
      final api = ApiClient(
        baseUrl: 'https://api.test/',
        client: MockClient((r) async {
          seen = r.url;
          return http.Response('1', 200);
        }),
      );
      await api.get('x', parse: identity);
      expect(seen.toString(), 'https://api.test/x');
    });

    test('creates default client and closes', () {
      ApiClient(baseUrl: 'https://a.test').close();
    });
  });

  group('decorators', () {
    test('AuthClient adds bearer token, skips when null', () async {
      final seen = <http.BaseRequest>[];
      final inner = MockClient((r) async {
        seen.add(r);
        return http.Response('{}', 200);
      });
      var token = 't1';
      final auth = AuthClient(inner, tokenProvider: () => token);
      await auth.get(Uri.parse('https://a.test'));
      expect(seen.last.headers['Authorization'], 'Bearer t1');
      final none = AuthClient(inner, tokenProvider: () => null);
      await none.get(Uri.parse('https://a.test'));
      expect(seen.last.headers.containsKey('Authorization'), isFalse);
      token = 't2';
      auth.close();
    });

    test('LoggingClient logs request and response', () async {
      final logs = <String>[];
      final client = LoggingClient(
        MockClient((_) async => http.Response('', 201)),
        log: logs.add,
      );
      await client.get(
        Uri(
          scheme: 'https',
          userInfo: 'myuser:super-secret-password',
          host: 'a.test',
          path: '/p',
          queryParameters: {
            'access_token': 'query-secret',
            'apiKey': 'key-secret',
            'keep': 'value',
          },
        ),
      );
      client.close();
      expect(logs, hasLength(2));
      expect(logs.first, contains('REDACTED@a.test/p'));
      expect(logs.first, contains('keep=value'));
      final joinedLogs = logs.join();
      expect(joinedLogs, isNot(contains('myuser')));
      expect(joinedLogs, isNot(contains('super-secret-password')));
      expect(joinedLogs, isNot(contains('query-secret')));
      expect(joinedLogs, isNot(contains('key-secret')));
    });
  });
}
