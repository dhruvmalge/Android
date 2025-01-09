import 'package:flutter/material.dart';
import 'display_AirInFlightTeam_values.dart';
import 'display_ATCTeam_values.dart';
import 'display_GroundTeam_values.dart';
import 'display_EnvironmentStatus_values.dart';

class DisplayData extends StatefulWidget {
  const DisplayData({super.key});

  @override
  DisplayDataState createState() => DisplayDataState();
}

class DisplayDataState extends State<DisplayData>{

  PageController pageController = PageController();
  int currentIndex = 0;

  void _onPageChanged(int index) {
    setState(() {
      currentIndex = index; // Update the BottomNavigationBar's selected index
    });
  }

  @override
  void dispose(){
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: PageView(
        controller: pageController,
        children: [
          AirInFLightTeamData(),
          ATCTeamData(),
          GroundTeamData(),
          EnvironmentData(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageController.initialPage.toInt(),
        type: BottomNavigationBarType.shifting,
        onTap: (index){
          pageController.jumpToPage(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.flight_takeoff),
            backgroundColor: Color.fromARGB(194, 239, 131, 156),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.airplane_ticket),
            backgroundColor: Color.fromARGB(194, 239, 131, 156),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_airport),
            backgroundColor: Color.fromARGB(194, 239, 131, 156),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.thermostat),
            backgroundColor: Color.fromARGB(194, 239, 131, 156),
            label: "",
          ),
        ],
      ),
    );
  }
}