import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';

class ApproveRejectWidget extends StatelessWidget {
  final String title;
  final bool isActionAlreadyPerformed;

  final ValueChanged<String> onApprove;
  final ValueChanged<String> onReject;
  final VoidCallback? onThirdTap;

  final IconData approveIcon;
  final IconData rejectIcon;
  final IconData thirdIcon;

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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              child: Text(
                '$title :',
                style: AppTextStyle.ts14R(),
              ),
            ),
          ),

          if (!isActionAlreadyPerformed) ...[
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () => _showRemarkDialog(
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
                  child: Icon(
                    approveIcon,
                    size: 24,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () => _showRemarkDialog(
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
                  child: Icon(
                    rejectIcon,
                    size: 24,
                    color: Colors.red,
                  ),
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
                child: Icon(
                  thirdIcon,
                  size: 24,
                  color: AppColor.primary,
                ),
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

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(actionType),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: remarkController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter remark',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Remark is required';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final remark = remarkController.text.trim();
                  Navigator.pop(dialogContext);
                  onSubmit(remark);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
