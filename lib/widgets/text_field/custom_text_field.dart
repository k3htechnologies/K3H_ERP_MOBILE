import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController textController;
  final String? hint;
  final String? title;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatterList;
  final bool obscureText;
  final int minLines;
  final int maxLines;
  final bool readOnly;
  final FocusNode? focusNode;
  final Widget? prefixWidget;
  final Widget? suffixWidget;
  final Function(String)? onChangeFunction;
  final Function(String)? onSubmitFunction;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.textController,
    this.hint,
    this.title,
    this.keyboardType,
    this.inputFormatterList = const [],
    this.obscureText = false,
    this.minLines = 1,
    this.maxLines = 1,
    this.readOnly = false,
    this.focusNode,
    this.prefixWidget,
    this.suffixWidget,
    this.onChangeFunction,
    this.onSubmitFunction,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              title!,
              style: AppTextStyle.ts14R(color: readOnly ? AppColor.grey : null),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 14.0),
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
            focusNode: focusNode,
            style:
            readOnly
                ? AppTextStyle.ts14R().copyWith(color: AppColor.grey)
                : AppTextStyle.ts14R(),
            onChanged: onChangeFunction,
            onFieldSubmitted: onSubmitFunction,
            validator: validator,
            decoration: InputDecoration(
              isDense: true,
              counterText: '',
              hintText: hint ?? "",
              hintStyle: AppTextStyle.ts14R().copyWith(color: AppColor.grey),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 14.0,
              ),
              prefixIcon: prefixWidget,
              suffixIcon: suffixWidget,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(
                  color: AppColor.primary,
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: BorderSide(color: AppColor.grey30, width: 1.0),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: BorderSide(color: AppColor.grey30, width: 1.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: BorderSide(color: AppColor.error, width: 1.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: AppColor.error, width: 1.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}