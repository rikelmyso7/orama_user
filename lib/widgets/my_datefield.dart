import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orama_user/widgets/date_dialog.dart';
import 'package:orama_user/widgets/my_textstyle.dart';

class MyDateField extends StatefulWidget {
  final DateTime date;
  final String? hintText;
  final Function(DateTime) newDate;
  const MyDateField(
      {super.key, required this.date, this.hintText, required this.newDate});

  @override
  State<MyDateField> createState() => _MyDateFieldState();
}

class _MyDateFieldState extends State<MyDateField> {
  final TextEditingController dateController = TextEditingController();

  selectDate() async {
    var newDate = await DialogsRepository.selectDate(context, widget.date);
    return newDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: TextFormField(
          controller: dateController,
          readOnly: true,
          onTap: () async {
            var newDate = await selectDate();
            if (newDate != null) {
              dateController.text = DateFormat('dd/MM/yyyy').format(newDate);
              widget.newDate(newDate);
            }
            setState(() {});
          },
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            fillColor: Colors.white,
            filled: true,
            hintText: widget.hintText,
            hintStyle: MyTextStyle.hintTextFieldStyle,
            suffixIcon: IconButton(
              icon: Icon(Icons.calendar_month),
              color: Colors.grey,
              iconSize: 28,
              onPressed: () async {
                var newDate = await selectDate();
                if (newDate != null) {
                  dateController.text =
                      DateFormat('dd/MM/yyyy').format(newDate);
                  widget.newDate(newDate);
                }
                setState(() {});
              },
            ),
          )),
    );
  }
}
