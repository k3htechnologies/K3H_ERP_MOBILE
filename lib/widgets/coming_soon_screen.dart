import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';

class ComingSoonScreen extends StatefulWidget {
  final String title;
  const ComingSoonScreen({super.key, required this.title});

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen> {
  void _closeDialog() {
    Navigator.of(context, rootNavigator: true).pop();
    goRouter.replaceNamed(AppRoutes.dashboardScreen);
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              goRouter.replaceNamed(AppRoutes.dashboardScreen);
            }
          },
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        CustomIconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.warning_amber_outlined,
                            color: AppColor.yellow,
                            size: 16,
                          ),
                          backgroundColor: AppColor.yellow.withValues(
                            alpha: .2,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            "COMING SOON",
                            style: AppTextStyle.ts16SB(),
                          ),
                        ),

                        InkWell(
                          onTap: _closeDialog,
                          child: Icon(
                            Icons.close,
                            color: AppColor.black,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(
                    color: AppColor.black.withValues(alpha: 0.50),
                    thickness: 0.5,
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Text(
                      "This feature is currently under development and will be available soon.",
                      style: AppTextStyle.ts14SB(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showComingSoonDialog(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        goRouter.replaceNamed(AppRoutes.dashboardScreen);
      },
      child: Scaffold(
        appBar: CustomAppBar(
          screenTitle: widget.title,
          authorization: AuthorizationModel(),
        ),
        body: Container(),
      ),
    );
  }
}
