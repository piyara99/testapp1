import 'package:flutter/material.dart';

class ImageCommunicationPage extends StatefulWidget {
  const ImageCommunicationPage({super.key});

  @override
  ImageCommunicationPageState createState() => ImageCommunicationPageState();
}

class ImageCommunicationPageState extends State<ImageCommunicationPage> {
  List<Map<String, dynamic>> images = [
    {'name': 'Drink Water', 'image': 'assets/water.jpg'},
    {'name': 'Eat Food', 'image': 'assets/food.jpg'},
    {'name': 'Sleep', 'image': 'assets/sleep.jpg'},
  ];

  void _addImage() {
    setState(() {
      images.add({'name': 'New Image', 'image': 'assets/placeholder.jpg'});
    });
  }

  void _editImage(int index) {
    TextEditingController nameController = TextEditingController(
      text: images[index]['name'],
    );
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Image Communication'),
            content: TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Label Name'),
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
                onPressed: () {
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

  void _deleteImage(int index) {
    setState(() {
      images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Image Communication'),
        backgroundColor: Colors.blue[400],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select an Image to Communicate:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[400],
              ),
            ),
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
                        Image.asset(images[index]['image'], height: 80),
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
            Center(
              child: ElevatedButton(
                onPressed: _addImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[400],
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  'Add New Image',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
