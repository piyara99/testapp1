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
            backgroundColor: Colors.blue[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Edit Image',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
            content: TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Label Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.redAccent),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
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
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text(
          'Say It with Pictures!',
          style: TextStyle(
            fontFamily: 'ComicSans',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[300],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Tap a card to speak!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Optional: play sound or give visual cue here
                    },
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.white,
                      shadowColor: Colors.blue[200],
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.asset(
                                images[index]['image'],
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              images[index]['name'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.orangeAccent,
                                  ),
                                  onPressed: () => _editImage(index),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red[400],
                                  ),
                                  onPressed: () => _deleteImage(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _addImage,
              icon: Icon(Icons.add, color: Colors.white),
              label: Text(
                'Add New Image',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[400],
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
