// about_us.dart
import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  final List<Map<String, String>> members = [
    {
      'id': '1112917',
      'name': '潘翊嘉',
      'comment': '第一次看NBA，請問LBJ是喜歡比貓的意思嗎？',
      'image': 'assets/pan.png'
    },
    {
      'id': '1112918',
      'name': '冷博傳',
      'comment': '你生活搞苦，記得保持微笑',
      'image': 'assets/leng.png'
    },
    {
      'id': '1112961',
      'name': '葉子琳',
      'comment': '別問弱爆，哥的情緒零碎',
      'image': 'assets/ye.png'
    },
    {
      'id': '1112963',
      'name': '李若華',
      'comment': '生活枯燥乏味 早八讓我入眠',
      'image': 'assets/li.png'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('About us'),
        backgroundColor: Colors.purple[800],
      ),
      body: Container(
        color: Color(0xFFDCE8C8),
        child: ListView(
          children: members.map((member) {
            return Card(
              color: Colors.primaries[members.indexOf(member) % Colors.primaries.length][100],
              margin: EdgeInsets.all(10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(member['image']!),
                ),
                title: Text('${member['id']} ${member['name']}'),
                subtitle: Text(member['comment']!),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
