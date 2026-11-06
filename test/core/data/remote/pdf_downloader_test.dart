import 'dart:io';
import 'dart:typed_data';

import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/pdf_downloader.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late PdfDownloader downloader;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('pdf_test');
    downloader = PdfDownloader(cacheDirectory: () async => directory);
  });
  tearDown(() => directory.delete(recursive: true));

  test('guarda el pdf en pdfs/ con el nombre de Content-Disposition', () async {
    final bytes = Uint8List.fromList([0x25, 0x50, 0x44, 0x46]);

    final file = await downloader.download(
      'proforma',
      () async => ApiFile(
        bytes: bytes,
        contentDisposition: 'attachment; filename="proforma-OT-15.pdf"',
      ),
    );

    expect(file.path, '${directory.path}/pdfs/proforma-OT-15.pdf');
    expect(await file.readAsBytes(), bytes);
  });

  test('un error del backend llega con su message y no deja archivo', () async {
    await expectLater(
      downloader.download(
        'pase',
        () async => throw const ApiException(
          httpStatus: 422,
          code: 'UNPROCESSABLE_ENTITY',
          message: 'La orden no está pagada',
        ),
      ),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          'La orden no está pagada',
        ),
      ),
    );
    expect(await directory.list().isEmpty, isTrue);
  });

  test('el nombre del archivo es seguro y siempre termina en pdf', () {
    expect(
      PdfDownloader.fileName(
        "attachment; filename*=UTF-8''informe%20salud.pdf",
        'x',
      ),
      'informe_salud.pdf',
    );
    expect(
      PdfDownloader.fileName('attachment; filename="../../evil.pdf"', 'x'),
      'evil.pdf',
    );
    expect(PdfDownloader.fileName(null, 'proforma-wo1'), 'proforma-wo1.pdf');
    expect(
      PdfDownloader.fileName(
        'attachment; filename="plano.pdf"; filename*=UTF-8\'\'extendido.pdf',
        'x',
      ),
      'extendido.pdf',
    );
    expect(
      PdfDownloader.fileName("attachment; filename*=UTF-8''mal%ZZ.pdf", 'x'),
      'x.pdf',
    );
    expect(
      PdfDownloader.fileName("attachment; filename*=UTF-8''mal%FF.pdf", 'x'),
      'x.pdf',
    );
  });
}
