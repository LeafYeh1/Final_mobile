import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'history_page.dart';  // 確認你的 HistoryPage 支援接收 List<HistoryRecord>
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});
  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  int _initialTime = 1 * 60;
  int _remainingTime = 1 * 60;
  Timer? _timer;
  bool _isRunning = false;

  // 這裡改成用 List 累積歷史
  List<HistoryRecord> _historyRecords = [];

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        timer.cancel();
        setState(() => _isRunning = false);
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  Future<void> _resetTimer({bool exitAfterReset = false}) async {
    _timer?.cancel();

    if (exitAfterReset && _remainingTime != _initialTime) {
      final now = DateTime.now();
      final elapsedSeconds = _initialTime - _remainingTime;
      final startTime = now.subtract(Duration(seconds: elapsedSeconds));
      final record = HistoryRecord(
        date: '${now.year} / ${now.month} / ${now.day}',
        duration: '${elapsedSeconds ~/ 60} min ${elapsedSeconds % 60} sec',
        start: '${startTime.hour.toString().padLeft(2, '0')} : ${startTime.minute.toString().padLeft(2, '0')}',
        end: '${now.hour.toString().padLeft(2, '0')} : ${now.minute.toString().padLeft(2, '0')}',
      );
      _historyRecords.add(record);
      // 寫入 Firebase Firestore
      final uid = FirebaseAuth.instance.currentUser!.uid;
      if (record.date != null && record.start != null && record.end != null && record.duration != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('timehistory')
            .add({
          'date': record.date,
          'start': record.start,
          'end': record.end,
          'duration': record.duration,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        print('❗ 有欄位為 null，不寫入 Firebase');
      }

    }

    setState(() {
      _isRunning = false;
      _remainingTime = _initialTime;
    });

    if (exitAfterReset) {
      // 傳整個歷史清單到 HistoryPage
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HistoryPage(historyRecords: _historyRecords),
        ),
      );
      // 回來後可視需要清空或保持歷史，這裡不清空讓歷史持續累積
    }
  }

  Future<void> _editTime() async {
    final controller = TextEditingController(text: (_initialTime ~/ 60).toString());
    int? minutes = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('設定倒數時間（分鐘）'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "輸入分鐘數"),
          ),
          actions: [
            TextButton(
              child: Text("取消"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("確定"),
              onPressed: () {
                final value = int.tryParse(controller.text);
                if (value != null && value > 0) {
                  Navigator.pop(context, value);
                } else {
                  // 輸入錯誤可顯示提示或直接關閉
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );

    if (minutes != null && minutes > 0) {
      setState(() {
        _initialTime = minutes * 60;
        _remainingTime = _initialTime;
        _isRunning = false;
        _timer?.cancel();
      });
    }
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  Widget _buildTopBar({required bool isRunning, required VoidCallback onEdit}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.home, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.white),
                onPressed: isRunning ? null : onEdit,
              ),
            ],
          ),
          Text(
            'Timer',
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black26)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCircle({required double progress, required String timeText}) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 280,
            height: 280,
            child: CustomPaint(
              painter: GradientCircularProgressPainter(
                progress: progress,
                color: Color(0xFF383054),
              ),
            ),
          ),
          Text(
            timeText,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons({
    required bool isRunning,
    required VoidCallback onStart,
    required VoidCallback onPause,
    required VoidCallback onReset,
  }) {
    return SizedBox(
      height: 120,
      child: Center(
        child: isRunning
            ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCircleButton(Icons.pause, "Pause", onPause),
            _buildCircleButton(Icons.stop, "Quit", () => _resetTimer(exitAfterReset: true)),
          ],
        )
            : ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1B143F),
            padding: EdgeInsets.symmetric(horizontal: 80, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: onStart,
          child: Text(
            "S T A R T",
            style: TextStyle(
              fontSize: 32,
              letterSpacing: 2,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1B143F),
            shape: CircleBorder(),
            padding: EdgeInsets.all(18),
          ),
          onPressed: onPressed,
          child: Icon(icon, size: 32),
        ),
        SizedBox(height: 8),
        Text(label)
      ],
    );
  }

  Widget _buildHistoryBar() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HistoryPage(historyRecords: _historyRecords)),
        );
      },
      child: Container(
        width: double.infinity,
        color: Colors.grey.shade300,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 28),
        child: Row(
          children: [
            Icon(Icons.library_books, size: 28),
            SizedBox(width: 8),
            Text(
              'H I S T O R Y',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildTimerComponent({
    required int initialTime,
    required int remainingTime,
    required bool isRunning,
    required VoidCallback onStart,
    required VoidCallback onPause,
    required VoidCallback onReset,
    required VoidCallback onEdit,
  }) {
    double progress = initialTime > 0 ? remainingTime / initialTime : 0;

    return Scaffold(
      backgroundColor: Color(0xCED3D9AF),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(isRunning: isRunning, onEdit: onEdit),
            Expanded(child: _buildTimerCircle(progress: progress, timeText: _formatTime(remainingTime))),
            _buildControlButtons(
              isRunning: isRunning,
              onStart: onStart,
              onPause: onPause,
              onReset: onReset,
            ),
            SizedBox(height: 32),
            _buildHistoryBar(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildTimerComponent(
      initialTime: _initialTime,
      remainingTime: _remainingTime,
      isRunning: _isRunning,
      onStart: _startTimer,
      onPause: _pauseTimer,
      onReset: _resetTimer,
      onEdit: _editTime,
    );
  }
}

class GradientCircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  GradientCircularProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 20.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;  // 改成直角端點

    // 進度圈
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }


  @override
  bool shouldRepaint(covariant GradientCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}


