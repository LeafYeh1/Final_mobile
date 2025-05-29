import 'package:flutter/material.dart';

class MissionPage extends StatelessWidget {
  const MissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3E3),
      appBar: AppBar(
        title: const Text('Daily Mission'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daily Mission', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildMissionTile('Water flower in the morning', 1),
            _buildMissionTile('Water flower in the night', 1),
            _buildMissionTile('Take picture\n(No time limit)', 1),

            const SizedBox(height: 30),
            const Text('Advance Mission', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildMissionTile('Health tips\nWatch a video', 1),
            _buildMissionTile('Invite friends\n(No time limit)', 5),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionTile(String title, int coin) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.check_circle_outline, color: Colors.grey),
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$coin', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            const Icon(Icons.monetization_on, color: Colors.amber),
          ],
        ),
      ),
    );
  }
}
