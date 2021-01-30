import 'package:flutter/foundation.dart' as foundation;
import 'package:shared_preferences/shared_preferences.dart';

class AppStateModel extends foundation.ChangeNotifier {
  List<Score> _scores;

  addScore(double score) {
    _scores.sort((a, b) => b.score.compareTo(a.score));
    if (_scores.length > 9) {
      if (_scores[9].score < score) {
        _scores.removeRange(8, _scores.length - 1);
      }
      _scores.add(new Score(score));
      notifyListeners();
      _saveScore();
    }
  }

  List<Score> getScores() {
    _scores.sort((a, b) => b.score.compareTo(a.score));
    return _scores;
  }

  readScore() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'score';
    final value = prefs.getStringList(key) ?? [];
    print('read: $value');
    //somehow parse back to score. JSON?
    _scores = value.map((s) => new Score(double.parse(s))).toList();
  }

  _saveScore() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'score';
    final value = _scores;
    prefs.setStringList(key, _scores.map((s) => s.toString()).toList());
    print('saved $value');
  }
}

class Score {
  double score;

  Score(this.score);

  @override
  String toString() {
    //serialize timestampe to
    return score.toString();
  }
}
