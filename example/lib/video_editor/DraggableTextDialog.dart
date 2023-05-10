import 'package:flutter/material.dart';

class TextDialog extends StatelessWidget {
  final TextEditingController controller;

  const TextDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Color.fromARGB(255, 0, 0, 0).withAlpha(1),
      child: TextField(
        minLines: 1,
        maxLines: 3,
        keyboardType: TextInputType.multiline,
        style: TextStyle(color: Colors.white, fontSize: 30),
        controller: controller,
        textAlign: TextAlign.center,
        cursorColor: Colors.white,
        cursorWidth: 3,
        cursorRadius: Radius.circular(10),
        cursorHeight: 50,
        decoration: new InputDecoration(
          border: new OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide: new BorderSide(
              color: Colors.white,
              width: 3,
            ),
          ),
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
          hintText: "Hint here",
          hintStyle: TextStyle(color: Color.fromARGB(232, 255, 255, 255), fontSize: 30),
        ),
      ),
    );
  }
}
