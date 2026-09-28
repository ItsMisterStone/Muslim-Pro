// lib/models/athkar\_model.dart 
class Athkar {
     final String id;
      final String textArabic; 
      final String transliteration;
       final String translation;
        final int targetCount; 
        int currentCount;
 Athkar({ 
    required this.id,
     required this.textArabic, 
     required this.transliteration, 
     required this.translation, 
     required this.targetCount,
      this.currentCount = 0,
       });
  }