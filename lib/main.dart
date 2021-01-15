import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:psnake/game/mysnake.dart';
import 'package:psnake/router.dart';
import 'router.dart' as router;
import 'app-state-model.dart';

void main() {
  return runApp(
    ChangeNotifierProvider<AppStateModel>(
      create: (context) => AppStateModel()..readScore(),
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
      color: CupertinoColors.white,
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
        backgroundColor: CupertinoColors.white, child: MySnake());
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext mcontext) {
    final model = Provider.of<AppStateModel>(mcontext);
    return CupertinoPageScaffold(
        child: CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.play),
            label: 'Play',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.group),
            label: 'Multiplayer',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.star),
            label: 'Highscore',
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
                        child: Center(child: Text("Start Game")),
                        onPressed: () =>
                            Navigator.pushNamed(mcontext, GameViewRoute))),
              );
            });
          case 1:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: Center(child: Text("implementation ongoing")),
              );
            });
          case 2:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: ListView.builder(
                  // Let the ListView know how many items it needs to build.
                  itemCount: model.getScores().length,
                  // Provide a builder function. This is where the magic happens.
                  // Convert each item into a widget based on the type of item it is.
                  itemBuilder: (context, index) {
                    final item = model.getScores()[index];

                    return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(item.score.toInt().toString()),
                          //Text(item.time.toString())
                        ]);
                  },
                ),
              );
            });
          default:
            return null;
        }
      },
    ));
  }
}
