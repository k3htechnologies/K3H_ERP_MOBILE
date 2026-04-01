import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

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
  final double bottomMargin;

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
    this.bottomMargin = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: validator,
      builder: (FormFieldState<String> formFieldState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (formFieldState.value != textController.text) {
            formFieldState.didChange(textController.text);
          }
        });

        final hasError = formFieldState.hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      title!,
                      style: AppTextStyle.ts14R(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  if (isRequired == true)
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Text(
                        "*",
                        style: AppTextStyle.ts14R(color: AppColor.error),
                      ),
                    ),
                ],
              ),
            Padding(
              padding: EdgeInsets.only(bottom: 2.0),
              child: TextFormField(
                controller: textController,
                keyboardType: keyboardType,
                inputFormatters: inputFormatterList,
                obscureText: obscureText,
                readOnly: readOnly,
                enableInteractiveSelection: !readOnly,
                showCursor: !readOnly,
                onTap: readOnly ? () {} : null,
                minLines: minLines,
                maxLines: maxLines,
                cursorColor: AppColor.primary,
                focusNode: focusNode,
                style:
                    readOnly
                        ? AppTextStyle.ts14R().copyWith(color: AppColor.grey)
                        : AppTextStyle.ts14R(),
                onChanged: (value) {
                  onChangeFunction?.call(value);
                },
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                onFieldSubmitted: onSubmitFunction,
                decoration: InputDecoration(
                  isDense: true,
                  counterText: '',
                  hintText: hint ?? "",
                  hintStyle: AppTextStyle.ts14R().copyWith(
                    color: AppColor.grey,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 14.0,
                  ),
                  prefixIcon: prefixWidget,
                  suffixIcon: suffixWidget,

                  //  APPLY hasError HERE
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

            //  SHOW ERROR TEXT (WITHOUT REMOVING ANYTHING ELSE)
            hasError
                ? Container(
                  padding: const EdgeInsets.only(top: 2, left: 12),
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: AppColor.error, size: 14),
                      horizontalSpacing(width: 5),
                      Expanded(
                        child: Text(
                          formFieldState.errorText ?? "",
                          style: AppTextStyle.ts12R(color: AppColor.error),
                        ),
                      ),
                    ],
                  ),
                )
                : SizedBox(height: bottomMargin),
          ],
        );
      },
    );
  }
}
