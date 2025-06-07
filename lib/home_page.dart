import 'package:flutter/material.dart';
import 'mission_page.dart';
import 'user_page.dart';
import 'camera_page.dart';
import 'coins_page.dart';
import 'timer_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    HomeContent(),
    MissionPage(),
    UserPage(),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Image.asset('assets/logo.jpg', height: 120), // Logo 圖片

          const SizedBox(height: 20),
          // 工具區塊
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTool(context, Icons.camera_alt, "Camera"),
              _buildTool(context, Icons.timer, "Timer"),
              _buildTool(context, Icons.stars, "Coins"),
            ],
          ),

          const SizedBox(height: 30),
          // 健康知識區塊
          Row(
            children: const [
              Text("Health knowledge", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildHealthCard("assets/health1.jpg", "Health Tips"),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildHealthCard("assets/health2.jpg", "Health Tips"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTool(BuildContext context, IconData icon, String label) {
    return InkWell(
      onTap: () {
        if (label == "Camera") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CameraPage()),
          );
        }
        if (label == "Timer") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TimerPage()),
          );
        }
        if (label == "Coins") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CoinsPage()),
          );
        }
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.lightGreen.shade100,
            child: Icon(icon, size: 30, color: Colors.green[700]),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }


  Widget _buildHealthCard(String imagePath, String title) {
    return InkWell(
      onTap: () {
        // 點擊進入詳細健康知識頁面（之後可以實作）
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(8),
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
