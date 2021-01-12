import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psnake/game/mysnake.dart';
import 'package:psnake/router.dart';
import 'router.dart' as router;
import 'app-state-model.dart';

void main() {
  return runApp(
    ChangeNotifierProvider<AppStateModel>(
      create: (context) => AppStateModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Snake',
      color: Colors.white,
      initialRoute: HomeViewRoute,
      onGenerateRoute: router.generateRoute,
      onUnknownRoute: (settings) => CupertinoPageRoute(
          builder: (context) => UndefinedView(
                name: settings.name,
              )),
    );
  }
}

class SinglePlayerGamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: Colors.white, child: MySnake());
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext mcontext) {
    return CupertinoPageScaffold(
        child: CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.play),
            title: Text('Play'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.antenna_radiowaves_left_right),
            title: Text('Multiplayer'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.star),
            title: Text('Highscore'),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: Center(
                    child: CupertinoButton(
                        child: Text("Start Game"),
                        onPressed: () =>
                            Navigator.pushNamed(mcontext, GameViewRoute))),
              );
            });
          case 1:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: Text("implementation ongoing"),
              );
            });
          case 2:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: Text("implementation ongoing"),
              );
            });
          default:
            return null;
        }
      },
    ));
  }
}
