import 'package:flutter/material.dart';

class ColorState {
  final Color color;
  int _count = 0;

  ColorState(this.color);

  void incrementCount() {
    _count++;
  }

  void decrementCount() {
    _count--;
  }

  void resetCount() {
    _count = 0;
  }

  int get count => _count;
}

class BubbleState {
  final int colorIndex, number;
  bool isActive = true;

  BubbleState({@required this.colorIndex, this.number});
}

class Move {
  final String colorName;
  final int index;
  final bool isCorrectMove;

  Move(this.colorName, this.index, this.isCorrectMove);
}

class Rule {
  final bool timer, number, color;

  const Rule({this.timer = false, this.number = false, this.color = false});
}
