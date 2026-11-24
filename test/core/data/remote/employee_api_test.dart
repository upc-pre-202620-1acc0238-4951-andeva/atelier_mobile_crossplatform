import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/employee/employee_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('getMemberships lee MembershipResource de GET /api/v1/memberships', () async {
    late Uri requested;
    final api = EmployeeApi(
      client: ApiClient(
        client: MockClient((request) async {
          requested = request.url;
          return http.Response(
            '[{"id":"m1","employeeName":"Ana Pérez","email":"ana@taller.pe","status":"ACTIVE","roles":[]},'
            '{"id":"m2"}]',
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
        baseUrl: 'https://api.test',
      ),
    );

    final memberships = await api.getMemberships();

    expect(requested.path, '/api/v1/memberships');
    expect(memberships.map((m) => m.id), ['m1', 'm2']);
    expect(memberships.first.employeeName, 'Ana Pérez');
    expect(memberships.first.status, 'ACTIVE');
    expect(memberships.last.employeeName, isNull);
  });
}
