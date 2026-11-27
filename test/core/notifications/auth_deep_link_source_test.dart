import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/auth_deep_link_inbox.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/auth_deep_link_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAppLinks extends Mock implements AppLinks {}

void main() {
  late _MockAppLinks links;
  late StreamController<Uri> stream;
  late AuthDeepLinkInbox inbox;
  late AuthDeepLinkSource source;

  setUp(() {
    links = _MockAppLinks();
    stream = StreamController<Uri>.broadcast();
    inbox = AuthDeepLinkInbox();
    when(() => links.uriLinkStream).thenAnswer((_) => stream.stream);
    source = AuthDeepLinkSource(inbox: inbox, links: links);
  });

  tearDown(() async {
    await source.stop();
    await stream.close();
  });

  final reset = Uri.parse('https://atelier.andeva.tech/auth/reset-password?token=abc');

  test('publica el enlace con el que se abrió la app', () async {
    when(() => links.getInitialLink()).thenAnswer((_) async => reset);
    await source.start();
    expect(inbox.pending, const ResetPasswordDeepLink('abc'));
  });

  test('no repite el enlace inicial si el flujo lo vuelve a emitir', () async {
    when(() => links.getInitialLink()).thenAnswer((_) async => reset);
    await source.start();
    inbox.consume();
    stream.add(reset);
    await Future<void>.delayed(Duration.zero);
    expect(inbox.pending, isNull);
  });

  test('publica los enlaces que llegan después e ignora los ajenos', () async {
    when(() => links.getInitialLink()).thenAnswer((_) async => null);
    await source.start();
    stream.add(Uri.parse('https://otro.dev/auth/reset-password?token=x'));
    await Future<void>.delayed(Duration.zero);
    expect(inbox.pending, isNull);
    stream.add(Uri.parse('https://atelier.andeva.tech/auth/accept-invitation?token=inv'));
    await Future<void>.delayed(Duration.zero);
    expect(inbox.pending, const AcceptInvitationDeepLink('inv'));
  });
}
