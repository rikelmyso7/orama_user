import 'package:flutter/material.dart';

class DialogsRepository {
  DialogsRepository._();

  static Future<DateTime?> selectDate(
      BuildContext context, DateTime date) async {
    DateTime? _datePicker = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: const Color(0xff60C03D),
                onPrimary: Colors.black45,
                surface:Colors.white,
                onSurface: Colors.black,
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child!,
          );
      },
    );

    return _datePicker;
  }
}
