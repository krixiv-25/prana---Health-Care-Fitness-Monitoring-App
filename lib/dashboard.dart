import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'logadd.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Map<String, dynamic>> _weightData = [];

  @override
  void initState() {
    super.initState();
    _fetchWeightData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchWeightData(); 
  }

  Future<void> _fetchWeightData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('weight_logs')
            .orderBy('timestamp')
            .get();

    setState(() {
      _weightData =
          snapshot.docs.map((doc) {
            final data = doc.data();
            final timestamp = data['timestamp'] as Timestamp;
            return {
              'date': timestamp.toDate(),
              'weight': (data['weight'] as num).toDouble(),
              'x': timestamp.millisecondsSinceEpoch.toDouble(),
            };
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasData = _weightData.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(99, 75, 102, 1),
        centerTitle: true,
        title: const Text(
          "DASHBOARD",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Weight Loss Over Time",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (hasData)
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(8),
                  child: LineChart(
                    LineChartData(
                      minX: _weightData.first['x'],
                      maxX: _weightData.last['x'],
                      minY:
                          _weightData
                              .map((e) => e['weight'] as double)
                              .reduce(min) -
                          5,
                      maxY:
                          _weightData
                              .map((e) => e['weight'] as double)
                              .reduce(max) +
                          5,
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            interval:
                                (_weightData.length > 1)
                                    ? (_weightData.last['x'] -
                                            _weightData.first['x']) /
                                        7 
                                    : 1,
                            getTitlesWidget: (value, meta) {
                              final date = DateTime.fromMillisecondsSinceEpoch(
                                value.toInt(),
                              );
                              return Text(
                                DateFormat('MM/dd').format(date),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 2, 
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots:
                              _weightData
                                  .map(
                                    (data) => FlSpot(data['x'], data['weight']),
                                  )
                                  .toList(),
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Text("No weight data available."),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(99, 75, 102, 1),
        currentIndex: 1,
        selectedItemColor: const Color.fromRGBO(24, 2, 12, 1),
        unselectedItemColor: const Color.fromRGBO(149, 144, 168, 1),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              break;
            case 2:
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                builder: (context) => LogAdd(),
              );
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/map');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/mental');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement),
            label: 'Mental',
          ),
        ],
      ),
    );
  }
}
