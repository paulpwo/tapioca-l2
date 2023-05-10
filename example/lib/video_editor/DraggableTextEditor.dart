// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import 'dotted_decoration.dart';
import 'matrix_gesture_detector.dart';

class DraggableTextEditor extends StatefulWidget {
  final String floatText;
  final ValueNotifier<Matrix4> notifier;
  bool isEditfloatText;
  final ValueNotifier<Color> textColor;
  final GlobalKey textKey;
  final GlobalKey paintText;

  DraggableTextEditor(
      {required this.floatText,
      required this.notifier,
      required this.isEditfloatText,
      required this.textColor,
      required this.textKey,
      required this.paintText});

  @override
  _DraggableTextEditorState createState() => _DraggableTextEditorState();
}

class _DraggableTextEditorState extends State<DraggableTextEditor> {
  @override
  Widget build(BuildContext context) {
    return MatrixGestureDetector(
      onMatrixUpdate: (m, tm, sm, rm) {
        widget.notifier.value = m;
      },
      child: RepaintBoundary(
        key: widget.paintText,
        child: AnimatedBuilder(
          animation: widget.notifier,
          builder: (ctx, child) {
            return Transform(
              transform: widget.notifier.value,
              child: Stack(
                children: <Widget>[
                  Container(
                    height: 400,
                    width: 400,
                    // color: Colors.red,
                    // decoration: FlutterLogoDecoration(),
                    padding: EdgeInsets.only(top: 100),
                    alignment: Alignment(0, -0.5),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      children: [
                        widget.isEditfloatText
                            ? Container(
                                key: widget.textKey,
                                padding: const EdgeInsets.all(10),
                                decoration: DottedDecoration(
                                  shape: Shape.box,
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    if (widget.isEditfloatText) {
                                      widget.isEditfloatText = false;
                                    } else {
                                      widget.isEditfloatText = true;
                                    }
                                    setState(() {});
                                  },
                                  child: Text(
                                    widget.floatText,
                                    style: TextStyle(color: widget.textColor.value, fontSize: 40),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : Container(
                                key: widget.textKey,
                                padding: const EdgeInsets.all(10),
                                child: GestureDetector(
                                  onTap: () {
                                    if (widget.isEditfloatText) {
                                      widget.isEditfloatText = false;
                                    } else {
                                      widget.isEditfloatText = true;
                                    }
                                    setState(() {});
                                  },
                                  child: Text(
                                    widget.floatText,
                                    style: TextStyle(color: widget.textColor.value, fontSize: 40),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
