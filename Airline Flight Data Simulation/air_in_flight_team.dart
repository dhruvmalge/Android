class AirInFlightTeam {
  final AircraftPosition aircraftPosition;
  final AltitudeAndAirspeed altitudeAndAirspeed;
  final FuelConsumption fuelConsumption;
  final WeightAndBalance weightAndBalance;
  final EnginePerformance enginePerformance;
  final NavigationSystems navigationSystems;
  final WeatherConditions weatherConditions;
  final FlightInstruments flightInstruments;
  final EmergencyProtocols emergencyProtocols;
  final PassengerSafety passengerSafety;
  final CabinCrewCoordination cabinCrewCoordination;

  AirInFlightTeam({
    required this.aircraftPosition,
    required this.altitudeAndAirspeed,
    required this.fuelConsumption,
    required this.weightAndBalance,
    required this.enginePerformance,
    required this.navigationSystems,
    required this.weatherConditions,
    required this.flightInstruments,
    required this.emergencyProtocols,
    required this.passengerSafety,
    required this.cabinCrewCoordination,
  });

  factory AirInFlightTeam.fromJson(Map<String, dynamic> json) {
    return AirInFlightTeam(
      aircraftPosition: AircraftPosition.fromJson(json['aircraft_position']),
      altitudeAndAirspeed: AltitudeAndAirspeed.fromJson(json['altitude_and_airspeed']),
      fuelConsumption: FuelConsumption.fromJson(json['fuel_consumption']),
      weightAndBalance: WeightAndBalance.fromJson(json['weight_and_balance']),
      enginePerformance: EnginePerformance.fromJson(json['engine_performance']),
      navigationSystems: NavigationSystems.fromJson(json['navigation_systems']),
      weatherConditions: WeatherConditions.fromJson(json['weather_conditions']),
      flightInstruments: FlightInstruments.fromJson(json['flight_instruments']),
      emergencyProtocols: EmergencyProtocols.fromJson(json['emergency_protocols']),
      passengerSafety: PassengerSafety.fromJson(json['passenger_safety']),
      cabinCrewCoordination: CabinCrewCoordination.fromJson(json['cabin_crew_coordination']),
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

class AltitudeAndAirspeed {
  final double altitude;
  final double airspeed;

  AltitudeAndAirspeed({
    required this.altitude,
    required this.airspeed,
  });

  factory AltitudeAndAirspeed.fromJson(Map<String, dynamic> json) {
    return AltitudeAndAirspeed(
      altitude: json['altitude'],
      airspeed: json['airspeed'],
    );
  }
}

class FuelConsumption {
  final double currentLevel;
  final double rateOfConsumption;

  FuelConsumption({
    required this.currentLevel,
    required this.rateOfConsumption,
  });

  factory FuelConsumption.fromJson(Map<String, dynamic> json) {
    return FuelConsumption(
      currentLevel: json['current_level'],
      rateOfConsumption: json['rate_of_consumption'],
    );
  }
}

class WeightAndBalance {
  final double totalWeight;
  final String cargoDistribution;

  WeightAndBalance({
    required this.totalWeight,
    required this.cargoDistribution,
  });

  factory WeightAndBalance.fromJson(Map<String, dynamic> json) {
    return WeightAndBalance(
      totalWeight: json['total_weight'],
      cargoDistribution: json['cargo_distribution'],
    );
  }
}

class EnginePerformance {
  final String engine1Status;
  final String engine2Status;
  final PerformanceParameters performanceParameters;

  EnginePerformance({
    required this.engine1Status,
    required this.engine2Status,
    required this.performanceParameters,
  });

  factory EnginePerformance.fromJson(Map<String, dynamic> json) {
    return EnginePerformance(
      engine1Status: json['engine_1_status'],
      engine2Status: json['engine_2_status'],
      performanceParameters: PerformanceParameters.fromJson(json['performance_parameters']),
    );
  }
}

class PerformanceParameters {
  final double engine1Thrust;
  final double engine2Thrust;
  final double fuelEfficiency;

  PerformanceParameters({
    required this.engine1Thrust,
    required this.engine2Thrust,
    required this.fuelEfficiency,
  });

  factory PerformanceParameters.fromJson(Map<String, dynamic> json) {
    return PerformanceParameters(
      engine1Thrust: json['engine_1_thrust'],
      engine2Thrust: json['engine_2_thrust'],
      fuelEfficiency: json['fuel_efficiency'],
    );
  }
}

class NavigationSystems {
  final String gpsStatus;
  final String currentWaypoint;

  NavigationSystems({
    required this.gpsStatus,
    required this.currentWaypoint,
  });

  factory NavigationSystems.fromJson(Map<String, dynamic> json) {
    return NavigationSystems(
      gpsStatus: json['gps_status'],
      currentWaypoint: json['current_waypoint'],
    );
  }
}

class WeatherConditions {
  final String turbulence;
  final double windSpeed;
  final double cloudCover;

  WeatherConditions({
    required this.turbulence,
    required this.windSpeed,
    required this.cloudCover,
  });

  factory WeatherConditions.fromJson(Map<String, dynamic> json) {
    return WeatherConditions(
      turbulence: json['turbulence'],
      windSpeed: json['wind_speed'],
      cloudCover: json['cloud_cover'],
    );
  }
}

class FlightInstruments {
  final double altimeter;
  final String attitudeIndicator;
  final double speedIndicator;
  final double verticalSpeedIndicator;

  FlightInstruments({
    required this.altimeter,
    required this.attitudeIndicator,
    required this.speedIndicator,
    required this.verticalSpeedIndicator,
  });

  factory FlightInstruments.fromJson(Map<String, dynamic> json) {
    return FlightInstruments(
      altimeter: json['altimeter'],
      attitudeIndicator: json['attitude_indicator'],
      speedIndicator: json['speed_indicator'],
      verticalSpeedIndicator: json['vertical_speed_indicator'],
    );
  }
}

class EmergencyProtocols {
  final String status;
  final String response;

  EmergencyProtocols({
    required this.status,
    required this.response,
  });

  factory EmergencyProtocols.fromJson(Map<String, dynamic> json) {
    return EmergencyProtocols(
      status: json['status'],
      response: json['response'],
    );
  }
}

class PassengerSafety {
  final double cabinPressure;
  final double oxygenLevels;
  final bool medicalEmergencies;

  PassengerSafety({
    required this.cabinPressure,
    required this.oxygenLevels,
    required this.medicalEmergencies,
  });

  factory PassengerSafety.fromJson(Map<String, dynamic> json) {
    return PassengerSafety(
      cabinPressure: json['cabin_pressure'],
      oxygenLevels: json['oxygen_levels'],
      medicalEmergencies: json['medical_emergencies'],
    );
  }
}

class CabinCrewCoordination {
  final String communicationStatus;
  final String emergencyTrainingStatus;

  CabinCrewCoordination({
    required this.communicationStatus,
    required this.emergencyTrainingStatus,
  });

  factory CabinCrewCoordination.fromJson(Map<String, dynamic> json) {
    return CabinCrewCoordination(
      communicationStatus: json['communication_status'],
      emergencyTrainingStatus: json['emergency_training_status'],
    );
  }
}
