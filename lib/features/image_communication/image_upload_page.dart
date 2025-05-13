import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ImageUploadPage extends StatefulWidget {
  const ImageUploadPage({super.key});

  @override
  State<ImageUploadPage> createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  String? _selectedCategory;

  List<Map<String, dynamic>> images = [];

  final List<String> categories = [
    'Flashcards',
    'Emotions',
    'Daily Routines',
    'Hygiene',
    'Fruits',
    'School',
    'Toys & Play',
    'Safety Signs',
    'Do & Don’t',
    'Reward Icons',
    'Clothing',
    'Places',
    'People',
    'Animals',
    'Actions',
    'Weather',
    'Vehicles',
  ];

  Future<void> _fetchImages() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('imageLibrary').get();

    if (!mounted) return;

    setState(() {
      images =
          querySnapshot.docs.map((doc) {
            return {'id': doc.id, 'name': doc['caption'], 'image': doc['url']};
          }).toList();
    });
  }

  Future<void> _addImage() async {
    if (_urlController.text.isEmpty ||
        _captionController.text.isEmpty ||
        _selectedCategory == null) {
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('imageLibrary').add({
        'url': _urlController.text.trim(),
        'caption': _captionController.text.trim(),
        'category': _selectedCategory,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image added successfully!")),
      );

      _fetchImages();

      setState(() {
        _urlController.clear();
        _captionController.clear();
        _selectedCategory = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding image: $e')));
    }
  }

  void _editImage(int index) {
    TextEditingController nameController = TextEditingController(
      text: images[index]['name'],
    );
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Image Caption'),
            content: TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Caption'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.blue[400]),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('imageLibrary')
                      .doc(images[index]['id'])
                      .update({'caption': nameController.text});
                  setState(() {
                    images[index]['name'] = nameController.text;
                  });
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[400],
                ),
                child: Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  void _deleteImage(int index) async {
    final imageId = images[index]['id'];
    await FirebaseFirestore.instance
        .collection('imageLibrary')
        .doc(imageId)
        .delete();
    setState(() {
      images.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: const [
            CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.image, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text(
              'Image Upload',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Image URL and Caption:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(labelText: 'Enter caption'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Select category'),
              items:
                  categories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCategory = val;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text("Add Image"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.deepPurple.shade100,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(images[index]['image'], height: 80),
                        const SizedBox(height: 8),
                        Text(
                          images[index]['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.deepPurple[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Colors.deepPurple[700],
                              ),
                              onPressed: () => _editImage(index),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red[400]),
                              onPressed: () => _deleteImage(index),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
