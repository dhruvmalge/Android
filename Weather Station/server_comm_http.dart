import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherDisplay extends StatefulWidget {
  const WeatherDisplay({super.key});

  @override
  _WeatherDisplayState createState() => _WeatherDisplayState();
}

class Weather {
  final double temperature;
  final double humidity;
  final double pressure;
  final int windSpeed;
  final int precipitation;
  final int visibility;
  final int dewPoint;
  final int cloudCover;

  Weather({
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.precipitation,
    required this.visibility,
    required this.dewPoint,
    required this.cloudCover,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
        temperature: json['temperature'],
        humidity: json['humidity'],
        pressure: json['pressure'],
        windSpeed: json['wind speed'],
        precipitation: json['precipitation'],
        visibility: json['visibility'],
        dewPoint: json['dew point'],
        cloudCover: json['cloud cover']);
  }
}

class _WeatherDisplayState extends State<WeatherDisplay>
    with TickerProviderStateMixin {
  late Future<Weather> weatherData;
  final StreamController<Weather> _weatherStreamController =
      StreamController<Weather>();
  Timer? _timer;
  late bool showError;
  bool isRefreshed = false;

  final Shader _linearShader = const LinearGradient(
    colors: [Colors.cyan, Colors.yellow, Colors.purple, Colors.orange],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  ).createShader(const Rect.fromLTWH(0, 0, 320, 80));

  late PageController pageViewController;
  late TabController tabController;
  int currentPageIndex = 0;

  Future<Weather> fetchWeather() async {
    final url = Uri.parse("http://192.168.43.172:8000/data");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = Weather.fromJson(json.decode(response.body));
      _weatherStreamController.sink.add(data);
      return data;
    } else {
      Image.asset("assets/exceptions/server-disconnected.png");
      const Text("Failed to load data");
      _weatherStreamController.sink.addError("Failed to Load Data");
    }

    final packageJson = json.decode(response.body) as Map<String, dynamic>;
    return Weather.fromJson(packageJson);
  }

  @override
  void initState() {
    super.initState();
    pageViewController = PageController();
    tabController =
        TabController(length: currentPageIndex.bitLength, vsync: this);
    fetchWeather();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      fetchWeather();
    });
  }

  void refreshData() {
    setState(() {
      isRefreshed = true;
      fetchWeather();
    });

    Future.delayed(const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _timer?.cancel();
    pageViewController.dispose();
    tabController.dispose();
    _weatherStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Weather>(
      stream: _weatherStreamController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/exceptions/disconnected.png",
                height: 50,
                width: 50,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text("Error loading data..."),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: (){
                    setState(() {
                      fetchWeather();
                      const CircularProgressIndicator();
                    });
                  }, child: const Text("Refresh"))
            ],
          ));
        }
        if (snapshot.hasData) {
          final weather = snapshot.data!;
          List<Map<String, String>> weatherData = [
            {
              'title': 'Temperature',
              'value': '${weather.temperature}°C',
              'imagePath': 'assets/weather/temperature.png',
            },
            {
              'title': 'Humidity',
              'value': '${weather.humidity} %',
              'imagePath': 'assets/weather/humidity.png',
            },
            {
              'title': 'Pressure',
              'value': '${weather.pressure} hPa',
              'imagePath': 'assets/weather/pressure.png',
            },
            {
              'title': 'Wind Speed',
              'value': '${weather.windSpeed} km/h',
              'imagePath': 'assets/weather/windspeed.png',
            },
            {
              'title': 'Precipitation',
              'value': '${weather.precipitation} mm',
              'imagePath': 'assets/weather/precipitation.png',
            },
            {
              'title': 'Visibility',
              'value': '${weather.visibility} km',
              'imagePath': 'assets/weather/visibility.png',
            },
            {
              'title': 'Dew Point',
              'value': '${weather.dewPoint}°C',
              'imagePath': 'assets/weather/dew point.png',
            },
            {
              'title': 'Cloud Cover',
              'value': '${weather.cloudCover} %',
              'imagePath': 'assets/weather/cloudcover.png',
            },
          ];
          return Stack(
            children: <Widget>[
              RefreshIndicator(
                onRefresh: () async {refreshData();},
                child: PageView(
                  children: [
                    GridView(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      children: [
                        for (var item in weatherData)
                          PageViewContentGrid(
                            title: item['title'] ?? "No data",
                            value: item['value'] ?? "No Data",
                            imagePath: item['imagePath'] ?? "No data",
                          ),
                      ],
                    ),
                    SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Summary",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                              foreground: Paint()..shader = _linearShader,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          for (var item in weatherData)
                            PageViewContent(
                              title: item['title'] ?? "No data",
                              value: item['value'] ?? "No Data",
                              imagePath: item['imagePath'] ?? "No data",
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (isRefreshed)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.white.withOpacity(0.2),
                    child: const CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        }
        return const Center(child: Text("No data available"));
      },
    );
  }
}

class PageViewContent extends StatelessWidget {
  final String title;
  final String value;
  final String imagePath;

  const PageViewContent(
      {super.key,
      required this.title,
      required this.value,
      required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 200,
            width: 200,
            alignment: Alignment.centerRight,
          ),
          const SizedBox(height: 25),
          Text(title, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class PageViewContentGrid extends StatelessWidget {
  final String title;
  final String value;
  final String imagePath;

  const PageViewContentGrid(
      {super.key,
      required this.title,
      required this.value,
      required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 90,
            width: 90,
            alignment: Alignment.centerRight,
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 10)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 10)),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
