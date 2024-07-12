import 'package:flutter/material.dart';
import 'package:orama_user/widgets/my_textstyle.dart';

class MyButton extends StatefulWidget {
  final String buttonName;
  final Function()? onTap;
  const MyButton({super.key, required this.buttonName, this.onTap});

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (widget.onTap != null && isLoading == false) {
          try {
            isLoading = true;
            setState(() {});
            await widget.onTap!();
            isLoading = false;
            setState(() {});
          } catch (e) {
            isLoading = false;
            setState(() {});
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        decoration: BoxDecoration(
          color: widget.onTap == null ? Colors.grey : Color(0xff60C03D),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 12,
              offset: Offset(0, 7), // changes position of shadow
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? Container(
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  widget.buttonName,
                  style: MyTextStyle.largerButtonTextStyle,
                ),
        ),
      ),
    );
  }
}
