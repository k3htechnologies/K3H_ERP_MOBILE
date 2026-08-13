import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/features/business_development/proposed_plans/data/model/amenity_category.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/checkbox/custom_checkbox.dart';

class AmenityCategoryTile extends StatelessWidget {
  final AmenityCategory category;
  final Function(AmenityCategory) onCategoryChanged;
  final bool canAction;
  const AmenityCategoryTile({
    super.key,
    required this.category,
    required this.onCategoryChanged,
    this.canAction = true,
  });
  @override
  Widget build(BuildContext context) {
    final selectedSubCategoryCount =
        category.subCategories
            .where((e) => e.isSelected == true)
            .toList()
            .length;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Category Title with Expand/Collapse Icon
          InkWell(
            onTap: () {
              final updatedCategory = AmenityCategory(
                title: category.title,
                subCategories: category.subCategories,
                isExpanded: !category.isExpanded,
              );
              onCategoryChanged(updatedCategory);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: category.title,
                          style: AppTextStyle.ts14M(),
                        ),
                        TextSpan(
                          text: " ($selectedSubCategoryCount)",
                          style: AppTextStyle.ts14M(color: AppColor.grey),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    category.isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColor.grey,
                  ),
                ],
              ),
            ),
          ),
          // Subcategories List
          if (category.isExpanded)
            Column(
              children: [
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColor.grey.withValues(alpha: 0.2),
                ),
                ...category.subCategories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final subCategory = entry.value;
                  final isLast = index == category.subCategories.length - 1;
                  return InkWell(
                    onTap: () {
                      if (!canAction) return;
                      final updatedSubCategories =
                          List<AmenitySubCategory>.from(category.subCategories);
                      updatedSubCategories[index] = AmenitySubCategory(
                        name: subCategory.name,
                        isSelected: !subCategory.isSelected,
                      );
                      final updatedCategory = AmenityCategory(
                        title: category.title,
                        subCategories: updatedSubCategories,
                        isExpanded: category.isExpanded,
                      );
                      onCategoryChanged(updatedCategory);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border:
                            isLast
                                ? null
                                : Border(
                                  bottom: BorderSide(
                                    color: AppColor.grey.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                      ),
                      child: Row(
                        children: [
                          CustomCheckBox(
                            isSelected: subCategory.isSelected,
                            isDisabled: !canAction,
                            onChanged: (value) {
                              if (!canAction) return;
                              final updatedSubCategories =
                                  List<AmenitySubCategory>.from(
                                    category.subCategories,
                                  );
                              updatedSubCategories[index] = AmenitySubCategory(
                                name: subCategory.name,
                                isSelected: value,
                              );
                              final updatedCategory = AmenityCategory(
                                title: category.title,
                                subCategories: updatedSubCategories,
                                isExpanded: category.isExpanded,
                              );
                              onCategoryChanged(updatedCategory);
                            },
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              subCategory.name,
                              style: AppTextStyle.ts14R(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }
}
