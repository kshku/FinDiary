import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:findiary/core/database/database.dart';
import 'package:findiary/core/database/daos/family_dao.dart';
import 'package:findiary/core/grpc/family_service.dart';
import 'package:findiary/features/families/bloc/family_bloc.dart';
import 'package:findiary/features/families/bloc/family_event.dart';
import 'package:findiary/features/families/bloc/family_state.dart';

class MockFamilyDao extends Mock implements FamilyDao {}
class MockFamilyGrpcService extends Mock implements FamilyGrpcService {}

void main() {
  late FamilyBloc bloc;
  late MockFamilyDao mockDao;
  late MockFamilyGrpcService mockGrpc;

  setUp(() {
    mockDao = MockFamilyDao();
    mockGrpc = MockFamilyGrpcService();
    bloc = FamilyBloc(familyDao: mockDao, familyGrpcService: mockGrpc);
  });

  tearDown(() => bloc.close());

  group('FamilyBloc', () {
    test('initial state is FamilyInitial', () {
      expect(bloc.state, const FamilyInitial());
    });

    blocTest<FamilyBloc, FamilyState>(
      'emits [Loading, Loaded] on FamilyListRequested',
      build: () {
        when(() => mockDao.listFamilies()).thenAnswer((_) async => []);
        return bloc;
      },
      act: (b) => b.add(const FamilyListRequested()),
      expect: () => [
        const FamilyLoading(),
        const FamilyLoaded(families: []),
      ],
    );

    blocTest<FamilyBloc, FamilyState>(
      'emits [Loading, Loaded] on FamilyDetailRequested with family and members',
      build: () {
        when(() => mockDao.getFamily('fam-1')).thenAnswer(
          (_) async => Family(id: 'fam-1', name: 'Test', ownerId: 'u1', createdAt: '', updatedAt: '', syncStatus: 0),
        );
        when(() => mockDao.listMembers('fam-1')).thenAnswer((_) async => []);
        return bloc;
      },
      act: (b) => b.add(const FamilyDetailRequested('fam-1')),
      expect: () => [
        const FamilyLoading(),
        isA<FamilyDetailLoaded>(),
      ],
    );

    blocTest<FamilyBloc, FamilyState>(
      'emits [Loading, Loaded] on InvitationsRequested',
      build: () {
        when(() => mockDao.listFamilies()).thenAnswer((_) async => []);
        return bloc;
      },
      act: (b) => b.add(const InvitationsRequested()),
      expect: () => [
        const FamilyLoading(),
        const FamilyLoaded(families: []),
      ],
    );
  });
}
