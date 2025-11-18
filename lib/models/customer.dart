class Customer {
  final String id;
  final String meterId;
  final String name;
  final String address;
  final String phone;
  final DateTime registrationDate;

  Customer({
    required this.id,
    required this.meterId,
    required this.name,
    required this.address,
    required this.phone,
    required this.registrationDate,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? '',
      meterId: json['meterId'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      registrationDate: json['registrationDate'] != null
          ? DateTime.parse(json['registrationDate'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meterId': meterId,
      'name': name,
      'address': address,
      'phone': phone,
      'registrationDate': registrationDate.toIso8601String(),
    };
  }
}
