import 'dart:io';
import 'dart:typed_data';

import 'package:cognitiveservice/models/sentiment.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

class ResultDrawer {
  final paint = Paint();
  final double percent = 0.4;

  ResultDrawer();

  Future<ui.FrameInfo> _getImageFrame(Uint8List bytes,
      [int width, int height]) async {
    if (width != null && height != null) {
      final codec = await ui.instantiateImageCodec(bytes,
          targetHeight: width, targetWidth: height);
      return codec.getNextFrame();
    } else {
      final codec = await ui.instantiateImageCodec(bytes);
      return codec.getNextFrame();
    }
  }

  Future<ByteData> draw(FaceEmotion faceEmotion, File base) async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final FaceRectangle rectangle = faceEmotion.faceRectangle;
    final factor = rectangle.width * percent;
    final size = (rectangle.width + factor).truncate();
    final dx = rectangle.left - (factor * 0.5);
    final dy = rectangle.top - size + 0.0;

    var frame = await _getImageFrame(base.readAsBytesSync());
    canvas.drawImage(frame.image, Offset.zero, paint);
    ByteData data = await rootBundle.load(
        "assets/emojies/${faceEmotion.faceAttributes.emotion.compute}.png");
    var frame2 = await _getImageFrame(Uint8List.view(data.buffer), size, size);

    Offset offset = Offset(dx, dy);
    canvas.drawImage(frame2.image, offset, paint);
    ui.Picture picture = recorder.endRecording();

    final img = await picture.toImage(frame.image.width, frame.image.height);
    return await img.toByteData(format: ui.ImageByteFormat.png);
  }
}
