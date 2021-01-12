import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'game/mysnake.dart';
import 'model/app-state-model.dart';

void main() {
  return runApp(
    ChangeNotifierProvider<AppStateModel>(
      create: (_) => AppStateModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Flutter Demo',
      home: CupertinoPageScaffold(child: MySnake()),
    );
  }
}