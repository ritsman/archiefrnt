class Product {
  final int id;
  final String name;
  final double? weight;
  final double? rate;

  Product({
    required this.id,
    required this.name,
    this.weight,
    this.rate,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      weight: json['weight'] == null ? null : (json['weight'] as num).toDouble(),
      rate: json['rate'] == null ? null : (json['rate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'weight': weight,
    'rate': rate,
  };
}
