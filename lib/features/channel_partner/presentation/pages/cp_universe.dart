import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';

class CpUniverseScreen extends StatefulWidget {
  const CpUniverseScreen({super.key});

  @override
  State<CpUniverseScreen> createState() => _CpUniverseScreenState();
}

class _CpUniverseScreenState extends State<CpUniverseScreen> {
  void _showComingSoonDialog(BuildContext context) {
    DialogHelper.showCustomDialogue(
      context,
      icon: CustomIconButton(
        onPressed: () {},
        icon: Icon(
          Icons.warning_amber_outlined,
          color: AppColor.yellow,
          size: 16,
        ),
        backgroundColor: AppColor.yellow.withValues(alpha: .2),
      ),
      title: "COMING SOON",
      onDismiss: () => goRouter.replaceNamed(AppRoutes.dashboardScreen),
      childContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            color: AppColor.black.withValues(alpha: 0.50),
            thickness: 0.5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(
              "This feature is currently under development and will be available soon.",
              style: AppTextStyle.ts14SB(),
            ),
          ),
        ],
      ),
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
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "CP Universe",
        authorization: AuthorizationModel(),
      ),
      body: Container(),
    );
  }
}
