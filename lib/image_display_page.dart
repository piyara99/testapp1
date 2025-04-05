import 'package:flutter/material.dart';

class ImageDisplayPage extends StatefulWidget {
  final String imageUrl;
  final String caption;

  const ImageDisplayPage({
    super.key,
    required this.imageUrl,
    required this.caption,
  });

  @override
  _ImageDisplayPageState createState() => _ImageDisplayPageState();
}

class _ImageDisplayPageState extends State<ImageDisplayPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Image
            Center(
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                height: 300, // Adjust the image size as needed
              ),
            ),
            const SizedBox(height: 20),

            // Display Caption
            Text(
              widget.caption,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Message Input Box
            const Text(
              'Type your message below:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Your message',
              ),
              maxLines: 4, // Allow multiple lines
            ),
            const SizedBox(height: 20),

            // Close Button
            Center(
              child: ElevatedButton(
                onPressed:
                    () => Navigator.pop(context), // Go back to previous page
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
