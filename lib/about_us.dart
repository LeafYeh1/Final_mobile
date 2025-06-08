// about_us.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Map<String, String>> members = [
    {
      'id': '1112917',
      'name': '潘翊嘉',
      'comment': '第一次看NBA，請問LBJ是露比醬的意思嗎？',
      'image': 'assets/pan.jpg',
      'audio': 'assets/audio/pan.mp3',
    },
    {
      'id': '1112918',
      'name': '冷博雋',
      'comment': '你若生活痛苦，記得保持微笑',
      'image': 'assets/leng.jpg',
      'audio': 'assets/audio/leng.mp3',
    },
    {
      'id': '1112961',
      'name': '葉子琳',
      'comment': 'Never Gonna Give You Up',
      'image': 'assets/ye.jpg',
      'audio': 'assets/audio/ye.mp3',
    },
    {
      'id': '1112963',
      'name': '李若華',
      'comment': '生活枯燥乏味 早八謀殺人類',
      'image': 'assets/li.jpg',
      'audio': 'assets/audio/li.mp3',
    },
  ];

  final List<Color> greenShades = [
    const Color(0xFFB2E8C3),
    const Color(0xFFA4D8A5),
    const Color(0xFFB4E197),
    const Color(0xFFA7D7A8),
    const Color(0xFF8CD790),
    const Color(0xFF75C67A),
  ];

  Future<void> _playAudio(String path) async {
    await _audioPlayer.stop(); // 若已有播放則停止
    await _audioPlayer.play(AssetSource(path.replaceFirst('assets/', '')));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('About us'),
        backgroundColor: const Color(0xFF329F40),
      ),
      body: Container(
        color: const Color(0xFFDCE8C8),
        child: ListView(
          children: [
            ...members.map((member) {
              return GestureDetector(
                onTap: () {
                  final audioPath = member['audio'];
                  if (audioPath != null) {
                    _playAudio(audioPath);
                  }
                },
                child: Card(
                  color: greenShades[members.indexOf(member) % greenShades.length],
                  margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: Colors.grey.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage(member['image']!),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${member['id']} ${member['name']}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Space Grotesk',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                member['comment']!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Space Grotesk',
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),

            // 可選：圖片區（如前面討論）
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/member.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
