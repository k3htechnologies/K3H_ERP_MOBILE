import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';

class LoginTextFieldWidget extends StatelessWidget {
  final TextEditingController textController;
  final String? hint;
  final String? label;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatterList;
  final bool obscureText;
  final int minLines;
  final int maxLines;
  final bool readOnly;
  final bool isMargin;
  final FocusNode? focusNode;
  final Widget? prefixWidget;
  final Widget? suffixWidget;
  final Function(String)? onChangeFunction;
  final Function(String)? onSubmitFunction;
  final String? Function(String?)? validator;

  const LoginTextFieldWidget({
    super.key,
    required this.textController,
    this.hint,
    this.label,
    this.keyboardType,
    this.inputFormatterList = const [],
    this.obscureText = false,
    this.minLines = 1,
    this.maxLines = 1,
    this.readOnly = false,
    this.isMargin = true,
    this.focusNode,
    this.prefixWidget,
    this.suffixWidget,
    this.onChangeFunction,
    this.onSubmitFunction,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 40.0,
      margin:
      isMargin
          ? const EdgeInsetsDirectional.only(bottom: 10.0)
          : const EdgeInsetsDirectional.only(bottom: 0.0),
      child: TextFormField(
        controller: textController,
        keyboardType: keyboardType,
        inputFormatters: inputFormatterList,
        obscureText: obscureText,
        readOnly: readOnly,
        minLines: minLines,
        maxLines: maxLines,
        cursorColor: AppColor.primary,
        textInputAction: TextInputAction.newline,
        style:
        readOnly
            ? AppTextStyle.ts14R().copyWith(color: AppColor.grey)
            : AppTextStyle.ts14R(),
        onChanged: onChangeFunction,
        onTapOutside: (event) {
          FocusScope.of(context).unfocus();
        },
        onFieldSubmitted: onSubmitFunction,
        validator: validator,
        decoration: InputDecoration(
          counterText: '',
          isDense: true,
          hoverColor: AppColor.white,
          hintText: hint ?? '',
          hintStyle: AppTextStyle.ts14R().copyWith(color: AppColor.grey),
          labelText: label,
          labelStyle:
          readOnly
              ? AppTextStyle.ts14R().copyWith(color: AppColor.grey)
              : AppTextStyle.ts14R(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 15.0,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: readOnly ? AppColor.darkGrey : AppColor.info,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color:
              readOnly
                  ? AppColor.darkGrey
                  : AppColor.grey.withValues(alpha: 0.3),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          errorBorder: OutlineInputBorder(
            gapPadding: 0,
            borderSide: BorderSide(color: AppColor.error, width: 1.0),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            gapPadding: 0,
            borderSide: BorderSide(color: AppColor.error, width: 1.0),
            borderRadius: BorderRadius.circular(12.0),
          ),
          errorStyle: AppTextStyle.ts14R(color: AppColor.error),
          prefixIcon: prefixWidget,
          suffixIcon: suffixWidget,
        ),
      ),
    );
  }
}