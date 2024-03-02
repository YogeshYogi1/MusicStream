import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'constants.dart';

class GlassMorphism extends StatelessWidget {
  final Widget child;
  final double start;
  final double end;
  final Color color;
  final bool needBorder;
  final double bRadius;
  final bool isTopRadiusOnly;
  final double blurValue;
  const GlassMorphism({
    Key? key,
    required this.child,
    required this.start,
    required this.end,
    this.color = Colors.white,
    this.bRadius = 10,
    this.needBorder = true,
    this.isTopRadiusOnly = false,
    this.blurValue = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: !isTopRadiusOnly
          ? BorderRadius.all(Radius.circular(bRadius))
          : BorderRadius.only(
          topRight: Radius.circular(bRadius),
          topLeft: Radius.circular(bRadius)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(start),
                color.withOpacity(end),
              ],
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
            ),
            borderRadius: !isTopRadiusOnly
                ? BorderRadius.all(Radius.circular(bRadius))
                : BorderRadius.only(
                    topRight: Radius.circular(bRadius),
                    topLeft: Radius.circular(bRadius)),
            border: Border.all(
              width: 1.5,
              color: needBorder ? color.withOpacity(0.2) : Colors.transparent,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class SongTileCard extends StatelessWidget {
  const SongTileCard({
    super.key,
    required this.playButton,
    required this.songName,
    required this.time, this.songCoverImg ,
  });

  final VoidCallback playButton;
  final String songName;
  final String time;
  final Uint8List? songCoverImg;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.only(left: 13, right: 13),
          child: Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child:songCoverImg== null ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                   kbackGroundImage,
                    fit: BoxFit.cover,
                  ),
                ): Image.memory(songCoverImg!),
              ),
              const SizedBox(
                width: 20,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      songName,
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
                onPressed: playButton,
                icon: const Icon(
                  Icons.play_circle_outline_rounded,
                  color: kwhiteColor,
                  size: 35,
                ),
              )
            ],
          ),
        ),
        Container(
          height: 1,
          color: Colors.white,
          margin:
              const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 20),
        )
      ],
    );
  }
}


