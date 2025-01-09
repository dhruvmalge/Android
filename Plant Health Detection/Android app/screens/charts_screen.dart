import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:plant_health_detection/storage/database.dart';
import 'package:http/http.dart' as http;

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  late List<ChartData> _chartData = [];
  late Timer timer;
  final String apiUrl = 'http://192.168.43.172:5000/data';

  @override
  void initState() {
    super.initState();
    _fetchFromDB();
    fetchDataFromServer();
    timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      fetchDataFromServer();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> _fetchFromDB() async {
    List<ChartData> chartData = [];
    try {
      List<Map<String, dynamic>> data = await DatabaseHelper.instance.fetchData();
      for (var item in data) {
        String timestamp = item['datetime'] ?? '';

        double confidence = double.tryParse(item['confidence'] ?? '0') ?? 0.0;

        chartData.add(ChartData(timestamp, confidence));
      }

      if (chartData.length > 60) {
        chartData = chartData.sublist(chartData.length - 60);
      }

      setState(() {
        _chartData = chartData;
      });
    } catch (e) {
      debugPrint('Error fetching data from database: $e');
    }
  }

  Future<void> fetchDataFromServer() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        String predictedDisease = jsonData['predicted_disease'] ?? 'None';

        double confidence = double.tryParse(jsonData['confidence']?.toString() ?? '0') ?? 0.0;

        List<String> detectedObjects = List<String>.from(jsonData['detected_objects']);
        String datetime = jsonData['datetime'];

        DatabaseHelper.instance.insertData(
          DateTime.parse(datetime),
          confidence.toString(),
          predictedDisease,
          jsonEncode(detectedObjects),
        );

        setState(() {
          _chartData.add(ChartData(datetime, confidence));
          if (_chartData.length > 60) {
            _chartData.removeAt(0);
          }
        });
      } else {
        throw Exception('Failed to load data from server');
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Health Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SfCartesianChart(
          title: const ChartTitle(text: 'Confidence Over Time'),
          legend: const Legend(isVisible: true),
          tooltipBehavior: TooltipBehavior(enable: true),
          primaryXAxis: const CategoryAxis(
            title: AxisTitle(text: 'Timestamp'),
          ),
          primaryYAxis: const NumericAxis(
            title: AxisTitle(text: 'Confidence'),
          ),
          series: <LineSeries<ChartData, String>>[
            LineSeries<ChartData, String>(
              dataSource: _chartData,
              xValueMapper: (ChartData chartData, _) => chartData.timestamp,
              yValueMapper: (ChartData chartData, _) => chartData.confidence,
              name: 'Confidence',
              markerSettings: const MarkerSettings(isVisible: true),
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String timestamp;
  final double confidence;

  ChartData(this.timestamp, this.confidence);
}
