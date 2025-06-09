import 'package:flutter/material.dart';
import 'mission_page.dart';
import 'user_page.dart';
import 'camera_page.dart';
import 'coins_page.dart';
import 'timer_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';

final AudioPlayer _coinPlayer = AudioPlayer();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const HomeContent(),
    const MissionPage(),
    const UserPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Mission'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCBD3AA), // 淡綠色背景
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(10, 30, 10, 12), // top 改成 60，讓整體往下
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset('assets/logo.jpg', height: 200, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                Text(
                  "Tools",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Color(0xFF496a36)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Tools 區塊
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTool(context, Icons.camera_alt, "Camera"),
                _buildTool(context, Icons.timer, "Timer"),
                _buildTool(context, Icons.stars, "Coins"),
              ],
            ),

            const SizedBox(height: 20),

            // Health knowledge 區塊
            Row(
              children: const [
                Text(
                  "Health Knowledge",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Color(0xFF496a36)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildHealthCard(
                    context,
                    "assets/health1.jpg",
                    "臺北市衛生局: 高齡者有氧運動健康操",

                    "https://www.youtube.com/watch?v=7pIeSsndwbA",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHealthCard(
                    context,
                    "assets/health2.jpg",
                    "How the food you eat affects ...",
                    "https://www.youtube.com/watch?v=xyQY8a-ng6g",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHealthCard(
                    context,
                    "assets/health3.jpg",
                    "不要生氣~~吳美雲老師讚美操 6",
                    "https://www.youtube.com/watch?v=7Xdfi3qkPEw",
                  ),
                ),
              ],
            ),



          ],
        ),
      ),
    );
  }

  Widget _buildTool(BuildContext context, IconData icon, String label) {
    return InkWell(
      onTap: () {
        if (label == "Camera") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraPage()));
        } else if (label == "Timer") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const TimerPage()));
        } else if (label == "Coins") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CoinsPage()));
        }
      },
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Colors.black87),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCard(BuildContext context, String imagePathOrUrl, String title, String url) {
    // 嘗試從 url 抓出 YouTube 影片ID，若沒有就用原本 imagePathOrUrl
    String? thumbnailUrl;
    if (url.contains("youtube.com/watch?v=")) {
      final uri = Uri.parse(url);
      final videoId = uri.queryParameters['v'];
      if (videoId != null && videoId.isNotEmpty) {
        thumbnailUrl = "https://img.youtube.com/vi/$videoId/hqdefault.jpg";
      }
    }

    return InkWell(
      onTap: () async {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
        final Uri uri = Uri.parse(url);

        try {
          await FirebaseFirestore.instance.runTransaction((transaction) async {
            final snapshot = await transaction.get(userDoc);
            final data = snapshot.data();
            if (data == null) return;

            final missions = data['missions'] ?? {};
            final currentCoins = (data['coins'] ?? 0) as int;

            // ✅ 檢查是否已完成任務
            if (missions['click_health_tips'] != true) {
              // 更新任務完成狀態與增加 coins
              await userDoc.set({
                'missions': {'click_health_tips': true},
                'coins': currentCoins + 20,
              }, SetOptions(merge: true));
              // ✅ 顯示提示訊息
              // 播放 coin 音效
              try {
                await _coinPlayer.play(AssetSource('audio/coins.mp3'));
              } catch (e) {
                print('❌ Failed to play coin sound: $e');
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🎉 +20 coin for watching health tips!')),
              );
            }
          });

          // ✅ 開啟影片
          await launchUrl(uri, mode: LaunchMode.externalApplication);

        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("無法開啟網頁或任務處理失敗")),
          );
        }
      },
      child: Container(
        height: 230,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.zero,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: thumbnailUrl != null
                  ? Image.network(
                thumbnailUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // 如果載入失敗，用原本 local 圖片
                  return Image.asset(
                    imagePathOrUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              )
                  : Image.asset(
                imagePathOrUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



}

