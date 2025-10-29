import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'salesman.dart';
import 'client.dart';
import 'product.dart';

import '../slip.dart'; // Your main slip model (with slip details as a list)
import '../payments/payments.dart'; // Make sure you have Payment + ClientMini classes defined

class ApiService {
  //static const String baseUrl = 'http://192.168.29.132:8000'; // Replace with your FastAPI IP
  //static const String baseUrl = 'http://103.73.190.204:8000';
  static const String baseUrl = 'http://192.168.29.237:8000';
//master/salesman
  static Future<List<Salesman>> fetchSalesmen() async {
    final response = await http.get(Uri.parse('$baseUrl/salesmen/'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Salesman.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch salesmen');
    }
  }

  static Future<Salesman> createSalesman(Salesman salesman) async {
    final response = await http.post(
      Uri.parse('$baseUrl/salesmen/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(salesman.toJson()),
    );
    if (response.statusCode == 200) {
      return Salesman.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create salesman');
    }
  }

  static Future<Salesman> updateSalesman(int id, Salesman salesman) async {
    final response = await http.put(
      Uri.parse('$baseUrl/salesmen/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(salesman.toJson()),
    );
    if (response.statusCode == 200) {
      return Salesman.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update salesman');
    }
  }

  static Future<void> deleteSalesman(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/salesmen/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete salesman');
    }
  }

  //master/clients
  static Future<List<Client>> fetchClients() async {
    final response = await http.get(Uri.parse('$baseUrl/clients/'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Client.fromJson(json)).toList();
    }
    throw Exception('Failed to load clients');
  }

  static Future<Client> createClient(Client client) async {
    final response = await http.post(
      Uri.parse('$baseUrl/clients/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(client.toJson()),
    );
    if (response.statusCode == 200) {
      return Client.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create client');
  }

  static Future<Client> updateClient(int id, Client updatedClient) async {
    final response = await http.put(
      Uri.parse('$baseUrl/clients/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedClient.toJson()),
    );
    if (response.statusCode == 200) {
      return Client.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update client');
  }

  static Future<void> deleteClient(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/clients/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete client');
    }
  }

  //product crud
// Product endpoints
  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products/'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    }
    throw Exception('Failed to load products');
  }

  static Future<Product> createProduct(Product p) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(p.toJson()),
    );
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create product');
  }

  static Future<Product> updateProduct(int id, Product p) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(p.toJson()),
    );
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update product');
  }

  static Future<void> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete product');
    }
  }
  //slip
  // Your slip detail model

  // --- SLIPS ---

  // Fetch all slips (with details)
  static Future<List<Slip>> fetchSlips() async {
    final response = await http.get(Uri.parse('$baseUrl/slips/'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Slip.fromJson(e)).toList();
    }
    throw Exception('Failed to load slips');
  }

  // Get a single slip by ID
  static Future<Slip> fetchSlipById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/slips/$id'));
    if (response.statusCode == 200) {
      return Slip.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load slip');
  }

  // Create a new slip (and its slip details)
  static Future<Slip> createSlip(Slip slip) async {
    print("---------");
    print(jsonEncode(slip.toJson()));
    final response = await http.post(
      Uri.parse('$baseUrl/slips/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          slip.toJson()), // Slip contains nested slipDetails in toJson
    );
    print("ppppppp2");
    print(Slip.fromJson(jsonDecode(response.body)));
    if (response.statusCode == 200) {
      print(response.body);
      print(response.statusCode);
      print(Slip.fromJson(jsonDecode(response.body)));
      return Slip.fromJson(jsonDecode(response.body));
    }
    print(slip);
    throw Exception('Failed to create slip2:$slip');
  }

  // Update/edit a slip (by ID)
  static Future<Slip> updateSlip(int id, Slip slip) async {
    final response = await http.put(
      Uri.parse('$baseUrl/slips/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(slip.toJson()),
    );
    if (response.statusCode == 200) {
      return Slip.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update slip: $slip');
  }

  // Delete a slip by ID
  static Future<void> deleteSlip(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/slips/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete slip');
    }
  }

  // --- SLIP DETAILS ---
  // Generally, you will manage slip details as part of the parent Slip
  // However, if you want to support individual slip detail edits or deletes:
  // (Adjust endpoint names if they differ in your backend.)

  static Future<void> deleteSlipDetail(int slipDetailId) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/slip_details/$slipDetailId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete slip detail');
    }
  }

  // Add more methods for updating an individual slip detail if your backend supports it.
  // In most apps, slip details are created/updated as part of the parent slip.

  // --- Utility: Fetch previous vehicle numbers ---
  static Future<List<String>> fetchVehicleNumbers() async {
    final response = await http.get(
        Uri.parse('$baseUrl/slips/vehicle_numbers/')); // Adjust path as needed
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<String>();
    }
    return [];
  }

  // Generate slip number for a specific date (if backend provides this API)
  static Future<String> generateSlipNumber(DateTime forDate) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/slips/generate_slip_number?date=${forDate.toIso8601String()}'),
    );
    if (response.statusCode == 200) {
      return response.body
          .replaceAll('"', ''); // Parse if backend returns as JSON string
    }
    throw Exception('Failed to generate slip number');
  }
//payments module

  /// Fetches the latest payments (limit 100 if backend supports limit param)
  static Future<List<Payment>> fetchPayments({int limit = 100}) async {
    final uri = Uri.parse("$baseUrl/payments?limit=$limit");

    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((p) => Payment.fromJson(p)).toList();
    } else {
      throw Exception("Failed to load payments: ${response.statusCode}");
    }
  }

  /// Creates a new payment
  static Future<Payment> createPayment({
    required int clientId,
    required double amount,
    String? notes,
    required DateTime date,
  }) async {
    final uri = Uri.parse("$baseUrl/payments/");

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "client_id": clientId,
        "amount": amount,
        "notes": notes ?? "",
        "date": DateFormat('yyyy-MM-dd').format(date),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Payment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to create payment: ${response.body}");
    }
  }
  ///updates a payment by ID
  static Future<Payment> updatePayment({
    required int id,
    required int clientId,
    required double amount,
    String? notes,
    required DateTime date,
  }) async {
    final response = await http.put(
      Uri.parse("$baseUrl/payments/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "client_id": clientId,
        "amount": amount,
        "notes": notes,
        "date": date.toIso8601String().split("T").first, // 'YYYY-MM-DD'
      }),
    );

    if (response.statusCode == 200) {
      return Payment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to update payment");
    }
  }



  /// Deletes a payment by ID
  static Future<bool> deletePayment(int paymentId) async {
    final uri = Uri.parse("$baseUrl/payments/$paymentId");

    final response = await http.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Failed to delete payment: ${response.body}");
    }
  }
}
