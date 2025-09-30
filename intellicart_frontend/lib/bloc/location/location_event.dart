part of 'location_bloc.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object> get props => [];
}

class GetCurrentLocation extends LocationEvent {
  const GetCurrentLocation();
}

class StartLocationTracking extends LocationEvent {
  const StartLocationTracking();
}

class StopLocationTracking extends LocationEvent {
  const StopLocationTracking();
}