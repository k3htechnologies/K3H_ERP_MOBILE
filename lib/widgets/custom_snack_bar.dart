import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';

class CustomSnackBar {
  static void showTopSnackBar(
    BuildContext context, {
    required String title,
    bool isError = false,
  }) {
    final overlay = Overlay.of(context);

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => _SnackBarSlideDown(
            title: title,
            isError: isError,
            onClose: () {
              if (overlayEntry.mounted) {
                overlayEntry.remove();
              }
            },
          ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3)).then((_) {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

class _SnackBarSlideDown extends StatefulWidget {
  final String title;
  final bool isError;
  final VoidCallback onClose;

  const _SnackBarSlideDown({
    required this.title,
    required this.isError,
    required this.onClose,
  });

  @override
  State<_SnackBarSlideDown> createState() => _SnackBarSlideDownState();
}

class _SnackBarSlideDownState extends State<_SnackBarSlideDown>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      right: 20,
      child: SafeArea(
        minimum: const EdgeInsets.only(top: 12),
        child: SlideTransition(
          position: _offsetAnimation,
          child: _SnackBarContent(
            title: widget.title,
            isError: widget.isError,
            onClose: widget.onClose,
          ),
        ),
      ),
    );
  }
}

class _SnackBarContent extends StatelessWidget {
  final String title;
  final bool isError;
  final VoidCallback onClose;

  const _SnackBarContent({
    required this.title,
    required this.isError,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isError ? AppColor.lightRed : const Color(0xffE7F6E9),
          border: Border.all(
            color: isError ? AppColor.error : AppColor.green,
            width: .5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ICON
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isError ? AppColor.error : const Color(0xff16A34A),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isError ? Icons.not_interested_outlined : Icons.check,
                color: Colors.white,
                size: 18,
              ),
            ),

            const SizedBox(width: 12),

            // TEXT
            Expanded(
              child: Text(
                title,
                style: AppTextStyle.ts14SB(
                  color: isError ? AppColor.error : const Color(0xff16A34A),
                ),
              ),
            ),

            const SizedBox(width: 6),

            // CLOSE BUTTON
            GestureDetector(
              onTap: onClose,
              child: Icon(
                Icons.close,
                color: isError ? AppColor.error : AppColor.darkGreen10,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
