import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'dart:math';

class CustomDice extends StatefulWidget {
  final int value;
  final bool isRolling;
  final VoidCallback onRoll;
  final double size;

  const CustomDice({
    super.key,
    required this.value,
    required this.isRolling,
    required this.onRoll,
    this.size = 80,
  });

  @override
  State<CustomDice> createState() => _CustomDiceState();
}

class _CustomDiceState extends State<CustomDice>
    with SingleTickerProviderStateMixin {
  late DiceGame _game;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _game = DiceGame(value: widget.value, isRolling: widget.isRolling);
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(CustomDice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _game.updateValue(widget.value);
    }
    if (widget.isRolling != oldWidget.isRolling) {
      _game.setRolling(widget.isRolling);
    }
  }

  @override
  void dispose() {
    _game.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isRolling ? null : widget.onRoll,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = widget.isRolling
              ? 1.0 + 0.05 * sin(_pulseController.value * 2 * pi)
              : 1.0;
          return Transform.scale(
            scale: scale,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: GameWidget(
                game: _game,
                // backgroundColor: Colors.transparent,
                // Wipes out the fallback circle loading indicator entirely
                loadingBuilder: (context) => const SizedBox.shrink(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DiceGame extends FlameGame {
  int value;
  bool isRolling;
  DiceComponent? _diceComponent;

  DiceGame({required this.value, required this.isRolling});

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _diceComponent = DiceComponent(value: value, size: size.x * 0.9);
    _diceComponent!.position = size / 2;
    add(_diceComponent!);
  }

  void updateValue(int newValue) {
    value = newValue;
    _diceComponent?.updateValue(value);
  }

  void setRolling(bool rolling) {
    isRolling = rolling;
    if (isRolling) {
      _diceComponent?.startRolling();
    } else {
      _diceComponent?.stopRolling();
    }
  }
}

class DiceComponent extends PositionComponent {
  int value;
  bool isRolling = false;
  double rotationAngle = 0;
  double targetRotation = 0;
  double scaleValue = 1.0;

  final Paint _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = const Color(0xFF1A1A2E)
    ..strokeWidth = 2.5;

  static const Map<int, List<Offset>> _dotPositions = {
    1: [Offset(0, 0)],
    2: [Offset(-0.3, -0.3), Offset(0.3, 0.3)],
    3: [Offset(-0.3, -0.3), Offset(0, 0), Offset(0.3, 0.3)],
    4: [
      Offset(-0.3, -0.3),
      Offset(0.3, -0.3),
      Offset(-0.3, 0.3),
      Offset(0.3, 0.3),
    ],
    5: [
      Offset(-0.3, -0.3),
      Offset(0.3, -0.3),
      Offset(0, 0),
      Offset(-0.3, 0.3),
      Offset(0.3, 0.3),
    ],
    6: [
      Offset(-0.3, -0.3),
      Offset(0.3, -0.3),
      Offset(-0.3, 0),
      Offset(0.3, 0),
      Offset(-0.3, 0.3),
      Offset(0.3, 0.3),
    ],
  };

  DiceComponent({required this.value, required double size})
    : super(size: Vector2(size, size), anchor: Anchor.center);

  void updateValue(int newValue) {
    value = newValue;
  }

  void startRolling() {
    isRolling = true;
    targetRotation += 2 * 3.14159;
    scaleValue = 1.1;
  }

  void stopRolling() {
    isRolling = false;
    scaleValue = 1.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isRolling) {
      rotationAngle += dt * 5.0;
      if (rotationAngle > targetRotation) {
        rotationAngle = targetRotation;
      }
      scaleValue += (1.0 - scaleValue) * 0.05;
    } else {
      final diff = targetRotation - rotationAngle;
      if (diff.abs() > 0.01) {
        rotationAngle += diff * 0.15;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final center = Offset(size.x / 2, size.y / 2);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scaleValue);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.grey.shade50, Colors.white, Colors.grey.shade100],
    );
    final gradientPaint = Paint()..shader = gradient.createShader(rect);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    canvas.drawRRect(rrect, gradientPaint);
    canvas.drawRRect(rrect, _borderPaint);

    final dotRadius = size.x * 0.08;
    final positions = _dotPositions[value] ?? [];
    final dotSpacing = size.x * 0.25;

    for (var pos in positions) {
      final dotCenter = Offset(
        center.dx + (pos.dx * dotSpacing),
        center.dy + (pos.dy * dotSpacing),
      );

      final dotGradient = const RadialGradient(
        center: Alignment(-0.2, -0.2),
        radius: 0.8,
        colors: [Color(0xFF3A3A5A), Color(0xFF1A1A2E)],
      );
      final dotGradientPaint = Paint()
        ..shader = dotGradient.createShader(
          Rect.fromCircle(center: dotCenter, radius: dotRadius * 1.2),
        )
        ..style = PaintingStyle.fill;

      canvas.drawCircle(dotCenter, dotRadius * 1.1, dotGradientPaint);

      final highlightDotPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        dotCenter - Offset(dotRadius * 0.3, dotRadius * 0.3),
        dotRadius * 0.4,
        highlightDotPaint,
      );
    }

    canvas.restore();
  }
}
