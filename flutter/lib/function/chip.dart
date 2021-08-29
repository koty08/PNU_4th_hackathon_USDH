import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:usdh/Widget/widget.dart';

class ChipState extends StatelessWidget {
  const ChipState({
    required this.label,
    required this.onDeleted,
    required this.index,
  });

  final String label;
  final ValueChanged<int> onDeleted;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Chip(
      labelStyle: TextStyle(fontFamily: "SCDream", color: Color(0xffa9aaaf), fontWeight: FontWeight.w500, fontSize: 11.5),
      labelPadding: EdgeInsets.only(left: 10),
      backgroundColor: Color(0xff639ee1).withOpacity(0.7),
      label: smallText(label, 11, Colors.white),
      deleteIcon: const Icon(
        Icons.close,
        color: Colors.white,
        size: 13,
      ),
      onDeleted: () {
        onDeleted(index);
      },
    );
  }
}