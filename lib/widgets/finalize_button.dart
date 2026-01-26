import 'package:flutter/material.dart';

class FinalizeButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FinalizeButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      label: const Text('Finalizar'),
      icon: const Icon(Icons.check),
    );
  }
}
