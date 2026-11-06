import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('domain no importa Flutter, http, Drift, get_it ni plugins', () {
    final imports = RegExp(
      r'''^\s*(import|export)\s+['"]([^'"]+)['"]''',
      multiLine: true,
    );
    final files = Directory('lib/features/tasks/domain')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    expect(files, isNotEmpty);

    for (final file in files) {
      for (final match in imports.allMatches(file.readAsStringSync())) {
        final uri = match.group(2)!;
        final allowed = uri.startsWith('dart:') ||
            uri.startsWith(
              'package:atelier_mobile_crossplatform/features/tasks/domain/',
            ) ||
            uri.startsWith('package:atelier_mobile_crossplatform/core/domain/') ||
            uri == 'package:decimal/decimal.dart' ||
            !uri.startsWith('package:');
        expect(allowed, isTrue, reason: '${file.path} importa $uri');
      }
    }
  });
}
