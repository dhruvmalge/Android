import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'database.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Weather {
  final double ldrValue;
  final double temperature;
  final double humidity;

  Weather({
    required this.ldrValue,
    required this.temperature,
    required this.humidity,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      ldrValue: json['LDR'] != null ? json['LDR'].toDouble() : 0.0,
      temperature: json['temp'] != null ? json['temp'].toDouble() : 0.0,
      humidity: json['humidity'] != null ? json['humidity'].toDouble() : 0.0,
    );
  }
}

Future<Weather> fetchWeather() async {
  final response =
      await http.get(Uri.parse("http://192.168.43.109/dht_values"));
  if (response.statusCode == 200) {
    return Weather.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load weather data');
  }
}

class ESPCommunicationMQTT extends StatefulWidget {
  const ESPCommunicationMQTT({super.key});

  @override
  _ESPCommunicationMQTTState createState() => _ESPCommunicationMQTTState();
}

class _ESPCommunicationMQTTState extends State<ESPCommunicationMQTT> {
  late MqttClient client;
  Weather? currentWeather;
  bool state1 = false,
      state2 = false,
      state3 = false,
      state4 = false,
      state5 = false,
      state6 = false;
  double ldrValue = 0.0;
  double temperature = 0.0, humidity = 0.0;
  List<ChartData> ldrData = [];
  List<ChartData> tempData = [];
  List<ChartData> humidityData = [];
  double counter = 0.0;
  List<DataRow> tableRows = [];

  @override
  void initState() {
    super.initState();
    connectMQTT();
    fetchWeatherData();
    fetchDataFromDatabase();
    Timer.periodic(
        const Duration(seconds: 2), (_) => client.keepAlivePeriod.isInfinite);
    Timer.periodic(const Duration(seconds: 2), (_) => fetchWeatherData());
  }

  Future<void> fetchWeatherData() async {
    try {
      Weather weather = await fetchWeather();
      setState(() {
        currentWeather = weather;
        temperature = weather.temperature;
        humidity = weather.humidity;
        ldrValue = weather.ldrValue;

        tempData.add(ChartData(counter, temperature));
        humidityData.add(ChartData(counter, humidity));
        ldrData.add(ChartData(counter, ldrValue));
        counter++;

        tableRows.add(DataRow(cells: [
          // DataCell(Text(counter.toString())),
          DataCell(Text(DateTime.now().toString())),
          DataCell(Text(temperature.toString())),
          DataCell(Text(humidity.toString())),
          DataCell(Text(ldrValue.toString())),
        ]));
      });
      DatabaseHelper.instance.insertData(ldrValue, temperature, humidity);
    } catch (e) {
      print("Error fetching weather data: $e");
    }
  }

  Future<void> fetchDataFromDatabase() async {
    List<Map<String, dynamic>> data = await DatabaseHelper.instance.fetchData();
    setState(() {
      for (var row in data) {
        double storedTemperature = row['temperature'];
        double storedHumidity = row['humidity'];
        double storedLdrValue = row['ldrValue'];
        String timestamp = row['timestamp'];

        tempData.add(ChartData(counter++, storedTemperature));
        humidityData.add(ChartData(counter++, storedHumidity));
        ldrData.add(ChartData(counter++, storedLdrValue));

        tableRows.add(DataRow(cells: [
          DataCell(Text(storedTemperature.toString())),
          DataCell(Text(storedHumidity.toString())),
          DataCell(Text(storedLdrValue.toString())),
        ]));
      }
    });
  }

  Future<void> connectMQTT() async {
    client = MqttClient('test.mosquitto.org', 'flutter_client');
    client.port = 1883;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;

    try {
      await client.connect();
      if (client.connectionStatus == MqttConnectionState.connected) {
        print('Connected to MQTT broker');
        client.subscribe('esp32/ldr', MqttQos.atLeastOnce);
        client.subscribe('esp32/dht', MqttQos.atLeastOnce);
      } else {
        print('Failed to connect to MQTT broker');
      }
    } catch (e) {
      print('Error connecting to MQTT: $e');
    }

    client.updates?.listen((List<MqttReceivedMessage> c) {
      final message = c[0].payload;
      final topic = c[0].topic;
      final payload = utf8.decode(message.payload);
      print("Received message on topic: $topic");
      print("Payload: $payload");

      if (topic == 'esp32/dht') {
        final data = json.decode(payload);
        setState(() {
          temperature = data['temp'];
          humidity = data['humidity'];
          tempData.add(ChartData(counter, temperature));
          humidityData.add(ChartData(counter, humidity));
          counter++;
          print('Data updated: $temperature, $humidity');
        });
        DatabaseHelper.instance.insertData(ldrValue, temperature, humidity);
      }

      if (topic == 'esp32/ldr') {
        final data = json.decode(payload);
        setState(() {
          ldrValue = data['LDR'];
          ldrData.add(ChartData(counter, ldrValue));
          counter++;
          print('LDR Data updated: $ldrValue');
        });
        DatabaseHelper.instance.insertData(ldrValue, temperature, humidity);
      }
    });
  }

  void onConnected() {
    print('Connected to MQTT broker');
  }

  void onDisconnected() {
    print('Disconnected from MQTT broker');
  }

  void toggleDevice(String topic, bool state) {
    if (client.connectionStatus == MqttConnectionState.connected) {
      final String message = state ? 'on' : 'off';
      client.publishMessage(
        topic,
        MqttQos.atLeastOnce,
        MqttClientPayloadBuilder().addString(message).payload!,
      );
      print('Message sent to topic $topic: $message');
    } else {
      print('MQTT client not connected. Attempting to reconnect...');
      connectMQTT().then((_) {
        final String message = state ? 'on' : 'off';
        client.publishMessage(
          topic,
          MqttQos.atLeastOnce,
          MqttClientPayloadBuilder().addString(message).payload!,
        );
        print('Message sent to topic $topic: $message');
      }).catchError((e) {
        print('Failed to reconnect: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Control your Home"),
        centerTitle: true,
      ),
      body: PageView(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(10),
                    child: SfCartesianChart(
                      primaryXAxis: NumericAxis(),
                      primaryYAxis: NumericAxis(),
                      title: ChartTitle(text: 'Real-time Sensor Data'),
                      legend: Legend(isVisible: true),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: [
                        LineSeries<ChartData, double>(
                          dataSource:
                              ldrData.isEmpty ? [ChartData(0, 0)] : ldrData,
                          xValueMapper: (ChartData data, _) => data.time,
                          yValueMapper: (ChartData data, _) => data.value,
                          name: 'LDR',
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(10),
                    child: SfCartesianChart(
                      primaryXAxis: NumericAxis(),
                      primaryYAxis: NumericAxis(),
                      title: ChartTitle(text: 'Real-time Sensor Data'),
                      legend: Legend(isVisible: true),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: [
                        LineSeries<ChartData, double>(
                          dataSource:
                          tempData.isEmpty ? [ChartData(0, 0)] : tempData,
                          xValueMapper: (ChartData data, _) => data.time,
                          yValueMapper: (ChartData data, _) => data.value,
                          name: 'Temperature',
                          color: Colors.red,
                        ),
                        LineSeries<ChartData, double>(
                          dataSource: humidityData.isEmpty
                              ? [ChartData(0, 0)]
                              : humidityData,
                          xValueMapper: (ChartData data, _) => data.time,
                          yValueMapper: (ChartData data, _) => data.value,
                          name: 'Humidity',
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (currentWeather != null) ...[
                    Text("Temperature: ${currentWeather!.temperature}°C"),
                    Text("Humidity: ${currentWeather!.humidity}%"),
                    Text("LDR: ${currentWeather!.ldrValue} "),
                  ] else
                    const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  // Grid of switches for controlling devices
                  Container(
                    height: 500,
                    padding: const EdgeInsets.all(5.0),
                    child: GridView(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      children: [
                        _buildSwitchTile("LED", state1, (bool value) {
                          setState(() {
                            state1 = value;
                          });
                          toggleDevice('home/led', value);
                        }),
                        _buildSwitchTile("Buzzer", state2, (bool value) {
                          setState(() {
                            state2 = value;
                          });
                          toggleDevice('home/buzzer', value);
                        }),
                        _buildSwitchTile("Motor", state3, (bool value) {
                          setState(() {
                            state3 = value;
                          });
                          toggleDevice('home/motor', value);
                        }),
                        _buildSwitchTile("RGB", state4, (bool value) {
                          setState(() {
                            state4 = value;
                          });
                          toggleDevice('home/rgb', value);
                        }),
                        _buildSwitchTile("Relay", state5, (bool value) {
                          setState(() {
                            state5 = value;
                          });
                          toggleDevice('home/relay', value);
                        }),
                        _buildSwitchTile("Servo", state6, (bool value) {
                          setState(() {
                            state6 = value;
                          });
                          toggleDevice('home/servo', value);
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: DataTable(
              columns: const [
                // DataColumn(label: Text('Number')),
                DataColumn(label: Text('Timestamp')),
                DataColumn(label: Text('Temperature')),
                DataColumn(label: Text('Humidity')),
                DataColumn(label: Text('LDR')),
              ],
              rows: tableRows,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (client.connectionStatus == MqttConnectionState.connected) {
      client.unsubscribe('esp32/ldr');
      client.unsubscribe('esp32/dht');
    }
    client.updates?.drain();
    client.disconnect();
    super.dispose();
  }

  // Helper function to build a Switch ListTile
  Widget _buildSwitchTile(
      String deviceName, bool deviceState, ValueChanged<bool> onChanged) {
    return ListTile(
      title: Text("$deviceName is ${deviceState ? "ON" : "OFF"}"),
      trailing: Switch(
        value: deviceState,
        activeColor: deviceState ? Colors.orangeAccent : Colors.blue[500],
        inactiveThumbColor: Colors.blue,
        inactiveTrackColor: Colors.blue[50],
        onChanged: onChanged,
      ),
    );
  }
}

class ChartData {
  final double time;
  final double value;

  ChartData(this.time, this.value);
}
