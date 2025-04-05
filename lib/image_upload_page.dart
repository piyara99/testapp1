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

  List<Map<String, dynamic>> images = []; // List to hold fetched images

  // Fetch images from Firestore
  Future<void> _fetchImages() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('imageLibrary').get();
    setState(() {
      images =
          querySnapshot.docs.map((doc) {
            return {'id': doc.id, 'name': doc['caption'], 'image': doc['url']};
          }).toList();
    });
  }

  // Add image URL and caption to Firestore
  Future<void> _addImage() async {
    if (_urlController.text.isEmpty || _captionController.text.isEmpty) return;

    try {
      // Add the URL and caption to Firestore
      await FirebaseFirestore.instance.collection('imageLibrary').add({
        'url': _urlController.text.trim(),
        'caption': _captionController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image added successfully!")),
      );

      _fetchImages(); // Refresh the image list

      setState(() {
        _urlController.clear();
        _captionController.clear();
      });
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding image: $e')));
    }
  }

  // Edit the caption of an image
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
                  // Update Firestore with new caption
                  await FirebaseFirestore.instance
                      .collection('imageLibrary')
                      .doc(images[index]['id'])
                      .update({'caption': nameController.text});
                  setState(() {
                    images[index]['name'] = nameController.text;
                  });
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

  // Delete an image from Firestore
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
    _fetchImages(); // Fetch images when the page is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Image Upload'),
        backgroundColor: Colors.blue[400],
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
                color: Colors.blue[400],
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[400],
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
                    color: Colors.blue[50],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          images[index]['image'],
                          height: 80,
                        ), // Display image from URL
                        SizedBox(height: 8),
                        Text(
                          images[index]['name'],
                          style: TextStyle(color: Colors.blue[600]),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue[400]),
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
