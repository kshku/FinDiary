import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:findiary/core/network/connectivity_notifier.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockConnectivity mockConnectivity;
  late ConnectivityNotifier notifier;

  setUp(() {
    mockConnectivity = MockConnectivity();
    notifier = ConnectivityNotifier(connectivity: mockConnectivity);
  });

  group('ConnectivityNotifier', () {
    test('initialize sets isOnline to true when wifi is available', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => const Stream<bool>.empty());

      await notifier.initialize();

      expect(notifier.isOnline, isTrue);
    });

    test('initialize sets isOnline to false when no connectivity', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => const Stream<bool>.empty());

      await notifier.initialize();

      expect(notifier.isOnline, isFalse);
    });

    test('onConnectivityChanged emits when state changes', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => Stream.value([ConnectivityResult.wifi]));

      final states = <bool>[];
      notifier.onConnectivityChanged.listen(states.add);

      await notifier.initialize();

      expect(notifier.isOnline, isTrue);
      expect(states, [true]);
    });

    test('isOnline defaults to false', () {
      expect(notifier.isOnline, isFalse);
    });
  });
}
