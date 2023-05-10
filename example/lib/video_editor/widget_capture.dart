import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';

class WidgetCapture extends StatefulWidget {
  final Widget child;

  const WidgetCapture({required this.child});

  @override
  _WidgetCaptureState createState() => _WidgetCaptureState();

  Future<Uint8List?> capture() async {
    _WidgetCaptureState state = _WidgetCaptureState();
    await state.capture();
  }
}

class _WidgetCaptureState extends State<WidgetCapture> {
  GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Widget de fondo transparente
        Container(
          color: Colors.transparent,
        ),
        // Widget a capturar
        RepaintBoundary(
          key: _globalKey,
          child: widget.child,
        ),
      ],
    );
  }

  Future<Uint8List> capture() async {
    // RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    // ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    // return image;
    RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    // // Crear un objeto de tipo Image y devolverlo
    // return Image.memory(pngBytes);
    return pngBytes;
  }
}
