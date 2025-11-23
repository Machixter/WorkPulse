import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/payment.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _walletController = TextEditingController();
  
  String _selectedMethod = 'M-Pesa';
  String _selectedCrypto = 'BTC';
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    _walletController.dispose();
    super.dispose();
  }

  Future<void> _initiatePayment() async {
    if (_amountController.text.trim().isEmpty) {
      _showError('Please enter an amount');
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    // Validate method-specific fields
    if (_selectedMethod == 'M-Pesa' && _phoneController.text.trim().isEmpty) {
      _showError('Please enter M-Pesa phone number');
      return;
    }

    if (_selectedMethod == 'Crypto' && _walletController.text.trim().isEmpty) {
      _showError('Please enter wallet address');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final payment = Payment(
        userId: _user?.uid ?? 'demo_user',
        method: _selectedMethod,
        cryptoType: _selectedMethod == 'Crypto' ? _selectedCrypto : null,
        amount: amount,
        status: 'pending',
        timestamp: DateTime.now(),
        details: {
          if (_selectedMethod == 'M-Pesa') 'phone': _phoneController.text.trim(),
          if (_selectedMethod == 'Crypto') 'wallet': _walletController.text.trim(),
        },
      );

      await _firestore.collection('payments').add(payment.toMap());

      _amountController.clear();
      _phoneController.clear();
      _walletController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Payment initiated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Error initiating payment: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Management'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Payment Form Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Initiate Payment',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Payment Method Selector
                        DropdownButtonFormField<String>(
                          initialValue: _selectedMethod,
                          decoration: const InputDecoration(
                            labelText: 'Payment Method',
                            prefixIcon: Icon(Icons.payment),
                          ),
                          items: ['M-Pesa', 'Stripe', 'Crypto']
                              .map((method) => DropdownMenuItem(
                                    value: method,
                                    child: Text(method),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedMethod = value!);
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // M-Pesa specific fields
                        if (_selectedMethod == 'M-Pesa') ...[
                          TextField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              hintText: '254712345678',
                              prefixIcon: Icon(Icons.phone),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Stripe info
                        if (_selectedMethod == 'Stripe') ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Stripe account linking required. This will be processed via Stripe Connect.',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Crypto specific fields
                        if (_selectedMethod == 'Crypto') ...[
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCrypto,
                            decoration: const InputDecoration(
                              labelText: 'Cryptocurrency',
                              prefixIcon: Icon(Icons.currency_bitcoin),
                            ),
                            items: ['BTC', 'ETH', 'USDC']
                                .map((crypto) => DropdownMenuItem(
                                      value: crypto,
                                      child: Text(crypto),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedCrypto = value!);
                            },
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _walletController,
                            decoration: const InputDecoration(
                              labelText: 'Wallet Address',
                              hintText: '0x...',
                              prefixIcon: Icon(Icons.account_balance_wallet),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Amount Field
                        TextField(
                          controller: _amountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            prefixIcon: Icon(Icons.attach_money),
                            hintText: '0.00',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                        const SizedBox(height: 24),
                        
                        // Submit Button
                        ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _initiatePayment,
                          icon: _isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.send),
                          label: Text(_isProcessing ? 'Processing...' : 'Initiate Payment'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const Divider(height: 1),
            
            // Recent Payments Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Recent Payments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('payments')
                          .where('userId', isEqualTo: _user?.uid ?? 'demo_user')
                          .orderBy('timestamp', descending: true)
                          .limit(10)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.payment, size: 64, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text(
                                  'No payments yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final doc = snapshot.data!.docs[index];
                            final payment = Payment.fromFirestore(
                              doc.data() as Map<String, dynamic>,
                              doc.id,
                            );

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: payment.status == 'completed'
                                      ? Colors.green[100]
                                      : Colors.orange[100],
                                  child: Icon(
                                    payment.method == 'M-Pesa'
                                        ? Icons.phone_android
                                        : payment.method == 'Stripe'
                                            ? Icons.credit_card
                                            : Icons.currency_bitcoin,
                                    color: payment.status == 'completed'
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                                title: Text(
                                  '\$${payment.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Text(
                                  '${payment.method}${payment.cryptoType != null ? ' (${payment.cryptoType})' : ''}\n${DateFormat('MMM d, y h:mm a').format(payment.timestamp)}',
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: payment.status == 'completed'
                                        ? Colors.green[50]
                                        : Colors.orange[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    payment.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: payment.status == 'completed'
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
