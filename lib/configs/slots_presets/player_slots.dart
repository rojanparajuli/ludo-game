import 'package:flutter/material.dart';


class PlayerSlot {
  const PlayerSlot({required this.defaultName, required this.color});

  final String defaultName;
  final Color color;
}

const List<PlayerSlot> kPlayerSlots = [
  PlayerSlot(defaultName: 'Red', color: Color(0xFFE53935)),
  PlayerSlot(defaultName: 'Green', color: Color(0xFF43A047)),
  PlayerSlot(defaultName: 'Yellow', color: Color(0xFFFBC02D)),
  PlayerSlot(defaultName: 'Blue', color: Color(0xFF1E88E5)),
];