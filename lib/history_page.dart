import 'package:flutter/material.dart';
import 'timer_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<HistoryRecord> history = [
    HistoryRecord(date: '2025 / 5 / 10', duration: '1 hr', start: '10 : 30', end: '11 : 30'),
    // ... 其他紀錄
  ];

  void _removeRecord(int index) {
    setState(() {
      history.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC8D0AD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFC8D0AD),
        leading: const BackButton(color: Colors.black),
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final newRecord = await Navigator.push<HistoryRecord>(
                context,
                MaterialPageRoute(builder: (_) => const TimerPage()),
              );
              if (newRecord != null) {
                setState(() {
                  history.insert(0, newRecord);
                });
              }
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final record = history[index];
          return ListTile(
            title: Text('${record.date} - ${record.duration}'),
            subtitle: Text('Start: ${record.start}  End: ${record.end}'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _removeRecord(index),
            ),
          );
        },
      ),
    );
  }
}


class HistoryRecord {
  final String date;
  final String duration;
  final String start;
  final String end;

  const HistoryRecord({
    required this.date,
    required this.duration,
    required this.start,
    required this.end,
  });
}

class HistoryCard extends StatelessWidget {
  final HistoryRecord record;
  final VoidCallback onDelete;

  const HistoryCard({super.key, required this.record, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFFACE588),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFD7A06),
              ),
              alignment: Alignment.center,
              child: Text(
                record.duration,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Space Grotesk',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.date,
                    style: const TextStyle(
                      fontSize: 22,
                      fontFamily: 'Space Grotesk',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('START : ${record.start}'),
                  Text('END :   ${record.end}'),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}