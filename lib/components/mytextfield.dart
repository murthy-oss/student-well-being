import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final String hint;
  final bool obscure;
  final bool selection;
  final FocusNode? focusNode;
  final TextEditingController controller;
  final IconData preIcon;
  final IconData? suffixIcon; // Make suffixIcon optional
  final autofillhints;
  final FormFieldValidator<String>? validator; // Add validator

  const MyTextField({
    Key? key,
    required this.controller,
    required this.hint,
    required this.obscure,
    required this.selection,
    this.focusNode,
    required this.preIcon,
    this.suffixIcon,
    this.autofillhints,
    this.validator, // Add validator parameter
// Update suffixIcon to be optional
  }) : super(key: key);

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: AutofillGroup(
        child: TextFormField(
          validator: widget.validator, // Set the validator

          autofillHints: widget.autofillhints,
          obscureText: _obscureText,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
            contentPadding: EdgeInsets.all(20),
            hintText: widget.hint,
            prefixIcon: Icon(widget.preIcon),
            suffixIcon: widget.suffixIcon != null
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(_obscureText
                          ? Icons.visibility_off
                          : Icons.visibility),
                    ),
                  )
                : null,
            fillColor: Color(0xFFE5E5E5),
            filled: true,
            focusColor: Color(0xffd8c8ea),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
          controller: widget.controller,
          style: TextStyle(
            fontFamily: 'ABC Diatype',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
