import 'slip_details.dart';

class ClientMini {
  final int id;
  final String name;

  ClientMini({required this.id, required this.name});

  factory ClientMini.fromJson(Map<String, dynamic> json) =>
      ClientMini(id: json['id'], name: json['name']);
}

class SalesmanMini {
  final int id;
  final String name;

  SalesmanMini({required this.id, required this.name});

  factory SalesmanMini.fromJson(Map<String, dynamic> json) =>
      SalesmanMini(id: json['id'], name: json['name']);
}




class Slip {
  final int id;
  final String slipNumber;
  final int clientId;
  final int salesmanId;
  final DateTime slipDate;
  final String? vehicleNumber;
  final double totalAmount;
  final List<SlipDetail> slipDetails;
  final ClientMini? client;
  final SalesmanMini? salesman;

  Slip({
    required this.id,
    required this.slipNumber,
    required this.clientId,
    this.client,
    required this.salesmanId,
    this.salesman,
    required this.slipDate,
    this.vehicleNumber,
    required this.totalAmount,
    required this.slipDetails,
  });

  factory Slip.fromJson(Map<String, dynamic> json) {
    return Slip(
      id: json['id'],
      slipNumber: json['slip_number'],
      clientId: json['client_id'],
      salesmanId: json['salesman_id'],
      client: json['client'] != null ? ClientMini.fromJson(json['client']) : null,
      salesman: json['salesman'] != null ? SalesmanMini.fromJson(json['salesman']) : null,
      slipDate: DateTime.parse(json['slip_date']),
      vehicleNumber: json['vehicle_number'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      slipDetails: (json['slip_details'] as List<dynamic>)
          .map((e) => SlipDetail.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slip_number': slipNumber,
      'client_id': clientId,
      'salesman_id': salesmanId,
      'slip_date': slipDate.toIso8601String().substring(0, 10),
      'vehicle_number': vehicleNumber,
      'total_amount': totalAmount,
      'slip_details': slipDetails.map((detail) => detail.toJson()).toList(),
    };
  }

  Slip copyWith({
    int? id,
    String? slipNumber,
    int? clientId,
    int? salesmanId,
    DateTime? slipDate,
    String? vehicleNumber,
    double? totalAmount,
    List<SlipDetail>? slipDetails,
  }) {
    return Slip(
      id: id ?? this.id,
      slipNumber: slipNumber ?? this.slipNumber,
      clientId: clientId ?? this.clientId,
      salesmanId: salesmanId ?? this.salesmanId,
      slipDate: slipDate ?? this.slipDate,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      totalAmount: totalAmount ?? this.totalAmount,
      slipDetails: slipDetails ?? this.slipDetails,
    );
  }

  @override
  String toString() {
    return 'Slip(id: $id, slipNumber: $slipNumber, clientId: $clientId, salesmanId: $salesmanId, slipDate: $slipDate, vehicleNumber: $vehicleNumber, totalAmount: $totalAmount, slipDetails: $slipDetails)';
  }
}
