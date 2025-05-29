import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final void Function(Map<String, dynamic>)? onChanged;

  EditProfilePage({this.onChanged});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _initialName = 'HJM';
  final _initialEmail = 'hjm.2025@gmail.com';
  final _initialHeight = '180';
  final _initialWeight = '65';

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  bool _isEditing = false;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _initialName);
    _emailController = TextEditingController(text: _initialEmail);
    _heightController = TextEditingController(text: _initialHeight);
    _weightController = TextEditingController(text: _initialWeight);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
      _notifyChange();
    }
  }

  void _notifyChange() {
    final updatedData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'height': _heightController.text,
      'weight': _weightController.text,
      'profileImagePath': _profileImage?.path,
    };
    if (widget.onChanged != null) {
      widget.onChanged!(updatedData);
    }
  }

  void _saveChanges() {
    FocusScope.of(context).unfocus(); // 收起鍵盤
    _notifyChange();
    setState(() {
      _isEditing = false;
    });
    // 不要 Navigator.pop，停留在編輯頁面
  }

  void _cancelChanges() {
    setState(() {
      _nameController.text = _initialName;
      _emailController.text = _initialEmail;
      _heightController.text = _initialHeight;
      _weightController.text = _initialWeight;
      _profileImage = null;
      _isEditing = false;
    });
    _notifyChange(); // 通知父頁面恢復初始資料
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  Widget _buildEditableField(String label, TextEditingController controller, {TextInputType? type}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: controller,
          keyboardType: type,
          onTap: _startEditing,
          onChanged: (_) => _notifyChange(), // 每次輸入都同步通知父頁面
        ),
        SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Text('Edit Profile'),
        backgroundColor: Colors.grey[800],
        actions: [
          if (!_isEditing)
            IconButton(icon: Icon(Icons.save), onPressed: _saveChanges),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : AssetImage('assets/profile.png') as ImageProvider,
                          ),
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.4),
                            ),
                          ),
                          Icon(Icons.camera_alt, color: Colors.white, size: 30),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildEditableField('Name', _nameController),
                  _buildEditableField('E-mail', _emailController),
                  _buildEditableField('Height', _heightController, type: TextInputType.number),
                  _buildEditableField('Weight', _weightController, type: TextInputType.number),
                ],
              ),
            ),
          ),
          if (_isEditing)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      child: Text('Save'),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _cancelChanges,
                      child: Text('Cancel'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
