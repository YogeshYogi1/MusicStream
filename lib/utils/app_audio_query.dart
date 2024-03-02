import 'dart:developer';
import 'dart:typed_data';

import 'package:on_audio_query/on_audio_query.dart';

import '../Models/song_model_img.dart';

class AppAudioQuery {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<List<SongModelImg>> getALlAudioList() async {
    List<SongModelImg> songs = [];
    final  songList = await _audioQuery.querySongs( ignoreCase: true);
      for(SongModel model in songList){
        Uint8List? uIntData = await getAlbumImage(model.id);
        songs.add(SongModelImg(songModel: model, image: uIntData));
      }
    return songs;
  }

/*  Future<List<GenreModel>> getAlbumList() async {
    List<GenreModel> songList = [];
    bool audioPermission = await _audioQuery.permissionsStatus();
    if (audioPermission) {
      songList = await _audioQuery.queryGenres(sortType: GenreSortType.GENRE);
     var a = await _audioQuery.queryAudiosFrom(AudiosFromType.GENRE,songList[0].id);
      log(a.toString());
     print('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
    }
    return songList;
  }*/

  Future<Uint8List?> getAlbumImage(int id,) async {
    Uint8List? image;
      image = await _audioQuery.queryArtwork(id,ArtworkType.AUDIO);
    return image;
  }


}
