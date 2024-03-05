import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:music_stream/Models/song_model_img.dart';
import 'package:music_stream/components/widgets.dart';
import 'package:music_stream/providers/offline_provider.dart';
import 'package:music_stream/screens/music_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../components/constants.dart';

class MusicListScreen extends StatefulWidget {
  const MusicListScreen({super.key});

  @override
  State<MusicListScreen> createState() => _MusicListScreenState();
}

class _MusicListScreenState extends State<MusicListScreen> {
  Uint8List? bgImg;
  late final ScrollController _scrollController;
  ValueNotifier<double> streamPlayerHeight = ValueNotifier(250);
  ValueNotifier<double> categoryHeight = ValueNotifier(50);
  final ValueNotifier<double> _fontSize = ValueNotifier(20);
  ValueNotifier<double> miniPlayerHeight = ValueNotifier(80);
  late OfflineProvider offlineProvider;

  @override
  void initState() {
    super.initState();
    offlineProvider = Provider.of<OfflineProvider>(context, listen: false);
    offlineProvider.getSongsList(showDialoge: _showingDialog);
    offlineProvider.updateBackGroundImage();
    _scrollController = ScrollController();
    sizeControlling();
  }

  sizeControlling() {
    _scrollController.addListener(() {
      if (_scrollController.offset <= 593) {
        streamPlayerHeight.value = 250.0 - _scrollController.offset;
        categoryHeight.value = 50 - _scrollController.offset;
        _fontSize.value = 20.0 - _scrollController.offset / 6.0;
        _fontSize.value = _fontSize.value.clamp(0.0, 20.0);
        if (streamPlayerHeight.value < 80) {
          streamPlayerHeight.value = 80.0;
        }
        if (categoryHeight.value <= 0) {
          categoryHeight.value = 0;
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.loose,
        children: [
          backgroundImg(),
          Column(
            children: [
              search(),
              Expanded(
                child: Column(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: categoryHeight,
                      builder: (context, value, child) {
                        return Container(
                          margin: const EdgeInsets.only(top: 0),
                          height: value,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 13),
                                child: titles('All'),
                              ),
                              titles('Artist'),
                              titles('Album'),
                              titles('Genre'),
                            ],
                          ),
                        );
                      },
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return MusicScreen(
                                songModelImg: offlineProvider.songDataList[0],
                              );
                            },
                          ),
                        );
                      },
                      child: ValueListenableBuilder(
                          valueListenable: streamPlayerHeight,
                          builder: (context, value, child) {
                            return Consumer<OfflineProvider>(
                              builder: (context, color, child) => Container(
                                height: streamPlayerHeight.value,
                                width: double.maxFinite,
                                margin: const EdgeInsets.only(
                                    left: 13, right: 13, top: 13, bottom: 13),
                                decoration: BoxDecoration(
                                  color: color.appDynamicColor.length > 1
                                      ? color.appDynamicColor[0]
                                      : null,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Play With Friends While Working ",
                                            style: kTextStyleBasic.copyWith(
                                                fontSize: _fontSize.value),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Icon(
                                            Icons.play_arrow_outlined,
                                            size: 40,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: _fontSize.value,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 15),
                                            child: Text(
                                              'DeadPool is Playing ....',
                                              style: kTextStyleBasic.copyWith(
                                                  fontSize: _fontSize.value),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
                    Expanded(
                      child: GlassMorphism(
                        start: 0.3,
                        end: 0.5,
                        bRadius: 25,
                        blurValue: 20,
                        color: Colors.black,
                        isTopRadiusOnly: true,
                        child: Consumer<OfflineProvider>(
                          builder: (context, value, child) {
                            return offlineProvider.songDataList.isNotEmpty
                                ? ListView.builder(
                                    itemCount: value.songDataList.length,
                                    controller: _scrollController,
                                    padding: const EdgeInsets.only(bottom: 100),
                                    itemBuilder: (context, index) {
                                      final model = value.songDataList[index];
                                      return SongTileCard(
                                        songName:
                                            model.songModel.displayNameWOExt,
                                        time: model.songModel.artist.toString(),
                                        songCoverImg: model.image,
                                        playButton: () async {
                                          await value.playSong(index: index);
                                        },
                                      );
                                    },
                                  )
                                : const Center(
                                    child: CircularProgressIndicator(),
                                  );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                miniPlayerHeight.value -= details.primaryDelta!.toDouble();
                if (miniPlayerHeight.value < 80) {
                  miniPlayerHeight.value = 80;
                } else if (miniPlayerHeight.value > 250) {
                  miniPlayerHeight.value = 250;
                }
              },
              onVerticalDragEnd: (details) {
                if (miniPlayerHeight.value > 160) {
                  miniPlayerHeight.value = 250;
                } else {
                  miniPlayerHeight.value = 80;
                }
              },
              child: ValueListenableBuilder(
                valueListenable: miniPlayerHeight,
                builder: (context, containerHeight, child) =>
                    Consumer<OfflineProvider>(
                  builder: (context, value, child) {
                    int songIndex = value.songIndex;

                    return offlineProvider.songDataList.isNotEmpty
                        ? StreamBuilder(
                            stream: value.audioPlayerManager.positionStream,
                            builder: (context, snapshot) => MiniPlayerView(
                              height: containerHeight,
                              songName: value.songDataList[songIndex].songModel
                                  .displayNameWOExt,
                              time: value
                                  .songDataList[songIndex].songModel.artist
                                  .toString(),
                              songCoverImg: value.songDataList[songIndex].image,
                              bgColor: value.appDynamicColor.length > 1
                                  ? value.appDynamicColor[0]
                                  : null,
                              playButton: () async {
                                await value.playSong(
                                  index: songIndex,
                                );
                              },
                              nextButton: () async {
                                await value.playNextSong();
                              },
                              previousButton: () async {
                                await value.playPreviousSong();
                              },
                              playPauseIcon: kPlayIcon,
                            ),
                          )
                        : Container(
                            height: 80,
                            color: Colors.black45,
                          );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _showingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
              'Please grant the storage permission to use this feature.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Settings'),
            ),
          ],
        );
      },
    );
  }

  Widget titles(String name) {
    return Padding(
      padding: const EdgeInsets.only(right: 25),
      child: GlassMorphism(
        start: 0.5,
        end: 0.8,
        bRadius: 20,
        needBorder: false,
        color: Colors.black,
        child: SizedBox(
          width: 80,
          child: Center(
            child: Text(
              name,
              style: kTextStyleBasic,
            ),
          ),
        ),
      ),
    );
  }

  Widget search() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        child: GlassMorphism(
          start: 0.2,
          end: 0.2,
          bRadius: 20,
          color: Colors.black,
          child: Container(
            height: 40,
            width: double.maxFinite,
            alignment: Alignment.bottomLeft,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search,
                size: 25,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget backgroundImg() {
    return Consumer<OfflineProvider>(
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: value.appDynamicColor,
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
            ),
          ),
        );
      },
    );
  }
}

class MiniPlayerView extends StatelessWidget {
  final double height;
  final VoidCallback playButton;
  final VoidCallback nextButton;
  final VoidCallback previousButton;
  final String songName;
  final String time;
  final Uint8List? songCoverImg;
  final Color? bgColor;
  final Widget playPauseIcon;

  const MiniPlayerView(
      {super.key,
      required this.height,
      required this.playButton,
      required this.songName,
      required this.time,
      this.songCoverImg,
      this.bgColor = Colors.black,
      required this.nextButton,
      required this.previousButton,
      required this.playPauseIcon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: bgColor,
      child: Container(
        height: 45,
        padding: const EdgeInsets.only(left: 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: songCoverImg == null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        kbackGroundImage,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.memory(songCoverImg!),
            ),
            const SizedBox(
              width: 20,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 227,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    songName + songName,
                    style: kTextStyleBasic,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    time,
                    style: kTextStyleBasic,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: previousButton,
              icon: const Icon(
                Icons.skip_previous,
                color: kwhiteColor,
                size: 30,
              ),
            ),
            IconButton(onPressed: playButton, icon: playPauseIcon),
            IconButton(
              onPressed: nextButton,
              icon: const Icon(
                Icons.skip_next,
                color: kwhiteColor,
                size: 30,
              ),
            )
          ],
        ),
      ),
    );
  }
}
