import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tapioca/tapioca.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:video_player/video_player.dart';

import 'video_editor/screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final navigatorKey = GlobalKey<NavigatorState>();
  late XFile _video;
  bool isLoading = false;
  static const EventChannel _channel = const EventChannel('video_editor_progress');
  late StreamSubscription _streamSubscription;
  int processPercentage = 0;

  @override
  void initState() {
    super.initState();
    _enableEventReceiver();
  }

  @override
  void dispose() {
    super.dispose();
    _disableEventReceiver();
  }

  void _enableEventReceiver() {
    _streamSubscription = _channel.receiveBroadcastStream().listen((dynamic event) {
      setState(() {
        processPercentage = (event.toDouble() * 100).round();
      });
    }, onError: (dynamic error) {
      print('Received error: ${error.message}');
    }, cancelOnError: true);
  }

  void _disableEventReceiver() {
    _streamSubscription.cancel();
  }

  _pickVideo() async {
    try {
      final ImagePicker _picker = ImagePicker();
      XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          _video = video;
          isLoading = true;
        });
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Video Editor Example App'),
        ),
        body: Center(
            child: isLoading
                ? Column(mainAxisSize: MainAxisSize.min, children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text(
                      processPercentage.toString() + "%",
                      style: TextStyle(fontSize: 20),
                    ),
                  ])
                : ElevatedButton(
                    child: Text("Pick a video and Edit it"),
                    onPressed: () async {
                      print("clicked!");
                      await _pickVideo();
                      var tempDir = await getTemporaryDirectory();
                      final path = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}result.mp4';
                      print(tempDir);
                      // final imageBitmap = (await rootBundle.load("assets/tapioca_drink.png")).buffer.asUint8List();
                      try {
                        setState(() {
                          isLoading = false;
                          processPercentage = 0;
                        });

                        final currentState = navigatorKey.currentState;
                        if (currentState != null) {
                          currentState.push(
                            MaterialPageRoute(builder: (context) => VideoScreen(_video.path)),
                          );
                        }
                        /*
                        final tapiocaBalls = [
                          TapiocaBall.filter(Filters.pink, 0.2),
                          TapiocaBall.imageOverlay(imageBitmap, 300, 300),
                          TapiocaBall.textOverlay(
                              "text", 100, 10, 100, Color(0xffffc0cb)),
                        ];
                        print("will start");
                        final cup = Cup(Content(_video.path), tapiocaBalls);
                        cup.suckUp(path).then((_) async {
                          print("finished");
                          setState(() {
                            processPercentage = 0;
                          });
                          print(path);
                          GallerySaver.saveVideo(path).then((bool? success) {
                            print(success.toString());
                          });
                          final currentState = navigatorKey.currentState;
                          if (currentState != null) {
                            currentState.push(
                              MaterialPageRoute(builder: (context) =>
                                  VideoScreen(path)),
                            );
                          }

                          setState(() {
                            isLoading = false;
                          });
                        }).catchError((e) {
                          print('Got error: $e');
                        });
                        */
                      } on PlatformException {
                        print("error!!!!");
                      }
                    },
                  )),
      ),
    );
  }
}
