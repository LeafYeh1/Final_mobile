  import 'package:flutter/material.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';

  // 定義資料模型
  class HistoryRecord {
    final String date;
    final String duration;
    final String start;
    final String end;

    HistoryRecord({
      required this.date,
      required this.duration,
      required this.start,
      required this.end,
    });
  }

  // 建立 HistoryPage
  class HistoryPage extends StatefulWidget {
    final List<HistoryRecord> historyRecords;

    const HistoryPage({Key? key, this.historyRecords = const []}) : super(key: key);

    @override
    State<HistoryPage> createState() => _HistoryPageState();
  }

  class _HistoryPageState extends State<HistoryPage> {
    List<HistoryRecord> _firebaseHistory = [];

    @override
    void initState() {
      super.initState();
      _loadFirebaseHistory();
    }

    // 從 Firestore 讀取使用者歷史紀錄
    Future<void> _loadFirebaseHistory() async {
      try {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('timehistory')
            .orderBy('timestamp', descending: true)
            .get();

        setState(() {
          _firebaseHistory = snapshot.docs.map((doc) {
            final data = doc.data();
            return HistoryRecord(
              date: data['date'] ?? '',
              duration: data['duration'] ?? '',
              start: data['start'] ?? '',
              end: data['end'] ?? '',
            );
          }).toList();
        });
      } catch (e) {
        print('🔥 Firebase 讀取失敗：$e');
      }
    }

    @override
    Widget build(BuildContext context) {
      final allHistory = _firebaseHistory;

      return Scaffold(
        appBar: AppBar(
          title: Text('History'),
          backgroundColor: Colors.white,
        ),
        backgroundColor: Color(0xCED3D9AF),
        body: ListView.builder(
          itemCount: allHistory.length,
          itemBuilder: (context, index) {
            final record = allHistory[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              color: Color(0xADABE589),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🗓️  Date：${record.date}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('⏱️  Duration：${record.duration}', style: TextStyle(fontSize: 16)),
                    Text('🕑  Start：${record.start}', style: TextStyle(fontSize: 16)),
                    Text('🕓  End：${record.end}', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
  }