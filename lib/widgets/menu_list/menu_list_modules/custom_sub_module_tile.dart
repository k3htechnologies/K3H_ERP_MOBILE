import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/menu_list/folder_structure.dart';

class CustomSubModuleTile extends StatefulWidget {
  final String title;
  final String imagePath;
  final List<Widget>? items;
  final bool isActive;
  final bool isExpanded;
  final bool isLast;
  final VoidCallback? onTapCallback;

  const CustomSubModuleTile({
    super.key,
    required this.title,
    required this.imagePath,
    this.items,
    this.isActive = false,
    this.isExpanded = false,
    this.isLast = false,
    this.onTapCallback,
  });

  @override
  State<CustomSubModuleTile> createState() => _CustomSubModuleTileState();
}

class _CustomSubModuleTileState extends State<CustomSubModuleTile> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final hasItems = widget.items != null && widget.items!.isNotEmpty;
    const double tileHeight = 48.0;
    const double childTileHeight = 40.0;

    // HEIGHT WILL BE CONSTANT BUT THE IT WILL BE EXPANDED ACCORDING TO THE STATE OF EXPANSION TILE
    final double calculatedHeight =
        _isExpanded && hasItems
            ? tileHeight + (widget.items!.length * childTileHeight)
            : tileHeight;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 15,
          height: calculatedHeight,
          child: CustomPaint(
            painter: FolderStructureTypeLines(
              drawHorizontalLine: true,
              isLastModule: widget.isLast,
            ),
          ),
        ),
        Expanded(
          child: Theme(
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
                        minTileHeight: tileHeight,
                        initiallyExpanded: widget.isExpanded,
                        onExpansionChanged:
                            (val) => setState(() => _isExpanded = val),
                        childrenPadding: const EdgeInsets.only(left: 15.0),
                        title: Row(
                          children: [
                            Container(
                              height: 6,
                              width: 6,
                              decoration: BoxDecoration(
                                color: AppColor.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyle.ts14R(
                                  color:
                                      widget.isActive
                                          ? AppColor.slightDarkBlue
                                          : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        children: widget.items!,
                      )
                      : ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        title: Row(
                          children: [
                            Container(
                              height: 6,
                              width: 6,
                              decoration: BoxDecoration(
                                color: AppColor.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyle.ts14R(
                                  color:
                                      widget.isActive
                                          ? AppColor.slightDarkBlue
                                          : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: widget.onTapCallback,
                      ),
            ),
          ),
        ),
      ],
    );
  }
}
