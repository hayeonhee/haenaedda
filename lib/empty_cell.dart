import 'package:flutter/material.dart';

class EmptyCell extends StatelessWidget {
  const EmptyCell({super.key});

  @override
  Widget build(BuildContext context) {
    return const AspectRatio(
      aspectRatio: 1,
      child: SizedBox.shrink(),
    );
  }
}
