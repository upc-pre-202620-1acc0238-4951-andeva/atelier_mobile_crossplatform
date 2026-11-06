import 'dart:io';
import 'dart:math' show max, min;

import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/core/media/storage_paths.dart';
import 'package:atelier_mobile_crossplatform/core/media/supabase_uploader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

SupabaseUploader uploaderWith(
  http.Client client, {
  String baseUrl = 'https://p.supabase.co/',
  String anonKey = 'anon',
}) {
  return SupabaseUploader(
    client: client,
    baseUrl: baseUrl,
    anonKey: anonKey,
    bucket: 'atelier',
    notConfiguredMessage: 'sin configurar',
    uploadFailedMessage: 'no subió',
  );
}

void main() {
  group('compressionMinSide', () {
    /// La fórmula del plugin, medida sobre el archivo original.
    List<int> resultOf(int width, int height, int minSide) {
      final scale = max(1, min(width / minSide, height / minSide));
      return [(width / scale).round(), (height / scale).round()];
    }

    test('el lado mayor queda en 1600, también en vertical y panorámica', () {
      expect(resultOf(4000, 3000, compressionMinSide(4000, 3000)), [1600, 1200]);
      expect(resultOf(3000, 4000, compressionMinSide(3000, 4000)), [1200, 1600]);
      expect(resultOf(8000, 1000, compressionMinSide(8000, 1000)), [1600, 200]);
    });

    test('sirve aunque el plugin mida la foto ya rotada', () {
      final minSide = compressionMinSide(4000, 3000);
      expect(resultOf(3000, 4000, minSide), [1200, 1600]);
    });

    test('una foto pequeña no se agranda', () {
      expect(resultOf(800, 600, compressionMinSide(800, 600)), [800, 600]);
    });
  });

  test('las rutas siguen la tabla de 04 §3', () {
    expect(StoragePaths.intake('t', 'w', 'p'), 't/work-orders/w/intake/p.jpg');
    expect(
      StoragePaths.taskEvidence('t', 'w', 'k', 'p'),
      't/work-orders/w/tasks/k/p.jpg',
    );
    expect(
      StoragePaths.proposal('t', 'w', 'p'),
      't/work-orders/w/proposals/p.jpg',
    );
    expect(
      StoragePaths.purchaseReceipt('t', 'o', 'p'),
      't/purchase-orders/o/receipt/p.jpg',
    );
  });

  group('upload', () {
    late Directory directory;
    late File file;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('upload_test');
      file = File('${directory.path}/foto.jpg')..writeAsBytesSync([1, 2, 3]);
    });
    tearDown(() => directory.delete(recursive: true));

    test('envía la anon key, x-upsert y los bytes, sin el JWT', () async {
      late http.Request sent;
      final uploader = uploaderWith(
        MockClient((request) async {
          sent = request;
          return http.Response('{}', 200);
        }),
      );

      await uploader.upload(file, 't/a.jpg');

      expect(
        sent.url.toString(),
        'https://p.supabase.co/storage/v1/object/atelier/t/a.jpg',
      );
      expect(sent.headers['Authorization'], 'Bearer anon');
      expect(sent.headers['apikey'], 'anon');
      expect(sent.headers['x-upsert'], 'true');
      expect(sent.bodyBytes, [1, 2, 3]);
      expect(
        uploader.publicUrlFor('t/a.jpg'),
        'https://p.supabase.co/storage/v1/object/public/atelier/t/a.jpg',
      );
    });

    test('sin configuración no sale a la red', () async {
      final uploader = uploaderWith(
        MockClient((_) async => fail('no debe llamar')),
        anonKey: '',
      );

      await expectLater(
        uploader.upload(file, 't/a.jpg'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            'SUPABASE_NOT_CONFIGURED',
          ),
        ),
      );
    });

    test('un rechazo y la falta de red se clasifican', () async {
      await expectLater(
        uploaderWith(
          MockClient((_) async => http.Response('{}', 500)),
        ).upload(file, 't/a.jpg'),
        throwsA(
          isA<ApiException>().having((e) => e.httpStatus, 'status', 500),
        ),
      );
      await expectLater(
        uploaderWith(
          MockClient((_) async => throw const SocketException('sin red')),
        ).upload(file, 't/a.jpg'),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
