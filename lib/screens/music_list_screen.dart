import 'dart:ffi';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:music_stream/components/widgets.dart';
import 'package:music_stream/providers/ui_provider.dart';
import 'package:music_stream/utils/app_audio_query.dart';
import 'package:music_stream/utils/app_permission.dart';
import 'package:music_stream/utils/audio_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../Models/song_model_img.dart';
import '../components/constants.dart';
import '../components/palleteGenerator.dart';

class MusicListScreen extends StatefulWidget {
  const MusicListScreen({super.key});

  @override
  State<MusicListScreen> createState() => _MusicListScreenState();
}

class _MusicListScreenState extends State<MusicListScreen> {
  AppPermissionHandler appPermissionHandler = AppPermissionHandler();
  AppAudioQuery appAudioQuery = AppAudioQuery();
  Uint8List? bgImg;
  int playingIndex =0 ;
  List<SongModelImg> songDataList = [];
  late final ScrollController _scrollController;
  AudioPlayerManager audioPlayerManager = AudioPlayerManager();

  ValueNotifier<List<Color>> colors = ValueNotifier(
      [Colors.black, Colors.black87, Colors.white70, Colors.black54]);
  ValueNotifier<double> containerHeight = ValueNotifier(250);
  final ValueNotifier<double> _fontSize = ValueNotifier(20);
  ValueNotifier<double> containerMinHeight = ValueNotifier(80);

  @override
  void initState() {
    super.initState();
    Provider.of<UiProvider>(context).updateColor();
    _scrollController = ScrollController();
    sizeControlling();
    initialSetup();
  }

  initialSetup() async {
    await appPermissionHandler.askPermission(showDialog: showingDialog);
    songDataList = await appAudioQuery.getALlAudioList();
  }

  sizeControlling() {
    _scrollController.addListener(() {
      containerHeight.value = 250.0 - _scrollController.offset;
      _fontSize.value = 20.0 - _scrollController.offset / 6.0;
      _fontSize.value = _fontSize.value.clamp(0.0, 20.0);
      if (containerHeight.value < 80) {
        containerHeight.value = 80.0;
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
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      height: 35,
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
                    ),
                    InkWell(
                      onTap: () {},
                      child: ValueListenableBuilder(
                          valueListenable: containerHeight,
                          builder: (context, value, child) {
                            return Container(
                              height: containerHeight.value,
                              width: double.maxFinite,
                              margin: const EdgeInsets.only(
                                  left: 13, right: 13, top: 13, bottom: 13),
                              decoration: BoxDecoration(
                                color: colors.value.length > 1
                                    ? colors.value[0]
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
                                    padding: EdgeInsets.all(8.0),
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
                        child: songDataList.isNotEmpty
                            ? ListView.builder(
                                itemCount: songDataList.length,
                                controller: _scrollController,
                                itemBuilder: (context, index) {
                                  return SongTileCard(
                                    songName: songDataList[index]
                                        .songModel
                                        .displayNameWOExt,
                                    time: songDataList[index].songModel.artist.toString(),
                                    songCoverImg: songDataList[index].image,
                                    playButton: () {
                                      setState(
                                        () {
                                          playingIndex = index;
                                          bgImg = songDataList[index].image;
                                         // updateColor();
                                        },
                                      );
                                      audioPlayerManager.play(
                                          songDataList[index].songModel.data);
                                    },
                                  );
                                },
                              )
                            : const Center(
                                child: CircularProgressIndicator(),
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
                containerMinHeight.value -= details.primaryDelta!.toDouble();
                if (containerMinHeight.value < 80) {
                  containerMinHeight.value = 80;
                } else if (containerMinHeight.value > 250) {
                  containerMinHeight.value = 250;
                }
              },
              onVerticalDragEnd: (details) {
                if (containerMinHeight.value > 160) {
                  containerMinHeight.value = 250;
                } else {
                  containerMinHeight.value = 80;
                }
              },
              child: ValueListenableBuilder(
                valueListenable: containerMinHeight,
                builder: (context, value, child) {
                  return ValueListenableBuilder<List<Color>>(
                    valueListenable: colors,
                    builder: (context, color, child) {
                      return MiniPlayerView(
                        height: value,
                        songName: songDataList[playingIndex].songModel.displayNameWOExt,
                        time:songDataList[playingIndex].songModel.artist.toString(),
                        songCoverImg: bgImg,
                        bgColor: color.length > 1 ? color[0] : null,
                        playButton: () {
                          bgImg = songDataList[playingIndex].image;
                         // updateColor();
                          audioPlayerManager.play(songDataList[playingIndex].songModel.data);
                        },
                        nextButton: () {

                          setState(() {
                            playingIndex+=1;
                          });
                          bgImg = songDataList[playingIndex].image;
                        //  updateColor();
                          audioPlayerManager.play(songDataList[playingIndex].songModel.data);
                        },
                        previousButton: () {

                          setState(() {
                            playingIndex-=1;
                          });
                          bgImg = songDataList[playingIndex].image;
                         // updateColor();
                          audioPlayerManager.play(songDataList[playingIndex].songModel.data);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  showingDialog() {
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

  SafeArea search() {
    return SafeArea(
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
    );
  }

  Widget backgroundImg() {
    return ValueListenableBuilder<List<Color>>(
      valueListenable: colors,
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: value,
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

  const MiniPlayerView(
      {super.key,
      required this.height,
      required this.playButton,
      required this.songName,
      required this.time,
      this.songCoverImg,
      this.bgColor = Colors.black,
      required this.nextButton,
      required this.previousButton});

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
                    songName +songName,
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
            IconButton(
              onPressed: playButton,
              icon: const Icon(
                Icons.play_circle_outline_rounded,
                color: kwhiteColor,
                size: 30,
              ),
            ),
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
//echo "# MusicStream" >> README.md
// git init
// git add README.md
// git commit -m "first commit"
// git branch -M main
// git remote add origin https://github.com/YogeshYogi1/MusicStream.git
// git push -u origin main