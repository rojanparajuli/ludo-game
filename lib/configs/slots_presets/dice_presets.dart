import 'package:flutter_ludo/flutter_ludo.dart';

class DicePreset {
  const DicePreset({
    required this.label,
    required this.description,
    required this.rules,
  });

  final String label;
  final String description;
  final LudoDiceRules rules;
}

const List<DicePreset> kDicePresets = [
  DicePreset(
    label: 'Classic',
    description: 'Roll a 6 to leave home, or to go again.',
    rules: LudoDiceRules(startAllowedValues: [6], extraTurnValues: [6]),
  ),
  DicePreset(
    label: 'Easy start',
    description: 'Leave home on a 1 or a 6.',
    rules: LudoDiceRules(startAllowedValues: [1, 6], extraTurnValues: [6]),
  ),
  DicePreset(
    label: 'No extra turns',
    description: 'Rolling a 6 never grants another turn.',
    rules: LudoDiceRules(startAllowedValues: [6], extraTurnValues: []),
  ),
];
