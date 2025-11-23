import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SupervisorInsightsScreen extends StatefulWidget {
  const SupervisorInsightsScreen({super.key});

  @override
  State<SupervisorInsightsScreen> createState() => _SupervisorInsightsScreenState();
}

class _SupervisorInsightsScreenState extends State<SupervisorInsightsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supervisor Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing insights...')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Students',
                      '0',
                      Icons.people,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Anomalies',
                      '0',
                      Icons.warning_amber,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Logs',
                      '0',
                      Icons.event_note,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Payments',
                      '\$0',
                      Icons.attach_money,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Anomaly Trends Chart
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Anomaly Trends',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 10,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                                    if (value.toInt() >= 0 && value.toInt() < months.length) {
                                      return Text(
                                        months[value.toInt()],
                                        style: const TextStyle(fontSize: 12),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(fontSize: 12),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: [
                              BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 0, color: Colors.blueAccent)]),
                              BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 0, color: Colors.blueAccent)]),
                              BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 0, color: Colors.blueAccent)]),
                              BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 0, color: Colors.blueAccent)]),
                              BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 0, color: Colors.blueAccent)]),
                              BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 0, color: Colors.blueAccent)]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Student List
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Student Activity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.people_outline, size: 48, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text(
                              'No students assigned yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
