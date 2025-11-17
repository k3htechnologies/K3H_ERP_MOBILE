import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';


class CustomModuleTile extends StatefulWidget {
  final String title;
  final String imagePath;
  final List<Widget>? items;
  final bool isActive;
  final bool isExpanded;
  final bool isLast;
  final VoidCallback? onTapCallback;

  const CustomModuleTile({
    super.key,
    required this.title,
    required this.imagePath,
    this.onTapCallback,
    this.items,
    this.isExpanded = false,
    this.isActive = false,
    this.isLast = false,
  });

  @override
  State<CustomModuleTile> createState() => _CustomModuleTileState();
}

class _CustomModuleTileState extends State<CustomModuleTile> {
  @override
  Widget build(BuildContext context) {
    final hasItems = widget.items != null && widget.items!.isNotEmpty;
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: ListTileTheme(
        minLeadingWidth: 0,
        minVerticalPadding: 0,
        child:
            hasItems
                ? ExpansionTile(
                  collapsedIconColor: AppColor.black,
                  iconColor: AppColor.black,
                  minTileHeight: 30,
                  initiallyExpanded: widget.isExpanded,
                  childrenPadding: const EdgeInsets.only(left: 15.0),
                  title: Row(
                    children: [
                      Image.asset(widget.imagePath, height: 20),
                      horizontalSpacing(),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: AppTextStyle.ts16SB(
                            color:
                                widget.isActive
                                    ? AppColor.slightDarkBlue
                                    : AppColor.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  children: widget.items!,
                )
                : ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                  minTileHeight: 30,
                  title: Row(
                    children: [
                      Image.asset(widget.imagePath, height: 20),
                      horizontalSpacing(),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: AppTextStyle.ts16SB(
                            color:
                                widget.isActive
                                    ? AppColor.slightDarkBlue
                                    : AppColor.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  onTap: widget.onTapCallback,
                ),
      ),
    );
  }
}
