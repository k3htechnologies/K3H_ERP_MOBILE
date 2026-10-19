import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';

class ExpandableFloorRow extends StatefulWidget {
  final String title;
  final String floor;

  const ExpandableFloorRow({
    super.key,
    required this.title,
    required this.floor,
  });

  @override
  State<ExpandableFloorRow> createState() => _ExpandableFloorRowState();
}

class _ExpandableFloorRowState extends State<ExpandableFloorRow> {
  final ValueNotifier<bool> _isExpanded = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isExpanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final floors =
        widget.floor
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    final hasMoreFloors = floors.length > 2;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ValueListenableBuilder<bool>(
        valueListenable: _isExpanded,
        builder: (context, isExpanded, child) {
          final visibleFloors =
              isExpanded || !hasMoreFloors ? floors : floors.take(2).toList();

          return buildRowTitleValue(
            title: widget.title,
            value: visibleFloors.join(', '),
            singleLine: false,
            customValueWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(visibleFloors.join(', '), style: AppTextStyle.ts14R()),
                if (hasMoreFloors)
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
