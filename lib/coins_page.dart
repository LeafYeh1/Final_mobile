import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';


final player = AudioPlayer();
String? currentlyAnimating; // 控制正在兌換的項目（避免多重點擊）
class CoinsPage extends StatefulWidget {
  const CoinsPage({super.key});

  @override
  State<CoinsPage> createState() => _CoinsPageState();
}

class _CoinsPageState extends State<CoinsPage> {
  int userPoints = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserPoints();
  }

  Future<void> fetchUserPoints() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("⚠️ No user logged in.");
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();

      print("✅ Fetched user data: $data");

      setState(() {
        userPoints = data?['coins'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching user points: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3D9BA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 返回首頁按鈕
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  "🌿 My Points",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Text("Current points", style: TextStyle(fontSize: 16, color: Colors.white)),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 50,
                      width: 200,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xFFB7D849),
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Color(0xFFB7D849),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    bottomLeft: Radius.circular(25),
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: isLoading
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                userPoints == 0 ? "No points yet" : "$userPoints Pt",
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text("Points reward", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      _buildRewardItem("assets/giftcard.png", "7-11 gift \$50", 2500),
                      _buildRewardItem("assets/iphone.jpg", "iPhone 16 Pro 1TB", 4000),
                      _buildRewardItem("assets/ipad.jpg", "iPad Air 7", 8000),
                      _buildRewardItem("assets/signed_photo.jpg", "瑞峰 葉 Signed photo", 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardItem(String imagePath, String title, int cost) {
    final isAnimating = currentlyAnimating == title;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutBack,
            transform: isAnimating
                ? (Matrix4.identity()
              ..scale(1.5)
              ..rotateZ(0.2))
                : Matrix4.identity(),
            child: ColorFiltered(
              colorFilter: isAnimating
                  ? const ColorFilter.mode(Colors.yellowAccent, BlendMode.modulate)
                  : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
              child: Image.asset(imagePath, width: 60, height: 60, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.orange, size: 18),
                  Text("$cost", style: const TextStyle(color: Colors.orange)),
                ],
              ),
              const SizedBox(height: 4),
              ElevatedButton(
                onPressed: () async {
                  if (userPoints < cost) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Not enough coins!")),
                    );
                    return;
                  }

                  setState(() {
                    currentlyAnimating = title;
                    userPoints -= cost;
                  });

                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .update({'coins': userPoints});
                  }

                  await showGiftDialog(title);

                  setState(() {
                    currentlyAnimating = null;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("🎉 Successfully exchanged $title!")),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text("Exchange", style: TextStyle(color: Colors.white)),
              )
            ],
          )
        ],
      ),
    );
  }
  Future<void> showGiftDialog(String title) async {
    await player.play(AssetSource('audio/exchange.mp3'));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 閃亮特效背景
            Positioned.fill(
              child: Lottie.asset('assets/lottie/success.json',
                repeat: true,
                fit: BoxFit.cover,
              ),
            ),
            // 禮物盒
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset('assets/lottie/giftbox.json',
                    repeat: false,
                    width: 200,
                    height: 200),
                Text("你收到了 🎁", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                Text(title, style: TextStyle(fontSize: 22, color: Colors.yellowAccent, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await player.stop(); // 停止音樂
                    Navigator.pop(context); // 關閉 dialog
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text("OK", style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
