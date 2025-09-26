class Client {
  final int id;
  final String name;
  final String? phone;
  final String? address;

  Client({
    required this.id,
    required this.name,
    this.phone,
    this.address,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'address': address,
  };

  @override
  String toString() => 'Client(id: $id, name: $name, phone: $phone, address: $address)';
}
