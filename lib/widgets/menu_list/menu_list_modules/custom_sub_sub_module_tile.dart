import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/menu_list/folder_structure.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CustomSubSubModuleTile extends StatelessWidget {
  final String title;
  final String iconData;
  final VoidCallback onTapFunction;
  final bool isActive;
  final bool isLast;

  const CustomSubSubModuleTile({
    super.key,
    required this.title,
    required this.iconData,
    required this.onTapFunction,
    this.isActive = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 15,
            child: CustomPaint(
              painter: FolderStructureTypeLines(
                drawHorizontalLine: true,
                isLastModule: isLast,
              ),
            ),
          ),

          Expanded(
            child: InkWell(
              onTap: onTapFunction,
              child: Container(
                constraints: const BoxConstraints(minHeight: 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 6,
                      width: 6,
                      decoration: BoxDecoration(
                        color: AppColor.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    horizontalSpacing(width: 8),

                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyle.ts14R(
                          color: isActive ? AppColor.primary : AppColor.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
