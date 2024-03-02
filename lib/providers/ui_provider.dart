import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../components/constants.dart';
import '../components/palleteGenerator.dart';

class UiProvider extends ChangeNotifier{
/*  ValueNotifier<List<Color>> colors = ValueNotifier(
      [Colors.black, Colors.black87, Colors.white70, Colors.black54]);
  ValueNotifier<double> containerHeight = ValueNotifier(250);
  final ValueNotifier<double> _fontSize = ValueNotifier(20);
  ValueNotifier<double> containerMinHeight = ValueNotifier(80);*/
  ImageColorExtractor colorExtractor = ImageColorExtractor.instance;
  List<Color> appDynamicColor =  [];
  Uint8List? backGroundImage;


 Future<void> updateColor({dynamic bgImg }) async {
    final value = await colorExtractor.extractColors(bgImg ?? kbackGroundImage);
    if (value.length >= 2) {
      appDynamicColor = value;
    } else {
      appDynamicColor = [
        Colors.black,
        Colors.black87,
        Colors.white70,
        Colors.black54
      ];
    }
    notifyListeners();
  }

  updateBackGroundImage(Uint8List? newImage){
   backGroundImage = newImage;
   notifyListeners();
  }


}