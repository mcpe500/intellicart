// lib/presentation/bloc/app_mode_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intellicart_frontend/data/repositories/app_repository.dart';
import 'package:intellicart_frontend/data/repositories/app_repository_impl.dart';

// --- ENUM for Modes ---
enum AppMode { buyer, seller }

// --- EVENTS ---
abstract class AppModeEvent extends Equatable {
  const AppModeEvent();
  @override
  List<Object> get props => [];
}

class SetAppMode extends AppModeEvent {
  final AppMode mode;
  const SetAppMode(this.mode);
  @override
  List<Object> get props => [mode];
}

class LoadAppMode extends AppModeEvent {}


// --- STATE ---
class AppModeState extends Equatable {
  final AppMode mode;
  const AppModeState(this.mode);

  @override
  List<Object> get props => [mode];
}

// --- BLOC ---
class AppModeBloc extends Bloc<AppModeEvent, AppModeState> {
  final AppRepository _repository;

  AppModeBloc({AppRepository? repository}) 
      : _repository = repository ?? AppRepositoryImpl(),
        super(const AppModeState(AppMode.buyer)) {
    on<LoadAppMode>(_onLoadAppMode);
    on<SetAppMode>(_onSetAppMode);
  }

  Future<void> _onLoadAppMode(
    LoadAppMode event,
    Emitter<AppModeState> emit,
  ) async {
    final modeString = await _repository.getAppMode();
    final mode = modeString == 'seller' ? AppMode.seller : AppMode.buyer;
    emit(AppModeState(mode));
  }

  Future<void> _onSetAppMode(
    SetAppMode event,
    Emitter<AppModeState> emit,
  ) async {
    final modeString = event.mode == AppMode.seller ? 'seller' : 'buyer';
    await _repository.setAppMode(modeString);
    emit(AppModeState(event.mode));
  }
}