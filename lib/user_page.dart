import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'edit_profile.dart';
import 'faq.dart';
import 'about_us.dart';
import 'main.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String name = "";
  String email = "";
  String age = "";
  String height = "";
  String weight = "";
  File? profileImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = userDoc.data();

      if (data != null) {
        setState(() {
          name = data['name'] ?? '';
          email = data['email'] ?? '';
          age = data['age'] ?? '';
          height = data['height'] ?? '';
          weight = data['weight'] ?? '';
          final imagePath = data['profileImagePath'];
          if (imagePath != null && imagePath != '') {
            profileImage = File(imagePath);
          }
        });
      }
    }
  }

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
          Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: profileImage != null
                    ? FileImage(profileImage!)
                    : const AssetImage('assets/avatar.jpg') as ImageProvider,
              ),
              const SizedBox(height: 10),
              Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(email, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _UserInfo(label: "Age", value: age),
                  const SizedBox(width: 20),
                  _UserInfo(label: "Height", value: height),
                  const SizedBox(width: 20),
                  _UserInfo(label: "Weight", value: weight),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView(
              children: [
                _ProfileTile(
                  title: "Edit Profile",
                  icon: Icons.edit,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfilePage(
                          onChanged: (updatedData) {
                            setState(() {
                              name = updatedData['name'] ?? name;
                              age = updatedData['age'] ?? age;
                              email = updatedData['email'] ?? email;
                              height = updatedData['height'] ?? height;
                              weight = updatedData['weight'] ?? weight;
                              final imagePath = updatedData['profileImagePath'];
                              if (imagePath != null && imagePath != '') {
                                profileImage = File(imagePath);
                              }
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
                _ProfileTile(
                    title: "FAQ",
                    icon: Icons.help_outline,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => FAQPage()));
                    }),
                _ProfileTile(
                    title: "About us",
                    icon: Icons.info_outline,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AboutUsPage()));
                    }),
                _ProfileTile(
                    title: "Log out",
                    icon: Icons.logout,
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                              (route) => false);
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
