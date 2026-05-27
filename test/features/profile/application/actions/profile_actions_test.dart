import 'package:codequest/features/auth/domain/errors/auth_failure.dart';
import 'package:codequest/features/auth/domain/repositories/auth_repository_contract.dart';
import 'package:codequest/features/auth/domain/repositories/user_profile_repository_contract.dart';
import 'package:codequest/features/auth/domain/value_objects/display_name.dart';
import 'package:codequest/features/auth/domain/value_objects/email_address.dart';
import 'package:codequest/features/auth/domain/value_objects/password.dart';
import 'package:codequest/features/profile/application/actions/delete_account_action.dart';
import 'package:codequest/features/profile/application/actions/update_notifications_action.dart';
import 'package:codequest/features/profile/application/actions/update_password_action.dart';
import 'package:codequest/features/profile/application/actions/update_profile_action.dart';
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
  });

  group('UpdateProfileAction', () {
    test('atualiza nome e bio no repositorio e displayName no auth', () async {
      final authRepository = _AuthRepositoryMock();
      final profileRepository = _UserProfileRepositoryMock();
      final action = UpdateProfileAction(authRepository, profileRepository);

      when(
        () => profileRepository.updateProfile(
          uid: any(named: 'uid'),
          name: any(named: 'name'),
          bio: any(named: 'bio'),
        ),
      ).thenAnswer((_) async {});

      when(
        () => authRepository.updateDisplayName(
          displayName: any(named: 'displayName'),
        ),
      ).thenAnswer((_) async {});

      await action.call(uid: 'u1', name: '  João Silva  ', bio: 'Ola mundo!');

      final profileCall = verify(
        () => profileRepository.updateProfile(
          uid: captureAny(named: 'uid'),
          name: captureAny(named: 'name'),
          bio: captureAny(named: 'bio'),
        ),
      ).captured;
      expect(profileCall[1], 'João Silva');
      expect(profileCall[2], 'Ola mundo!');
    });

    test('lanca erro quando bio ultrapassa 160 caracteres', () async {
      final authRepository = _AuthRepositoryMock();
      final profileRepository = _UserProfileRepositoryMock();
      final action = UpdateProfileAction(authRepository, profileRepository);

      expect(
        () => action.call(
          uid: 'u1',
          name: 'João',
          bio: 'a' * 161,
        ),
        throwsA(
          isA<AuthFailure>()
              .having((e) => e.code, 'code', 'invalid-bio'),
        ),
      );
    });

    test('converte bio vazia para null', () async {
      final authRepository = _AuthRepositoryMock();
      final profileRepository = _UserProfileRepositoryMock();
      final action = UpdateProfileAction(authRepository, profileRepository);

      when(
        () => profileRepository.updateProfile(
          uid: any(named: 'uid'),
          name: any(named: 'name'),
          bio: any(named: 'bio'),
        ),
      ).thenAnswer((_) async {});

      when(
        () => authRepository.updateDisplayName(
          displayName: any(named: 'displayName'),
        ),
      ).thenAnswer((_) async {});

      await action.call(uid: 'u1', name: 'João', bio: '   ');

      final call = verify(
        () => profileRepository.updateProfile(
          uid: captureAny(named: 'uid'),
          name: captureAny(named: 'name'),
          bio: captureAny(named: 'bio'),
        ),
      ).captured;
      expect(call[2], isNull);
    });
  });

  group('UpdatePasswordAction', () {
    test('reautentica e atualiza senha quando senhas coincidem', () async {
      final authRepository = _AuthRepositoryMock();
      final action = UpdatePasswordAction(authRepository);

      when(
        () => authRepository.reauthenticate(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {});

      when(
        () => authRepository.updatePassword(newPassword: any(named: 'newPassword')),
      ).thenAnswer((_) async {});

      await action.call(
        email: 'user@test.com',
        currentPassword: 'OldPass12',
        newPassword: 'NewPass34',
        confirmPassword: 'NewPass34',
      );

      verify(
        () => authRepository.reauthenticate(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).called(1);
      verify(
        () => authRepository.updatePassword(
          newPassword: any(named: 'newPassword'),
        ),
      ).called(1);
    });

    test('lanca passwordMismatch quando senhas nao coincidem', () async {
      final authRepository = _AuthRepositoryMock();
      final action = UpdatePasswordAction(authRepository);

      expect(
        () => action.call(
          email: 'user@test.com',
          currentPassword: 'OldPass12',
          newPassword: 'NewPass34',
          confirmPassword: 'DifferentPass56',
        ),
        throwsA(
          isA<AuthFailure>()
              .having((e) => e.code, 'code', 'password-mismatch'),
        ),
      );

      verifyNever(
        () => authRepository.reauthenticate(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });
  });

  group('DeleteAccountAction', () {
    test('deleta perfil no Firestore e usuario no Auth, nessa ordem', () async {
      final authRepository = _AuthRepositoryMock();
      final profileRepository = _UserProfileRepositoryMock();
      final action = DeleteAccountAction(authRepository, profileRepository);

      when(
        () => profileRepository.deleteProfile(any()),
      ).thenAnswer((_) async {});

      when(() => authRepository.deleteCurrentUser()).thenAnswer((_) async {});

      await action.call(uid: 'u1');

      verifyInOrder([
        () => profileRepository.deleteProfile('u1'),
        () => authRepository.deleteCurrentUser(),
      ]);
    });

    test('propaga erro se deleteCurrentUser falhar', () async {
      final authRepository = _AuthRepositoryMock();
      final profileRepository = _UserProfileRepositoryMock();
      final action = DeleteAccountAction(authRepository, profileRepository);

      when(
        () => profileRepository.deleteProfile(any()),
      ).thenAnswer((_) async {});

      when(
        () => authRepository.deleteCurrentUser(),
      ).thenThrow(AuthFailure.requiresRecentLogin());

      await expectLater(
        () => action.call(uid: 'u1'),
        throwsA(isA<AuthFailure>()),
      );
    });
  });

  group('UpdateNotificationsAction', () {
    test('delega ao repositorio com os parametros corretos', () async {
      final profileRepository = _UserProfileRepositoryMock();
      final action = UpdateNotificationsAction(profileRepository);

      when(
        () => profileRepository.updateNotificationPreferences(
          uid: any(named: 'uid'),
          enabled: any(named: 'enabled'),
        ),
      ).thenAnswer((_) async {});

      await action.call(uid: 'u1', enabled: false);

      verify(
        () => profileRepository.updateNotificationPreferences(
          uid: 'u1',
          enabled: false,
        ),
      ).called(1);
    });
  });
}
