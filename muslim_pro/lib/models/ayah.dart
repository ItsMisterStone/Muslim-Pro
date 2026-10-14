class Ayah {
  final int surahNumber;
  final int ayahNumber; // number within the surah
  final String textArabic;
  final String textEnglish;
  final int juz;
  final int page;

  Ayah({
    required this.surahNumber,
    required this.ayahNumber,
    required this.textArabic,
    required this.textEnglish,
    required this.juz,
    required this.page,
  });

  Map<String, dynamic> toMap() => {
        'surah_number': surahNumber,
        'ayah_number': ayahNumber,
        'text_arabic': textArabic,
        'text_english': textEnglish,
        'juz': juz,
        'page': page,
      };

  factory Ayah.fromMap(Map<String, dynamic> m) => Ayah(
        surahNumber: m['surah_number'] as int,
        ayahNumber: m['ayah_number'] as int,
        textArabic: m['text_arabic'] as String,
        textEnglish: m['text_english'] as String,
        juz: m['juz'] as int,
        page: m['page'] as int,
      );
}