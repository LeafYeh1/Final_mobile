// edit_profile.dart
import 'package:flutter/material.dart';

class EditProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit Profile'),
        backgroundColor: Colors.grey[800],
      ),
      body: Container(
        color: Color(0xFFDFE6D7),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/profile.png'),
              ),
            ),
            SizedBox(height: 20),
            Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(readOnly: true, decoration: InputDecoration(hintText: 'HJM')),
            SizedBox(height: 10),
            Text('E-mail', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(readOnly: true, decoration: InputDecoration(hintText: 'hjm.2025@gmail.com')),
            SizedBox(height: 10),
            Text('Height', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(readOnly: true, decoration: InputDecoration(hintText: '180')),
            SizedBox(height: 10),
            Text('Weight', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(readOnly: true, decoration: InputDecoration(hintText: '65')),
          ],
        ),
      ),
    );
  }
}