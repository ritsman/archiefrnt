import '../slip.dart';
class Payment {
  final int id;
  final ClientMini client;
  final double amount;
  final String? notes;
  final DateTime date;

  Payment({
    required this.id,
    required this.client,
    required this.amount,
    this.notes,
    required this.date,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json['id'],
    client: ClientMini.fromJson(json['client']),
    amount: (json['amount'] as num).toDouble(),
    notes: json['notes'],
    date: DateTime.parse(json['date']),
  );
  Map<String, dynamic> toJson() => {
    "id": id,
    "client": {
      "id": client.id,
      "name": client.name,
    },
    "amount": amount,
    "notes": notes,
    "date": date.toIso8601String(),
  };
  Payment copyWith({
    int? id,
    ClientMini? client,
    double? amount,
    String? notes,
    DateTime? date,
  }) {
    return Payment(
      id: id ?? this.id,
      client: client ?? this.client,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      date: date ?? this.date,
    );
  }

}
