import 'package:flutter/material.dart';

class DraggableText2 extends StatefulWidget {
  final String text;

  const DraggableText2({required this.text});

  @override
  _DraggableText2State createState() => _DraggableText2State();
}

class _DraggableText2State extends State<DraggableText2> {
  Offset _offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _offset += details.delta;
          // Limitar el movimiento dentro del padre
          if (_offset.dx < 0) {
            _offset = Offset(0, _offset.dy);
          } else if (_offset.dx > MediaQuery.of(context).size.width - 100) {
            _offset = Offset(MediaQuery.of(context).size.width - 100, _offset.dy);
          }
          if (_offset.dy < 0) {
            _offset = Offset(_offset.dx, 0);
          } else if (_offset.dy > MediaQuery.of(context).size.height - 100) {
            _offset = Offset(_offset.dx, MediaQuery.of(context).size.height - 100);
          }
        });
      },
      child: Stack(
        children: [
          Positioned(
            left: _offset.dx,
            top: _offset.dy,
            child: Text(widget.text),
          ),
        ],
      ),
    );
  }
}
