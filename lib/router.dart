import 'package:flutter/cupertino.dart';
import 'main.dart';

const String HomeViewRoute = '/';
const String GameViewRoute = 'game';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case HomeViewRoute:
      return CupertinoPageRoute(builder: (context) => HomePage());
    case GameViewRoute:
      return CupertinoPageRoute(builder: (context) => SinglePlayerGamePage());
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
