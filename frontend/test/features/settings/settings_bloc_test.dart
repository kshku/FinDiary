import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:findiary/core/auth/auth_service.dart';
import 'package:findiary/core/theme/app_theme.dart';
import 'package:findiary/core/theme/themes/clean_modern.dart';
import 'package:findiary/core/theme/themes/dark_finance.dart';
import 'package:findiary/features/settings/bloc/settings_bloc.dart';
import 'package:findiary/features/settings/bloc/settings_event.dart';
import 'package:findiary/features/settings/bloc/settings_state.dart';

class MockAuthService extends Mock implements AuthService {}
class MockThemeCubit extends Mock implements ThemeCubit {}

void main() {
  late MockAuthService mockAuthService;
  late MockThemeCubit mockThemeCubit;
  late SharedPreferences prefs;

  setUp(() async {
    mockAuthService = MockAuthService();
    mockThemeCubit = MockThemeCubit();
    SharedPreferences.setMockInitialValues({'app_theme': 'clean_modern'});
    prefs = await SharedPreferences.getInstance();
  });

  group('SettingsBloc', () {
    blocTest<SettingsBloc, SettingsState>(
      'loads current theme from preferences',
      setUp: () {
        when(() => mockThemeCubit.state)
            .thenReturn(cleanModernTheme());
      },
      build: () => SettingsBloc(
        authService: mockAuthService,
        themeCubit: mockThemeCubit,
        prefs: prefs,
      ),
      act: (bloc) => bloc.add(const SettingsRequested()),
      expect: () => [
        const SettingsLoaded(currentTheme: AppTheme.cleanModern),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'changes theme on ThemeChanged',
      setUp: () {
        when(() => mockThemeCubit.state)
            .thenReturn(darkFinanceTheme());
      },
      build: () => SettingsBloc(
        authService: mockAuthService,
        themeCubit: mockThemeCubit,
        prefs: prefs,
      ),
      act: (bloc) => bloc.add(const ThemeChanged(AppTheme.darkFinance)),
      expect: () => [
        const SettingsLoaded(currentTheme: AppTheme.darkFinance),
      ],
      verify: (_) {
        verify(() => mockThemeCubit.setTheme(AppTheme.darkFinance)).called(1);
      },
    );
  });
}
