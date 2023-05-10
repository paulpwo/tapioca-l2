// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tapioca/tapioca.dart';
import 'package:video_player/video_player.dart';

import 'DraggableTextDialog.dart';
import 'DraggableTextEditor.dart';
import 'fullscreen.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as IMG;

class VideoScreen extends StatefulWidget {
  bool isEditfloatText = false;
  bool download = false;
  String floatText = '';
  int processPercentage = 0;
  GlobalKey appBar = GlobalKey();
  GlobalKey textKey = GlobalKey();
  GlobalKey paintText = GlobalKey();
  GlobalKey videoPlayerKey = GlobalKey();
  GlobalKey videoPlayerCanvaKey = GlobalKey();
  GlobalKey containerKey = GlobalKey();

  final String path;
  final ValueNotifier<Color> textColor = ValueNotifier(Colors.blue);
  final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
  final navigatorKey = GlobalKey<NavigatorState>();

  late AppBar appBarView;

  VideoScreen(this.path);

  @override
  _VideoAppState createState() => _VideoAppState(path);
}

class _VideoAppState extends State<VideoScreen> {
  static const EventChannel _channel = const EventChannel('video_editor_progress');
  late StreamSubscription _streamSubscription;

  final String path;
  _VideoAppState(this.path);

  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    widget.appBarView = AppBar(
      key: widget.appBar,
      backgroundColor: Colors.amber,
      elevation: 0,
      title: Text(''),
      actions: [
        if (!widget.isEditfloatText)
          IconButton(
              onPressed: () {
                // onlyAudio.value = !onlyAudio.value;
                // _generateAudiowave(context);
                setState(() {});
              },
              icon: const Icon(Icons.mic_none_sharp, color: Colors.white)),
        !widget.isEditfloatText
            ? IconButton(
                onPressed: () {
                  // _openCropScreen(context);
                },
                icon: const Icon(Icons.crop, color: Colors.white),
              )
            : IconButton(
                onPressed: () {
                  _removeText(context);
                },
                icon: const Icon(Icons.delete, color: Colors.white),
              ),
        IconButton(
          onPressed: () {
            _insertText(context);
          },
          icon: const Icon(Icons.text_fields, color: Colors.white),
        ),
        IconButton(
          onPressed: () {
            try {
              _captureImage(context);
            } catch (e) {
              print(e);
            }
          },
          icon: const Icon(Icons.download, color: Colors.white),
        )
      ],
      // agregar más widgets, como iconos o botones aquí
    );
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

  void _enableEventReceiver() {
    _streamSubscription = _channel.receiveBroadcastStream().listen((dynamic event) {
      setState(() {
        widget.processPercentage = (event.toDouble() * 100).round();
      });
    }, onError: (dynamic error) {
      print('Received error: ${error.message}');
    }, cancelOnError: true);
  }

  void _disableEventReceiver() {
    _streamSubscription.cancel();
  }

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
      widget.isEditfloatText = true;
      setState(() {});
    }
  }

  void _removeText(BuildContext context) async {
    widget.floatText = '';
    widget.isEditfloatText = false;
    setState(() {});
  }

  void _exportVideo(BuildContext context) async {
    setState(() {
      widget.download = true;
    });
    List<TapiocaBall> tapiocaBalls = [
      // TapiocaBall.filter(Filters.pink, 0.2),
      // TapiocaBall.imageOverlay(imageBitmap, 300, 300),
      // TapiocaBall.textOverlay("text", 100, 10, 100, Color(0xffffc0cb)),
    ];
    if (widget.floatText != '') {
      RenderRepaintBoundary boundary = widget.paintText.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      String dir = (await getApplicationDocumentsDirectory()).path;
      String fullPath = '$dir/overlay.png';
      print("local file full path $fullPath");
      File fileimg = File(fullPath);
      await fileimg.writeAsBytes(pngBytes);
      print(fileimg.path);
      //? Resize to fit the video size
      // IMG.Image? imageResize = IMG.decodeImage(file.readAsBytesSync());
      // IMG.Image imageResizeFull = IMG.copyResize(imageResize!, width: 720, height: 1280);
      // new File(fullPath)..writeAsBytesSync(IMG.encodePng(imageResizeFull));

      GallerySaver.saveVideo(fileimg.path).then((bool? success) {
        print(success.toString());
      });
      final imageBitmap = (await rootBundle.load("assets/tapioca_drink.png")).buffer.asUint8List();
      // final translation = widget.notifier.value.getTranslation();
      // final x = translation[0];
      // final y = translation[1];
      final RenderBox renderBox = widget.navigatorKey.currentContext?.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      Size videoSize = _controller.value.size;

      final x = position.dx;
      final y = position.dy;

      final videoRenderBox = widget.videoPlayerKey.currentContext!.findRenderObject() as RenderBox;
      final videoPosition = videoRenderBox.localToGlobal(Offset.zero);
      final videoX = videoPosition.dx;
      final videoY = videoPosition.dy;

      tapiocaBalls.add(TapiocaBall.imageOverlay(pngBytes, 300, 300));
    }

    final cup = Cup(Content(path), tapiocaBalls);
    var tempDir = await getTemporaryDirectory();
    final newpath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}result.mp4';
    cup.suckUp(newpath).then((_) async {
      print("finished");
      setState(() {
        widget.processPercentage = 0;
      });
      print(newpath);
      GallerySaver.saveVideo(newpath).then((bool? success) {
        print(success.toString());
      });
      // _loadVideo(newpath);

      Navigator.of(context).push(MaterialPageRoute(builder: (context) => VideoScreen(newpath)));

      setState(() {
        widget.download = false;
      });
    }).catchError((e) {
      print('Got error: $e');
    });

    // await Future.delayed(Duration(seconds: 1));
    // GallerySaver.saveVideo(path).then((bool? success) {
    //   print(success.toString());
    //   setState(() {
    //     widget.download = false;
    //   });
    // });
  }

  Future<Uint8List?> _captureImageInner() async {
    RenderRepaintBoundary boundary = widget.containerKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    return byteData.buffer.asUint8List();
  }

  Future<void> _captureImage(BuildContext context) async {
    try {
      Size videoSize = _controller.value.size;
      var pngBytes = await _captureImageInner();
      // Size screenSize = MediaQuery.of(context).size;
      // double imageWidth = videoSize.width;
      // double imageHeight = videoSize.height;

      // Crear un widget de imagen con la imagen a escala
      Image widgetImage = Image.memory(pngBytes!);

      // // Mostrar el widget de imagen a pantalla completa
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: widgetImage,
            color: Colors.yellow,
          );
        },
      );

      // final double statusBarHeight = MediaQuery.of(context).padding.top;
      // final double appBarHeight = AppBar().preferredSize.height;
      // final double totalHeight = statusBarHeight + appBarHeight;

      // final videoRenderBox = widget.textKey.currentContext!.findRenderObject() as RenderBox;
      // final videoPosition = videoRenderBox.localToGlobal(Offset.zero);
      // final textX = videoPosition.dx;
      // final textY = videoPosition.dy;
      List<TapiocaBall> tapiocaBalls = [
        // TapiocaBall.filter(Filters.pink, 0.2),
        // TapiocaBall.imageOverlay(imageBitmap, 300, 300),
        // TapiocaBall.textOverlay(widget.floatText, textX.toInt(), textY.toInt() - totalHeight.toInt(), 50, Color(0xFFB0AEAE)),
      ];

      final double statusBarHeight = MediaQuery.of(context).padding.top;
      double appBarBottomY = widget.appBar.currentContext!.findRenderObject()!.paintBounds.bottom;
      final double appBarHeight = widget.appBarView.preferredSize.height;

      final double totalHeight = statusBarHeight + appBarHeight;

      final textRenderBox = widget.textKey.currentContext!.findRenderObject() as RenderBox;
      final textPosition = textRenderBox.localToGlobal(Offset.zero);
      final textX = textPosition.dx.toInt();
      final textY = textPosition.dy.toInt() - appBarBottomY - 2;

      tapiocaBalls.add(TapiocaBall.imageOverlayFull(pngBytes));
      final cup = Cup(Content(path), tapiocaBalls);
      var tempDir = await getTemporaryDirectory();
      final newpath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}result.mp4';
      cup.suckUp(newpath).then((_) async {
        print("finished");
        setState(() {
          widget.processPercentage = 0;
        });
        print(newpath);
        GallerySaver.saveVideo(newpath).then((bool? success) {
          print(success.toString());
        });
        // _loadVideo(newpath);

        Navigator.of(context).push(MaterialPageRoute(builder: (context) => VideoScreen(newpath)));

        setState(() {
          widget.download = false;
        });
      }).catchError((e) {
        print('Got error: $e');
      });
    } catch (e) {
      print(e);
    }

    // Devolver la imagen original
    // return image;
  }

  Future<ui.Image> _scaleImage(ui.Image image, int width, int height) async {
    final size = Size(width.toDouble(), height.toDouble());
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height); // Crea un rectángulo con el tamaño de la imagen

    final paint = Paint()..filterQuality = FilterQuality.high;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, rect)..drawImage(image, Offset.zero, paint);
    final picture = recorder.endRecording();
    final pngBytes = await picture.toImage(width, height);
    final byteData = await pngBytes.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    final scaledImage = await decodeImageFromList(bytes);
    return scaledImage;
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final appBarHeight = kToolbarHeight;
    return Scaffold(
      key: widget.navigatorKey,
      extendBodyBehindAppBar: false,
      appBar: widget.appBarView,
      body: Stack(
        key: widget.videoPlayerCanvaKey,
        fit: StackFit.expand,
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
                      margin: EdgeInsets.only(top: 1),
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
          if (widget.floatText != '')
            Positioned(
              bottom: 1,
              child: ValueListenableBuilder(
                  valueListenable: widget.notifier,
                  builder: (BuildContext context, value, Widget? child) {
                    final double statusBarHeight = MediaQuery.of(context).padding.top;
                    double appBarBottomY = widget.appBar.currentContext!.findRenderObject()!.paintBounds.bottom;
                    final double appBarHeight = widget.appBarView.preferredSize.height;

                    final double totalHeight = statusBarHeight + appBarHeight;

                    final textRenderBox = widget.textKey.currentContext!.findRenderObject() as RenderBox;
                    final textPosition = textRenderBox.localToGlobal(Offset.zero);
                    final textX = textPosition.dx.toInt();
                    final textY = textPosition.dy.toInt() - appBarBottomY - 2;
                    //
                    Size vs = _controller.value.size;
                    return Text(
                      "textX : $textX |   textY:  $textY  \nVH : ${vs.height} vW: ${vs.width}",
                      maxLines: 3,
                      textAlign: TextAlign.justify,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  }),
            ),
          if (widget.floatText != '')
            Positioned(
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
            ),
          if (widget.download)
            Positioned(
                child: Center(
              child: CircularProgressIndicator(),
            )),
          if (widget.download)
            Positioned(
                child: Center(
              child: Text(
                widget.processPercentage.toString() + "%",
                style: TextStyle(fontSize: 20),
              ),
            )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
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
