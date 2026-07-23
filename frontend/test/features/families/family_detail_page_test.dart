import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:findiary/core/database/database.dart';
import 'package:findiary/features/families/family_detail_page.dart';
import 'package:findiary/features/families/bloc/family_bloc.dart';
import 'package:findiary/features/families/bloc/family_event.dart';
import 'package:findiary/features/families/bloc/family_state.dart';

class FamilyBlocMock extends MockBloc<FamilyEvent, FamilyState>
    implements FamilyBloc {}

void main() {
  late FamilyBlocMock bloc;

  setUp(() {
    bloc = FamilyBlocMock();
  });

  testWidgets('FamilyDetailPage shows family info', (tester) async {
    when(() => bloc.state).thenReturn(FamilyDetailLoaded(
      family: Family(id: '1', name: 'Test Fam', ownerId: 'u1', createdAt: '2026-07-18', updatedAt: '', syncStatus: 0),
      members: [],
    ));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<FamilyBloc>.value(
          value: bloc,
          child: const FamilyDetailPage(familyId: '1'),
        ),
      ),
    );

    expect(find.text('Test Fam'), findsOneWidget);
  });
}
