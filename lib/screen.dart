import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'code_files.dart';

class BubbleScreen extends StatefulWidget {
  static String id = 'game_screen';

  @override
  _BubbleScreenState createState() => _BubbleScreenState();
}

class _BubbleScreenState extends State<BubbleScreen> {
  final random = Random();
  final Map<String, ColorState> colours = {
    'Reds': ColorState(Colors.red), // 336
    'Purples': ColorState(Colors.purple), // 27b0
    'Yellows': ColorState(Colors.yellow), // eb3b
    'Blues': ColorState(Colors.cyan), // bcd4
    'Greens': ColorState(Colors.lightGreenAccent), // ff59
  };

  List<BubbleState> bubbles = [];
  int level;

  String rule;
  String ruleColorName;
  int ruleNumber;
  int ruleCount;

  Timer _timer;
  int _start = 10;

  bool correctMove = true, showOverlay = false, gameOver = false;

  int popped = 0;

  Future<void> loadLevelFuture;

  @override
  void initState() {
    super.initState();

    loadLevelFuture = _loadLevel();
    _loadGame();
  }

  Future<void> _loadLevel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    level = prefs.getInt('level') ?? 0;
  }

  void _loadGame() {
    rule = kRules.keys.elementAt(random.nextInt(3));
    ruleColorName = colours.keys.elementAt(random.nextInt(colours.length));
    ruleNumber = 1 + random.nextInt(6 - 1); // to ensure non-zero number always

    bubbles.clear();
    bubbles = List.generate(
      // at least 18 bubbles, at most 30 bubbles
      (6 * 3) + random.nextInt((6 * 4) - 11),
      (index) => BubbleState(
        colorIndex: random.nextInt(colours.length),
        number: rule.contains('N') ? index + 1 : null,
      ),
    );

    colours.values.forEach((element) {
      element.resetCount();
    });

    bubbles.forEach(
      (item) => colours.values.elementAt(item.colorIndex).incrementCount(),
    );

    switch (rule) {
      case 'C':
        ruleCount = colours[ruleColorName].count;
        break;

      case 'N':
        ruleCount = (bubbles.length / ruleNumber).floor();
        break;

      case 'NC':
        ruleCount = bubbles
            .where((element) =>
                element.colorIndex ==
                    colours.keys.toList().indexOf(ruleColorName) &&
                element.number % ruleNumber == 0)
            .length;
        break;
    }

    if (gameOver && showOverlay) {
      setState(() {
        gameOver = false;
        showOverlay = false;
        popped = 0;
        correctMove = true;
      });
    }

//    colours.values.forEach((element) {
//      print(element.count);
//    });
  }

  @override
  Widget build(BuildContext context) {
    print('running');

    return Scaffold(
      appBar: AppBar(
        title: Text('Pop My Bubble!'),
//        actions: <Widget>[
//          FlatButton(
//            child: Text(
//              '$_start',
//              style: TextStyle(color: Colors.white, fontSize: 20),
//            ),
//            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
//            onPressed: () => null,
//          )
//        ],
      ),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              children: <Widget>[
                FutureBuilder<void>(
                    future: loadLevelFuture,
                    builder: (context, snapshot) {
                      return Text(
                        'Level ' + (level != null ? level.toString() : ''),
                        style: TextStyle(fontSize: 22),
                      );
                    }),
//                Text(
//                  'Level ' + (level != null ? level.toString() : ''),
//                  style: TextStyle(fontSize: 22),
//                ),
                Text(
                  'Pop the ' + _getRule(rule, ruleColorName, ruleNumber),
                  style: TextStyle(fontSize: 22),
                ),
                GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: bubbles.length,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                  itemBuilder: (context, index) {
                    Color randColor = colours.values
                        .elementAt(bubbles[index].colorIndex)
                        .color;
                    String colorName =
                        colours.keys.elementAt(bubbles[index].colorIndex);
                    return bubbles[index].isActive
                        ? Bubble(
                            rule: rule,
                            ruleColour: colours[ruleColorName].color,
                            colour: randColor,
                            // colorName used as key from colours map to manipulate colour count after a move
                            colorName: colorName,
                            ruleNumber: rule.contains('N') ? ruleNumber : null,
                            number: rule.contains('N') ? index + 1 : null,
                            parentAction: _updateMove,
                            index: index,
                          )
                        : Container();
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            child: InkWell(
              onTap: () {
                if (ruleCount == 0 && popped == 0)
                  _gameWon();
                else
                  _gameOver();
              },
              child: Ink(
                height: kBottomNavigationBarHeight,
                width: MediaQuery.of(context).size.width,
                color: Colors.lightBlueAccent,
                child: Center(
                  child: Text(
                    'Don\'t Fool Me!',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: showOverlay,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200.withOpacity(0.5)),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Visibility(
              visible: showOverlay,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    gameOver ? 'GAME OVER' : 'LEVEL UP!',
                    style: TextStyle(fontSize: 40),
                  ),
                  FloatingActionButton.extended(
                    label: Text(gameOver ? 'Play Again' : 'Next Level'),
                    onPressed: () {
                      print('rebuilding..');
                      Navigator.pushReplacementNamed(context, BubbleScreen.id);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// returns rule String to be displayed at the top
  String _getRule(String rule, String colorName, int number) {
    switch (rule) {
      case 'C':
        return colorName;
      case 'N':
        return 'Multiples of $number';
      case 'NC':
        return colorName + ' that are Multiples of $number';
      default:
        return colorName;
    }
  }

  /// takes a Move object for the latest Move made, determines whether the correct move was made,
  /// manipulates colour count and removes that bubble from the Grid,
  /// and renders overlay in case of wrong move or
  /// level up (if no. of popped bubbles is equal to the original rule count,
  /// i.e. no. of bubbles satisfying the rule)
  void _updateMove(Move currentMove) {
    setState(() {
      correctMove = currentMove.isCorrectMove;
      popped++;
      bubbles[currentMove.index].isActive = false;
      colours[currentMove.colorName].decrementCount();
    });

    if (!correctMove)
      _gameOver();
    else if (correctMove && popped == ruleCount) _gameWon();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            timer.cancel();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  void _gameOver() {
    print('Game Over!');
    setState(() {
      gameOver = true;
      showOverlay = true;
    });
  }

  Future<void> _gameWon() async {
    print('Woohoo, you won!!');
    // update level in SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('level', level + 1);
    setState(() {
      showOverlay = true;
    });
  }

  @override
  void dispose() {
    if (_timer != null) _timer.cancel();
    colours.clear();
    bubbles.clear();
    super.dispose();
  }
}
