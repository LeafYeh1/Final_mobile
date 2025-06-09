import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';

final AudioPlayer _coinPlayer = AudioPlayer();

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final List<File> _images = [];

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _images.insert(0, File(image.path));
      });

      // 拍完照 → 檢查並更新任務狀態
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

        final docSnap = await userDoc.get();
        final data = docSnap.data() ?? {};
        final missions = data['missions'] ?? {};
        final currentCoins = data['coins'] ?? 0;

        // 檢查任務是否已完成
        if (missions['take_picture'] != true) {
          // 更新任務完成狀態與增加 coins
          await userDoc.set({
            'missions': {'take_picture': true},
            'coins': currentCoins + 20,
          }, SetOptions(merge: true));
          // 播放 coin 音效
          try {
            await _coinPlayer.play(AssetSource('audio/coins.mp3'));
          } catch (e) {
            print('❌ Failed to play coin sound: $e');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🎉 20 coins earned for taking picture!')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3E3),
      appBar: AppBar(
        title: const Text('Photo Album'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _takePhoto,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Snap'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _images.isEmpty
                ? const Center(child: Text('No photos yet'))
                : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_images[index], fit: BoxFit.cover),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
