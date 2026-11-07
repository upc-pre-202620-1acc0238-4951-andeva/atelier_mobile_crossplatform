import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/affiliate_customer_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/affiliation_lookup_dto.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/create_company_customer_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/create_individual_customer_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/customer_dto.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/vehicle_dto.dart';

/// Clientes y afiliación de docs/api/crm.md.
class CustomerApi {
  final ApiClient client;

  const CustomerApi({required this.client});

  Future<List<CustomerDto>> search(String? search) async {
    final List list = await client.get(
      '/api/v1/customers',
      query: search == null ? null : {'search': search},
    );
    return list
        .map((e) => CustomerDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CustomerDto> getCustomer(String id) async {
    final Map<String, dynamic> json = await client.get('/api/v1/customers/$id');
    return CustomerDto.fromJson(json);
  }

  Future<List<VehicleDto>> getVehicles(String id) async {
    final List list = await client.get('/api/v1/customers/$id/vehicles');
    return list
        .map((e) => VehicleDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CustomerDto> createIndividual(
    CreateIndividualCustomerRequestDto body,
  ) async {
    final Map<String, dynamic> json = await client.post(
      '/api/v1/customers/individuals',
      body: body.toJson(),
    );
    return CustomerDto.fromJson(json);
  }

  Future<CustomerDto> createCompany(
    CreateCompanyCustomerRequestDto body,
  ) async {
    final Map<String, dynamic> json = await client.post(
      '/api/v1/customers/companies',
      body: body.toJson(),
    );
    return CustomerDto.fromJson(json);
  }

  Future<AffiliationLookupDto> lookupAffiliation(String email) async {
    final Map<String, dynamic> json = await client.get(
      '/api/v1/customers/affiliation-lookup',
      query: {'email': email},
    );
    return AffiliationLookupDto.fromJson(json);
  }

  Future<CustomerDto> affiliate(AffiliateCustomerRequestDto body) async {
    final Map<String, dynamic> json = await client.post(
      '/api/v1/customers/affiliations',
      body: body.toJson(),
    );
    return CustomerDto.fromJson(json);
  }
}
