import 'package:flutter/material.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CustomExpandableCard extends StatefulWidget {
  final Widget header;
  final Widget body;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool initiallyExpanded;
  final VoidCallback? onExpansionChanged;

  const CustomExpandableCard({
    super.key,
    required this.header,
    required this.body,
    this.padding,
    this.margin,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
  });

  @override
  State<CustomExpandableCard> createState() => _CustomExpandableCardState();
}

class _CustomExpandableCardState extends State<CustomExpandableCard>
    with SingleTickerProviderStateMixin {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    widget.onExpansionChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: widget.margin ?? const EdgeInsets.only(bottom: 10),
      padding: widget.padding ?? const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            onTap: _toggle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: widget.header),
                horizontalSpacing(),
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: AnimatedRotation(
                    turns: _expanded ? .5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                ),
              ],
            ),
          ),
          ClipRect(
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              alignment: Alignment.topCenter,
              heightFactor: _expanded ? 1 : 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: widget.body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
