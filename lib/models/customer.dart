import 'package:hive/hive.dart';

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

class CustomerAdapter extends TypeAdapter<Customer> {
  @override
  final int typeId = 1;

  @override
  Customer read(BinaryReader reader) {
    final id = reader.read() as String;
    final meterId = reader.read() as String;
    final name = reader.read() as String;
    final address = reader.read() as String;
    final phone = reader.read() as String;
    final regMillis = reader.read() as int;
    return Customer(
      id: id,
      meterId: meterId,
      name: name,
      address: address,
      phone: phone,
      registrationDate: DateTime.fromMillisecondsSinceEpoch(regMillis),
    );
  }

  @override
  void write(BinaryWriter writer, Customer obj) {
    writer.write(obj.id);
    writer.write(obj.meterId);
    writer.write(obj.name);
    writer.write(obj.address);
    writer.write(obj.phone);
    writer.write(obj.registrationDate.millisecondsSinceEpoch);
  }
}
