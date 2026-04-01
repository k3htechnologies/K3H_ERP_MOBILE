import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CustomDropDownWidget extends StatelessWidget {
  final List<Map<String, dynamic>> dataList;
  final Function(Map<String, dynamic>) onSelected;
  final bool? isRequired;
  final String? title;
  final String? hintText;
  final String? Function(Map<String, dynamic>?)? validator;
  final Map<String, dynamic>? initialValue;
  final bool isDisabled;
  final VoidCallback? onValueClear;
  const CustomDropDownWidget({
    super.key,
    required this.dataList,
    this.isRequired = false,
    required this.onSelected,
    this.title,
    this.hintText,
    this.validator,
    this.initialValue,
    this.isDisabled = false,
    this.onValueClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        if (title != null)
          Row(
            children: [
              Text(
                title!,
                style: AppTextStyle.ts14R(),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              isRequired == true
                  ? Text("*", style: AppTextStyle.ts14R(color: AppColor.error))
                  : SizedBox(),
            ],
          ),
        FormField<Map<String, dynamic>>(
          validator: validator,
          initialValue:
              (initialValue == null || initialValue!.isEmpty)
                  ? null
                  : initialValue,
          builder: (FormFieldState<Map<String, dynamic>> formFieldState) {
            final hasError = formFieldState.hasError;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IgnorePointer(
                  ignoring: isDisabled,
                  child: CustomDropdown<Map<String, dynamic>>.search(
                    initialItem: initialValue,
                    closedHeaderPadding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 10.0,
                    ),
                    hintText: hintText ?? 'Select',
                    decoration: CustomDropdownDecoration(
                      hintStyle: AppTextStyle.ts14R().copyWith(
                        color: AppColor.grey,
                      ),
                      expandedBorderRadius: BorderRadius.circular(6),
                      closedBorderRadius: BorderRadius.circular(6),
                      closedErrorBorderRadius: BorderRadius.circular(6),
                      expandedBorder: Border.all(
                        color: AppColor.grey30,
                        width: 1.0,
                      ),
                      closedBorder: Border.all(
                        color:
                            isDisabled
                                ? AppColor.grey.withValues(alpha: 0.2)
                                : hasError
                                ? AppColor.error
                                : AppColor.grey30,
                        width: 1.0,
                      ),
                      closedErrorBorder: Border.all(
                        color: AppColor.error.withValues(alpha: 0.5),
                        width: 1.0,
                      ),
                      errorStyle: AppTextStyle.ts14R(
                        color: AppColor.error,
                      ).copyWith(fontSize: 0),
                    ),
                    items: dataList,
                    listItemPadding: EdgeInsets.zero,
                    listItemBuilder: (context, item, isSelected, onItemSelect) {
                      return ListTile(
                        title: Text(
                          item['DisplayName'] ?? '',
                          style: AppTextStyle.ts14R(),
                        ),
                        onTap: onItemSelect,
                      );
                    },
                    headerBuilder: (context, selectedItem, isSelected) {
                      final displayName =
                          selectedItem['DisplayName']?.toString() ?? '';

                      final hasValue = displayName.isNotEmpty;

                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              hasValue ? displayName : (hintText ?? 'Select'),
                              style: AppTextStyle.ts14R().copyWith(
                                color: hasValue ? null : AppColor.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          if (onValueClear != null && hasValue)
                            GestureDetector(
                              onTap: () {
                                // Clear FormField state
                                formFieldState.didChange(null);

                                // Call external clear callback
                                onValueClear!();
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: AppColor.grey,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                    onChanged: (value) {
                      if (!isDisabled) {
                        formFieldState.didChange(value);
                        onSelected(value!);
                      }
                    },
                  ),
                ),
                hasError
                    ? Container(
                      padding: const EdgeInsets.only(left: 12.0, top: 2.0),
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColor.error,
                            size: 14,
                          ),
                          horizontalSpacing(width: 5),
                          Flexible(
                            child: Text(
                              formFieldState.errorText ?? '',
                              style: AppTextStyle.ts12R(color: AppColor.error),
                            ),
                          ),
                        ],
                      ),
                    )
                    : const SizedBox(height: 18),
              ],
            );
          },
        ),
      ],
    );
  }
}
