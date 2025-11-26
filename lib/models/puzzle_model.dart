import 'dart:math';

class PuzzleModel {
  final int size;
  List<int> tiles;
  int moves;
  int emptyIndex;

  PuzzleModel({required this.size})
      : tiles = [],
        moves = 0,
        emptyIndex = 0 {
    _initialize();
  }

  void _initialize() {
    // Create solved state
    tiles = List.generate(size * size - 1, (index) => index + 1);
    tiles.add(0); // 0 represents empty tile
    emptyIndex = size * size - 1;

    // Shuffle until solvable
    _shuffle();
  }

  void _shuffle() {
    Random random = Random();
    // Perform random valid moves to ensure solvability
    for (int i = 0; i < size * size * 100; i++) {
      List<int> validMoves = _getValidMoves();
      if (validMoves.isNotEmpty) {
        int randomMove = validMoves[random.nextInt(validMoves.length)];
        _swap(emptyIndex, randomMove);
        emptyIndex = randomMove;
      }
    }
    moves = 0; // Reset move counter after shuffle
  }

  List<int> _getValidMoves() {
    List<int> validMoves = [];
    int row = emptyIndex ~/ size;
    int col = emptyIndex % size;

    // Up
    if (row > 0) validMoves.add(emptyIndex - size);
    // Down
    if (row < size - 1) validMoves.add(emptyIndex + size);
    // Left
    if (col > 0) validMoves.add(emptyIndex - 1);
    // Right
    if (col < size - 1) validMoves.add(emptyIndex + 1);

    return validMoves;
  }

  void _swap(int index1, int index2) {
    int temp = tiles[index1];
    tiles[index1] = tiles[index2];
    tiles[index2] = temp;
  }

  bool moveTile(int index) {
    if (!canMove(index)) return false;

    _swap(index, emptyIndex);
    emptyIndex = index;
    moves++;
    return true;
  }

  bool canMove(int index) {
    int row = index ~/ size;
    int col = index % size;
    int emptyRow = emptyIndex ~/ size;
    int emptyCol = emptyIndex % size;

    // Check if adjacent to empty tile
    return (row == emptyRow && (col - emptyCol).abs() == 1) ||
        (col == emptyCol && (row - emptyRow).abs() == 1);
  }

  bool isSolved() {
    for (int i = 0; i < tiles.length - 1; i++) {
      if (tiles[i] != i + 1) return false;
    }
    return tiles[tiles.length - 1] == 0;
  }

  void reset() {
    _initialize();
  }
}
