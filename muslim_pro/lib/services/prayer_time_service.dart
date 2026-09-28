import 'package:adhan_dart/adhan_dart.dart';

class PrayerTimeService {
  /// Returns today's prayer times in order, converted to the phone's local time.
  Map<String, DateTime> getTodayTimes(double latitude, double longitude) {
    final coordinates = Coordinates(latitude, longitude);

    // Karachi method + Hanafi Asr is the common choice for Bangladesh
    final params = CalculationMethodParameters.karachi();
    params.madhab = Madhab.hanafi;

    final times = PrayerTimes(
      coordinates: coordinates,
      date: DateTime.now(),
      calculationParameters: params,
      precision: true,
    );

    // adhan_dart returns UTC, so convert each one to local time
    return {
      'Fajr': times.fajr.toLocal(),
      'Sunrise': times.sunrise.toLocal(),
      'Dhuhr': times.dhuhr.toLocal(),
      'Asr': times.asr.toLocal(),
      'Maghrib': times.maghrib.toLocal(),
      'Isha': times.isha.toLocal(),
    };
  }
}