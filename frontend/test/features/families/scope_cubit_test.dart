import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:findiary/features/families/bloc/scope_cubit.dart';

void main() {
  group('ScopeCubit', () {
    test('initial state is personal scope', () {
      final cubit = ScopeCubit();
      expect(cubit.state, const Scope(scopeId: 'personal', scopeType: 'personal', label: 'Personal'));
      cubit.close();
    });

    blocTest<ScopeCubit, Scope>(
      'emits family scope when switchToFamily is called',
      build: () => ScopeCubit(),
      act: (c) => c.switchToFamily('fam-1', 'My Family'),
      expect: () => [const Scope(scopeId: 'fam-1', scopeType: 'family', label: 'My Family')],
    );

    blocTest<ScopeCubit, Scope>(
      'emits personal scope when switchToPersonal is called',
      build: () => ScopeCubit(),
      seed: () => const Scope(scopeId: 'fam-1', scopeType: 'family', label: 'My Family'),
      act: (c) => c.switchToPersonal(),
      expect: () => [const Scope(scopeId: 'personal', scopeType: 'personal', label: 'Personal')],
    );
  });
}
