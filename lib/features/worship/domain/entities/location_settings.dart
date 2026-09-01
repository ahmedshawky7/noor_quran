enum LocationMode { automatic, manual }

class LocationSettings {
  const LocationSettings({
    this.mode = LocationMode.automatic,
    this.manualLabel = 'الموقع اليدوي',
    this.manualLatitude = 30.0444,
    this.manualLongitude = 31.2357,
  });

  final LocationMode mode;
  final String manualLabel;
  final double manualLatitude;
  final double manualLongitude;

  LocationSettings copyWith({
    LocationMode? mode,
    String? manualLabel,
    double? manualLatitude,
    double? manualLongitude,
  }) {
    return LocationSettings(
      mode: mode ?? this.mode,
      manualLabel: manualLabel ?? this.manualLabel,
      manualLatitude: manualLatitude ?? this.manualLatitude,
      manualLongitude: manualLongitude ?? this.manualLongitude,
    );
  }
}
