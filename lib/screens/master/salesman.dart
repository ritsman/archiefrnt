class Salesman {
  final int id;
  final String name;
  final double? commission;
  final String? phone;

  Salesman({
    required this.id,
    required this.name,
    this.commission,
    this.phone,
  });

  factory Salesman.fromJson(Map<String, dynamic> json) {
    return Salesman(
      id: json['id'],
      name: json['name'],
      commission: (json['commission'] != null) ? (json['commission'] as num).toDouble() : null,
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'commission': commission,
    'phone': phone,
  };
}
