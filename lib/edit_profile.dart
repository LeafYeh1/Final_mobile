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

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _heightFocus = FocusNode();
  final _weightFocus = FocusNode();

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _heightFocus.dispose();
    _weightFocus.dispose();
    super.dispose();
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
    widget.onChanged?.call(updatedData);
  }

  void _saveChanges() {
    FocusScope.of(context).unfocus(); // 正確收鍵盤
    _notifyChange();
    setState(() {
      _isEditing = false;
    });
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
    _notifyChange();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  Widget _buildEditableField(String label, TextEditingController controller, FocusNode focusNode,
      {TextInputType? type}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: type,
          onTap: _startEditing,
          onChanged: (_) => _notifyChange(),
          style: TextStyle(fontSize: 25),
          decoration: InputDecoration(
            filled: true,
            fillColor: focusNode.hasFocus ? Color(0x504e5549) : Color(0xAF4e5549),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: TextStyle(fontSize: 22)),
        backgroundColor: Colors.lightGreen,
      ),
      backgroundColor: const Color(0xFFC8D0AD),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // 點擊空白處也收鍵盤
          setState(() {
            _isEditing = false;
          });
        },
        child: Column(
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
                    _buildEditableField('Name', _nameController, _nameFocus),
                    _buildEditableField('E-mail', _emailController, _emailFocus),
                    _buildEditableField('Height', _heightController, _heightFocus, type: TextInputType.number),
                    _buildEditableField('Weight', _weightController, _weightFocus, type: TextInputType.number),
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
                        child: Text('Save', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _cancelChanges,
                        child: Text('Cancel', style: TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
