import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'history_page.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});
  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  int _initialTime = 1 * 60; // 初始倒數時間（秒）
  int _remainingTime = 1 * 60;
  Timer? _timer;
  bool _isRunning = false;

  /// 開始計時器
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

  /// 暫停計時器
  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  /// 重設計時器（不跳轉頁面）
  void _resetTimer({bool exitAfterReset = false}) {
    _timer?.cancel();

    if (exitAfterReset && _remainingTime != _initialTime) {
      final now = DateTime.now();
      final startTime = now.subtract(Duration(seconds: _initialTime - _remainingTime));
      final record = HistoryRecord(
        date: '${now.year} / ${now.month} / ${now.day}',
        duration: '${((_initialTime - _remainingTime) ~/ 60)} min',
        start: '${startTime.hour.toString().padLeft(2, '0')} : ${startTime.minute.toString().padLeft(2, '0')}',
        end: '${now.hour.toString().padLeft(2, '0')} : ${now.minute.toString().padLeft(2, '0')}',
      );
      Navigator.pop(context, record);
    } else if (exitAfterReset) {
      Navigator.pop(context);
    }

    setState(() {
      _remainingTime = _initialTime;
      _isRunning = false;
    });
  }
  //如果你之後仍希望在某些狀況下「退出頁面並帶出歷史紀錄」：
  // 你可以把 _resetTimer() 改成接受參數來區分用途。
  //如果只是要重設不退出： onPressed: () => _resetTimer(),
  //如果未來某些狀況想要重設並退出： onPressed: () => _resetTimer(exitAfterReset: true),


  /// 編輯倒數時間
  Future<void> _editTime() async {
    int? minutes = await showDialog<int>(
      context: context,
      builder: (context) {
        int tempMinutes = _initialTime ~/ 60;
        return AlertDialog(
          title: Text('設定倒數時間（分鐘）'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "輸入分鐘數"),
            onChanged: (value) {
              tempMinutes = int.tryParse(value) ?? tempMinutes;
            },
          ),
          actions: [
            TextButton(
              child: Text("取消"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("確定"),
              onPressed: () => Navigator.pop(context, tempMinutes),
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

  /// 時間格式化
  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  /// 上方標題列
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

  /// 中央倒數環形進度條
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

  /// 控制按鈕區域
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
            _buildCircleButton(Icons.stop, "Quit", onReset),
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

  /// 底部歷史紀錄入口
  Widget _buildHistoryBar() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push<HistoryRecord>(
          context,
          MaterialPageRoute(builder: (_) => const HistoryPage()),
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

  /// 主體組件
  Widget buildTimerComponent({
    required int initialTime,
    required int remainingTime,
    required bool isRunning,
    required VoidCallback onStart,
    required VoidCallback onPause,
    required VoidCallback onReset,
    required VoidCallback onEdit,
  }) {
    double progress = remainingTime / initialTime;

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

/// 繪製環形進度條的畫家
class GradientCircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  GradientCircularProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 18.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, backgroundPaint);

    final foregroundPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
