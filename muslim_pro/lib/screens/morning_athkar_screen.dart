import 'package:flutter/material.dart';
import '../models/athkar_model.dart';

class MorningAthkarScreen extends StatefulWidget {
  const MorningAthkarScreen({Key? key}) : super(key: key);

  @override
  State<MorningAthkarScreen> createState() => _MorningAthkarScreenState();
}

class _MorningAthkarScreenState extends State<MorningAthkarScreen> {
  final List<Athkar> _morningAthkarList = [
    Athkar(
      id: '1',
      textArabic: '''أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ''',
      transliteration: "Asbahna wa asbahal-mulku lillah, walhamdu lillah",
      translation: 'We have entered a new day and with it all sovereignty belongs to Allah, praise be to Allah.',
      targetCount: 1,
    ),
    Athkar(
      id: '2',
      textArabic: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
      transliteration: "Subhanallahi wa bihamdihi",
      translation: 'Glory is to Allah and praise is to Him.',
      targetCount: 100,
    ),
    Athkar(
      id: '3',
      textArabic: '''ٱللَّهُ لَآ إِلَـٰهَ إِلَّا هُوَ ٱلْحَىُّ ٱلْقَيُّومُ ۚ
لَا تَأْخُذُهُۥ سِنَةٌ وَلَا نَوْمٌ ۚ
لَّهُۥ مَا فِى ٱلسَّمَـٰوَٰتِ وَمَا فِى ٱلْأَرْضِ ۗ
مَن ذَا ٱلَّذِى يَشْفَعُ عِندَهُۥٓ إِلَّا بِإِذْنِهِۦ ۚ
يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ
وَلَا يُحِيطُونَ بِشَىْءٍ مِّنْ عِلْمِهِۦٓ إِلَّا بِمَا شَآءَ ۚ
وَسِعَ كُرْسِيُّهُ ٱلسَّمَـٰوَٰتِ وَٱلْأَرْضَ ۖ
وَلَا يَـُٔودُهُۥ حِفْظُهُمَا ۚ وَهُوَ ٱلْعَلِىُّ ٱلْعَظِيمُ ٢٥٥''',
      transliteration: '''Allahu laaa ilaaha illaa huwal haiyul qai-yoom
laa taakhuzuhoo sinatunw wa laa nawm
lahoo maa fissamaawaati wa maa fil ard
man zallazee yashfaAu indahooo illaa be iznih
yaAlamu maa baina aideehim wa maa khalfahum
wa laa yuheetoona beshai immin ilmihee illa be maa shaaaa wasiAa kursiyyuhus samaa waati wal arda 
wa la ya ooduho hifzuhumaa wa huwal aliyyul azeem''', // <-- Added missing comma here
      translation: """Allah! There is no god ˹worthy of worship˺ except Him, the Ever-Living, All-Sustaining.
Neither drowsiness nor sleep overtakes Him. 
To Him belongs whatever is in the heavens and whatever is on the earth. 
Who could possibly intercede with Him without His permission? 
He ˹fully˺ knows what is ahead of them and what is behind them, but no one can grasp any of His knowledge—except what He wills ˹to reveal˺. 
His Seat encompasses the heavens and the earth, and the preservation of both does not tire Him. 
For He is the Most High, the Greatest.""", // <-- Changed to triple quotes for multiline
      targetCount: 1,
    ),
    Athkar(
      id: '4',
      textArabic: '''اَللّٰهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوْتُ وَإِلَيْكَ النُّشُوْرُ''',
      transliteration: "Allahumma bika asbahna, wa bika amsaina, wa bika nahya, wa bika namutu, wa ilayka-n-nushur",
      translation: '''O Allah, by You we have entered the morning and by You we enter upon the evening.
By You we live and we die, and to You is the resurrection.''', // <-- Changed to triple quotes
      targetCount: 1,
    ),
    Athkar(
      id: '5',
      textArabic: '''رَضِيتُ بِاللَّهِ رَبًّا، وَبِالإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ نَبِيًّا''',
      transliteration: "Radhitu billahi Rabba, wa bil-Islami dina, wa bi-Muhammadin nabiyya",
      translation: 'I am pleased with Allah as my Lord, with Islam as my religion, and with Muhammad (ﷺ) as my Prophet.',
      targetCount: 3,
    ),
    Athkar(
      id: '6',
      textArabic: '''يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ''',
      transliteration: "Yaa Hayyu Yaa Qayyoom bi Rahmatika astagheeth\nAslih lee sha’nee kullahu wa laa takilni ilaa nafsi tarfata ‘ayin",
      translation: '''O Ever Living One, O Self-Sustaining One, by You Mercy do I ask for your support in setting all my affairs right.
Do not leave me to my soul for so much as a the blink of an eye.''', // <-- Changed to triple quotes
      targetCount: 1,
    ), 
    Athkar(
      id: '7',
      textArabic: 'سُـبْحانَ الله',
      transliteration: "SubHanallah",
      translation: 'Glory be to Allah',
      targetCount: 33,
    ),    
    Athkar(
      id: '8',
      textArabic: 'ٱلْحَمْدُ لِلَّٰهِ',
      transliteration: "Al-Ḥamdu lillāh",
      translation: 'Praise be to Allah',
      targetCount: 33,
    ), 
    Athkar(
      id: '9',
      textArabic: 'اللّٰهُ أَكْبَر',
      transliteration: 'Allāhu Akbar',
      translation: 'Allah is the greatest',
      targetCount: 34,
    ), 
  ];

  void _incrementCounter(int index) {
    setState(() {
      if (_morningAthkarList[index].currentCount < _morningAthkarList[index].targetCount) {
        _morningAthkarList[index].currentCount++;
      }
    });
  }

  void _resetCounters() {
    setState(() {
      for (var item in _morningAthkarList) {
        item.currentCount = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Morning Athkar (أذكار الصباح)'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset All Counters',
            onPressed: _resetCounters,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: _morningAthkarList.length,
        itemBuilder: (context, index) {
          final athkar = _morningAthkarList[index];
          final isCompleted = athkar.currentCount >= athkar.targetCount;

          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: isCompleted ? Colors.teal.shade50 : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    athkar.textArabic,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    athkar.transliteration,
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    athkar.translation,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress: ${athkar.currentCount} / ${athkar.targetCount}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? Colors.teal : Colors.black,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: isCompleted ? null : () => _incrementCounter(index),
                        icon: Icon(isCompleted ? Icons.check_circle : Icons.touch_app),
                        label: Text(isCompleted ? 'Completed' : 'Count'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}