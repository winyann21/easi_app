// ignore_for_file: unnecessary_const, prefer_typing_uninitialized_variables, unnecessary_null_in_if_null_operators
import 'package:flutter/material.dart';

class RoundRectTextFormField extends StatelessWidget {
  const RoundRectTextFormField({
    Key? key,
    this.controller,
    this.obscureText = false,
    required this.hintText,
    required this.labelText,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixIconOnPressed,
    this.textInputAction,
    this.keyboardType,
    this.onFieldSubmitted,
    this.onTap,
    this.textCapitalization,
  }) : super(key: key);

  final TextEditingController? controller;
  final bool? obscureText;
  final String? hintText;
  final String? labelText;
  final validator;
  final IconData? prefixIcon;
  final suffixIcon;
  final suffixIconOnPressed;
  final textInputAction;
  final keyboardType;
  final onFieldSubmitted;
  final onTap;
  final textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: onTap,
      controller: controller,
      obscureText: obscureText!,
      decoration: InputDecoration(
        hintText: hintText!,
        labelText: labelText!,
        prefixIcon: Icon(
          prefixIcon,
          color: Colors.orange,
        ),
        suffixIcon: suffixIcon == null
            ? null
            : IconButton(
                onPressed: suffixIconOnPressed,
                icon: Icon(
                  suffixIcon,
                  color: Colors.orange,
                ),
              ),
        focusedBorder: const OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.orange,
          ),
          borderRadius: const BorderRadius.all(
            const Radius.circular(10.0),
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.orange,
          ),
          borderRadius: const BorderRadius.all(
            const Radius.circular(10.0),
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
          ),
          borderRadius: const BorderRadius.all(
            const Radius.circular(10.0),
          ),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
          ),
          borderRadius: const BorderRadius.all(
            const Radius.circular(10.0),
          ),
        ),
      ),
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
    );
  }
}
