import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController textController;
  final bool? isRequired;
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
    this.isRequired = false,
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
    return FormField<String>(
      validator: validator,
      initialValue: textController.text,
      builder: (FormFieldState<String> formFieldState) {
        final hasError = formFieldState.hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text(
                      title!,
                      style: AppTextStyle.ts14R(
                        color: readOnly ? AppColor.grey : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isRequired == true
                        ? Text("*", style: AppTextStyle.ts14R(color: AppColor.error))
                        : SizedBox(),
                  ],
                ),
              ),

            Padding(
              padding: EdgeInsets.only(bottom:  2.0),
              child: TextFormField(
                controller: textController,
                keyboardType: keyboardType,
                inputFormatters: inputFormatterList,
                obscureText: obscureText,
                readOnly: readOnly,
                minLines: minLines,
                maxLines: maxLines,
                cursorColor: AppColor.primary,
                focusNode: focusNode,
                style: readOnly
                    ? AppTextStyle.ts14R().copyWith(color: AppColor.grey)
                    : AppTextStyle.ts14R(),
                onChanged: (value) {
                  formFieldState.didChange(value); // IMPORTANT
                  onChangeFunction?.call(value);
                },
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                onFieldSubmitted: onSubmitFunction,
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

                  // 🔥 APPLY hasError HERE
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                    borderSide: BorderSide(
                      color: hasError ? AppColor.error : AppColor.grey30,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                    borderSide: BorderSide(
                      color: hasError ? AppColor.error : AppColor.primary,
                      width: 1.0,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                    borderSide: BorderSide(color: AppColor.error, width: 1.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                    borderSide: BorderSide(color: AppColor.error, width: 1.0),
                  ),
                ),
              ),
            ),

            // 🔥 SHOW ERROR TEXT (WITHOUT REMOVING ANYTHING ELSE)
            hasError?
              Padding(
                padding: const EdgeInsets.only(top: 2, left: 12),
                child: Text(
                  formFieldState.errorText ?? "",
                  style: AppTextStyle.ts12R(color: AppColor.error),
                ),
              ) : const SizedBox(height: 18),
          ],
        );
      },
    );
  }
}
