import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';

class CustomExportButton extends StatefulWidget {
  final bool isDisabled;
  final Function(String) onExport;

  const CustomExportButton({
    super.key,
    required this.onExport,
    this.isDisabled = false,
  });

  @override
  State<CustomExportButton> createState() => _CustomExportButtonState();
}

class _CustomExportButtonState extends State<CustomExportButton> {
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
    const double dropdownWidth = 180;

    final RenderBox buttonBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;

    final Offset buttonPosition = buttonBox.localToGlobal(Offset.zero);

    final double screenWidth = MediaQuery.of(context).size.width;

    double shiftX = 0;

    final overflowRight = buttonPosition.dx + dropdownWidth - screenWidth;

    if (overflowRight > 0) {
      shiftX = -overflowRight - 8;
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
              offset: Offset(shiftX, 40),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: dropdownWidth,
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildItem(label: 'Export as Excel', value: 'EXCEL'),
                      _buildItem(label: 'Export as PDF', value: 'PDF'),
                    ],
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

  Widget _buildItem({required String label, required String value}) {
    return InkWell(
      onTap: () {
        _removeOverlay();
        widget.onExport(value);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.file_download_outlined, color: AppColor.primary),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyle.ts14R()),
          ],
        ),
      ),
    );
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
        icon: Icon(
          Icons.file_download_outlined,
          size: 16,
          color: widget.isDisabled ? AppColor.grey2 : AppColor.darkGreen,
        ),
        backgroundColor: AppColor.lightGreen,
      ),
    );
  }
}
