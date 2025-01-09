import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  ControlScreenState createState() => ControlScreenState();
}

class ControlScreenState extends State<ControlScreen> {
  bool motorState = false;
  bool servoState = false;
  bool relayState = false;
  bool ledState = false;

  late MqttServerClient client;
  bool isConnected = false;

  final String broker = 'broker.emqx.io';
  final int port = 1883;
  final String clientId = 'flutter_client';
  final int keepAlivePeriod = 20; // Seconds
  final List<String> topics = [
    "home/control/motor",
    "home/control/servo",
    "home/control/relay",
    "home/control/led"
  ];

  @override
  void initState() {
    super.initState();
    _initializeMQTT();
  }

  Future<void> _initializeMQTT() async {
    client = MqttServerClient(broker, clientId)
      ..port = port
      ..keepAlivePeriod = keepAlivePeriod
      ..onConnected = _onConnected
      ..onDisconnected = _onDisconnected
      ..logging(on: false);

    try {
      await client.connect();
    } catch (e) {
      print('MQTT Client connection failed: $e');
      _reconnect();
    }
  }

  void _onConnected() {
    print('Connected to MQTT broker');
    setState(() => isConnected = true);
    for (String topic in topics) {
      client.subscribe(topic, MqttQos.atMostOnce);
    }
    client.updates?.listen(_onMessageReceived);
  }

  void _onDisconnected() {
    print('Disconnected from MQTT broker');
    setState(() => isConnected = false);
    _reconnect();
  }

  Future<void> _reconnect() async {
    int attempt = 0;
    const maxAttempts = 5;

    while (!isConnected && attempt < maxAttempts) {
      attempt++;
      print('Reconnecting... Attempt $attempt');
      try {
        await client.connect();
        if (isConnected) break;
      } catch (e) {
        print('Reconnect attempt $attempt failed: $e');
      }
      await Future.delayed(Duration(seconds: attempt * 2)); // Exponential backoff
    }
    if (!isConnected) {
      print('Max reconnect attempts reached. Unable to reconnect.');
    }
  }

  void _onMessageReceived(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final MqttReceivedMessage message in messages) {
      final MqttPublishMessage payload = message.payload as MqttPublishMessage;
      final String content =
      MqttPublishPayload.bytesToStringAsString(payload.payload.message);

      setState(() {
        switch (message.topic) {
          case "home/control/motor":
            motorState = content == 'on';
            break;
          case "home/control/servo":
            servoState = content == 'on';
            break;
          case "home/control/relay":
            relayState = content == 'on';
            break;
          case "home/control/led":
            ledState = content == 'on';
            break;
        }
      });
    }
  }

  Future<void> _sendSwitchState(String topic, bool value) async {
    if (!isConnected) {
      print('Client not connected. Retrying...');
      await _reconnect();
    }

    final message = value ? 'on' : 'off';
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    try {
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      print('Published $topic: $message');
    } catch (e) {
      print('Error publishing to $topic: $e');
    }
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Control Screen"),
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          _buildSwitchTile("Motor", motorState, "home/control/motor"),
          _buildSwitchTile("Servo", servoState, "home/control/servo"),
          _buildSwitchTile("Relay", relayState, "home/control/relay"),
          _buildSwitchTile("LED", ledState, "home/control/led"),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool state, String topic) {
    return ListTile(
      title: Text(state ? "$title ON" : "$title OFF"),
      leading: Switch(
        value: state,
        onChanged: (value) {
          setState(() {
            switch (topic) {
              case "home/control/motor":
                motorState = value;
                break;
              case "home/control/servo":
                servoState = value;
                break;
              case "home/control/relay":
                relayState = value;
                break;
              case "home/control/led":
                ledState = value;
                break;
            }
          });
          _sendSwitchState(topic, value);
        },
      ),
    );
  }
}
