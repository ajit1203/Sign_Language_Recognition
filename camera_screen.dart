import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';

class CameraScreen extends StatefulWidget {
  final CameraController controller;

  const CameraScreen({Key? key, required this.controller}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  String _convertedText = ''; // Text received from backend
  bool _isCameraReady = false;
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await _controller.initialize();
      setState(() {
        _isCameraReady = true;
      });
      _startCameraFeed(); // Start sending camera feed to backend
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _startCameraFeed() {
    // Send continuous video feed to backend (example implementation)
    _controller.startImageStream((CameraImage image) {
      // Process the image and send it to backend continuously
      // Replace this with your actual implementation
      sendImageToBackend(image).then((response) {
        if (mounted) {
          setState(() {
            _convertedText = response; // Update converted text from backend
          });
        }
      }).catchError((error) {
        print('Error sending image to backend: $error');
      });
    });
  }

  Future<String> sendImageToBackend(CameraImage image) async {
    // Simulated function to process and send image to backend
    // Replace this with your actual implementation
    return Future.delayed(Duration(seconds: 1), () {
      return 'Text from backend'; // Simulated response
    });
  }

  void _speakText() async {
    await flutterTts.speak(_convertedText);
  }

  @override
  void dispose() {
    _controller.stopImageStream(); // Stop the image stream
    _controller.dispose(); // Dispose the camera controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Camera Screen'),
          backgroundColor: Colors.grey[900], // Dark grey color for app bar
        ),
        body: _isCameraReady
            ? Stack(
                children: [
                  Transform.scale(
                    scale: _controller.value.aspectRatio /
                        MediaQuery.of(context).size.aspectRatio,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: CameraPreview(_controller),
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
        bottomNavigationBar: Container(
          height: 200, // Fixed height for the bottom navigation bar
          color: Colors.grey.withOpacity(0.8),
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Converted Text:',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        _convertedText,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.0), // Add spacing between text and buttons
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _speakText,
                    child: Text('Speak Text'),
                  ),
                  SizedBox(width: 8.0), // Add spacing between buttons
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _convertedText = '';
                      });
                    },
                    child: Text('Clear'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}