class Masjid {
  final int? id;
  final String name;
  final String area;

  // Minutes after Waqt starts when this specific Masjid calls Adhan
  final int fajrAdhanOffset;
  final int dhuhrAdhanOffset;
  final int asrAdhanOffset;
  final int maghribAdhanOffset;
  final int ishaAdhanOffset;

  // Minutes after this Masjid's Adhan when Jamaat starts
  final int fajrJamaatDelay;
  final int dhuhrJamaatDelay;
  final int asrJamaatDelay;
  final int maghribJamaatDelay;
  final int ishaJamaatDelay;

  Masjid({
    this.id,
    required this.name,
    required this.area,
    required this.fajrAdhanOffset,
    required this.dhuhrAdhanOffset,
    required this.asrAdhanOffset,
    required this.maghribAdhanOffset,
    required this.ishaAdhanOffset,
    required this.fajrJamaatDelay,
    required this.dhuhrJamaatDelay,
    required this.asrJamaatDelay,
    required this.maghribJamaatDelay,
    required this.ishaJamaatDelay,
  });

  // Helper to get Adhan time for a specific prayer at this Masjid
  DateTime getAdhanTime(String prayer, DateTime baseWaqtTime) {
    switch (prayer) {
      case 'Fajr':
        return baseWaqtTime.add(Duration(minutes: fajrAdhanOffset));
      case 'Dhuhr':
        return baseWaqtTime.add(Duration(minutes: dhuhrAdhanOffset));
      case 'Asr':
        return baseWaqtTime.add(Duration(minutes: asrAdhanOffset));
      case 'Maghrib':
        return baseWaqtTime.add(Duration(minutes: maghribAdhanOffset));
      case 'Isha':
        return baseWaqtTime.add(Duration(minutes: ishaAdhanOffset));
      default:
        return baseWaqtTime;
    }
  }

  // Helper to get Jamaat time for a specific prayer at this Masjid
  DateTime getJamaatTime(String prayer, DateTime baseWaqtTime) {
    final adhanTime = getAdhanTime(prayer, baseWaqtTime);
    switch (prayer) {
      case 'Fajr':
        return adhanTime.add(Duration(minutes: fajrJamaatDelay));
      case 'Dhuhr':
        return adhanTime.add(Duration(minutes: dhuhrJamaatDelay));
      case 'Asr':
        return adhanTime.add(Duration(minutes: asrJamaatDelay));
      case 'Maghrib':
        return adhanTime.add(Duration(minutes: maghribJamaatDelay));
      case 'Isha':
        return adhanTime.add(Duration(minutes: ishaJamaatDelay));
      default:
        return adhanTime.add(const Duration(minutes: 15));
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'area': area,
      'fajr_adhan': fajrAdhanOffset,
      'dhuhr_adhan': dhuhrAdhanOffset,
      'asr_adhan': asrAdhanOffset,
      'maghrib_adhan': maghribAdhanOffset,
      'isha_adhan': ishaAdhanOffset,
      'fajr_jamaat': fajrJamaatDelay,
      'dhuhr_jamaat': dhuhrJamaatDelay,
      'asr_jamaat': asrJamaatDelay,
      'maghrib_jamaat': maghribJamaatDelay,
      'isha_jamaat': ishaJamaatDelay,
    };
  }

  factory Masjid.fromMap(Map<String, dynamic> map) {
    return Masjid(
      id: map['id'] as int?,
      name: map['name'] as String,
      area: map['area'] as String,
      fajrAdhanOffset: map['fajr_adhan'] as int,
      dhuhrAdhanOffset: map['dhuhr_adhan'] as int,
      asrAdhanOffset: map['asr_adhan'] as int,
      maghribAdhanOffset: map['maghrib_adhan'] as int,
      ishaAdhanOffset: map['isha_adhan'] as int,
      fajrJamaatDelay: map['fajr_jamaat'] as int,
      dhuhrJamaatDelay: map['dhuhr_jamaat'] as int,
      asrJamaatDelay: map['asr_jamaat'] as int,
      maghribJamaatDelay: map['maghrib_jamaat'] as int,
      ishaJamaatDelay: map['isha_jamaat'] as int,
    );
  }
}