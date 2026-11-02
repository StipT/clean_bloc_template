import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('Success exposes value and maps', () {
      const Result<int> r = Success(2);
      expect(r.isSuccess, isTrue);
      expect(r.valueOrNull, 2);
      expect(r.failureOrNull, isNull);
      expect(r.map((v) => v * 2), const Success(4));
    });

    test('Err exposes failure and keeps it on map', () {
      const Result<int> r = Err(NetworkFailure());
      expect(r.isSuccess, isFalse);
      expect(r.valueOrNull, isNull);
      expect(r.failureOrNull, const NetworkFailure());
      expect(r.map((v) => v * 2), const Err<int>(NetworkFailure()));
    });

    test('when dispatches on the variant', () {
      const Result<int> ok = Success(1);
      const Result<int> bad = Err(UnknownFailure());
      expect(ok.when(success: (v) => 's$v', failure: (f) => 'f'), 's1');
      expect(bad.when(success: (v) => 's', failure: (f) => 'f'), 'f');
    });
  });

  group('Failure', () {
    test('has value equality and message', () {
      expect(
        const ServerFailure(statusCode: 500, message: 'x'),
        const ServerFailure(statusCode: 500, message: 'x'),
      );
      expect(const ServerFailure(statusCode: 500, message: 'x').message, 'x');
      final msg = List.filled(1, 'a').first;
      expect(NetworkFailure(msg), NetworkFailure(msg));
      expect(NetworkFailure(msg).props, [msg]);
      expect(const ServerFailure(statusCode: 1).props, ['Server error', 1]);
      expect(const TimeoutFailure(), isNot(const NetworkFailure()));
      for (final f in const <Failure>[
        NetworkFailure(),
        TimeoutFailure(),
        UnauthorizedFailure(),
        ParsingFailure(),
        UnknownFailure(),
      ]) {
        expect(f.message, isNotEmpty);
      }
    });
  });
}
