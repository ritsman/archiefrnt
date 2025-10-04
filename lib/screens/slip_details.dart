import 'master/product.dart';
class SlipDetail {
  final int id;              // Database ID for the slip detail, 0 or null if new
  final Product? product;    // The associated product (can be null when not selected)
  final double? quantity;
  final double? rate;
  final double? weight;
  final double? amount;
  final DateTime? slipDate;  // The slip date (usually same as parent slip)

  SlipDetail({
    required this.id,
    this.product,
    this.quantity,
    this.rate,
    this.weight,
    this.amount,
    this.slipDate,
  });

  SlipDetail copyWith({
    int? id,
    Product? product,
    double? quantity,
    double? rate,
    double? weight,
    double? amount,
    DateTime? slipDate,
  }) {
    return SlipDetail(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      weight: weight ?? this.weight,
      amount: amount ?? this.amount,
      slipDate: slipDate ?? this.slipDate,
    );
  }

  factory SlipDetail.fromJson(Map<String, dynamic> json) {
    return SlipDetail(
      id: json['id'] ?? 0,
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      quantity: json['quantity'],
      rate: (json['rate'] != null) ? (json['rate'] as num).toDouble() : null,
      weight: (json['weight'] != null) ? (json['weight'] as num).toDouble() : null,
      amount: (json['amount'] != null) ? (json['amount'] as num).toDouble() : null,
      slipDate: json['slip_date'] != null ? DateTime.parse(json['slip_date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': product?.id,
      'quantity': quantity,
      'rate': rate,
      'weight': weight,
      'amount': amount,
      'slip_date': slipDate?.toIso8601String().substring(0, 10),
    };
  }

  @override
  String toString() {
    return 'SlipDetail(id: $id, product: $product, quantity: $quantity, rate: $rate, weight: $weight, amount: $amount, slipDate: $slipDate)';
  }
}
