import 'dart:async';
import 'dart:convert';
import 'air_in_flight_team.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AirInFLightTeamData extends StatefulWidget {
  const AirInFLightTeamData({super.key});

  @override
  AirInFlightTeamDataState createState() => AirInFlightTeamDataState();
}

class AirInFlightTeamDataState extends State<AirInFLightTeamData>
    with TickerProviderStateMixin {
  Timer? timer;
  final StreamController<AirInFlightTeam> airInFlightController =
      StreamController<AirInFlightTeam>();

  Future<AirInFlightTeam> fetchAirInFlightData() async {
    final url = Uri.parse("http://192.168.43.172:8000/airInFlightData");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      print("Fetching Data Successfully");
      final data = AirInFlightTeam.fromJson(jsonDecode(response.body));
      airInFlightController.sink.add(data);
      return data;
    } else {
      Image.asset("assets/exceptions/server-disconnected.png");
      const Text("Failed to load data");
      print("Not connected. Couldn't establish connection");
    }

    final packageJson = json.decode(response.body) as Map<String, dynamic>;
    return AirInFlightTeam.fromJson(packageJson);
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 2), (timer) {
      fetchAirInFlightData();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    airInFlightController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent[200],
      appBar: AppBar(
        title: Text("Air In Flight Team"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: StreamBuilder<AirInFlightTeam>(
          stream: airInFlightController.stream,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final aifData = snapshot.data!;
            List<Map<String, String>> aifListData = [
              {
                'Longitude': '${aifData.aircraftPosition.longitude}',
                'Latitude': '${aifData.aircraftPosition.latitude}',
                'Altitude': '${aifData.aircraftPosition.altitude}',
                'Air Speed': '${aifData.altitudeAndAirspeed.airspeed}',
                'As Altitude': '${aifData.altitudeAndAirspeed.altitude}',
                'Alti-Meter': '${aifData.flightInstruments.altimeter}',
                'Altitude Indicator':
                    aifData.flightInstruments.attitudeIndicator,
                'Speed Indicator':
                    '${aifData.flightInstruments.speedIndicator}',
                'Vertical Speed Indicator':
                    '${aifData.flightInstruments.verticalSpeedIndicator}',
                'Engine 1 Thrust':
                    '${aifData.enginePerformance.performanceParameters.engine1Thrust}',
                'Engine 2 Thrust':
                    '${aifData.enginePerformance.performanceParameters.engine2Thrust}',
                'Fuel Efficiency':
                    '${aifData.enginePerformance.performanceParameters.fuelEfficiency}',
                'Engine 1 Status': aifData.enginePerformance.engine1Status,
                'Engine 2 Status': aifData.enginePerformance.engine2Status,
                'Communication Status':
                    aifData.cabinCrewCoordination.communicationStatus,
                'Emergency Training Status':
                    aifData.cabinCrewCoordination.emergencyTrainingStatus,
                'Emergency Protocols Response':
                    aifData.emergencyProtocols.response,
                'Emergency Protocols Status':
                    aifData.emergencyProtocols.status,
                'Current Level Fuel': '${aifData.fuelConsumption.currentLevel}',
                'Rate of Level Fuel':
                    '${aifData.fuelConsumption.rateOfConsumption}',
                'Current Waypoint':
                    aifData.navigationSystems.currentWaypoint,
                'GPS Status': aifData.navigationSystems.gpsStatus,
                'Cabin Pressure': '${aifData.passengerSafety.cabinPressure}',
                'Medical Emergency':
                    '${aifData.passengerSafety.medicalEmergencies}',
                'O2 Levels': '${aifData.passengerSafety.oxygenLevels}',
                'Cloud Cover': '${aifData.weatherConditions.cloudCover}',
                'Wind Speed': '${aifData.weatherConditions.windSpeed}',
                'Turbulence': aifData.weatherConditions.turbulence,
                'Total Weight': '${aifData.weightAndBalance.totalWeight}',
                'Cargo Distribution':
                    aifData.weightAndBalance.cargoDistribution
              },
            ];
            return ListView.builder(
              itemCount: aifListData.length,
              itemBuilder: (ctx, index) {
                final airInFlightTeam = aifListData[index];
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
                      itemCount: airInFlightTeam.length,
                      itemBuilder: (ctx, gridIndex) {
                        final data = airInFlightTeam.entries.toList()[gridIndex];
                        return Card(
                          surfaceTintColor: Color.fromARGB(244, 207, 184, 117),
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
