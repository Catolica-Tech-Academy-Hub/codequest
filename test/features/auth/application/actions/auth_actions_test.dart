import 'package:codequest/features/auth/application/actions/sign_in_action.dart';
import 'package:codequest/features/auth/application/actions/sign_up_action.dart';
import 'package:codequest/features/auth/domain/entities/auth_user.dart';
import 'package:codequest/features/auth/domain/entities/user_profile.dart';
import 'package:codequest/features/auth/domain/repositories/auth_repository_contract.dart';
import 'package:codequest/features/auth/domain/repositories/user_profile_repository_contract.dart';
import 'package:codequest/features/auth/domain/value_objects/display_name.dart';
import 'package:codequest/features/auth/domain/value_objects/email_address.dart';
import 'package:codequest/features/auth/domain/value_objects/password.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _AuthRepositoryMock extends Mock implements AuthRepositoryContract {}

class _UserProfileRepositoryMock extends Mock
    implements UserProfileRepositoryContract {}

void main() {
  setUpAll(() {
    registerFallbackValue(EmailAddress('fallback@test.com'));
    registerFallbackValue(Password('Fallback12'));
    registerFallbackValue(DisplayName('Fallback User'));
    registerFallbackValue(
      UserProfile(
        uid: 'fallback',
        email: 'fallback@test.com',
        name: 'Fallback',
        leagueId: 'bronze-001',
        createdAt: DateTime(2024),
      ),
    );
  });

  group('SignInAction', () {
    test('encaminha email normalizado e senha para o repositorio', () async {
      final repository = _AuthRepositoryMock();
      final action = SignInAction(repository);
      final expectedUser = const AuthUser(uid: 'u1', email: 'user@test.com');

      when(
        () => repository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => expectedUser);

      final result = await action.call(
        email: ' User@Test.Com ',
        password: 'Abcdef12',
      );

      expect(result, expectedUser);

      final call = verify(
        () => repository.signIn(
          email: captureAny(named: 'email'),
          password: captureAny(named: 'password'),
        ),
      ).captured;

      expect((call[0] as EmailAddress).value, 'user@test.com');
      expect((call[1] as Password).value, 'Abcdef12');
    });
  });

  group('SignUpAction', () {
    test('encaminha VOs validos para o repositorio', () async {
      final repository = _AuthRepositoryMock();
      final profileRepository = _UserProfileRepositoryMock();
      final action = SignUpAction(repository, profileRepository);
      final expectedUser = const AuthUser(
        uid: 'u2',
        email: 'newuser@test.com',
        displayName: 'New User',
      );

      when(
        () => profileRepository.createProfile(any()),
      ).thenAnswer((_) async {});

      when(
        () => repository.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
        ),
      ).thenAnswer((_) async => expectedUser);

      final result = await action.call(
        email: 'NewUser@Test.com',
        password: 'Abcdef12',
        name: '  New User  ',
      );

      expect(result, expectedUser);

      final call = verify(
        () => repository.signUp(
          email: captureAny(named: 'email'),
          password: captureAny(named: 'password'),
          name: captureAny(named: 'name'),
        ),
      ).captured;

      expect((call[0] as EmailAddress).value, 'newuser@test.com');
      expect((call[1] as Password).value, 'Abcdef12');
      expect((call[2] as DisplayName).value, 'New User');
    });
  });
}
