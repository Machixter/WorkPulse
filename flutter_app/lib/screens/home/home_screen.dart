import 'package:flutter/material.dart';
import '../daily_logs/daily_log_screen.dart';
import '../payments/payment_screen.dart';
import '../ai/anomaly_detection_screen.dart';
import '../supervisor/supervisor_insights_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget screen,
  }) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.work, size: 28),
            SizedBox(width: 12),
            Text(
              'WorkPulse',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile coming soon')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Card(
                color: Colors.blueAccent,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Track your industrial attachment progress',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Core Features Section
              const Text(
                'Core Features',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildFeatureCard(
                context,
                title: 'Daily Logs',
                subtitle: 'Record your daily work activities',
                icon: Icons.edit_note,
                color: Colors.blue,
                screen: const DailyLogScreen(),
              ),
              const SizedBox(height: 12),
              
              _buildFeatureCard(
                context,
                title: 'Payments',
                subtitle: 'Manage stipend payments (M-Pesa, Stripe, Crypto)',
                icon: Icons.payment,
                color: Colors.green,
                screen: const PaymentScreen(),
              ),
              const SizedBox(height: 24),
              
              // AI Features Section
              const Text(
                'AI-Powered Insights',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildFeatureCard(
                context,
                title: 'Anomaly Detection',
                subtitle: 'AI analysis of logs and payments',
                icon: Icons.warning_amber,
                color: Colors.orange,
                screen: const AnomalyDetectionScreen(),
              ),
              const SizedBox(height: 12),
              
              _buildFeatureCard(
                context,
                title: 'Supervisor Insights',
                subtitle: 'Dashboard with trends and analytics',
                icon: Icons.analytics,
                color: Colors.purple,
                screen: const SupervisorInsightsScreen(),
              ),
              const SizedBox(height: 24),
              
              // Quick Stats
              const Text(
                'Quick Stats',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: Colors.blue[50],
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Icon(Icons.event_note, 
                              size: 32, 
                              color: Colors.blue
                            ),
                            SizedBox(height: 8),
                            Text(
                              '0',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Total Logs'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      color: Colors.green[50],
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Icon(Icons.attach_money, 
                              size: 32, 
                              color: Colors.green
                            ),
                            SizedBox(height: 8),
                            Text(
                              '\$0',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Total Paid'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
