// lib/widgets/loading_dialog.dart
import 'dart:async';
import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({
    super.key,
    this.color = const Color(0xff60C03D),
    this.barrierDismissible = false,
  });

  final Color color;
  final bool barrierDismissible;

  /// Mostra o diálogo de loading.
  ///
  /// * [autoCloseAfter] – se definido, fecha sozinho após esse tempo.
  static Future<T?> show<T>(
    BuildContext context, {
    Color color = const Color(0xff60C03D),
    bool barrierDismissible = false,
    Duration? autoCloseAfter,
  }) async {
    // abre o diálogo
    final dialogFuture = showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => LoadingDialog(
        color: color,
        barrierDismissible: barrierDismissible,
      ),
    );

    // se pediu auto-fechamento, agenda um pop
    if (autoCloseAfter != null) {
      Future.delayed(autoCloseAfter).then((_) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(); // fecha o diálogo
        }
      });
    }
    return dialogFuture;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: barrierDismissible,
      child: Center(child: CircularProgressIndicator(color: color)),
    );
  }
}
