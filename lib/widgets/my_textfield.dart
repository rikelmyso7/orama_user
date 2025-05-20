import 'package:flutter/material.dart';
import 'package:orama_user/widgets/my_textstyle.dart';
import 'package:flutter/services.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? icon;
  final Widget? prefixicon;
  final TextInputType? keyBoardType;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  const MyTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.inputFormatters,
    this.obscureText = false,
    this.validator,
    this.icon,
    this.prefixicon,
    this.keyBoardType,
    this.onChanged,
    this.textInputAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        height: 70,
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          validator: validator,
          keyboardType: keyBoardType,
          onChanged: onChanged,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            fillColor: Colors.white,
            filled: true,
            labelText: hintText,
            labelStyle: MyTextStyle.hintTextFieldStyle,
            prefixIcon: prefixicon,
            prefixIconColor: Colors.black38,
            suffixIcon: icon,
          ),
        ),
      ),
    );
  }
}
