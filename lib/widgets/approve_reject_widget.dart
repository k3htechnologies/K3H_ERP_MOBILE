import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ApproveRejectWidget extends StatelessWidget {
  final String actionTitle;
  final bool isActionAlreadyPerformed;

  final ValueChanged<String> onApprove;
  final ValueChanged<String> onReject;
  final VoidCallback? onThirdTap;

  final IconData approveIcon;
  final IconData rejectIcon;
  final IconData thirdIcon;
  final bool isMaster;
  final Widget? customWidget;
  final String popupTitle;
  final String? subTitle;
  // FOLLOWING FUNCTION CAN BE USED TO CONTROL WHETHER THE APPROVE/REJECT DIALOG CAN BE OPENED OR NOT. (USED IN MULTI APPROVAL SCENARIO)
  final bool Function()? canOpenDialog;

  const ApproveRejectWidget({
    super.key,
    required this.actionTitle,
    required this.onApprove,
    required this.onReject,
    this.onThirdTap,
    this.isActionAlreadyPerformed = false,
    this.approveIcon = Icons.check,
    this.rejectIcon = Icons.close,
    this.thirdIcon = Icons.watch_later_outlined,
    this.isMaster = false,
    this.customWidget,
    required this.popupTitle,
    this.subTitle,
    this.canOpenDialog,
  });
  // HANDLER FOR APPROVE/REJECT TAP - TO CHECK IF DIALOG CAN BE OPENED OR NOT
  void _handleApprovalTap(
    BuildContext context, {
    required String actionType,
    required ValueChanged<String> onSubmit,
  }) {
    if (canOpenDialog != null && !canOpenDialog!()) {
      return;
    }

    _showRemarkDialog(context, actionType: actionType, onSubmit: onSubmit);
  }

  @override
  Widget build(BuildContext context) {
    return isMaster
        ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            (customWidget != null)
                ? customWidget!
                : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Approval Status : ",
                      style: AppTextStyle.ts12M(color: AppColor.grey),
                    ),
                    approvalStatusWidget(actionTitle.toUpperCase()),
                  ],
                ),
            (isActionAlreadyPerformed && onThirdTap != null)
                ? Row(
                  children: [
                    CustomIconButton(
                      onPressed: onThirdTap!,
                      icon: Icon(Icons.watch_later_outlined, size: 16),
                    ),
                  ],
                )
                : Row(
                  spacing: 10.w,
                  children: [
                    CustomIconButton(
                      onPressed:
                          () => _handleApprovalTap(
                            context,
                            actionType: "Approve",
                            onSubmit: onApprove,
                          ),
                      backgroundColor: AppColor.lightGreen50,
                      icon: Icon(approveIcon, size: 16, color: AppColor.green),
                    ),
                    CustomIconButton(
                      onPressed:
                          () => _handleApprovalTap(
                            context,
                            actionType: "Reject",
                            onSubmit: onReject,
                          ),
                      backgroundColor: AppColor.lightRed,
                      icon: Icon(rejectIcon, size: 16, color: AppColor.red),
                    ),
                    if (onThirdTap != null)
                      CustomIconButton(
                        onPressed: onThirdTap!,

                        icon: Icon(
                          thirdIcon,
                          size: 16,
                          color: AppColor.primary,
                        ),
                      ),
                  ],
                ),
          ],
        )
        : Container(
          height: 40.h,
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.grey),
            borderRadius: BorderRadius.circular(6),
          ),
          clipBehavior: Clip.hardEdge,
          child: Row(
            children: [
              Expanded(
                flex: isActionAlreadyPerformed ? 1 : 2,
                child: Container(
                  height: double.infinity,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: const BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      bottomLeft: Radius.circular(6),
                    ),
                  ),
                  child: Text('$actionTitle :', style: AppTextStyle.ts14R()),
                ),
              ),
              if (!isActionAlreadyPerformed) ...[
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap:
                        () => _showRemarkDialog(
                          context,
                          actionType: "Approve",
                          onSubmit: onApprove,
                        ),
                    child: Container(
                      height: double.infinity,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD9F0DF),
                        border: Border(
                          left: BorderSide(color: AppColor.grey, width: .5),
                          right: BorderSide(color: AppColor.grey, width: .5),
                        ),
                      ),
                      child: Icon(approveIcon, size: 24, color: Colors.green),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap:
                        () => _showRemarkDialog(
                          context,
                          actionType: "Reject",
                          onSubmit: onReject,
                        ),
                    child: Container(
                      height: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColor.error.withValues(alpha: .2),
                        border: const Border(
                          right: BorderSide(color: AppColor.grey, width: .5),
                        ),
                      ),
                      child: Icon(rejectIcon, size: 24, color: Colors.red),
                    ),
                  ),
                ),
              ],

              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: onThirdTap,
                  child: Container(
                    height: double.infinity,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColor.lightBlue,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(6),
                        bottomRight: Radius.circular(6),
                      ),
                    ),
                    child: Icon(thirdIcon, size: 24, color: AppColor.primary),
                  ),
                ),
              ),
            ],
          ),
        );
  }

  void _showRemarkDialog(
    BuildContext context, {
    required String actionType,
    required ValueChanged<String> onSubmit,
  }) {
    final formKey = GlobalKey<FormState>();
    final remarkController = TextEditingController();

    DialogHelper.showCustomDialogue(
      context,
      title: popupTitle,
      childContent: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subTitle != null) ...[
              Text(subTitle!, style: AppTextStyle.ts14M(color: AppColor.grey)),
              verticalSpacing(),
            ],
            CustomTextField(
              title: "Remark",
              hint: "Enter remark",
              isRequired: true,
              minLines: 3,
              maxLines: 3,
              bottomMargin: 5.h,
              textController: remarkController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Remark is required';
                }
                return null;
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  text: actionType,
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      final remark = remarkController.text.trim();
                      goRouter.pop();
                      onSubmit(remark);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
