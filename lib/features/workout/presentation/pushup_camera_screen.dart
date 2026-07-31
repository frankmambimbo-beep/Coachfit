import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../data/workout_repository.dart';
import '../domain/workout_session.dart';
import '../domain/pose_analysis/pushup_counter.dart';

class PushupCameraScreen extends ConsumerStatefulWidget {
  const PushupCameraScreen({super.key});

  @override
  ConsumerState<PushupCameraScreen> createState() => _PushupCameraScreenState();
}

class _PushupCameraScreenState extends ConsumerState<PushupCameraScreen> {
  CameraController? _controller;
  PoseDetector? _poseDetector;
  final _counter = PushupCounter();

  String? _error;
  bool _isProcessingFrame = false;
  bool _streaming = false;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'No camera found on this device.');
        return;
      }

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      // NV21 is requested explicitly because it's the one raw format
      // ML Kit's InputImage.fromBytes accepts directly on Android
      // without extra plane-merging logic.
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await controller.initialize();
      if (!mounted) return;

      _poseDetector = PoseDetector(
        options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
      );

      setState(() => _controller = controller);
      await _startStreaming(camera);
    } catch (e) {
      setState(() => _error = 'Camera error: $e');
    }
  }

  Future<void> _startStreaming(CameraDescription camera) async {
    if (_controller == null || _poseDetector == null) return;
    _streaming = true;

    await _controller!.startImageStream((CameraImage image) async {
      // Drop frames while the previous one is still being processed —
      // ML Kit inference takes longer than the camera's frame rate, so
      // without this the queue backs up and the UI stutters badly.
      if (_isProcessingFrame) return;
      _isProcessingFrame = true;

      try {
        final inputImage = _toInputImage(image, camera);
        if (inputImage != null) {
          final poses = await _poseDetector!.processImage(inputImage);
          if (poses.isNotEmpty && mounted) {
            final completedRep = _counter.processPose(poses.first);
            if (completedRep) {
              setState(() {});
            }
          }
        }
      } catch (_) {
        // A single bad frame shouldn't crash the session — just skip it.
      } finally {
        _isProcessingFrame = false;
      }
    });
  }

  InputImage? _toInputImage(CameraImage image, CameraDescription camera) {
    final bytes = _concatenatePlanes(image.planes);

    final rotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.rotation0deg;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final allBytes = WriteBuffer();
    for (final plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  Future<void> _finishSet() async {
    if (_controller != null && _streaming) {
      await _controller!.stopImageStream();
      _streaming = false;
    }

    if (_counter.reps > 0) {
      await ref.read(workoutRepositoryProvider.notifier).addSession(
        title: 'Push-up Set',
        type: WorkoutType.strength,
        date: DateTime.now(),
        exercises: [
          ExerciseEntry(name: 'Push-ups', sets: 1, reps: _counter.reps),
        ],
      );
    }

    if (mounted) context.pop();
  }

  @override
  void dispose() {
    if (_streaming) _controller?.stopImageStream();
    _controller?.dispose();
    _poseDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Push-up Counter')),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(_error!, textAlign: TextAlign.center),
              ),
            )
          : _controller == null || !_controller!.value.isInitialized
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(_controller!),
                    Positioned(
                      top: AppSpacing.lg,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            '${_counter.reps}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: AppSpacing.xl,
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentTertiary,
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        ),
                        onPressed: _finishSet,
                        child: Text('Finish Set (${_counter.reps} reps)'),
                      ),
                    ),
                  ],
                ),
    );
  }
}
