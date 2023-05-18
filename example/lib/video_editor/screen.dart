// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tapioca/tapioca.dart';
import 'package:video_player/video_player.dart';

import 'DraggableTextDialog.dart';
import 'DraggableTextEditor.dart';
import 'color_picker.dart';
import 'fullscreen.dart';
import 'dart:ui' as ui;

import 'video_app_bar.dart';

class VideoScreen extends StatefulWidget {
  //? *************** GENERAL VARS ********************************************
  final String path;
  String floatText = '';
  late AppBar appBarView;
  int processPercentage = 0;
  GlobalKey appBar = GlobalKey();
  GlobalKey textKey = GlobalKey();
  GlobalKey paintText = GlobalKey();
  GlobalKey containerKey = GlobalKey();
  GlobalKey videoPlayerKey = GlobalKey();
  GlobalKey videoPlayerCanvaKey = GlobalKey();
  final navigatorKey = GlobalKey<NavigatorState>();
  //? *************** NOTIFIERs VARS ******************************************
  final ValueNotifier<bool> download = ValueNotifier(false);
  final ValueNotifier<bool> isEditfloatText = ValueNotifier(false);
  final ValueNotifier<Color> textColor = ValueNotifier(Colors.blue);
  final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());

  VideoScreen(this.path);

  @override
  _VideoAppState createState() => _VideoAppState(path);
}

class _VideoAppState extends State<VideoScreen> {
  //? *************** INNER VARS ********************************************
  static const EventChannel _channel = const EventChannel('video_editor_progress');
  late StreamSubscription _streamSubscription;
  late VideoPlayerController _controller;
  final String path;
  double startPos = 0;
  double endPos = -1;
  
  _VideoAppState(this.path);



  @override
  void initState() {
    super.initState();
    _loadVideo(path);
    _enableEventReceiver();
  }

  void _loadVideo(String video) {
    _controller = VideoPlayerController.file(File(video))
      ..initialize().then((_) {
        _controller.play();
        setState(() {});
      });
  }

  /// Use for receive Streams from Native code Kotlin or Swift
  void _enableEventReceiver() {
    _streamSubscription = _channel.receiveBroadcastStream().listen((dynamic event) {
      setState(() {
        widget.processPercentage = (event.toDouble() * 100).round();
      });
    }, onError: (dynamic error) {
      print('Received error: ${error.message}');
    }, cancelOnError: true);
  }

  /// Close receive Streams enabled by [_enableEventReceiver]
  void _disableEventReceiver() {
    _streamSubscription.cancel();
  }

  /// Insert or edit new text
  /// Valid for both methods and iimplement [showDialog] widget
  void _insertText(BuildContext context) async {
    final _textFieldController = TextEditingController();
    if (widget.floatText != '') {
      _textFieldController.text = widget.floatText;
    }
    await showDialog(
        context: context,
        builder: (context) {
          return TextDialog(controller: _textFieldController);
        });

    if (_textFieldController.value.text != "") {
      widget.floatText = _textFieldController.value.text;
      widget.isEditfloatText.value = true;
      setState(() {});
    }
  }

  void _removeText(BuildContext context) async {
    widget.floatText = '';
    widget.isEditfloatText.value = false;
    setState(() {});
  }

  /// [_captureImageInner] Inner use for generate screen shot
  Future<Uint8List?> _captureImageInner() async {
    RenderRepaintBoundary boundary = widget.containerKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    return byteData.buffer.asUint8List();
  }

  Future<void> _save(BuildContext context) async {
    List<TapiocaBall> tapiocaBalls = [];
    var tempDir = await getTemporaryDirectory();
    final newpath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}result.mp4';
    try {
      if (widget.floatText.isNotEmpty) {
        var pngBytes = await _captureImageInner();
        tapiocaBalls.add(TapiocaBall.imageOverlayFull(pngBytes!));
      } else {
        // NOTE: Fake filter for re-code video
        tapiocaBalls.add(TapiocaBall.filter(Filters.trasparent, 0.0, alpha: 0.0));
      }
      final cup = Cup(Content(path), tapiocaBalls);
      widget.download.value = true;
      cup.suckUp(newpath, startTime: startPos.toInt(), endTime: endPos.toInt()).then((_) async {
        print("finished");
        setState(() {
          widget.floatText = "";
          widget.processPercentage = 0;
        });
        print(newpath);
        GallerySaver.saveVideo(newpath).then((bool? success) {
          print(success.toString());
        });
        //NOTE: Use for test new video
        _loadVideo(newpath);
        //NOTE: Use for open new view without Getx
        // Navigator.of(context).push(MaterialPageRoute(builder: (context) => VideoScreen(newpath)));
        //NOTE: Use for open new view with Getx
        // Get.offNamed('route_name)
        setState(() {
          widget.download.value = false;
        });
      }).catchError((e) {
        print('Got error: $e');
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.navigatorKey,
      extendBodyBehindAppBar: false,
      appBar: VideoAppBar(
        key: widget.appBar,
        color: Colors.red,
        isEditfloatText: widget.isEditfloatText,
        onAudioIconPressed: () {
          setState(() {});
        },
        onRemoveTextPressed: () {
          _removeText(context);
        },
        onInsertTextPressed: () {
          _insertText(context);
        },
        onSavePressed: () {
          try {
            _save(context);
          } catch (e) {
            print(e);
          }
        },
      ),
      body: SafeArea(
        child: Stack(
          key: widget.videoPlayerCanvaKey,
          // fit: StackFit.expand,
          children: [
            _controller.value.isInitialized
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        if (!_controller.value.isPlaying &&
                            _controller.value.isInitialized &&
                            (_controller.value.duration == _controller.value.position)) {
                          _controller.initialize();
                          _controller.play();
                        } else {
                          _controller.value.isPlaying ? _controller.pause() : _controller.play();
                        }
                      });
                    },
                    child: FullScreenWidget(
                      // videoKey: widget.videoPlayerCanvaKey,
                      size: _controller.value.size,
                      child: Container(
                        margin: EdgeInsets.only(top: 0),
                        color: Colors.red,
                        key: widget.videoPlayerKey,
                        alignment: Alignment.topCenter,
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    ),
                  )
                : Container(),
            // NOTE: Video Trimmer
            if (_controller.value.isInitialized)
              Positioned(
                  left: 20,
                  right: 20,
                  child: TrimEditor(
                  viewerWidth: MediaQuery.of(context).size.width - 40,
                    viewerHeight: 50,
                    videoFile: path,
                    videoPlayerController: _controller,
                    fit: BoxFit.cover,
                    circleSize: 8.0,
                  circleSizeOnDrag: 13.0,
                    circlePaintColor: Colors.red,
                    borderPaintColor: Colors.red,
                    onChangeEnd: (position) {
                      this.endPos = position;
                    print("TrimEditor onchange end ==== $position");
                      // setState(() {});
                    },
                    onChangeStart: (position) {
                      this.startPos = position;
                    print("TrimEditor onchange start ==== $position");
                      // setState(() {});
                    },
                  onChangePlaybackState: (state) {
                    print("TrimEditor onchange onChangePlaybackState ==== $state");
                  },
                  ),
              ),
            // NOTE: Color Picker
            ValueListenableBuilder(
                valueListenable: ValueNotifier(widget.floatText),
                builder: (BuildContext context, String value, Widget? child) {
                  if (value.isNotEmpty) {
                    return Positioned(
                      top: 80,
                      right: 0,
                      child: ColorPicker(300, (current) {
                        if (current != null) {
                          try {
                            widget.textColor.value = current;
                            setState(() {});
                          } catch (e) {
                            print(e);
                          }
                        }
                      }),
                    );
                  }
                  return Container();
                }),

            // NOTE: Moveable Text
            ValueListenableBuilder(
              valueListenable: ValueNotifier(widget.floatText),
              builder: (BuildContext context, String value, Widget? child) {
                if (value.isNotEmpty) {
                  return Positioned(
                    top: 10,
                    bottom: 55,
                    left: 0,
                    right: 0,
                    child: RepaintBoundary(
                      key: widget.containerKey,
                      child: Container(
                        // color: Color.fromARGB(200, 0, 0, 2),
                        child: DraggableTextEditor(
                          textKey: widget.textKey,
                          paintText: widget.paintText,
                          notifier: widget.notifier,
                          isEditfloatText: widget.isEditfloatText,
                          textColor: widget.textColor,
                          floatText: widget.floatText,
                        ),
                      ),
                    ),
                  );
                }
                return Container();
              },
            ),
            // NOTE: Progress compress with current progress
            ValueListenableBuilder(
                valueListenable: widget.download,
                builder: (BuildContext context, bool value, Widget? child) {
                  if (value) {
                    return Positioned(
                        child: Center(
                      child: CircularProgressIndicator(),
                    ));
                  }
                  return Container();
                }),
            ValueListenableBuilder(
                valueListenable: widget.download,
                builder: (BuildContext context, bool value, Widget? child) {
                  if (value) {
                    return Positioned(
                        child: Center(
                      child: Text(
                        widget.processPercentage.toString() + "%",
                        style: TextStyle(fontSize: 20),
                      ),
                    ));
                  }
                  return Container();
                })
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _disableEventReceiver();
  }
}
