part of 'location_bloc.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

class LocationStateInitial extends LocationState {
  const LocationStateInitial();
}

class LocationStateLoading extends LocationState {
  const LocationStateLoading();
}

class LocationStateLoaded extends LocationState {
  final dynamic locationData;

  const LocationStateLoaded(this.locationData);

  @override
  List<Object> get props => [locationData];
}

class LocationStateTracking extends LocationState {
  const LocationStateTracking();
}

class LocationStateError extends LocationState {
  final String message;

  const LocationStateError(this.message);

  @override
  List<Object> get props => [message];
}
