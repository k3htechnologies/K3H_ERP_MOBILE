import 'package:flutter/material.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/data/model/amenity_category.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/checkbox/custom_checkbox.dart';

class ExpandableCategoryTile extends StatelessWidget {
  final AmenityCategory category;
  final Function(AmenityCategory) onCategoryChanged;

  const ExpandableCategoryTile({
    super.key,
    required this.category,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColor.grey.withValues(alpha: 0.2),
        ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category.title,
                    style: AppTextStyle.ts14M(),
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
                      final updatedSubCategories = List<AmenitySubCategory>.from(
                        category.subCategories,
                      );
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
                        border: isLast
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
                          CustomCheckbox(
                            value: subCategory.isSelected,
                            onChanged: (value) {
                              final updatedSubCategories =
                                  List<AmenitySubCategory>.from(
                                category.subCategories,
                              );
                              updatedSubCategories[index] = AmenitySubCategory(
                                name: subCategory.name,
                                isSelected: value ?? false,
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
