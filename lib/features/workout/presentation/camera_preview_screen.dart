import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';

/// Stage A of Phase 5: just proves the camera can open and show a live
/// preview. No pose detection or rep counting yet — that's Stage B,
/// added once this is confirmed working end-to-end.
class CameraPreviewScreen extends StatefulWidget {
  const CameraPreviewScreen({super.key});

  @override
  State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  CameraController? _controller;
  String? _error;

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

      // Prefer the front camera, since push-ups are typically filmed
      // facing the phone rather than from behind it.
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();
      if (!mounted) return;

      setState(() => _controller = controller);
    } catch (e) {
      // Most common cause here is the user denying the camera
      // permission prompt.
      setState(() => _error = 'Camera error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Test')),
      body: Center(
        child: _error != null
            ? Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.videocam_off, size: 48, color: AppColors.danger),
                    const SizedBox(height: AppSpacing.md),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _error = null);
                        _setup();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : _controller == null || !_controller!.value.isInitialized
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: CameraPreview(_controller!),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Text(
                        '✅ Camera is working',
                        style: TextStyle(
                            color: AppColors.accentTertiary,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: Text(
                          'Push-up rep counting comes next, once this preview is confirmed stable.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
