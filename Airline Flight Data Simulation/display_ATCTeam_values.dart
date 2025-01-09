import 'dart:async';
import 'dart:convert';
import 'atc_team.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ATCTeamData extends StatefulWidget {
  const ATCTeamData({super.key});

  @override
  ATCTeamDataState createState() => ATCTeamDataState();
}

class ATCTeamDataState extends State<ATCTeamData>
    with TickerProviderStateMixin {
  Timer? timer;

  final StreamController<AtcTeam> atcStreamController =
  StreamController<AtcTeam>();

  Future<AtcTeam> fetchATCData() async {
    final url = Uri.parse("http://192.168.43.172:8000/atc_data");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      print("Fetching Data Successfully");
      final data = AtcTeam.fromJson(jsonDecode(response.body));
      atcStreamController.sink.add(data);
      return data;
    } else {
      Image.asset("assets/exceptions/server-disconnected.png");
      const Text("Failed to load data");
      print("Not connected. Couldn't establish connection");
    }

    final packageJson = json.decode(response.body) as Map<String, dynamic>;
    return AtcTeam.fromJson(packageJson);
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 2), (timer) {
      fetchATCData();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    atcStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent[200],
      appBar: AppBar(
        title: Text("ATC Team"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: StreamBuilder<AtcTeam>(
          stream: atcStreamController.stream,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final atcData = snapshot.data!;
            List<Map<String, String>> atcListData = [
              {
                'Flight Name':atcData.flightDetails.flight_name,
                'Flight Type':atcData.flightDetails.flightType,
                'Source':atcData.flightDetails.source,
                'Destination':atcData.flightDetails.destination,
                'Longitude': '${atcData.aircraftPosition.longitude}',
                'Latitude': '${atcData.aircraftPosition.latitude}',
                'Altitude': '${atcData.aircraftPosition.altitude}',
                'Air Speed': atcData.weatherConditions.turbulence,
                'Wind Speed':'${atcData.weatherConditions.windSpeed}',
                'Current Weather':atcData.weatherConditions.currentWeather,
                'Current Altitude':'${atcData.altitudeAndSpeed.currentAltitude}',
                'Current Speed':'${atcData.altitudeAndSpeed.currentSpeed}',
                'Current Route':atcData.flightPaths.currentRoute,
                'Next Way Point':atcData.flightPaths.nextWaypoint,
                'Landing Clearance':atcData.landingAndDepartureClearances.landingClearance,
                'Departure Clearance':atcData.landingAndDepartureClearances.departureClearance,
                'Horizontal Separation':'${atcData.separationAndSequencing.horizontalSeparation}',
                'Vertical Separation':'${atcData.separationAndSequencing.verticalSeparation}',
                'Alert Status':atcData.trafficConflictAlerts.alertStatus,
                'Is Resolved Conflicts':atcData.trafficConflictAlerts.resolved,
              },
            ];
            return ListView.builder(
              itemCount: atcListData.length,
              itemBuilder: (ctx, index) {
                final atcData = atcListData[index];
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
                      itemCount: atcData.entries.length,
                      itemBuilder: (ctx, gridIndex) {
                        final data = atcData.entries.toList()[gridIndex];
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
