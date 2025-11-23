import 'package:cloud_firestore/cloud_firestore.dart';

class DailyLog {
  final String? id;
  final String userId;
  final String log;
  final DateTime date;
  final String source; // 'manual', 'voice', 'ai_assisted'
  final Map<String, dynamic>? metadata;

  DailyLog({
    this.id,
    required this.userId,
    required this.log,
    required this.date,
    this.source = 'manual',
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'log': log,
      'date': date.toIso8601String(),
      'source': source,
      'metadata': metadata,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  factory DailyLog.fromFirestore(Map<String, dynamic> data, String docId) {
    return DailyLog(
      id: docId,
      userId: data['userId'] ?? '',
      log: data['log'] ?? '',
      date: data['date'] != null 
          ? DateTime.parse(data['date']) 
          : DateTime.now(),
      source: data['source'] ?? 'manual',
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }
}
