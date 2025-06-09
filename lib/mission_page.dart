import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';

bool isWatering = false;
bool flowerWatered = false;
bool localWatering = false;
bool localFlowerWatered = false;

final player = AudioPlayer();

Widget _buildFlowerArea() {
  return StatefulBuilder(
    builder: (context, setLocalState) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedOpacity(
              opacity: isWatering ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 800),
              child: const Icon(Icons.water_drop, size: 55, color: Colors.blueAccent),
            ),
            const SizedBox(height: 8),
            Icon(
              Icons.local_florist,
              size: 55,
              color: flowerWatered ? Colors.green : Colors.pinkAccent,
            ),
            const SizedBox(height: 5),
            ElevatedButton.icon(
              onPressed: isWatering
                  ? null
                  : () async {
                setLocalState(() => isWatering = true);

                // 撥放澆水音效
                try {
                  await player.play(AssetSource('audio/water.mp3'));
                } catch (e) {
                  print("❌ Audio play failed: $e");
                }

                // 等待澆水動畫完成
                await Future.delayed(const Duration(seconds: 2));
                setLocalState(() {
                  isWatering = false;
                  flowerWatered = true;
                });

                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid == null) return;

                final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
                final snapshot = await userDoc.get();
                final data = snapshot.data();

                final hasDone = data?['missions']?['water_flower'] == true;
                if (!hasDone) {
                  // 更新 missions.water_flower = true 並加上 coins
                  await userDoc.update({
                    'missions.water_flower': true,
                    'coins': FieldValue.increment(10),
                  });

                  // 👉 更新畫面
                  if (context.mounted) {
                    final state = context.findAncestorStateOfType<_MissionPageState>();
                    state?._loadMissionStatus(); // <- 呼叫重新讀取狀態

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🎉 10 coins earned for water_flower!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.water),
              label: const Text(
                'Water',
                style: TextStyle(
                  fontSize: 20, // 這裡改變大小，例如 20 是較大的字
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

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
      body: Stack(
        children: [
          // 任務清單
          Padding(
            padding: const EdgeInsets.only(bottom: 120.0), // 預留底部空間
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: missions.entries.map((e) => _buildMissionTile(e.key, e.value)).toList(),
            ),
          ),

          // 澆水區域
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildFlowerArea(),
          ),
        ],
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
