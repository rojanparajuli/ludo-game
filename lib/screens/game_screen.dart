import 'package:flutter/material.dart';
import 'package:flutter_ludo/flutter_ludo.dart';
import 'package:ludo_app/configs/themes/app_colors.dart';
import 'package:ludo_app/widget/custom_dice.dart';
import 'results_screen.dart';
import 'dart:math';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.players, required this.diceRules});

  final List<LudoPlayer> players;
  final LudoDiceRules diceRules;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final LudoController _controller;
  bool _isGameFinished = false;
  bool _isAutoMoving = false;
  late AnimationController _animController;

  int _diceValue = 1;
  bool _isDiceRolling = false;
  bool _isDiceEnabled = true;
  int _lastRolledValue = 1;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _controller = LudoController(
      players: widget.players,
      diceRules: widget.diceRules,
      onPlayerWon: _handlePlayerWon,
      onGameFinished: _handleGameFinished,
      
      enableAudio: true,
    );

    _controller.addListener(_handleGameStateChanges);
    _animController.forward();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleGameStateChanges);
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleGameStateChanges() {
    if (_isGameFinished) return;

    final gameState = _controller.state;
    final shouldEnableDice = gameState.phase == LudoTurnPhase.awaitingRoll;

    if (_isDiceEnabled != shouldEnableDice && !_isAutoMoving) {
      setState(() {
        _isDiceEnabled = shouldEnableDice;
      });
    }

    if (gameState.phase == LudoTurnPhase.awaitingPieceSelection) {
      if (_diceValue != _lastRolledValue && !_isDiceRolling) {
        setState(() {
          _diceValue = _lastRolledValue;
        });
      }
    }

    // Auto Move Execution Engine
    if (gameState.phase == LudoTurnPhase.awaitingPieceSelection &&
        !_isAutoMoving) {
      final legalMoves = gameState.legalMoves;
      if (legalMoves.isEmpty) return;

      int? targetPieceId;

      if (legalMoves.length == 1) {
        targetPieceId = legalMoves.first.pieceId;
      } else {
        final currentPlayerIdx = gameState.currentPlayerIndex;
        final playerPieces = gameState.pieces
            .where((p) => p.playerIndex == currentPlayerIdx)
            .toList();
        final piecesAtHome = playerPieces.where((p) => p.isHome).toList();

        if (piecesAtHome.length == 4) {
          final homeExitMove = legalMoves.firstWhere(
            (move) => playerPieces.any((p) => p.id == move.pieceId && p.isHome),
            orElse: () => legalMoves.first,
          );
          targetPieceId = homeExitMove.pieceId;
        }
      }

      if (targetPieceId != null) {
        _isAutoMoving = true;
        final selectedId = targetPieceId;

        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          try {
            if (_controller.state.phase ==
                    LudoTurnPhase.awaitingPieceSelection &&
                _controller.state.legalMoves.any(
                  (m) => m.pieceId == selectedId,
                )) {
              _controller.selectPiece(selectedId);
            }
          } catch (e) {
            debugPrint('Auto-move execution guarded: $e');
          } finally {
            if (mounted) {
              setState(() {
                _isAutoMoving = false;
                _isDiceEnabled =
                    _controller.state.phase == LudoTurnPhase.awaitingRoll;
              });
            }
          }
        });
      }
    }
  }

  void _handlePlayerWon(int playerIndex, int place) {
    final name = widget.players[playerIndex].name;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name finished ${_ordinal(place)}! 🎉'),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: widget.players[playerIndex].color,
      ),
    );
  }

  void _handleGameFinished(List<int> winnersInOrder) {
    if (!mounted) return;
    _isGameFinished = true;
    setState(() {
      _isDiceEnabled = false;
    });
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
          players: widget.players,
          diceRules: widget.diceRules,
          winnersInOrder: winnersInOrder,
        ),
      ),
    );
  }

  String _ordinal(int n) {
    switch (n) {
      case 1:
        return '1st';
      case 2:
        return '2nd';
      case 3:
        return '3rd';
      default:
        return '${n}th';
    }
  }

  void _rollDice() {
    if (_isDiceRolling || _isGameFinished || !_isDiceEnabled) return;

    setState(() {
      _isDiceRolling = true;
    });

    int rollCount = 0;
    final random = Random();

    void doRoll() {
      if (rollCount < 6) {
        setState(() {
          _diceValue = random.nextInt(6) + 1;
        });
        rollCount++;
        Future.delayed(const Duration(milliseconds: 100), doRoll);
      } else {
        final rolledValue = _controller.rollDice();
        _lastRolledValue = rolledValue;
        setState(() {
          _diceValue = rolledValue;
          _isDiceRolling = false;
        });
      }
    }

    doRoll();
  }

  Alignment _getDiceAlignment(int playerIndex) {
    switch (playerIndex) {
      case 0:
        return Alignment.centerLeft;
      case 1:
        return Alignment.centerRight;
      case 2:
        return Alignment.centerRight;
      case 3:
        return Alignment.centerLeft;
      default:
        return Alignment.center;
    }
  }

  Future<bool> _showQuitConfirmation() async {
    if (_isGameFinished) return true;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Quit Game?'),
        content: const Text(
          'Are you sure you want to exit? Your ongoing match progress will be discarded.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Playing'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Quit'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final activePlayerIndex = _controller.state.currentPlayerIndex;
    final isTopTurn = activePlayerIndex == 0 || activePlayerIndex == 1;

    Widget builtDiceControl() {
      return Opacity(
        opacity: _isDiceEnabled ? 1.0 : 0.6,
        child: CustomDice(
          value: _diceValue,
          isRolling: _isDiceRolling,
          onRoll: _rollDice,
          size: 70,
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showQuitConfirmation();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Ludo Match',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // STATUS CONTROL HEADER
                const Spacer(),

                SizedBox(
                  height: 90,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: isTopTurn ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: !isTopTurn,
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        alignment: _getDiceAlignment(activePlayerIndex),
                        child: builtDiceControl(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // CENTRAL GAME BOARD FRAME
                Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: LudoGame(
                          theme: LudoTheme(
                            boardBackgroundColor: AppColors.boardBackground,
                            pathCellColor: AppColors.pathCell,
                            safeCellColor: AppColors.safeZone,
                            centerCellColor: AppColors.centerCell,
                            starIconColor: AppColors.starIcon,
                          ),
                          controller: _controller,
                          showDice: false,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                SizedBox(
                  height: 90,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: !isTopTurn ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: isTopTurn,
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        alignment: _getDiceAlignment(activePlayerIndex),
                        child: builtDiceControl(),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
