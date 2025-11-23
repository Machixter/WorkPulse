import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String? id;
  final String userId;
  final String method; // 'M-Pesa', 'Stripe', 'Crypto'
  final String? cryptoType; // 'BTC', 'ETH', 'USDC'
  final double amount;
  final String status;
  final DateTime timestamp;
  final Map<String, dynamic>? details;

  Payment({
    this.id,
    required this.userId,
    required this.method,
    this.cryptoType,
    required this.amount,
    required this.status,
    required this.timestamp,
    this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'method': method,
      'cryptoType': cryptoType,
      'amount': amount,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
      'details': details,
    };
  }

  factory Payment.fromFirestore(Map<String, dynamic> data, String docId) {
    return Payment(
      id: docId,
      userId: data['userId'] ?? '',
      method: data['method'] ?? '',
      cryptoType: data['cryptoType'],
      amount: (data['amount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      details: data['details'] as Map<String, dynamic>?,
    );
  }
}
