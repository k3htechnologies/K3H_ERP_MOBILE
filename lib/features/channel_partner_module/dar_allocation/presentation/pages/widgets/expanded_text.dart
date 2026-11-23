import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';

class ExpandableVillageColumn extends StatefulWidget {
  final String title;
  final String village;

  const ExpandableVillageColumn({
    super.key,
    required this.title,
    required this.village,
  });

  @override
  State<ExpandableVillageColumn> createState() => _ExpandableFloorRowState();
}

class _ExpandableFloorRowState extends State<ExpandableVillageColumn> {
  final ValueNotifier<bool> _isExpanded = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isExpanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final villages =
        widget.village
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    final hasMoreVillages = villages.length > 2;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ValueListenableBuilder<bool>(
        valueListenable: _isExpanded,
        builder: (context, isExpanded, child) {
          final visibleVillages =
              isExpanded || !hasMoreVillages
                  ? villages
                  : villages.take(2).toList();

          return buildColumnTitleValue(
            title: widget.title,
            value: visibleVillages.join(', '),
            removeExpanded: true,
            customValueWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(visibleVillages.join(', '), style: AppTextStyle.ts14R()),
                if (hasMoreVillages)
                  InkWell(
                    onTap: () => _isExpanded.value = !isExpanded,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isExpanded ? 'See less' : 'See more',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 17,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
