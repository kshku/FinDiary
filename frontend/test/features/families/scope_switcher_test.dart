import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:findiary/features/families/bloc/scope_cubit.dart';
import 'package:findiary/features/families/bloc/family_bloc.dart';
import 'package:findiary/features/families/bloc/family_event.dart';
import 'package:findiary/features/families/bloc/family_state.dart';
import 'package:findiary/features/families/widgets/scope_switcher.dart';
import 'package:findiary/core/database/database.dart';

class MockFamilyBloc extends MockBloc<FamilyEvent, FamilyState> implements FamilyBloc {}

void main() {
  late ScopeCubit scopeCubit;
  late MockFamilyBloc mockFamilyBloc;

  setUp(() {
    scopeCubit = ScopeCubit();
    mockFamilyBloc = MockFamilyBloc();
  });

  tearDown(() => scopeCubit.close());

  testWidgets('ScopeSwitcher shows personal by default', (tester) async {
    when(() => mockFamilyBloc.state).thenReturn(const FamilyLoaded(families: []));

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<ScopeCubit>.value(value: scopeCubit),
            BlocProvider<FamilyBloc>.value(value: mockFamilyBloc),
          ],
          child: const Scaffold(body: ScopeSwitcher()),
        ),
      ),
    );

    expect(find.text('Personal'), findsOneWidget);
  });

  testWidgets('ScopeSwitcher shows family names in popup', (tester) async {
    when(() => mockFamilyBloc.state).thenReturn(FamilyLoaded(families: [
      Family(id: 'f1', name: 'Test Fam', ownerId: 'u1', createdAt: '', updatedAt: '', syncStatus: 0),
    ]));

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<ScopeCubit>.value(value: scopeCubit),
            BlocProvider<FamilyBloc>.value(value: mockFamilyBloc),
          ],
          child: const Scaffold(body: ScopeSwitcher()),
        ),
      ),
    );

    await tester.tap(find.text('Personal'));
    await tester.pumpAndSettle();

    expect(find.text('Test Fam'), findsOneWidget);
  });
}
