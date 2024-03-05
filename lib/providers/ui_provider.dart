import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../Models/song_model_img.dart';
import '../components/constants.dart';
import '../components/palleteGenerator.dart';
import '../utils/app_audio_query.dart';
import '../utils/app_permission.dart';
import '../utils/audio_manager.dart';

class UiProvider extends ChangeNotifier {
  List<SongModelImg> songDataList = [];
  AppPermissionHandler appPermissionHandler = AppPermissionHandler();
  AppAudioQuery appAudioQuery = AppAudioQuery();
  AudioPlayerManager audioPlayerManager = AudioPlayerManager();
  ImageColorExtractor colorExtractor = ImageColorExtractor.instance;
  int errorCount = 0;
  Duration? songDuration;
  List<Color> appDynamicColor = [
    Colors.black,
    Colors.black87,
    Colors.white70,
    Colors.black54
  ];
  Uint8List? backGroundImage;
  int songIndex = 0;

  Future<void> updateColor({dynamic bgImg}) async {
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

  Future<void> updateBackGroundImage({Uint8List? newImage}) async {
    backGroundImage = newImage;
    await updateColor(bgImg: backGroundImage ?? kbackGroundImage);
  }

  getSongsList({required Function showDialoge}) async {
    await appPermissionHandler.askPermission(showDialog: showDialoge);
    songDataList = await appAudioQuery.getALlAudioList();
    notifyListeners();
  }

  playSong({required int index}) async {
    try {
      final songImage = songDataList[index].image;
      final songData = songDataList[index].songModel.data;
      await updateBackGroundImage(newImage: songImage);
      await audioPlayerManager.play(songData);
      songDuration =audioPlayerManager.audioPlayer.duration;
      songIndex = index;
      notifyListeners();
      errorCount = 0;
    } catch (e) {
      if(errorCount >= 5){
        return;
      }
      errorCount++;
      showLog('catching error $e $errorCount');
      playNextSong();
    }
  }

  playNextSong() async {
    try {

      if (songIndex <= songDataList.length - 2) {
        songIndex += 1;
        final songImage = songDataList[songIndex].image;
        final songData = songDataList[songIndex].songModel.data;
        await updateBackGroundImage(newImage: songImage);
        await audioPlayerManager.play(songData);
        songDuration =audioPlayerManager.audioPlayer.duration;
        notifyListeners();
        errorCount = 0;
      }
    } catch (e) {
      if(errorCount >= 5){
        return;
      }
      errorCount++;
      showLog('catching error $e $errorCount');
      playNextSong();
    }
  }

  playPreviousSong() async {
    if (songIndex != 0) {
      songIndex -= 1;
      final songImage = songDataList[songIndex].image;
      final songData = songDataList[songIndex].songModel.data;
      await updateBackGroundImage(newImage: songImage);
      await audioPlayerManager.play(songData);
      songDuration =audioPlayerManager.audioPlayer.duration;
      notifyListeners();
    }
  }

  ifCompletedPlayNext() async {}

  playPauseSong() {
    audioPlayerManager.pause();
    songDuration = audioPlayerManager.audioPlayer.duration;
    notifyListeners();
  }
}
