import 'dart:typed_data';
import 'dart:ui';
import 'package:palette_generator/palette_generator.dart';
import 'package:flutter/material.dart';

class ImageColorExtractor {

  static ImageColorExtractor? _imageColorExtractor;

  ImageColorExtractor._instance();

  static ImageColorExtractor get instance{
    _imageColorExtractor ??= ImageColorExtractor._instance();
    return _imageColorExtractor!;
  }


  Future<List<Color>> extractColors(
    dynamic imagePath,
  ) async {
    List<Color> colors = [];

    try {
      PaletteGenerator? paletteGenerator;
      if (imagePath is String) {
        paletteGenerator = await PaletteGenerator.fromImageProvider(
            AssetImage(imagePath),
            maximumColorCount: 3);
      } else {
        paletteGenerator =    await PaletteGenerator.fromImageProvider(MemoryImage(imagePath),
            maximumColorCount: 3);
      }

      if (paletteGenerator != null && paletteGenerator.colors.isNotEmpty) {
        colors.addAll(paletteGenerator.colors);
      }
    } catch (e) {
      // Handle errors, e.g., if the image is not found or cannot be decoded
      print('Error extracting colors: $e');
    }

    return colors;
  }
}
