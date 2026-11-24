import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reglas de los campos', () {
    expect(AuthValidation.isEmail('a@b.pe'), isTrue);
    expect(AuthValidation.isEmail('a@b'), isFalse);
    expect(AuthValidation.isPassword('1234567'), isFalse);
    expect(AuthValidation.isPassword('12345678'), isTrue);
    expect(AuthValidation.isPassword('x' * 65), isFalse);
    expect(AuthValidation.isName('   '), isFalse);
    expect(AuthValidation.isName('x' * 101), isFalse);
    expect(AuthValidation.isPhone('+51987654321'), isTrue);
    expect(AuthValidation.isPhone('12345'), isFalse);
    expect(AuthValidation.isOtp('123456'), isTrue);
    expect(AuthValidation.isOtp('12345a'), isFalse);
  });

  test('isEmail estricto', () {
    expect(AuthValidation.isEmail(' a.b@sub.dominio.pe '), isTrue);
    expect(AuthValidation.isEmail('a@@b.pe'), isFalse);
    expect(AuthValidation.isEmail('@b.pe'), isFalse);
    expect(AuthValidation.isEmail('.a@b.pe'), isFalse);
    expect(AuthValidation.isEmail('a..b@b.pe'), isFalse);
    expect(AuthValidation.isEmail('a@b..pe'), isFalse);
    expect(AuthValidation.isEmail('a@.b.pe'), isFalse);
    expect(AuthValidation.isEmail('a@-b.pe'), isFalse);
    expect(AuthValidation.isEmail('a@b.p'), isFalse);
    expect(AuthValidation.isEmail('a@b.p-e'), isFalse);
  });

  group('tokenFrom', () {
    test('un token pegado queda igual, sin espacios', () {
      expect(AuthValidation.tokenFrom('  abc123 '), 'abc123');
    });

    test('de un enlace toma el token', () {
      expect(
        AuthValidation.tokenFrom(
          'https://atelier.andeva.tech/auth/accept-invitation?a=1&token=abc#x',
        ),
        'abc',
      );
    });

    test('decodifica el token', () {
      expect(AuthValidation.tokenFrom('https://x/y?token=a%2Fb+c'), 'a/b c');
    });

    test('un % malformado no lanza', () {
      expect(AuthValidation.tokenFrom('https://x/y?token=a%zz'), 'a%zz');
    });

    test('un enlace sin token o con token vacío da cadena vacía', () {
      expect(AuthValidation.tokenFrom('https://x/y?a=1'), '');
      expect(AuthValidation.tokenFrom('https://x/y?token='), '');
    });

    test('un texto con ? que no es URL queda igual', () {
      expect(AuthValidation.tokenFrom('abc?def'), 'abc?def');
    });

    test('vacío da cadena vacía y el token se recorta a 512', () {
      expect(AuthValidation.tokenFrom('   '), '');
      expect(AuthValidation.tokenFrom('x' * 600).length, 512);
      expect(AuthValidation.tokenFrom('https://x/y?token=${'y' * 600}').length, 512);
    });
  });
}
