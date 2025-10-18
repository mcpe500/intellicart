import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intellicart_frontend/services/sensor_service.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc() : super(const LocationStateInitial()) {
    on<GetCurrentLocation>(_onGetCurrentLocation);
    on<StartLocationTracking>(_onStartLocationTracking);
    on<StopLocationTracking>(_onStopLocationTracking);
  }

  void _onGetCurrentLocation(GetCurrentLocation event, Emitter<LocationState> emit) async {
    emit(const LocationStateLoading());
    try {
      final locationData = await SensorService.instance.getCurrentLocation();
      if (locationData != null) {
        emit(LocationStateLoaded(locationData));
      } else {
        emit(const LocationStateError('Could not get location'));
      }
    } catch (e) {
      emit(LocationStateError(e.toString()));
    }
  }

  void _onStartLocationTracking(StartLocationTracking event, Emitter<LocationState> emit) async {
    emit(const LocationStateLoading());
    try {
      // TODO: Start location tracking
      await Future.delayed(const Duration(seconds: 1)); // Simulate setup
      emit(const LocationStateTracking());
    } catch (e) {
      emit(LocationStateError(e.toString()));
    }
  }

  void _onStopLocationTracking(StopLocationTracking event, Emitter<LocationState> emit) async {
    try {
      // TODO: Stop location tracking
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate cleanup
      emit(const LocationStateInitial());
    } catch (e) {
      emit(LocationStateError(e.toString()));
    }
  }
}
