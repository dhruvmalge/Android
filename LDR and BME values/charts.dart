import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SensorChart extends StatelessWidget {
  final List<FlSpot> ldrData;
  final List<FlSpot> tempData;
  final List<FlSpot> humidityData;

  const SensorChart({
    super.key,
    required this.ldrData,
    required this.tempData,
    required this.humidityData,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: const FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        minX: 0,
        maxX: 10,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: ldrData,
            isCurved: true,
            color: Colors.blue,
          ),
          LineChartBarData(
            spots: tempData,
            isCurved: true,
            color: Colors.red,
          ),
          LineChartBarData(
            spots: humidityData,
            isCurved: true,
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}
