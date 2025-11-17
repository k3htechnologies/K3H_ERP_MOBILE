import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/side_drawer/folder_structure.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CustomSubSubModuleTile extends StatefulWidget {
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
  State<CustomSubSubModuleTile> createState() => _CustomSubSubModuleTileState();
}

class _CustomSubSubModuleTileState extends State<CustomSubSubModuleTile> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          SizedBox(
            width: 15,
            height: double.infinity,
            child: CustomPaint(
              painter: FolderStructureTypeLines(
                drawHorizontalLine: true,
                isLastModule: widget.isLast,
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: widget.onTapFunction,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 5.0,
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      widget.iconData,
                      height: 18,
                      colorFilter: ColorFilter.mode(
                        widget.isActive
                            ? AppColor.slightDarkBlue
                            : AppColor.grey,
                        BlendMode.srcIn,
                      ),
                    ),
                    horizontalSpacing(width: 8),
                    Expanded(
                      child: Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.ts14R(
                          color:
                              widget.isActive
                                  ? AppColor.slightDarkBlue
                                  : AppColor.grey,
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
