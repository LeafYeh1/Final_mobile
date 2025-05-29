import 'package:flutter/material.dart';

class CoinsPage extends StatelessWidget {
  const CoinsPage({super.key});

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
                  const Text("點數累積", style: TextStyle(fontSize: 14)),
                  const Icon(Icons.code),
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
                          color: Color(0xFF78735B),
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
                              child: Text(
                                "350 Pt",
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                      _buildRewardItem("assets/giftcard.png", "7-11 gift \$50", 1000),
                      _buildRewardItem("assets/iphone.jpg", "iPhone 16 Pro 1TB", 10000000),
                      _buildRewardItem("assets/ipad.jpg", "iPad Air 7", 10000000),
                      _buildRewardItem("assets/signed_photo.jpg", "瑞峰 葉 Signed photo", 5000000),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Image.asset(imagePath, width: 60, height: 60, fit: BoxFit.cover),
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text("Exchange", style: TextStyle(color: Colors.white)),
              )
            ],
          )
        ],
      ),
    );
  }
}
