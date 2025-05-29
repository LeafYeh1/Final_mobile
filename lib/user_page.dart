import 'package:flutter/material.dart';
import 'edit_profile.dart';
import 'faq.dart';
import 'about_us.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3E3),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // 大頭照與基本資料
          Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/avatar.jpg'), // 自訂使用者圖片
              ),
              const SizedBox(height: 10),
              const Text("小明", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text("himing2001@gmail.com", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _UserInfo(label: "Age", value: "30"),
                  SizedBox(width: 20),
                  _UserInfo(label: "Height", value: "160"),
                  SizedBox(width: 20),
                  _UserInfo(label: "Weight", value: "65"),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          // 功能選單
          Expanded(
            child: ListView(
              children: [
                _ProfileTile(title: "Edit Profile", icon: Icons.edit, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfilePage()));
                }),
                _ProfileTile(title: "FAQ", icon: Icons.help_outline, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => FAQPage()));
                }),
                _ProfileTile(title: "About us", icon: Icons.info_outline, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AboutUsPage()));
                }),
                _ProfileTile(title: "Log out", icon: Icons.logout, onTap: () {
                  // TODO: 登出處理（可加跳轉回登入頁）
                  Navigator.popUntil(context, (route) => route.isFirst); // 暫時回首頁
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserInfo extends StatelessWidget {
  final String label;
  final String value;

  const _UserInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ProfileTile({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

