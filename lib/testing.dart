
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyDraggableContainer(),
    );
  }
}

class MyDraggableContainer extends StatefulWidget {
  @override
  State<MyDraggableContainer> createState() => _MyDraggableContainerState();
}

class _MyDraggableContainerState extends State<MyDraggableContainer> {
  ValueNotifier<double> containerMinHeight = ValueNotifier(100);

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                containerMinHeight.value -= details.primaryDelta!.toDouble();
                if (containerMinHeight.value < 100) {
                  containerMinHeight.value = 100;
                } else if (containerMinHeight.value > 250 ) {
                  containerMinHeight.value = 250;
                }
              },
              onVerticalDragEnd: (details) {
                if (containerMinHeight.value > 160) {
                  containerMinHeight.value = 250;
                }else{
                  containerMinHeight.value = 100;
                }
              },
              child: ValueListenableBuilder(
                valueListenable:containerMinHeight ,
                builder: (context,value,child) {
                  return Container(
                    width: 200.0,
                    height: containerMinHeight.value,
                    color: Colors.blue,
                  );
                }
              ),
            ),
          ),
        ],
      ),
    );
  }
}
