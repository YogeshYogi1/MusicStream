import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_stream/providers/ui_provider.dart';
import 'package:music_stream/screens/music_list_screen.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider (create: (_) => UiProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MusicListScreen(),
      //const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  AudioPlayer player = AudioPlayer();
  Future<void> methods(String url)async{
   await player.setUrl(url);
  }

  @override
  void initState() {
    Permission.storage.request();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              'Music Name',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: ()async{
              List<SongModel> query = await  _audioQuery.querySongs();
              await methods(query[0].data);
              await player.play();
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: ()async{
              List<SongModel> query = await  _audioQuery.querySongs();
              await methods(query[0].data);
              await player.pause();
            },
            tooltip: 'Decrement',
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: ()async{
              await player.setVolume(0.1);
            },
            tooltip: 'Decrement',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
