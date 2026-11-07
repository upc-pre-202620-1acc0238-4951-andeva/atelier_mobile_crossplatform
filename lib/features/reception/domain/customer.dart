/// `CustomerType` de docs/api/README.md §8.
enum CustomerType {
  individual('INDIVIDUAL'),
  company('COMPANY');

  final String value;
  const CustomerType(this.value);

  static CustomerType? fromString(String? raw) {
    for (final type in values) {
      if (type.value == raw) return type;
    }
    return null;
  }
}

/// Cliente del taller (`CustomerResource`). [displayName] es el nombre o la razón social.
class Customer {
  final String id;
  final CustomerType? type;
  final String displayName;
  final String? taxId;
  final String? email;
  final String? phone;
  final String? status;

  const Customer({
    required this.id,
    this.type,
    required this.displayName,
    this.taxId,
    this.email,
    this.phone,
    this.status,
  });
}

/// Alta de persona natural (US11 E2, US44 E2): `CreateIndividualCustomerResource`.
class NewIndividualCustomer {
  final String firstName;
  final String lastName;
  final String taxId;
  final String? email;
  final String? phone;

  const NewIndividualCustomer({
    required this.firstName,
    required this.lastName,
    required this.taxId,
    this.email,
    this.phone,
  });
}

/// Alta de empresa (US11 E2): `CreateCompanyCustomerResource`.
class NewCompanyCustomer {
  final String companyName;
  final String taxId;
  final String? email;
  final String? phone;

  const NewCompanyCustomer({
    required this.companyName,
    required this.taxId,
    this.email,
    this.phone,
  });
}
