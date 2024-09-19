// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class InputTextFieldWidget extends StatelessWidget {
  final TextEditingController textEditingController;
  final String hintText;
  final void Function()? onTap;
    const InputTextFieldWidget(this.textEditingController, this.hintText,{this.onTap,super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      child: TextField(
        controller: textEditingController,
        onTap: onTap??(){},
        decoration: InputDecoration(
            alignLabelWithHint: true,
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black)),
            fillColor: Colors.white54,
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey),
            contentPadding: EdgeInsets.only(bottom: 10),
            focusColor: Colors.white60),
      ),
    );
  }
}


