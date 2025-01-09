import 'dart:async';
import 'dart:convert';
import 'environment status.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EnvironmentData extends StatefulWidget {
  const EnvironmentData({super.key});

  @override
  EnvironmentDataState createState() => EnvironmentDataState();
}

class EnvironmentDataState extends State<EnvironmentData>
    with TickerProviderStateMixin {
  Timer? timer;
  final StreamController<EnvironmentalData> envStreamController =
  StreamController<EnvironmentalData>();

  Future<EnvironmentalData> fetchEnvironmentData() async {
    final url = Uri.parse("http://192.168.43.172:8000/environment_data");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      print("Fetching Data Successfully");
      final data = EnvironmentalData.fromJson(jsonDecode(response.body));
      envStreamController.sink.add(data);
      return data;
    } else {
      Image.asset("assets/exceptions/server-disconnected.png");
      const Text("Failed to load data");
      print("Not connected. Couldn't establish connection");
    }

    final packageJson = json.decode(response.body) as Map<String, dynamic>;
    return EnvironmentalData.fromJson(packageJson);
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 2), (timer) {
      fetchEnvironmentData();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    envStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent[200],
      appBar: AppBar(
        title: Text("Environment Data"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: StreamBuilder<EnvironmentalData>(
          stream: envStreamController.stream,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final envData = snapshot.data!;
            List<Map<String, String>> envListData = [
              {
                'Temperature':'${envData.temperature}',
                'Humidity':'${envData.humidity}',
                'Pressure':'${envData.pressure}',
                'Cloud Cover':'${envData.cloudCover}',
                'Wind Speed':'${envData.windSpeed}',
                'Precipitation':'${envData.precipitation}',
                'Dew Point':'${envData.dewPoint}',
                'Visibility':'${envData.visibility}',
              },
            ];
            return ListView.builder(
              itemCount: envListData.length,
              itemBuilder: (ctx, index) {
                final env = envListData[index];
                return InkWell(
                  focusNode: FocusNode(canRequestFocus: true),
                  splashFactory: InkSplash.splashFactory,
                  onTap: () {
                    Ink(color: Theme.of(context).colorScheme.onPrimaryContainer,);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: env.length,
                      itemBuilder: (ctx, gridIndex) {
                        final data = env.entries.toList()[gridIndex];
                        return Card(
                          color: Color.fromARGB(126, 149, 235, 244),
                          margin: EdgeInsets.all(5),
                          elevation: 5,
                          child: ListTile(
                            title: Text(data.key),
                            subtitle: Text(data.value),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
