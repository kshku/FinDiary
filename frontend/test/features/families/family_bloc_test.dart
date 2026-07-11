import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:drift/drift.dart';

import 'package:findiary/core/database/daos/family_dao.dart';
import 'package:findiary/core/grpc/family_service.dart';
import 'package:findiary/features/families/bloc/family_bloc.dart';
import 'package:findiary/features/families/bloc/family_event.dart';
import 'package:findiary/features/families/bloc/family_state.dart';
import 'package:findiary/core/database/database.dart';

class MockFamilyDao extends Mock implements FamilyDao {}
class MockFamilyGrpcService extends Mock implements FamilyGrpcService {}

void main() {
  late MockFamilyDao mockFamilyDao;
  late MockFamilyGrpcService mockFamilyGrpcService;

  setUp(() {
    mockFamilyDao = MockFamilyDao();
    mockFamilyGrpcService = MockFamilyGrpcService();
    registerFallbackValue(const FamiliesCompanion(
      id: Value(''),
      name: Value(''),
      ownerId: Value(''),
      createdAt: Value(''),
      updatedAt: Value(''),
    ));
  });

  group('FamilyBloc', () {
    blocTest<FamilyBloc, FamilyState>(
      'emits loading then loaded with families',
      setUp: () {
        when(() => mockFamilyDao.listFamilies())
            .thenAnswer((_) async => []);
      },
      build: () => FamilyBloc(
        familyDao: mockFamilyDao,
        familyGrpcService: mockFamilyGrpcService,
      ),
      act: (bloc) => bloc.add(const FamiliesRequested()),
      expect: () => [
        const FamilyLoading(),
        const FamilyLoaded(families: []),
      ],
    );

    blocTest<FamilyBloc, FamilyState>(
      'handles dao error gracefully',
      setUp: () {
        when(() => mockFamilyDao.listFamilies())
            .thenThrow(Exception('db error'));
      },
      build: () => FamilyBloc(
        familyDao: mockFamilyDao,
        familyGrpcService: mockFamilyGrpcService,
      ),
      act: (bloc) => bloc.add(const FamiliesRequested()),
      expect: () => [
        const FamilyLoading(),
        const FamilyFailure('Exception: db error'),
      ],
    );
  });
}
