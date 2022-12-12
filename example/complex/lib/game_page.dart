import 'package:squares_complex/game_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:squares/squares.dart';

class GamePage extends StatefulWidget {
  final GameController game;
  final PieceSet pieceSet;
  final PieceSet xiangqiPieceSet;
  final BoardTheme theme;
  final MarkerTheme? markerTheme;

  GamePage({
    Key? key,
    required this.game,
    required this.pieceSet,
    required this.xiangqiPieceSet,
    required this.theme,
    this.markerTheme,
  }) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  void _flipBoard() => widget.game.flipBoard();
  void _resign() => widget.game.resign();

  void _onMove(Move move) {
    widget.game.makeMove(move);
  }

  void _onPremove(Move move) {
    widget.game.makeMove(move);
  }

  void randomMove() {
    widget.game.randomMove();
  }

  @override
  Widget build(BuildContext context) {
    final _variant = widget.game.variant;
    bool _hands = _variant?.hands ?? false;
    return BlocBuilder<GameController, GameState>(
      bloc: widget.game,
      builder: (context, state) {
        int _orientation = state.board.orientation;
        return Container(
          // width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_hands) _hand(1 - _orientation),
              Padding(
                padding: EdgeInsets.all(4.0),
                child: BoardController(
                  state: state.board,
                  playState: state.state,
                  pieceSet: widget.game.isXiangqi
                      ? widget.xiangqiPieceSet
                      : widget.pieceSet,
                  theme: widget.theme,
                  size: state.size,
                  markerTheme: widget.markerTheme,
                  onMove: _onMove,
                  onPremove: _onPremove,
                  moves: state.moves,
                  draggable: true,
                  dragFeedbackSize: kIsWeb ? 1.5 : 2.0,
                  dragFeedbackOffset:
                      kIsWeb ? Offset(0.0, 0.0) : Offset(0.0, -1.0),
                  background:
                      widget.game.isXiangqi ? Squares.xiangqiBackground : null,
                  backgroundConfig: widget.game.isXiangqi
                      ? BackgroundConfig.noBackground
                      : BackgroundConfig.standard,
                  labelConfig: widget.game.isXiangqi
                      ? LabelConfig.disabled
                      : LabelConfig.standard,
                ),
              ),
              if (_hands) _hand(_orientation),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton.icon(
                    label: Text('Flip Board'),
                    icon: Icon(MdiIcons.rotate3DVariant),
                    onPressed: _flipBoard,
                  ),
                  TextButton.icon(
                    label: Text('Resign'),
                    icon: Icon(MdiIcons.flag),
                    onPressed: _resign,
                  ),
                ],
              ),
              Container(
                color: widget.theme.lightSquare.withOpacity(0.5),
                child: SelectableText(
                  state.board.fen(state.size),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _hand(int player) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        color: widget.theme.lightSquare,
        child: BlocBuilder<GameController, GameState>(
          bloc: widget.game,
          builder: (_context, state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                double width = constraints.maxWidth;
                double squareSize = width / state.size.h;
                return Hand(
                  theme: widget.theme,
                  pieceSet: widget.pieceSet,
                  pieces: state.hands[player],
                  fixedPieces: widget.game.variant!.commonPieceSymbols.reversed
                      .map((x) => player == Squares.white ? x : x.toLowerCase())
                      .toList(),
                  squareSize: squareSize,
                  badgeColour: Colors.blue,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
