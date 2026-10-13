import 'package:flutter/material.dart';
import '../models/athkar_model.dart';

class EveningAthkarScreen extends StatefulWidget {
  const EveningAthkarScreen({Key? key}) : super(key: key);

  @override
  State<EveningAthkarScreen> createState() => _EveningAthkarScreenState();
}

class _EveningAthkarScreenState extends State<EveningAthkarScreen> {
  final List<Athkar> _eveningAthkarList = [
    Athkar(
      id: '1',
      textArabic: '''اَمْسَيْنَا وَاَمْسَ الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ، 
      لَا إِلَهَ إِلَّّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ،
      لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ،
      رَبِّ أَسْأَلُكَ خَيْرَ مَا فِيْ هَذَا اللَّيْلَةِ وَخَيْرَ مَا بَعْدَهُ،
      وَأَعُوْذُ بِكَ مِنْ شَرِّ مَا فِي هَذَا اللَّيْلَةِ وَشَرِّ مَا بَعْدَهُ،
      رَبِّ أَعُوْذُ بِكَ مِنَ الْكَسَلِ، وَسُوءِ الْكِبَرِ،
       رَبِّ أَعُوْذُ بِكَ مِنْ عَذَابٍ فِيْ النَّارِ وَعَذَابٍ فِيْ الْقَبْرِ.''',
      transliteration: "Amsayna wa-amsal-mulku lillah walhamdu lillah la ilaha illal-lah,
       wahdahu la shareeka lah, 
       lahul-mulku walahul-hamd,
       wahuwa AAala kulli shayin qadeer, 
       rabbi as-aluka khayra ma fee hathihil-laylah,
       wakhayra ma baAAdaha,
       wa-aAAoothu bika min sharri hathihil-laylah,
       washarri ma baAAdaha, rabbi aAAoothu bika minal-kasal,
       wasoo-il kibar, rabbi aAAoothu bika min AAathabin fin-nar, waAAathabin fil-qabr.",
      translation: 'We have reached the evening and at this very time unto Allah belongs all sovereignty,and all praise is for Allah.
 None has the right to be worshipped except Allah,alone, without partner, to Him belongs all sovereignty and praise and He is over all things omnipotent.
    My Lord, I ask You for the good of this night and the good of what follows it and I take refuge in You from the evil of this night and the evil of what follows it.
    My Lord, I take refuge in You from laziness and senility.
    My Lord, I take refuge in You from torment in the Fire and punishment in the grave.',
      targetCount: 1,
    ),
    Athkar(
      id: '2',
      textArabic: '''اَللّٰهُمَّ بِكَ أَمْسَيْنَا وَبِكَ أَصْبَحْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوْتُ وَإِلَيْكَ الْمَصِيْرُ''',
      transliteration: "Allahumma bika amsayna, wa bika asbahna, wa bika nahya, wa bika namutu, wa ilaykal-maseer",
      translation: '''O Allah, by You we have entered the evening and by You we enter upon the morning. 
By You we live and we die, and to You is the return.''',
      targetCount: 1,
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
wa la ya ooduho hifzuhumaa wa huwal aliyyul azeem''',
      translation: """Allah! There is no god ˹worthy of worship˺ except Him, the Ever-Living, All-Sustaining.
Neither drowsiness nor sleep overtakes Him. 
To Him belongs whatever is in the heavens and whatever is on the earth. 
Who could possibly intercede with Him without His permission? 
He ˹fully˺ knows what is ahead of them and what is behind them, but no one can grasp any of His knowledge—except what He wills ˹to reveal˺. 
His Seat encompasses the heavens and the earth, and the preservation of both does not tire Him. 
For He is the Most High, the Greatest.""",
      targetCount: 1,
    ),
    Athkar(
      id: '4',
      textArabic: '''رَضِيتُ بِاللَّهِ رَبًّا، وَبِالإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ نَبِيًّا''',
      transliteration: "Radhitu billahi Rabba, wa bil-Islami dina, wa bi-Muhammadin nabiyya",
      translation: 'I am pleased with Allah as my Lord, with Islam as my religion, and with Muhammad (ﷺ) as my Prophet.',
      targetCount: 3,
    ),
    Athkar(
      id: '5',
      textArabic: '''يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ''',
      transliteration: "Yaa Hayyu Yaa Qayyoom bi Rahmatika astagheeth\nAslih lee sha’nee kullahu wa laa takilni ilaa nafsi tarfata ‘ayin",
      translation: '''O Ever Living One, O Self-Sustaining One, by You Mercy do I ask for your support in setting all my affairs right.
Do not leave me to my soul for so much as a the blink of an eye.''',
      targetCount: 1,
    ), 
    Athkar(
      id: '6',
      textArabic: 'سُـبْحانَ الله',
      transliteration: "SubHanallah",
      translation: 'Glory be to Allah',
      targetCount: 33,
    ),    
    Athkar(
      id: '7',
      textArabic: 'ٱلْحَمْدُ لِلَّٰهِ',
      transliteration: "Al-Ḥamdu lillāh",
      translation: 'Praise be to Allah',
      targetCount: 33,
    ), 
    Athkar(
      id: '8',
      textArabic: 'اللّٰهُ أَكْبَر',
      transliteration: 'Allāhu Akbar',
      translation: 'Allah is the greatest',
      targetCount: 34,
    ), 
     Athkar(
      id: '9',
      textArabic: '''حَسْبِيَ اللَّهُ لَآ إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ''',
      transliteration: "Hasbiyal-lahu la ilaha illa huwa, AAalayhi tawakkalt, wahuwa rabbul-AAarshil-AAatheem",
      translation: 'Allah is Sufficient for me, none has the right to be worshipped except Him, upon Him I rely and He is Lord of the exalted throne.',
      targetCount: 7,
    ),
     Athkar(
      id: '10',
      textArabic: '''أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ.''',
      transliteration: "aAAoothu bikalimatil-lahit-tammati min sharri ma khalaq.",
      translation: 'I take refuge in Allah’s perfect words from the evil He has created. ',
      targetCount: 3,
    ),
  ];

  void _incrementCounter(int index) {
    setState(() {
      if (_eveningAthkarList[index].currentCount < _eveningAthkarList[index].targetCount) {
        _eveningAthkarList[index].currentCount++;
      }
    });
  }

  void _resetCounters() {
    setState(() {
      for (var item in _eveningAthkarList) {
        item.currentCount = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evening Athkar (أذكار المساء)'),
        backgroundColor: Colors.indigo, // Changed to indigo for evening theme
        foregroundColor: Colors.white,
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
        itemCount: _eveningAthkarList.length,
        itemBuilder: (context, index) {
          final athkar = _eveningAthkarList[index];
          final isCompleted = athkar.currentCount >= athkar.targetCount;

          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: isCompleted ? Colors.indigo.shade50 : Colors.white,
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
                          color: isCompleted ? Colors.indigo : Colors.black,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: isCompleted ? null : () => _incrementCounter(index),
                        icon: Icon(isCompleted ? Icons.check_circle : Icons.touch_app),
                        label: Text(isCompleted ? 'Completed' : 'Count'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
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
    