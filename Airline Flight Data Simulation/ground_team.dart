class GroundTeam {
  final AircraftPosition aircraftPosition;
  final TaxiRoutes taxiRoutes;
  final Refuelling refuelling;
  final BaggageCargoLoading baggageCargoLoading;
  final AircraftMaintenance aircraftMaintenance;
  final PassengerBoarding passengerBoarding;
  final GroundSupportVehicles groundSupportVehicles;

  GroundTeam({
    required this.aircraftPosition,
    required this.taxiRoutes,
    required this.refuelling,
    required this.baggageCargoLoading,
    required this.aircraftMaintenance,
    required this.passengerBoarding,
    required this.groundSupportVehicles,
  });

  factory GroundTeam.fromJson(Map<String, dynamic> json) {
    return GroundTeam(
      aircraftPosition: AircraftPosition.fromJson(json['aircraft_position']),
      taxiRoutes: TaxiRoutes.fromJson(json['taxi_routes']),
      refuelling: Refuelling.fromJson(json['refueling']),
      baggageCargoLoading: BaggageCargoLoading.fromJson(json['baggage_cargo_loading']),
      aircraftMaintenance: AircraftMaintenance.fromJson(json['aircraft_maintenance']),
      passengerBoarding: PassengerBoarding.fromJson(json['passenger_boarding']),
      groundSupportVehicles: GroundSupportVehicles.fromJson(json['ground_support_vehicles']),
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

class TaxiRoutes {
  final String currentTaxiway;
  final String nextRunway;

  TaxiRoutes({
    required this.currentTaxiway,
    required this.nextRunway,
  });

  factory TaxiRoutes.fromJson(Map<String, dynamic> json) {
    return TaxiRoutes(
        currentTaxiway: json['current_taxiway'], nextRunway: json['next_runway']);
  }
}

class Refuelling {
  final String status;
  final String fuelType;
  final double fuelLevel;

  Refuelling({
    required this.status,
    required this.fuelLevel,
    required this.fuelType,
  });

  factory Refuelling.fromJson(Map<String, dynamic> json) {
    return Refuelling(
        status: json['status'],
        fuelLevel: json['fuel_level'],
        fuelType: json['fuel_type']);
  }
}

class BaggageCargoLoading {
  final double totalWeight;
  final String cargoDistribution;

  BaggageCargoLoading({
    required this.totalWeight,
    required this.cargoDistribution,
  });

  factory BaggageCargoLoading.fromJson(Map<String, dynamic> json) {
    return BaggageCargoLoading(
        totalWeight: json['total_weight'],
        cargoDistribution: json['cargo_distribution']);
  }
}

class AircraftMaintenance {
  final String status;
  final String checkType;

  AircraftMaintenance({
    required this.status,
    required this.checkType,
  });

  factory AircraftMaintenance.fromJson(Map<String, dynamic> json) {
    return AircraftMaintenance(
        status: json['status'], checkType: json['check_type']);
  }
}

class PassengerBoarding {
  final String status;
  final int passengerCount;

  PassengerBoarding({
    required this.status,
    required this.passengerCount,
  });

  factory PassengerBoarding.fromJson(Map<String, dynamic> json) {
    return PassengerBoarding(
        status: json['status'], passengerCount: json['passenger_count']);
  }
}

class GroundSupportVehicles {
  final int availableTugs;
  final int cateringTrucks;
  final int baggageVehicles;
  final int fuelTrucks;
  final int cleaningTrucks;

  GroundSupportVehicles({
    required this.availableTugs,
    required this.cateringTrucks,
    required this.baggageVehicles,
    required this.fuelTrucks,
    required this.cleaningTrucks,
  });

  factory GroundSupportVehicles.fromJson(Map<String, dynamic> json) {
    return GroundSupportVehicles(
      availableTugs: json['available_tugs'],
      cateringTrucks: json['catering_trucks'],
      baggageVehicles: json['baggage_vehicles'],
      fuelTrucks: json['fuel_trucks'],
      cleaningTrucks: json['cleaning_trucks'],
    );
  }
}
