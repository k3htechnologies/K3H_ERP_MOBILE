import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

class CustomDropDownWidget extends StatelessWidget {
  final List<Map<String, dynamic>> dataList;
  final Function(Map<String, dynamic>) onSelected;
  final String? title;
  final String? Function(Map<String, dynamic>?)? validator;
  final Map<String, dynamic>? initialValue;
  const CustomDropDownWidget({
    super.key,
    required this.dataList,
    required this.onSelected,
    this.title,
    this.validator,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        if (title != null)
          Text(
            title!,
            style: AppTextStyle.ts14R(),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        FormField<Map<String, dynamic>>(
          validator: validator,
          initialValue: initialValue,
          builder: (FormFieldState<Map<String, dynamic>> formFieldState) {
            final hasError = formFieldState.hasError;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomDropdown<Map<String, dynamic>>.search(
                  initialItem: initialValue,
                  closedHeaderPadding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 10.0,
                  ),
                  hintText: 'Select',
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
                      color: hasError ? AppColor.error : AppColor.grey30,
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
                    return Text(
                      selectedItem['DisplayName'] ?? '',
                      style: AppTextStyle.ts14R(),
                    );
                  },
                  onChanged: (value) {
                    formFieldState.didChange(value);
                    onSelected(value!);
                  },
                ),
                hasError
                    ? Padding(
                  padding: const EdgeInsets.only(left: 12.0, top: 2.0),
                  child: Text(
                    formFieldState.errorText ?? '',
                    style: AppTextStyle.ts12R(color: AppColor.error),
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