import 'dart:async';
import 'package:flutter/material.dart';
import '../models/puzzle_model.dart';

class GameScreen extends StatefulWidget {
  final int size;

  const GameScreen({super.key, required this.size});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late PuzzleModel puzzle;
  Timer? timer;
  int seconds = 0;
  bool isGameActive = false;
  Offset _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    puzzle = PuzzleModel(size: widget.size);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (!isGameActive) {
      isGameActive = true;
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          seconds++;
        });
      });
    }
  }

  void _stopTimer() {
    timer?.cancel();
    isGameActive = false;
  }

  void _resetGame() {
    setState(() {
      puzzle.reset();
      seconds = 0;
      _stopTimer();
    });
  }

  void _onDragStart(DragStartDetails details) {
    _dragOffset = Offset.zero;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _dragOffset += details.delta;
  }

  void _onDragEnd(int index) {
    if (puzzle.isSolved()) return;

    // Need minimum drag distance to register as a swipe
    const double minDragDistance = 20.0;
    if (_dragOffset.distance < minDragDistance) return;

    _startTimer();

    double dx = _dragOffset.dx;
    double dy = _dragOffset.dy;

    int row = index ~/ widget.size;
    int col = index % widget.size;
    int emptyRow = puzzle.emptyIndex ~/ widget.size;
    int emptyCol = puzzle.emptyIndex % widget.size;

    // Determine swipe direction and check if it moves towards empty space
    bool moved = false;
    if (dx.abs() > dy.abs()) {
      // Horizontal swipe
      if (dx > 0 && row == emptyRow && col == emptyCol + 1) {
        // Swipe right, empty is on the left
        moved = puzzle.moveTile(index);
      } else if (dx < 0 && row == emptyRow && col == emptyCol - 1) {
        // Swipe left, empty is on the right
        moved = puzzle.moveTile(index);
      }
    } else {
      // Vertical swipe
      if (dy > 0 && col == emptyCol && row == emptyRow + 1) {
        // Swipe down, empty is above
        moved = puzzle.moveTile(index);
      } else if (dy < 0 && col == emptyCol && row == emptyRow - 1) {
        // Swipe up, empty is below
        moved = puzzle.moveTile(index);
      }
    }

    if (moved) {
      setState(() {
        if (puzzle.isSolved()) {
          _stopTimer();
          _showWinDialog();
        }
      });
    }

    _dragOffset = Offset.zero;
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 恭喜！'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('你完成了拼图！'),
            const SizedBox(height: 10),
            Text('移动次数: ${puzzle.moves}'),
            Text('用时: ${_formatTime(seconds)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text('再玩一次'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('返回主菜单'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int secs = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Color _getTileColor(int number) {
    if (number == 0) return Colors.transparent;

    // Generate different colors based on the number
    double hue = (number * 360 / (widget.size * widget.size)).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.6).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.size}×${widget.size} 数字华容道'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
            tooltip: '重新开始',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildStats(),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: _buildPuzzleGrid(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.swap_horiz, '移动', puzzle.moves.toString()),
          _buildStatItem(Icons.timer, '用时', _formatTime(seconds)),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPuzzleGrid() {
    double screenWidth = MediaQuery.of(context).size.width;
    double maxSize = screenWidth * 0.9;
    double gridSize = maxSize > 500 ? 500 : maxSize;
    double tileSize = (gridSize - (widget.size + 1) * 4) / widget.size;

    return Container(
      width: gridSize,
      height: gridSize,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.size,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: widget.size * widget.size,
        itemBuilder: (context, index) {
          int number = puzzle.tiles[index];
          bool isEmpty = number == 0;
          bool canMove = puzzle.canMove(index);

          return GestureDetector(
            onPanStart: _onDragStart,
            onPanUpdate: _onDragUpdate,
            onPanEnd: (_) => _onDragEnd(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isEmpty ? Colors.grey.shade200 : _getTileColor(number),
                borderRadius: BorderRadius.circular(8),
                boxShadow: isEmpty
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Center(
                child: isEmpty
                    ? null
                    : Text(
                        number.toString(),
                        style: TextStyle(
                          fontSize: tileSize * 0.4,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 3.0,
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
