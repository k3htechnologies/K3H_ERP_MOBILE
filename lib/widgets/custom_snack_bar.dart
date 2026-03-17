import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';

class CustomSnackBar {
  static void showTopSnackBar(
    BuildContext context, {
    required String title,
    String? subtitle,
    bool isError = false,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => _SnackBarSlideDown(
            title: title,
            subtitle: subtitle,
            isError: isError,
          ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3)).then((_) {
      overlayEntry.remove();
    });
  }
}

class _SnackBarSlideDown extends StatefulWidget {
  final String title;
  final String? subtitle;
  final bool isError;

  const _SnackBarSlideDown({
    required this.title,
    this.subtitle,
    required this.isError,
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
        minimum: const EdgeInsets.only(top: 12), // pushes below status bar
        child: SlideTransition(
          position: _offsetAnimation,
          child: _SnackBarContent(
            subtitle: widget.subtitle,
            isError: widget.isError,
          ),
        ),
      ),
    );
  }
}

class _SnackBarContent extends StatelessWidget {
  final String? subtitle;
  final bool isError;

  const _SnackBarContent({required this.subtitle, required this.isError});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isError ? AppColor.lightRed : AppColor.lightGreen,
          border: Border.all(
            color: isError ? AppColor.error : AppColor.green,
            width: .5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        child: Row(
          crossAxisAlignment:
              subtitle != null
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
          children: [
            // ICON LEFT CIRCLE
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isError ? AppColor.error : AppColor.darkGreen10,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: AppTextStyle.ts14R(
                        color: isError ? AppColor.error : AppColor.darkGreen10,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 6),

            // CLOSE ICON
            Icon(
              Icons.close,
              color: isError ? AppColor.error : AppColor.darkGreen10,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
