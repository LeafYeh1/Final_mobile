import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MissionPage extends StatefulWidget {
  const MissionPage({super.key});

  @override
  State<MissionPage> createState() => _MissionPageState();
}

class _MissionPageState extends State<MissionPage> {
  final Map<String, int> missions = {
    'water_flower': 10,
    'take_picture': 20,
    'click_health_tips': 20,
    'timing' : 30,
  };

  Map<String, bool> completedMissions = {};
  bool isLoading = true;

  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    if (uid != null) _loadMissionStatus();
  }

  Future<void> _loadMissionStatus() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();

    if (data != null && data.containsKey('missions')) {
      final missionData = Map<String, dynamic>.from(data['missions']);
      setState(() {
        completedMissions = {
          for (var key in missions.keys) key: missionData[key] == true,
        };
        isLoading = false;
      });
    } else {
      setState(() {
        completedMissions = { for (var key in missions.keys) key: false };
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xCED3D9AF),
      appBar: AppBar(
        title: const Text('Daily Missions'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: missions.entries.map((e) => _buildMissionTile(e.key, e.value)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionTile(String title, int coin) {
    final isDone = completedMissions[title] ?? false;

    // 任務名稱轉換為人類可讀格式
    String prettyTitle(String raw) {
      return raw
          .split('_')
          .map((e) => e[0].toUpperCase() + e.substring(1))
          .join(' ');
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: isDone
            ? const LinearGradient(
          colors: [Color(0xFFA5F1A3), Color(0xFFA5F1A3)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: [0.0, 1.0], // ⬅️ 控制下方顏色比例
        )
            : const LinearGradient(
          colors: [Color(0xFF99D9F5), Color(0xFFFAFAFA)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: [0.0, 0.2], // ⬅️ 控制下方顏色比例
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        leading: Icon(
          isDone ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 32,
          color: isDone ? Colors.green.shade700 : Colors.grey,
        ),
        title: Text(
          prettyTitle(title),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDone ? Colors.green.shade800 : Colors.black87,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$coin',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.monetization_on, color: Colors.amber, size: 22),
            ],
          ),
        ),

      ),
    );
  }

}
