import 'package:flutter/cupertino.dart';
import 'package:psnake/singleplayer/single-player-snake.dart';

import 'main.dart';
import 'multiplayer/multi-player-snake.dart';

const String HomeViewRoute = '/';
const String SingleGameViewRoute = 'singlegame';
const String MultiGameViewRoute = 'multigame';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case HomeViewRoute:
      return CupertinoPageRoute(builder: (context) => HomePage());
    case SingleGameViewRoute:
      return CupertinoPageRoute(builder: (context) => SinglePlayerGamePage());
    case MultiGameViewRoute:
      return CupertinoPageRoute(builder: (context) => MultiplayerPlayerGamePage(deviceType: settings.arguments));
    default:
      return CupertinoPageRoute(builder: (context) => HomePage());
  }
}

class UndefinedView extends StatelessWidget {
  final String name;

  const UndefinedView({Key key, this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: Text('$name is not the page you looking for'),
      ),
    );
  }
}
