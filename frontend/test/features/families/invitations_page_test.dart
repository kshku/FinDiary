import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:findiary/features/families/invitations_page.dart';
import 'package:findiary/features/families/bloc/family_bloc.dart';
import 'package:findiary/features/families/bloc/family_event.dart';
import 'package:findiary/features/families/bloc/family_state.dart';

class FamilyBlocMock extends MockBloc<FamilyEvent, FamilyState> implements FamilyBloc {}

void main() {
  late FamilyBlocMock bloc;

  setUp(() {
    bloc = FamilyBlocMock();
  });

  testWidgets('InvitationsPage shows empty state', (tester) async {
    when(() => bloc.state).thenReturn(const FamilyLoaded(families: []));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<FamilyBloc>.value(
          value: bloc,
          child: const InvitationsPage(),
        ),
      ),
    );

    expect(find.text('No pending invitations'), findsOneWidget);
  });
}
