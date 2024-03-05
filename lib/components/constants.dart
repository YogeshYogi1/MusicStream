import 'dart:developer';

import 'package:flutter/material.dart';

const String kbackGroundImage = 'assets/musicBg.jpg';
const Color kBackgroundColor = Color(0xffca8daf);
const Color kwhiteColor = Colors.white;

const TextStyle kTextStyleBasic =
    TextStyle(color: kwhiteColor, fontSize: 16, fontWeight: FontWeight.w500);
const Icon kPlayIcon = Icon(
  Icons.play_circle_outline_rounded,
  color: kwhiteColor,
  size: 30,
);

const Icon kResumeIcon = Icon(
  Icons.pause,
  color: kwhiteColor,
  size: 30,
);

showLog(String msg) {
  log('>>>>>>>>>>>>>>>>>>>>> + ${msg.toString()}');
}
