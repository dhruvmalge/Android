class AtcTeam {
  final AircraftPosition aircraftPosition;
  final FlightPaths flightPaths;
  final SeparationAndSequencing separationAndSequencing;
  final AltitudeAndSpeed altitudeAndSpeed;
  final WeatherConditions weatherConditions;
  final TrafficConflictAlerts trafficConflictAlerts;
  final LandingAndDepartureClearances landingAndDepartureClearances;
  final FlightDetails flightDetails;

  AtcTeam({
    required this.flightDetails,
    required this.aircraftPosition,
    required this.flightPaths,
    required this.separationAndSequencing,
    required this.altitudeAndSpeed,
    required this.weatherConditions,
    required this.trafficConflictAlerts,
    required this.landingAndDepartureClearances,
  });

  factory AtcTeam.fromJson(Map<String, dynamic> json) {
    return AtcTeam(
      flightDetails: FlightDetails.fromJson(json['flight_details']),
      aircraftPosition: AircraftPosition.fromJson(json['aircraft_position']),
      flightPaths: FlightPaths.fromJson(json['flight_paths']),
      separationAndSequencing: SeparationAndSequencing.fromJson(json['separation_and_sequencing']),
      altitudeAndSpeed: AltitudeAndSpeed.fromJson(json['altitude_and_speed']),
      weatherConditions: WeatherConditions.fromJson(json['weather_conditions']),
      trafficConflictAlerts: TrafficConflictAlerts.fromJson(json['traffic_conflict_alerts']),
      landingAndDepartureClearances: LandingAndDepartureClearances.fromJson(json['landing_and_departure_clearances']),
    );
  }
}

class AircraftPosition {
  final double latitude;
  final double longitude;
  final double altitude;

  AircraftPosition({
    required this.latitude,
    required this.longitude,
    required this.altitude,
  });

  factory AircraftPosition.fromJson(Map<String, dynamic> json) {
    return AircraftPosition(
      latitude: json['latitude'],
      longitude: json['longitude'],
      altitude: json['altitude'],
    );
  }
}

class FlightPaths {
  final String currentRoute;
  final String nextWaypoint;

  FlightPaths({
    required this.currentRoute,
    required this.nextWaypoint,
  });

  factory FlightPaths.fromJson(Map<String, dynamic> json) {
    return FlightPaths(
      currentRoute: json['current_route'],
      nextWaypoint: json['next_waypoint'],
    );
  }
}

class SeparationAndSequencing {
  final double horizontalSeparation;
  final double verticalSeparation;

  SeparationAndSequencing({
    required this.horizontalSeparation,
    required this.verticalSeparation,
  });

  factory SeparationAndSequencing.fromJson(Map<String, dynamic> json) {
    return SeparationAndSequencing(
      horizontalSeparation: json['horizontal_separation'],
      verticalSeparation: json['vertical_separation'],
    );
  }
}

class AltitudeAndSpeed {
  final double currentAltitude;
  final double currentSpeed;

  AltitudeAndSpeed({
    required this.currentAltitude,
    required this.currentSpeed,
  });

  factory AltitudeAndSpeed.fromJson(Map<String, dynamic> json) {
    return AltitudeAndSpeed(
      currentAltitude: json['current_altitude'],
      currentSpeed: json['current_speed'],
    );
  }
}

class WeatherConditions {
  final String currentWeather;
  final double windSpeed;
  final String turbulence;

  WeatherConditions({
    required this.currentWeather,
    required this.windSpeed,
    required this.turbulence,
  });

  factory WeatherConditions.fromJson(Map<String, dynamic> json) {
    return WeatherConditions(
      currentWeather: json['current_weather'],
      windSpeed: json['wind_speed'],
      turbulence: json['turbulence'],
    );
  }
}

class TrafficConflictAlerts {
  final String alertStatus;
  final String resolved;

  TrafficConflictAlerts({
    required this.alertStatus,
    required this.resolved,
  });

  factory TrafficConflictAlerts.fromJson(Map<String, dynamic> json) {
    return TrafficConflictAlerts(
      alertStatus: json['alert_status'],
      resolved: json['resolved'],
    );
  }
}

class LandingAndDepartureClearances {
  final String departureClearance;
  final String landingClearance;

  LandingAndDepartureClearances({
    required this.departureClearance,
    required this.landingClearance,
  });

  factory LandingAndDepartureClearances.fromJson(Map<String, dynamic> json) {
    return LandingAndDepartureClearances(
      departureClearance: json['departure_clearance'],
      landingClearance: json['landing_clearance'],
    );
  }
}

class FlightDetails {
  final String source;
  final String destination;
  final String flight_name;
  final String flightType;

  FlightDetails({
    required this.source,
    required this.destination,
    required this.flight_name,
    required this.flightType,
  });

  factory FlightDetails.fromJson(Map<String, dynamic> json) {
    return FlightDetails(
        source: json['source'],
        destination: json['destination'],
        flight_name: json['flight_name'],
        flightType: json['flight_type'],
    );
  }
}