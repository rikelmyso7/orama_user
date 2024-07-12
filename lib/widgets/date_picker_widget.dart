  // date_picker_widget.dart
  import 'package:flutter/material.dart';
  import 'package:intl/intl.dart';

  class DatePickerWidget extends StatefulWidget {
    final DateTime initialDate;
    final ValueChanged<DateTime> onDateSelected;
    final DateFormat? dateFormat;
    final TextStyle? textStyle;
    final Color? buttonColor;
    final Color? iconColor;

    const DatePickerWidget({super.key, 
      required this.initialDate,
      required this.onDateSelected,
      this.dateFormat,
      this.textStyle,
      this.buttonColor,
      this.iconColor,
    });

    @override
    _DatePickerWidgetState createState() => _DatePickerWidgetState();
  }

  class _DatePickerWidgetState extends State<DatePickerWidget> {
    late DateTime _selectedDate;

    @override
    void initState() {
      super.initState();
      _selectedDate = widget.initialDate;
    }

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: widget.buttonColor ?? const Color(0xff60C03D),
                onPrimary: widget.iconColor ?? Colors.black45,
                surface: widget.buttonColor ?? Colors.white,
                onSurface: Colors.black,
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child!,
          );
        },
      );
      if (picked != null && picked != _selectedDate) {
        setState(() {
          _selectedDate = picked;
        });
        widget.onDateSelected(_selectedDate);
      }
    }

    @override
    Widget build(BuildContext context) {
      final DateFormat format = widget.dateFormat ?? DateFormat('dd/MM/yyyy');
      return TextButton(
        onPressed: () => _selectDate(context),
        style: TextButton.styleFrom(
          foregroundColor: widget.buttonColor ?? const Color(0xff60C03D),
        ),
        child: Text(
          format.format(_selectedDate),
          style: widget.textStyle ??
              const TextStyle(
                  color: Color(0xff60C03D), fontWeight: FontWeight.w500),
        ),
      );
    }
  }
