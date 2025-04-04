import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadPage extends StatefulWidget {
  const ImageUploadPage({super.key});

  @override
  State<ImageUploadPage> createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  File? _image;
  final picker = ImagePicker();
  final TextEditingController _captionController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null || _captionController.text.isEmpty) return;

    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance.ref().child('images/$fileName.jpg');
    final uploadTask = await ref.putFile(_image!);
    final imageUrl = await uploadTask.ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('imageLibrary').add({
      'url': imageUrl,
      'caption': _captionController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Image uploaded successfully!")),
    );

    setState(() {
      _image = null;
      _captionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Image')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _image != null
                ? Image.file(_image!, height: 200)
                : const Icon(Icons.image, size: 150),
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(labelText: "Enter caption"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _pickImage, child: const Text("Pick Image")),
            ElevatedButton(onPressed: _uploadImage, child: const Text("Upload Image")),
          ],
        ),
      ),
    );
  }
}
