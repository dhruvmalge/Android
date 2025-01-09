import 'dart:async';
import 'dart:convert';
import 'ground_team.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GroundTeamData extends StatefulWidget {
  const GroundTeamData({super.key});

  @override
  GroundTeamDataState createState() => GroundTeamDataState();
}

class GroundTeamDataState extends State<GroundTeamData>
    with TickerProviderStateMixin {
  Timer? timer;
  final StreamController<GroundTeam> groundTeamController =
  StreamController<GroundTeam>();

  Future<GroundTeam> fetchGroundData() async {
    final url = Uri.parse("http://192.168.43.172:8000/ground_team_data");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      print("Fetching Data Successfully");
      final data = GroundTeam.fromJson(jsonDecode(response.body));
      groundTeamController.sink.add(data);
      return data;
    } else {
      Image.asset("assets/exceptions/server-disconnected.png");
      const Text("Failed to load data");
      print("Not connected. Couldn't establish connection");
    }

    final packageJson = json.decode(response.body) as Map<String, dynamic>;
    return GroundTeam.fromJson(packageJson);
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 2), (timer) {
      fetchGroundData();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    groundTeamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent[200],
      appBar: AppBar(
        title: Text("Ground Team"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: StreamBuilder<GroundTeam>(
          stream: groundTeamController.stream,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final gtData = snapshot.data!;
            List<Map<String, String>> gtListData = [
              {
                'Longitude': '${gtData.aircraftPosition.longitude}',
                'Latitude': '${gtData.aircraftPosition.latitude}',
                'Altitude': '${gtData.aircraftPosition.altitude}',
                'Cleaning Trucks':'${gtData.groundSupportVehicles.cleaningTrucks}',
                'Fuel Trucks':'${gtData.groundSupportVehicles.fuelTrucks}',
                'Baggage Vehicles':'${gtData.groundSupportVehicles.baggageVehicles}',
                'Catering Trucks':'${gtData.groundSupportVehicles.cateringTrucks}',
                'Available Tugs':'${gtData.groundSupportVehicles.availableTugs}',
                'Passenger Counts':'${gtData.passengerBoarding.passengerCount}',
                'Passenger Boarding Status':gtData.passengerBoarding.status,
                'Maintenance Check Type':gtData.aircraftMaintenance.checkType,
                'Maintenance Status':gtData.aircraftMaintenance.status,
                'Total Cargo Weight':'${gtData.baggageCargoLoading.totalWeight}',
                'Total Cargo Distribute':gtData.baggageCargoLoading.cargoDistribution,
                'Fuel Type':gtData.refuelling.fuelType,
                'Fuel Level':'${gtData.refuelling.fuelLevel}',
                'Refuelling Status':gtData.refuelling.status,
                'Current Taxi Way':gtData.taxiRoutes.currentTaxiway,
                'Next Runway':gtData.taxiRoutes.nextRunway
              },
            ];
            return ListView.builder(
              itemCount: gtListData.length,
              itemBuilder: (ctx, index) {
                final groundTeam = gtListData[index];
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
                      itemCount: groundTeam.length,
                      itemBuilder: (ctx, gridIndex) {
                        final data = groundTeam.entries.toList()[gridIndex];
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
