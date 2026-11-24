import 'package:atelier_mobile_crossplatform/core/notifications/auth_deep_link_inbox.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseUri', () {
    test('invitación con token', () {
      final link = AuthDeepLinkInbox.parseUri(
        Uri.parse('https://atelier.andeva.tech/auth/accept-invitation?token=abc'),
      );

      expect(link, const AcceptInvitationDeepLink('abc'));
    });

    test('sin token queda vacío y el token se recorta a 512', () {
      expect(
        AuthDeepLinkInbox.parseUri(
          Uri.parse('https://atelier.andeva.tech/auth/accept-invitation'),
        )?.token,
        '',
      );
      expect(
        AuthDeepLinkInbox.parseUri(
          Uri.parse(
            'https://atelier.andeva.tech/auth/accept-invitation?token=${'x' * 600}',
          ),
        )?.token.length,
        AuthDeepLinkInbox.maxTokenLength,
      );
    });

    test('esquema, host o ruta ajenos se ignoran', () {
      expect(
        AuthDeepLinkInbox.parseUri(
          Uri.parse('http://atelier.andeva.tech/auth/accept-invitation?token=a'),
        ),
        isNull,
      );
      expect(
        AuthDeepLinkInbox.parseUri(
          Uri.parse('https://otro.test/auth/accept-invitation?token=a'),
        ),
        isNull,
      );
      expect(
        AuthDeepLinkInbox.parseUri(
          Uri.parse('https://atelier.andeva.tech/otra/ruta?token=a'),
        ),
        isNull,
      );
      expect(AuthDeepLinkInbox.parseUri(null), isNull);
    });

    test('el restablecer contraseña (US05) no se porta', () {
      expect(
        AuthDeepLinkInbox.parseUri(
          Uri.parse('https://atelier.andeva.tech/auth/reset-password?token=a'),
        ),
        isNull,
      );
    });
  });

  test('postFromUri deja el enlace pendiente y consume lo entrega una vez', () {
    final inbox = AuthDeepLinkInbox();
    var notified = 0;
    inbox.addListener(() => notified++);

    expect(inbox.postFromUri(Uri.parse('https://x.test/y')), isFalse);
    expect(
      inbox.postFromUri(
        Uri.parse('https://atelier.andeva.tech/auth/accept-invitation?token=t'),
      ),
      isTrue,
    );
    expect(inbox.pending, const AcceptInvitationDeepLink('t'));
    expect(inbox.consume(), const AcceptInvitationDeepLink('t'));
    expect(inbox.consume(), isNull);
    expect(notified, 2);
  });
}
