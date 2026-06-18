// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_ludo/flutter_ludo.dart';
import 'package:ludo_app/configs/themes/app_colors.dart';
import '../configs/slots_presets/dice_presets.dart';
import '../configs/slots_presets/player_slots.dart';
import 'game_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  late final List<TextEditingController> _nameControllers = [
    for (final slot in kPlayerSlots)
      TextEditingController(text: slot.defaultName),
  ];
  int _presetIndex = 0;

  @override
  void dispose() {
    for (final controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startGame() {
    final players = [
      for (var i = 0; i < kPlayerSlots.length; i++)
        LudoPlayer(
          name: _nameControllers[i].text.trim().isEmpty
              ? kPlayerSlots[i].defaultName
              : _nameControllers[i].text.trim(),
          color: kPlayerSlots[i].color,
        ),
    ];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          players: players,
          diceRules: kDicePresets[_presetIndex].rules,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'New Ludo Game',
          style: TextStyle(color: AppColors.textLight),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: AppColors.textLight,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            _buildHeader(context),

            const SizedBox(height: 24),

            _buildPlayerSection(context),

            const SizedBox(height: 20),

            _buildDiceRulesSection(context),

            const SizedBox(height: 32),

            _buildGameSummaryAndStartButton(context),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.primary,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.textLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.games_rounded,
              color: AppColors.textLight,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Game Setup',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Customize your game experience',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          // Mini Ludo board indicator
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.textLight.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomPaint(painter: _MiniBoardPainter()),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.people_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Players',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Enter names for each player',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${kPlayerSlots.length} Players',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: List.generate(
                kPlayerSlots.length,
                (i) => Padding(
                  padding: EdgeInsets.only(
                    bottom: i < kPlayerSlots.length - 1 ? 12 : 0,
                  ),
                  child: _PlayerNameField(
                    color: kPlayerSlots[i].color,
                    controller: _nameControllers[i],
                    index: i,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiceRulesSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.casino_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dice Rules',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Select your preferred rule set',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: List.generate(
                kDicePresets.length,
                (i) => Padding(
                  padding: EdgeInsets.only(
                    bottom: i < kDicePresets.length - 1 ? 8 : 0,
                  ),
                  child: _DiceRuleTile(
                    index: i,
                    preset: kDicePresets[i],
                    isSelected: _presetIndex == i,
                    onTap: () => setState(() => _presetIndex = i),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameSummaryAndStartButton(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSummaryItem(
                icon: Icons.people_rounded,
                label: 'Players',
                value: '${kPlayerSlots.length}',
                color: AppColors.primary,
              ),
              Container(
                width: 1,
                height: 30,
                color: AppColors.divider.withOpacity(0.3),
              ),
              _buildSummaryItem(
                icon: Icons.casino_rounded,
                label: 'Rules',
                value: kDicePresets[_presetIndex].label,
                color: AppColors.warning,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Start button
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          
          ),
          child: ElevatedButton(
            onPressed: _startGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textLight,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              minimumSize: const Size(double.infinity, 60),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.textLight.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded, size: 28),
                ),
                const SizedBox(width: 12),
                Text(
                  'Start Game',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PlayerNameField extends StatefulWidget {
  const _PlayerNameField({
    required this.color,
    required this.controller,
    required this.index,
  });

  final Color color;
  final TextEditingController controller;
  final int index;

  @override
  State<_PlayerNameField> createState() => _PlayerNameFieldState();
}

class _PlayerNameFieldState extends State<_PlayerNameField> {
  @override
  Widget build(BuildContext context) {
    final playerNames = ['Player 1', 'Player 2', 'Player 3', 'Player 4'];
    final colorMap = [
      AppColors.playerRed,
      AppColors.playerGreen,
      AppColors.playerYellow,
      AppColors.playerBlue,
    ];

    final playerColor = colorMap[widget.index % colorMap.length];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: playerColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: playerColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Player color indicator
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [playerColor, playerColor.withOpacity(0.7)],
              ),
              shape: BoxShape.circle,
             
            ),
            child: Center(
              child: Text(
                '${widget.index + 1}',
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: widget.controller,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: playerNames[widget.index],
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                suffixIcon: widget.controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        onPressed: () {
                          widget.controller.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiceRuleTile extends StatelessWidget {
  const _DiceRuleTile({
    required this.index,
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  final int index;
  final DicePreset preset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Dice icon with number
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.textLight
                        : AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        preset.label,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'SELECTED',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    preset.description,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary.withOpacity(0.3),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for mini Ludo board
class _MiniBoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    final cellSize = size.width / 6;
    final colors = [
      AppColors.playerRed,
      AppColors.playerGreen,
      AppColors.playerYellow,
      AppColors.playerBlue,
    ];

    // Draw mini board squares
    for (int row = 0; row < 6; row++) {
      for (int col = 0; col < 6; col++) {
        final rect = Rect.fromLTWH(
          col * cellSize,
          row * cellSize,
          cellSize,
          cellSize,
        );

        // Determine color for quadrants
        Color color;
        if (row < 2 && col < 2) {
          color = colors[0].withOpacity(0.3);
        } else if (row < 2 && col > 3) {
          color = colors[1].withOpacity(0.3);
        } else if (row > 3 && col < 2) {
          color = colors[2].withOpacity(0.3);
        } else if (row > 3 && col > 3) {
          color = colors[3].withOpacity(0.3);
        } else if (row >= 2 && row <= 3 && col >= 2 && col <= 3) {
          color = AppColors.card.withOpacity(0.5);
        } else {
          color = AppColors.card;
        }

        paint.color = color;
        canvas.drawRect(rect, paint);

        // Draw border
        paint.color = AppColors.border.withOpacity(0.3);
        paint.style = PaintingStyle.stroke;
        canvas.drawRect(rect, paint);
        paint.style = PaintingStyle.fill;
      }
    }

    // Draw center circle
    final center = Offset(size.width / 2, size.height / 2);
    paint.color = AppColors.primary;
    canvas.drawCircle(center, cellSize * 0.4, paint);

    paint.color = AppColors.textLight;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    canvas.drawCircle(center, cellSize * 0.3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
