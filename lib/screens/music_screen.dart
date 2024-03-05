import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_stream/components/widgets.dart';
import 'package:provider/provider.dart';

import '../Models/song_model_img.dart';
import '../components/constants.dart';
import '../providers/offline_provider.dart';

class MusicScreen extends StatefulWidget {
  final SongModelImg songModelImg;
  const MusicScreen({super.key, required this.songModelImg});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  String endTime = '';
  late OfflineProvider offlineProvider;
  @override
  void initState() {
    endTime = widget.songModelImg.songModel.duration.toString();
    offlineProvider = Provider.of<OfflineProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          /// back ground Image
          backgroundImg(),

          /// ContentView
          GlassMorphism(
            start: 0,
            end: 0,
            blurValue: 30,
            needBorder: false,
            child: Padding(
              padding: const EdgeInsets.only(left: 13, right: 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// App Bar
                  appBar(context),

                  /// Song CoverImage
                  coverImage(),

                  /// Song Title
                  songTitle(),

                  /// Song Artist
                  artistName(),

                  /// song Progress
                  songProgress(),

                  /// Play Pause and Skip
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 25),
                          child: IconButton(
                            onPressed: () {
                              offlineProvider.playPreviousSong();
                            },
                            icon: const Icon(
                              Icons.skip_previous,
                              color: kwhiteColor,
                              size: 50,
                            ),
                          ),
                        ),
                        StreamBuilder(
                          stream:
                              offlineProvider.audioPlayerManager.playerStateStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data!.processingState ==
                                  ProcessingState.completed) {
                                offlineProvider.playNextSong();
                              }
                              return IconButton(
                                onPressed: () {
                                  showLog(snapshot.data!.playing.toString());
                                  if (snapshot.data!.playing) {
                                    offlineProvider.playPauseSong();
                                  } else {
                                    offlineProvider.playSong(
                                        index: offlineProvider.songIndex);
                                  }
                                },
                                icon: Icon(
                                  snapshot.data!.playing ?  Icons.play_circle_outlined : Icons.pause,
                                  color: kwhiteColor,
                                  size: 60,
                                ),
                              );
                            } else {
                              return IconButton(
                                  onPressed: () {},
                                  icon: const CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 5));
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: IconButton(
                            onPressed: () {
                              offlineProvider.playNextSong();
                            },
                            icon: const Icon(
                              Icons.skip_next,
                              color: kwhiteColor,
                              size: 50,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Queue
          Positioned(
            top: size.height - 150,
            left: size.width / 2.25,
            child: const Text(
              'Queue',
              style: kTextStyleBasic,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          /// Queue
          Positioned(
            top: size.height - 100,
            child: SizedBox(
              height: 70,
              width: size.width,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: offlineProvider.songDataList.length ?? 0,
                itemBuilder: (context, index) => Consumer<OfflineProvider>(
                  builder: (context, value, child) => Container(
                    height: 70,
                    width: 80,
                    margin: const EdgeInsets.only(right: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: offlineProvider.songDataList[index].image == null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              kbackGroundImage,
                              fit: BoxFit.cover,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              offlineProvider.songDataList[index].image!,
                              fit: BoxFit.fill,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Consumer<OfflineProvider> songProgress() {
    return Consumer<OfflineProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            StreamBuilder<Duration?>(
              stream: provider.audioPlayerManager.positionStream,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  String formattedTime =
                      "${snapshot.data.inMinutes}:${(snapshot.data.inSeconds % 60).toString().padLeft(2, '0')}";
                  return Text(
                    formattedTime,
                    style: kTextStyleBasic,
                    overflow: TextOverflow.ellipsis,
                  );
                } else {
                  return const Text(
                    '0',
                    style: kTextStyleBasic,
                    overflow: TextOverflow.ellipsis,
                  );
                }
              },
            ),
            Expanded(
              child: StreamBuilder<Duration?>(
                stream: provider.audioPlayerManager.positionStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final max = offlineProvider.audioPlayerManager.audioPlayer
                            .duration?.inMilliseconds ??
                        30000;
                    final current = snapshot.data!.inMilliseconds;
                    return Slider(
                      onChanged: (double values) {
                        provider.audioPlayerManager
                            .seek(Duration(milliseconds: values.toInt()));
                      },
                      value: max.toDouble() <= current
                          ? max.toDouble()
                          : current.toDouble(),
                      min: 0,
                      max: max.toDouble(),
                      activeColor: provider.appDynamicColor.last,
                      thumbColor: provider.appDynamicColor.first,
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
            Consumer<OfflineProvider>(builder: (context, value, child) {
              final snapshot = provider.songDuration;
              var formattedTime = '';
              if (snapshot != null) {
                formattedTime =
                    "${snapshot.inMinutes}:${(snapshot.inSeconds % 60).toString().padLeft(2, '0')}";
              }
              return Text(
                formattedTime,
                style: kTextStyleBasic,
                overflow: TextOverflow.ellipsis,
              );
            }),
          ],
        );
      },
    );
  }

  Padding artistName() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: SizedBox(
        height: 20,
        child: Consumer<OfflineProvider>(
          builder: (context, value, child) => Text(
            value.songDataList[offlineProvider.songIndex].songModel.artist
                .toString(),
            style: kTextStyleBasic,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Padding songTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: SizedBox(
        height: 45,
        child: Consumer<OfflineProvider>(
          builder: (context, value, child) => Text(
            value.songDataList[offlineProvider.songIndex].songModel.title.toString(),
            style: kTextStyleBasic,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Consumer<OfflineProvider> coverImage() {
    return Consumer<OfflineProvider>(
      builder: (context, value, child) => Container(
        height: 250,
        width: 250,
        margin: const EdgeInsets.only(top: 60, bottom: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(200),
        ),
        child: value.backGroundImage == null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  kbackGroundImage,
                  fit: BoxFit.cover,
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  value.backGroundImage!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.fill,
                ),
              ),
      ),
    );
  }

  SizedBox appBar(BuildContext context) {
    return SizedBox(
      height: 80,
      width: double.maxFinite,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 25,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'Now Playing',
              style: kTextStyleBasic,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              color: Colors.white,
              size: 25,
            ),
          )
        ],
      ),
    );
  }

  Widget backgroundImg() {
    return Consumer<OfflineProvider>(
      builder: (context, value, child) {
        return SizedBox(
          height: double.maxFinite,
          width: double.maxFinite,
          child: value.backGroundImage == null
              ? Image.asset(
                  kbackGroundImage,
                  fit: BoxFit.cover,
                )
              : Image.memory(
                  value.backGroundImage!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.fill,
                ),
        );
      },
    );
  }
}
