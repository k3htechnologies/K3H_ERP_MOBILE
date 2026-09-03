import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/more/inward_outward/data/model/inward_outward.model.dart';
import 'package:k3h_erp_app/features/more/inward_outward/presentation/cubit/inward_outward_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class RevertSection extends StatefulWidget {
  final BuildContext context;
  final InwardOutwardModel inwardOutward;
  final AuthorizationModel routeAuthorizationModel;
  const RevertSection({
    super.key,
    required this.context,
    required this.inwardOutward,
    required this.routeAuthorizationModel,
  });
  @override
  State<RevertSection> createState() => _RevertSectionState();
}

class _RevertSectionState extends State<RevertSection> {
  Future<void> _showDeleteRevertDetailsDialog(
    BuildContext context,
    InwardOutwardRevertHistoryModel revert,
    int index,
  ) async {
    final result = await DialogHelper.deleteDialog(
      context,
      'Delete Revert Details',
      'Are you sure you want to delete this revert detail? This action cannot be undone.',
    );
    if (result && context.mounted) {
      await context.read<InwardOutwardCubit>().deleteRevert(
        context: context,
        inwardOutwardRevertId: revert.inwardOutwardRevertId,
        inwardOutwardId: widget.inwardOutward.inwardOutwardId,
        uniqueKey: widget.inwardOutward.uniqueKey,
        index: index,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (widget.inwardOutward.inwardOutwardRevertHistory.isEmpty) {
          return Center(child: noDataWidget(message: "No Revert Data Found"));
        }
        return ListView.separated(
          separatorBuilder: (context, index) => verticalSpacing(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          itemCount: widget.inwardOutward.inwardOutwardRevertHistory.length,
          itemBuilder: (context, index) {
            final revert =
                widget.inwardOutward.inwardOutwardRevertHistory[index];
            return Container(
              decoration: commonCardDecoration(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: buildRowTitleValue(
                          title: "Date",
                          fixesWidth: 60.w,
                          value: formatDateTimeAsDDMMMYYYY(revert.revertDate),
                          customValueWidget: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formatDateTimeAsDDMMMYYYY(revert.revertDate),
                                style: AppTextStyle.ts14M(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (index == 0)
                        Row(
                          spacing: 10.w,
                          children: [
                            CustomIconButton.edit(
                              isDisabled:
                                  !widget.routeAuthorizationModel.isAction,
                              onPressed: () {
                                goRouter.pushNamed(
                                  AppRoutes.revertInwardOutward,
                                  queryParameters: {
                                    "inwardOutwardId": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        widget.inwardOutward.inwardOutwardId
                                            .toString(),
                                      ),
                                    ),
                                    "uniquekey": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        widget.inwardOutward.uniqueKey,
                                      ),
                                    ),
                                    "revertHistory": Uri.encodeComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(revert.toJson()),
                                      ),
                                    ),
                                    "index": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        index.toString(),
                                      ),
                                    ),
                                  },
                                );
                              },
                            ),
                            CustomIconButton.delete(
                              isDisabled:
                                  !widget.routeAuthorizationModel.isAction,
                              onPressed: () {
                                _showDeleteRevertDetailsDialog(
                                  context,
                                  revert,
                                  index,
                                );
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                  buildRowTitleValue(
                    title: "Remark",
                    fixesWidth: 60.w,
                    singleLine: false,
                    value: revert.revertRemark,
                  ),
                  Row(
                    children: [
                      CustomButton.documentOutline(
                        isDisable: revert.revertDocumentURL.isEmpty,
                        onPressed: () {
                          if (revert.revertDocumentURL.isNotEmpty) {
                            showFilePreviewDialog(
                              context,
                              title: "Revert Document",
                              revert.revertDocumentURL.split(","),
                            );
                          }
                        },
                      ),
                      Spacer(),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
