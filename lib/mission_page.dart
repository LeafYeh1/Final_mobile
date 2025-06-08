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
      backgroundColor: const Color(0xFFEFF3E3),
      appBar: AppBar(
        title: const Text('Daily Mission'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text('Daily Missions', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildMissionTile('water_flower', 10),
            _buildMissionTile('take_picture', 20),
            _buildMissionTile('click_health_tips', 20),
            _buildMissionTile('timing', 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionTile(String title, int coin) {
    final isDone = completedMissions[title] ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16), // 增加上下內距
        leading: Icon(
          isDone ? Icons.check_circle : Icons.circle_outlined,
          color: isDone ? Colors.green : Colors.grey,
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 20), // 可視情況調整大小，建議 20~24
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$coin',style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 4),
            const Icon(Icons.monetization_on, color: Colors.amber, size: 28),
          ],
        ),
      ),
    );
  }
}
