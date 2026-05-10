import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

void main() {
  runApp(const AIObjectScannerApp());
}

class AIObjectScannerApp extends StatelessWidget {
  const AIObjectScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Object Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const ObjectDetectionPage(),
    );
  }
}

class ObjectDetectionPage extends StatefulWidget {
  const ObjectDetectionPage({super.key});

  @override
  State<ObjectDetectionPage> createState() => _ObjectDetectionPageState();
}

class _ObjectDetectionPageState extends State<ObjectDetectionPage> {
  List<YOLOResult> detections = [];
  double fps = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${detections.length} objects',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${fps.toStringAsFixed(1)} FPS',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: YOLOView(
                modelPath: 'assets/models/yolo11n.tflite',
                task: YOLOTask.detect,
                lensFacing: LensFacing.back,
                showOverlays: true,
                confidenceThreshold: 0.25,
                iouThreshold: 0.7,
                useGpu: false,
                onResult: (results) {
                  if (!mounted) return;

                  setState(() {
                    detections = results;
                  });
                },
                onPerformanceMetrics: (metrics) {
                  if (!mounted) return;

                  setState(() {
                    fps = metrics.fps;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}