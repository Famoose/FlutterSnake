enum Direction {
  right,
  left,
  up,
  down,
}

extension DirectionExt on Direction {
  Direction get oppositDir {
    switch (this) {
      case Direction.up:
        return Direction.down;
      case Direction.right:
        return Direction.left;
      case Direction.left:
        return Direction.right;
      case Direction.down:
        return Direction.up;
    }
  }
}

Direction fromString(String s){
  return Direction.values.firstWhere((e) => e.toString() == s);
}
