import 'package:flutter/material.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class ApproveRejectWidget extends StatelessWidget {
  final String title;
  final bool isActionAlreadyPerformed;

  final ValueChanged<String> onApprove;
  final ValueChanged<String> onReject;
  final VoidCallback? onThirdTap;

  final IconData approveIcon;
  final IconData rejectIcon;
  final IconData thirdIcon;
  final bool isMaster;
  final Widget? customWidget;

  const ApproveRejectWidget({
    super.key,
    required this.title,
    required this.onApprove,
    required this.onReject,
    this.onThirdTap,
    this.isActionAlreadyPerformed = false,
    this.approveIcon = Icons.check,
    this.rejectIcon = Icons.close,
    this.thirdIcon = Icons.watch_later_outlined,
    this.isMaster = false,
    this.customWidget,
  });

  @override
  Widget build(BuildContext context) {
    return isMaster
        ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            (customWidget != null)
                ? customWidget!
                : RichText(
                  text: TextSpan(
                    style: AppTextStyle.ts14M(color: AppColor.grey),
                    text: "Approval Status : ",
                    children: [
                      TextSpan(
                        style: AppTextStyle.ts14M(color: AppColor.black),
                        text: title,
                      ),
                    ],
                  ),
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
                  spacing: 10,
                  children: [
                    CustomIconButton(
                      onPressed:
                          () => _showRemarkDialog(
                            context,
                            actionType: "Approve",
                            onSubmit: onApprove,
                          ),
                      backgroundColor: AppColor.lightGreen50,
                      icon: Icon(approveIcon, size: 16, color: AppColor.green),
                    ),
                    CustomIconButton(
                      onPressed:
                          () => _showRemarkDialog(
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
          height: 40,
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      bottomLeft: Radius.circular(6),
                    ),
                  ),
                  child: Text('$title :', style: AppTextStyle.ts14R()),
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
      title: actionType,
      childContent: Form(
        key: formKey,
        child: Column(
          children: [
            CustomTextField(
              title: "Remark",
              hint: "Enter remark",
              minLines: 3,
              maxLines: 3,
              textController: remarkController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Remark is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),

      bottomSection: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomButton.cancelOutline(
            onPressed: () {
              goRouter.pop();
            },
          ),
          const SizedBox(width: 8),
          CustomButton(
            text: "Submit",
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
    );
  }
}
