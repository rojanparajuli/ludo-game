import 'package:flutter/material.dart';
import 'package:flutter_ludo/flutter_ludo.dart';

import 'game_screen.dart';
import 'setup_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({
    super.key,
    required this.players,
    required this.diceRules,
    required this.winnersInOrder,
  });

  final List<LudoPlayer> players;
  final LudoDiceRules diceRules;
  final List<int> winnersInOrder;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Results'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.primary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorScheme.primary.withValues(alpha: 0.05), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Trophy icon for winner
                if (winnersInOrder.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.amber.shade300,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.emoji_events,
                      size: 48,
                      color: Colors.amber.shade700,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  winnersInOrder.isNotEmpty && winnersInOrder.length == 1
                      ? '${players[winnersInOrder.first].name} Wins! 🎉'
                      : 'Game Complete!',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  winnersInOrder.length == 1
                      ? 'Congratulations on a fantastic game!'
                      : 'Thank you for playing!',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Final Standings',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: winnersInOrder.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final player = players[winnersInOrder[index]];
                        final isWinner = index == 0;
                        final isLast = index == winnersInOrder.length - 1;

                        return _RankRow(
                          rank: index + 1,
                          player: player,
                          isWinner: isWinner,
                          isLast: isLast,
                          totalPlayers: winnersInOrder.length,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const SetupScreen(),
                              ),
                              (route) => false,
                            ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('New Game'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => GameScreen(
                              players: players,
                              diceRules: diceRules,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Play Again'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.rank,
    required this.player,
    required this.isWinner,
    required this.isLast,
    required this.totalPlayers,
  });

  final int rank;
  final LudoPlayer player;
  final bool isWinner;
  final bool isLast;
  final int totalPlayers;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Different background colors based on position
    Color? backgroundColor;
    if (isWinner) {
      backgroundColor = Colors.amber.shade50;
    } else if (isLast && totalPlayers > 1) {
      backgroundColor = Colors.red.shade50;
    }

    // Medal emojis for top 3
    String? rankEmoji;
    if (rank == 1) {
      rankEmoji = '🥇';
    } else if (rank == 2) {
      rankEmoji = '🥈';
    } else if (rank == 3) {
      rankEmoji = '🥉';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Rank number or emoji
          SizedBox(
            width: 40,
            child: Text(
              rankEmoji ?? '#$rank',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: rankEmoji != null ? 24 : 18,
                color: isWinner ? Colors.amber.shade700 : null,
              ),
            ),
          ),
          // Player color circle with glow for winner
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: player.color,
              shape: BoxShape.circle,
              boxShadow: isWinner
                  ? [
                      BoxShadow(
                        color: player.color.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Player name
          Expanded(
            child: Text(
              player.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isWinner ? FontWeight.bold : FontWeight.w600,
                color: isWinner ? colorScheme.primary : null,
              ),
            ),
          ),
          // Position label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isWinner ? Colors.amber : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isWinner ? 'Winner' : '$rank${_getOrdinalSuffix(rank)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isWinner ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) return 'th';
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
