import 'package:location/location.dart';

class SensorService {
  static final SensorService instance = SensorService._init();
  Location? _location;

  SensorService._init();

  Future<void> initialize() async {
    _location = Location();
  }

  Future<LocationData?> getCurrentLocation() async {
    if (_location == null) {
      throw Exception('Location service not initialized');
    }

    bool serviceEnabled;
    // Use the location package's permission handling
    serviceEnabled = await _location!.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location!.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    // Get the current location (location package handles permissions internally)
    return await _location!.getLocation();
  }

  Stream<LocationData> getLocationStream() {
    if (_location == null) {
      throw Exception('Location service not initialized');
    }
    return _location!.onLocationChanged;
  }
}
