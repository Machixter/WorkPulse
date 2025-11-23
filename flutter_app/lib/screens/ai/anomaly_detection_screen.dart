import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnomalyDetectionScreen extends StatefulWidget {
  const AnomalyDetectionScreen({super.key});

  @override
  State<AnomalyDetectionScreen> createState() => _AnomalyDetectionScreenState();
}

class _AnomalyDetectionScreenState extends State<AnomalyDetectionScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;
  bool _isAnalyzing = false;
  List<Map<String, dynamic>> _anomalies = [];

  Future<void> _detectAnomalies() async {
    setState(() => _isAnalyzing = true);

    try {
      // Fetch recent logs
      final logsSnapshot = await _firestore
          .collection('daily_logs')
          .where('userId', isEqualTo: _user?.uid ?? 'demo_user')
          .orderBy('date', descending: true)
          .limit(30)
          .get();

      // Simple anomaly detection: short logs, large gaps, etc.
      final anomalies = <Map<String, dynamic>>[];
      DateTime? lastDate;

      for (var doc in logsSnapshot.docs) {
        final data = doc.data();
        final log = data['log'] as String;
        final date = DateTime.parse(data['date']);

        // Check for short logs
        if (log.split(' ').length < 10) {
          anomalies.add({
            'log': log,
            'date': date,
            'reason': 'Log too short (< 10 words)',
            'type': 'log',
          });
        }

        // Check for large time gaps
        if (lastDate != null) {
          final dayGap = date.difference(lastDate).inDays.abs();
          if (dayGap > 3) {
            anomalies.add({
              'log': log,
              'date': date,
              'reason': 'Large gap since last log ($dayGap days)',
              'type': 'log',
            });
          }
        }

        lastDate = date;
      }

      // Fetch recent payments
      final paymentsSnapshot = await _firestore
          .collection('payments')
          .where('userId', isEqualTo: _user?.uid ?? 'demo_user')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      // Check for payment anomalies
      for (var doc in paymentsSnapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] as num).toDouble();

        // Check for unusually high amounts
        if (amount > 10000) {
          anomalies.add({
            'log': 'Payment of \$${amount.toStringAsFixed(2)} via ${data['method']}',
            'date': (data['timestamp'] as Timestamp).toDate(),
            'reason': 'Unusually high amount',
            'type': 'payment',
            'amount': amount,
            'method': data['method'],
          });
        }
      }

      setState(() {
        _anomalies = anomalies;
        _isAnalyzing = false;
      });

      if (anomalies.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ No anomalies detected!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isAnalyzing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Anomaly Detection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About Anomaly Detection'),
                  content: const Text(
                    'This feature uses AI to analyze your daily logs and payments for unusual patterns:\n\n'
                    '• Very short log entries\n'
                    '• Large gaps between logs\n'
                    '• Unusually high payment amounts\n'
                    '• Frequent payments\n\n'
                    'Anomalies help supervisors identify potential issues.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Analysis Button
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _isAnalyzing ? null : _detectAnomalies,
                    icon: _isAnalyzing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.search),
                    label: Text(_isAnalyzing ? 'Analyzing...' : 'Run Anomaly Detection'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            
            // Results Section
            Expanded(
              child: _anomalies.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No anomalies detected yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Run the analysis to check for unusual patterns',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _anomalies.length,
                      itemBuilder: (context, index) {
                        final anomaly = _anomalies[index];
                        final isPayment = anomaly['type'] == 'payment';

                        return Card(
                          color: isPayment ? Colors.orange[50] : Colors.red[50],
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isPayment ? Icons.warning_amber : Icons.error_outline,
                                      color: isPayment ? Colors.orange : Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        anomaly['reason'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isPayment ? Colors.orange[900] : Colors.red[900],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  anomaly['log'],
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  anomaly['date'].toString().substring(0, 16),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (isPayment && anomaly['amount'] != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${anomaly['method']} • \$${anomaly['amount'].toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
