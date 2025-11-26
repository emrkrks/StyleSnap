import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';

class ScreenshotService {
  /// Capture a widget as an image
  static Future<Uint8List?> captureWidget(
    GlobalKey key, {
    double pixelRatio = 3.0,
  }) async {
    try {
      // Find the RenderObject
      RenderRepaintBoundary? boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) return null;

      // Convert to image
      ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);

      // Convert to bytes
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing widget: $e');
      return null;
    }
  }

  /// Save screenshot to temporary directory
  static Future<File?> saveToTemp(Uint8List imageBytes, String filename) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$filename.png');
      await file.writeAsBytes(imageBytes);
      return file;
    } catch (e) {
      debugPrint('Error saving screenshot: $e');
      return null;
    }
  }

  /// Capture and save widget in one call
  static Future<File?> captureAndSave(
    GlobalKey key,
    String filename, {
    double pixelRatio = 3.0,
  }) async {
    final imageBytes = await captureWidget(key, pixelRatio: pixelRatio);
    if (imageBytes == null) return null;

    return await saveToTemp(imageBytes, filename);
  }
}
