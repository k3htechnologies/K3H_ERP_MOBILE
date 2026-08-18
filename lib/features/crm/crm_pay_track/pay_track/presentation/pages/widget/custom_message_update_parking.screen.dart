import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';

class CustomMessageButton extends StatefulWidget {
  final bool isDisabled;
  final VoidCallback onWelcome;
  final VoidCallback onEmail;

  const CustomMessageButton({
    super.key,
    required this.onWelcome,
    required this.onEmail,
    this.isDisabled = false,
  });

  @override
  State<CustomMessageButton> createState() => _CustomMessageButtonState();
}

class _CustomMessageButtonState extends State<CustomMessageButton> {
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
    const double dropdownWidth = 160.0;

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
      builder: (_) {
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
              offset: Offset(shiftX, 42),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: dropdownWidth,
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .12),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildItem(
                        icon: Icons.message_outlined,
                        label: "Send Message",
                        onTap: () {
                          _removeOverlay();
                          widget.onWelcome();
                        },
                      ),
                      _buildItem(
                        icon: Icons.email_outlined,
                        label: "Send e-mail",
                        onTap: () {
                          _removeOverlay();
                          widget.onEmail();
                        },
                      ),
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

  Widget _buildItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          label,
          style: AppTextStyle.ts14R(
            color: AppColor.black.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
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
      child: CustomButton(
        key: _buttonKey,
        text: "Welcome",
        isDisable: widget.isDisabled,
        onPressed: _toggleOverlay,
      ),
    );
  }
}
