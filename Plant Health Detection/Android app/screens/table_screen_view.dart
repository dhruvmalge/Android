import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:plant_health_detection/storage/database.dart';

class TableView extends StatefulWidget {
  const TableView({super.key});

  @override
  TableViewState createState() => TableViewState();
}

class PlantData {
  final String confidence;
  final String predictedDisease;
  final List<String> detectedObjects;
  final DateTime datetime;

  PlantData({
    required this.confidence,
    required this.predictedDisease,
    required this.detectedObjects,
    required this.datetime,
  });

  factory PlantData.fromJson(Map<String, dynamic> json) {
    return PlantData(
      confidence: json['confidence'].toString(),
      predictedDisease: json['predicted_disease'] ?? "None",
      detectedObjects: List<String>.from(json['detected_objects'] ?? []),
      datetime: DateTime.parse(json['datetime']),
    );
  }
}

class TableViewState extends State<TableView> {
  List<DataRow> tableRows = [];
  bool isLoading = true;
  late Timer timer;

  final String apiUrl = 'http://192.168.43.172:5000/data';

  Future<void> fetchDataFromServer() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print("Fetched data: $jsonData");

        PlantData plantData = PlantData.fromJson(jsonData);

        await DatabaseHelper.instance.insertData(
          plantData.datetime,
          plantData.confidence,
          plantData.predictedDisease,
          jsonEncode(plantData.detectedObjects),
        );

        setState(() {
          tableRows.add(
            DataRow(cells: [
              DataCell(Text(plantData.datetime.toString())),
              DataCell(Text(plantData.confidence)),
              DataCell(Text(plantData.predictedDisease)),
              DataCell(Text(jsonEncode(plantData.detectedObjects))),
            ]),
          );
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data from server');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDataFromServer();
    timer = Timer.periodic(Duration(seconds: 2), (timer) {
      fetchDataFromServer();
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plant Data Table"),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : DataTable(
            columns: const [
              DataColumn(label: Text("Datetime")),
              DataColumn(label: Text("Confidence")),
              DataColumn(label: Text("Predicted Disease")),
              DataColumn(label: Text("Detected Objects")),
            ],
            rows: tableRows,
          ),
        ),
      ),
    );
  }
}
