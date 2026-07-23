import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:findiary/features/families/families_page.dart';
import 'package:findiary/features/families/bloc/family_bloc.dart';
import 'package:findiary/features/families/bloc/family_event.dart';
import 'package:findiary/features/families/bloc/family_state.dart';
import 'package:findiary/core/database/database.dart';

class FamilyBlocMock extends MockBloc<FamilyEvent, FamilyState>
    implements FamilyBloc {}

void main() {
  late FamilyBlocMock bloc;

  setUp(() {
    bloc = FamilyBlocMock();
  });

  testWidgets('FamiliesPage shows empty state', (tester) async {
    when(() => bloc.state).thenReturn(const FamilyLoaded(families: []));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<FamilyBloc>.value(
          value: bloc,
          child: const FamiliesPage(),
        ),
      ),
    );

    expect(find.text('No families yet'), findsOneWidget);
  });

  testWidgets('FamiliesPage shows family list', (tester) async {
    when(() => bloc.state).thenReturn(FamilyLoaded(families: [
      Family(
        id: '1',
        name: 'Test Family',
        ownerId: 'u1',
        createdAt: '',
        updatedAt: '',
        syncStatus: 0,
      ),
    ]));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<FamilyBloc>.value(
          value: bloc,
          child: const FamiliesPage(),
        ),
      ),
    );

    expect(find.text('Test Family'), findsOneWidget);
  });
}
