import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'code_files.dart';

class Bubble extends StatefulWidget {
  final String rule;

  final Color ruleColour, colour;
  final int ruleNumber, number;

  final ValueChanged<Move> parentAction;
  final String colorName;
  final int index;

  Bubble({
    @required this.rule,
    @required this.parentAction,
    @required this.index,
    @required this.ruleColour,
    @required this.colour,
    this.colorName,
    this.ruleNumber,
    this.number,
  });

  @override
  _BubbleState createState() => _BubbleState();
}

class _BubbleState extends State<Bubble> {
  double width = 80;
  Color color;

  final AudioCache player = AudioCache();

  @override
  void initState() {
    super.initState();
    color = widget.colour;
  }

  @override
  void dispose() {
    player.clearCache();
    color = null;
    super.dispose();
  }

  void _playSound() {
    player.play('pop.mp3');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _playSound();
        Move move;
        switch (widget.rule) {
          case 'C':
            move = Move(widget.colorName, widget.index,
                widget.colour == widget.ruleColour);
            break;
          case 'N':
            move = Move(widget.colorName, widget.index,
                widget.number % widget.ruleNumber == 0);
            break;
          case 'NC':
            move = Move(
                widget.colorName,
                widget.index,
                widget.colour == widget.ruleColour &&
                    widget.number % widget.ruleNumber == 0);
            break;
        }

        setState(() {
          width = 0;
          color = Colors.white.withOpacity(0.5);
        });

        WidgetsBinding.instance
            .addPostFrameCallback((_) => widget.parentAction(move));
      },
      child: AnimatedContainer(
        child: widget.number != null
            ? Center(
                child: Text(
                  widget.number.toString(),
                  style: TextStyle(fontSize: 20),
                ),
              )
            : Container(),
        height: width,
        width: width,
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(40),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFFFFFF),
              blurRadius: 25,
              spreadRadius: -10,
              offset: Offset(
                10,
                -20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
