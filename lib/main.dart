import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puzzle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainGame(),
    );
  }
}

class MainGame extends StatefulWidget {
  const MainGame({super.key});

  @override
  State<MainGame> createState() => _MainGameState();
}

class _MainGameState extends State<MainGame> {
  final int count = 4;
  List<List<Uint8List?>> board = [];

  @override
  void initState() {
    super.initState();
    initializeBoard();
  }

  void initializeBoard() async {
    final ByteData data = await rootBundle.load('lib/car.jpg');
    final Uint8List bytes = data.buffer.asUint8List();
    img.Image? originalImage = img.decodeImage(bytes);

    if (originalImage != null) {
      int pieceWidth = originalImage.width ~/ count;
      int pieceHeight = originalImage.height ~/ count;

      for (int i = 0; i < count; i++) {
        for (int j = 0; j < count; j++) {
          img.Image piece = img.copyCrop(
            originalImage,
            x: j * pieceWidth,
            y: i * pieceHeight,
            width: pieceWidth,
            height: pieceHeight,
          );

          final Uint8List pieceBytes = Uint8List.fromList(
            img.encodePng(piece),
          );
          board[i][j] = pieceBytes;
        }
      }

      board[count - 1][count - 1] = null;
      board.shuffle(Random());
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isInBound(int row, int col) {
      return row >= 0 &&
          row < count &&
          col >= 0 &&
          col < count &&
          board[row][col] == null;
    }

    void moveTo(List oldPos, List newPos) {
      setState(() {
        board[newPos[0]][newPos[1]] = board[oldPos[0]][oldPos[1]];
        board[oldPos[0]][oldPos[1]] = null;
      });
    }

    void onTap(row, col) {
      // TOP
      var r = row - 1;
      var c = col;
      if (isInBound(r, c)) {
        moveTo([row, col], [r, c]);
        return;
      }

      // BOTTOM
      r = row + 1;
      c = col;
      if (isInBound(r, c)) {
        moveTo([row, col], [r, c]);
        return;
      }

      // LEFT
      r = row;
      c = col - 1;
      if (isInBound(r, c)) {
        moveTo([row, col], [r, c]);
        return;
      }

      // RIGHT
      r = row;
      c = col + 1;
      if (isInBound(r, c)) {
        moveTo([row, col], [r, c]);
        return;
      }
    }

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: board.isEmpty
              ? const CircularProgressIndicator()
              : Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: GridView.builder(
                    itemCount: count * count,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: count,
                    ),
                    itemBuilder: (context, index) {
                      int row = index ~/ count;
                      int col = index % count;

                      if (board[row][col] == null) return null;

                      return GestureDetector(
                        onTap: () => onTap(row, col),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.cyan,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(255, 200, 200, 200),
                                offset: Offset(1, 1),
                              ),
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(-1, -1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child: Image.memory(
                            board[row][col]!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}
