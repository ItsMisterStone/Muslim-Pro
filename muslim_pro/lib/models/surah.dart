class Surah {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String meaning;
  final String revelationType; // Meccan or Medinan
  final int ayahCount;

  Surah({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.meaning,
    required this.revelationType,
    required this.ayahCount,
  });

  Map<String, dynamic> toMap() => {
        'number': number,
        'name_arabic': nameArabic,
        'name_english': nameEnglish,
        'meaning': meaning,
        'revelation_type': revelationType,
        'ayah_count': ayahCount,
      };

  factory Surah.fromMap(Map<String, dynamic> m) => Surah(
        number: m['number'] as int,
        nameArabic: m['name_arabic'] as String,
        nameEnglish: m['name_english'] as String,
        meaning: m['meaning'] as String,
        revelationType: m['revelation_type'] as String,
        ayahCount: m['ayah_count'] as int,
      );
}