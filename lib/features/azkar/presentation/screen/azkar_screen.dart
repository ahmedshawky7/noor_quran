import 'package:flutter/material.dart';
import 'package:noor_quran/features/azkar/domain/entities/zikr.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});
  
  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  List<Zikr> _morningAzkar = [];
  int _counters = 0;
  
  @override
  void initState() {
    super.initState();
    _loadAzkar();
  }
  
  Future<void> _loadAzkar() async {
    // In production, get from repository/database
    setState(() {
      _morningAzkar = [
        Zikr(id: 1, category: 'morning', textArabic: 'سبحان الله', textEnglish: 'Glory be to Allah', count: 33),
        Zikr(id: 2, category: 'morning', textArabic: 'الحمد لله', textEnglish: 'Praise be to Allah', count: 33),
        Zikr(id: 3, category: 'morning', textArabic: 'الله أكبر', textEnglish: 'Allah is the Greatest', count: 34),
      ];
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Morning Azkar')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _morningAzkar.length,
        itemBuilder: (context, index) {
          final zikr = _morningAzkar[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(zikr.textArabic, style: const TextStyle(fontSize: 24), textAlign: TextAlign.right),
                  const SizedBox(height: 8),
                  Text(zikr.textEnglish),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _counters++;
                          });
                          if (_counters >= zikr.count) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Completed!')),
                            );
                          }
                        },
                        child: Text('Count: $_counters / ${zikr.count}'),
                      ),
                      if (zikr.reference != null)
                        Text(zikr.reference!),
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