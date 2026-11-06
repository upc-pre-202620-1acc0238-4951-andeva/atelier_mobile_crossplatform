import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/device_token_registrar.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/notification_channels.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/push_inbox.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/push_router.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Recepción de push (docs/04-mobile-integration.md §2). No se registra `onBackgroundMessage`: en
/// segundo plano el sistema ya muestra la notificación y ese motor no tendría nada que hacer.
class PushMessagingService {
  final PushInbox inbox;
  final DeviceTokenRegistrar registrar;
  final SessionManager session;
  final FlutterLocalNotificationsPlugin notifications;
  final AppLocalizations strings;

  PushMessagingService({
    required this.inbox,
    required this.registrar,
    required this.session,
    required this.notifications,
    required this.strings,
  });

  /// Sin `google-services.json` solo quedan las notificaciones locales, y la app no falla.
  Future<void> start() async {
    await notifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // El permiso se pide tras el login, con explicación previa (paso 2).
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        _openPayload(response.payload);
      },
    );
    await NotificationChannels.create(notifications, strings);

    // App cerrada y se toca una notificación que se dibujó aquí.
    final launch = await notifications.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      _openPayload(launch?.notificationResponse?.payload);
    }

    if (Firebase.apps.isEmpty) return;

    FirebaseMessaging.onMessage.listen((message) => unawaited(_show(message)));
    FirebaseMessaging.onMessageOpenedApp.listen(_open);
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _open(initial);

    // `onRegistered` entrega un FID y el backend espera un token de registro (04 §2).
    // ignore: deprecated_member_use
    FirebaseMessaging.instance.onTokenRefresh.listen(
      (token) => unawaited(_registerRefreshed(token)),
    );
  }

  /// App abierta: el sistema no muestra nada.
  Future<void> _show(RemoteMessage message) async {
    final destination = PushRouter.route(message.data);
    if (destination == null) return;
    final channel = NotificationChannels.channelFor(
      PushRouter.channelFor(destination),
      strings,
    );
    await notifications.show(
      id: destination.hashCode & 0x7fffffff,
      title: message.notification?.title,
      body: message.notification?.body,
      payload: jsonEncode(message.data),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          importance: channel.importance,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  void _open(RemoteMessage message) {
    final destination = PushRouter.route(message.data);
    if (destination != null) inbox.post(destination);
  }

  void _openPayload(String? payload) {
    if (payload == null) return;
    final data = jsonDecode(payload);
    if (data is! Map<String, dynamic>) return;
    final destination = PushRouter.route(data);
    if (destination != null) inbox.post(destination);
  }

  Future<void> _registerRefreshed(String token) async {
    if (await session.getSession() == null) return;
    try {
      await registrar.register(token);
    } on ApiException catch (e) {
      log('No se registró el token: $e', name: 'PushMessagingService');
    } on NetworkException catch (e) {
      log('No se registró el token: $e', name: 'PushMessagingService');
    }
  }
}
