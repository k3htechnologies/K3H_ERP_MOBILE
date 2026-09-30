import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/text_style.dart';

import '../custom_chip_for_status_widget.dart';

class CustomStatusBadgeDropdown extends StatefulWidget {
  final String initialValue;
  final Map<String, StatusConfig> itemConfig;

  // Changed from ValueChanged<String>
  final Future<bool> Function(String value) onSelect;

  final bool disabled;

  const CustomStatusBadgeDropdown({
    super.key,
    required this.initialValue,
    required this.itemConfig,
    required this.onSelect,
    this.disabled = false,
  });

  @override
  State<CustomStatusBadgeDropdown> createState() =>
      _CustomStatusBadgeDropdownState();
}

class _CustomStatusBadgeDropdownState extends State<CustomStatusBadgeDropdown> {
  late String selectedValue;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant CustomStatusBadgeDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialValue != widget.initialValue) {
      selectedValue = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  // Only changed this logic
  Future<void> _onSelect(String value) async {
    _removeOverlay();

    final bool success = await widget.onSelect(value);

    if (!mounted) return;

    if (success) {
      setState(() {
        selectedValue = value;
      });
    }
  }

  void _toggleDropdown() {
    if (widget.disabled) return;

    if (_overlayEntry != null) {
      _removeOverlay();
    } else {
      _showDropdown();
    }
  }

  void _showDropdown() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;

    if (renderBox == null) return;

    final Offset position = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    final screenHeight = MediaQuery.of(context).size.height;

    const double itemHeight = 48;
    final double dropdownHeight = widget.itemConfig.length * itemHeight;

    const double verticalGap = 4;
    const double screenPadding = 8;

    final double spaceBelow = screenHeight - (position.dy + size.height);

    final double spaceAbove = position.dy;

    final bool showBelow =
        spaceBelow >= dropdownHeight + verticalGap || spaceBelow >= spaceAbove;

    final double top;

    if (showBelow) {
      top = position.dy + size.height + verticalGap;
    } else {
      top = position.dy - dropdownHeight - verticalGap;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeOverlay,
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: position.dx,
              top: top.clamp(
                screenPadding,
                screenHeight - dropdownHeight - screenPadding,
              ),
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset:
                    showBelow
                        ? Offset(0, size.height + verticalGap)
                        : Offset(0, -dropdownHeight - verticalGap),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 120),
                    child: IntrinsicWidth(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            widget.itemConfig.keys.map((item) {
                              return InkWell(
                                onTap: () => _onSelect(item),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      item,
                                      style: AppTextStyle.ts12M(),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final statusConfig = widget.itemConfig[selectedValue.toLowerCase()];

    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusConfig?.backgroundColor,
        border: Border.all(
          color: statusConfig?.textColor ?? Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusConfig?.textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            selectedValue,
            style: AppTextStyle.ts12SB().copyWith(
              color: statusConfig?.textColor,
            ),
          ),
          const SizedBox(width: 5),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: statusConfig?.textColor,
          ),
        ],
      ),
    );

    if (widget.disabled) {
      return badge;
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(onTap: _toggleDropdown, child: badge),
    );
  }
}
