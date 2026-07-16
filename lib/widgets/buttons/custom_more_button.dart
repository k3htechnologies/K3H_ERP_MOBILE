import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';

class CustomMoreItem {
  final Widget child;
  final VoidCallback onTap;

  const CustomMoreItem({required this.child, required this.onTap});
}

class CustomMoreButton extends StatefulWidget {
  final bool isDisabled;
  final List<CustomMoreItem> items;
  final double dropdownWidth;
  final double offsetY;
  final Color dropdownColor;
  final BorderRadius? borderRadius;
  final bool isVerticalMoreIcon;

  const CustomMoreButton({
    super.key,
    required this.items,
    this.isDisabled = false,
    this.dropdownWidth = 50,
    this.offsetY = 30,
    this.dropdownColor = Colors.transparent,
    this.borderRadius,
    this.isVerticalMoreIcon = true,
  });

  @override
  State<CustomMoreButton> createState() => _CustomMoreButtonState();
}

class _CustomMoreButtonState extends State<CustomMoreButton> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _buttonKey = GlobalKey();

  OverlayEntry? _overlayEntry;

  void _toggleOverlay() {
    if (_overlayEntry != null) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final RenderBox buttonBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;

    final Offset buttonPosition = buttonBox.localToGlobal(Offset.zero);

    final double screenWidth = MediaQuery.of(context).size.width;

    double shiftX = -(widget.dropdownWidth - buttonBox.size.width) / 2;

    if (buttonPosition.dx + shiftX < 8) {
      shiftX = -buttonPosition.dx + 8;
    }

    final double rightEdge = buttonPosition.dx + shiftX + widget.dropdownWidth;

    if (rightEdge > screenWidth - 8) {
      shiftX -= rightEdge - (screenWidth - 8);
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeOverlay,
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(shiftX, widget.offsetY),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: widget.dropdownWidth,
                  decoration: BoxDecoration(
                    color: widget.dropdownColor,
                    borderRadius:
                        widget.borderRadius ?? BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        widget.items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: InkWell(
                              onTap: () {
                                _removeOverlay();
                                item.onTap();
                              },
                              child: IgnorePointer(child: item.child),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: CustomIconButton(
        key: _buttonKey,
        onPressed: _toggleOverlay,
        isDisable: widget.isDisabled,
        backgroundColor: AppColor.lightBlue,
        icon: Icon(
          widget.isVerticalMoreIcon ? Icons.more_vert : Icons.more_horiz,
          size: 18,
          color: widget.isDisabled ? AppColor.grey2 : AppColor.primary,
        ),
      ),
    );
  }
}
