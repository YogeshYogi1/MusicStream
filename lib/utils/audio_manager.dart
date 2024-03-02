import 'package:just_audio/just_audio.dart';

class AudioPlayerManager {
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();
  late AudioPlayer _audioPlayer;

  factory AudioPlayerManager() {
    return _instance;
  }

  AudioPlayerManager._internal() {
    _audioPlayer = AudioPlayer();
  }

  AudioPlayer get audioPlayer => _audioPlayer;

  Future<void> play(String url) async {
    await _audioPlayer.setUrl(url);
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> next() async {
    await _audioPlayer.seekToNext();
  }

  Future<void> previous() async {
    await _audioPlayer.seekToPrevious();
  }

  Future<void> setShuffleMode() async {
    await _audioPlayer.shuffle();
  }

  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<Duration?> get positionStream => _audioPlayer.positionStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<SequenceState?> get sequenceStateStream => _audioPlayer.sequenceStateStream;
}