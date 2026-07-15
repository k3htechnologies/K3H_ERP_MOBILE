import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/cubit/utils_cubit.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/flat_handover/presentation/cubit/flat_handover_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/flat_handover/presentation/cubit/flat_handover_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/approve_reject_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class FlatHandoverScreen extends StatefulWidget {
  final int projectId;
  final int bookingId;
  const FlatHandoverScreen({
    super.key,
    required this.projectId,
    required this.bookingId,
  });

  @override
  State<FlatHandoverScreen> createState() => _FlatHandoverScreenState();
}

class _FlatHandoverScreenState extends State<FlatHandoverScreen> {
  late FlatHandoverCubit _flatHandoverCubit;
  late TextEditingController _searchTextC;

  @override
  void initState() {
    super.initState();
    _flatHandoverCubit = context.read<FlatHandoverCubit>();
    _searchTextC = TextEditingController();
    _flatHandoverCubit.getFlatHandoverFilesList(
      context: context,
      pageNumber: 1,
      projectId: widget.projectId,
      bookingId: widget.bookingId,
    );
  }

  @override
  void dispose() {
    _searchTextC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchBar(),
        Expanded(
          child: BlocBuilder<FlatHandoverCubit, FlatHandoverState>(
            builder: (context, state) {
              if ((state.isLoading ?? true) &&
                  state.flatHandoverFileList.isEmpty) {
                return Center(
                  child: noDataWidget(
                    message: "No Flat Handover Found",
                    iconSize: 180.0,
                  ),
                );
              }
              if (state.flatHandoverFileList.isEmpty) {
                return Center(child: noDataWidget(iconSize: 180));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: state.flatHandoverFileList.length,
                itemBuilder: (context, index) {
                  final flatHandoverDocuments =
                      state.flatHandoverFileList[index];
                  final approvalStatus = flatHandoverDocuments.approvalStatus;
                  final isAlreadyApproved =
                      approvalStatus.toLowerCase() == "approved";
                  final isRejected = approvalStatus.toLowerCase() == "rejected";
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: commonCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                flatHandoverDocuments.fileName,
                                style: AppTextStyle.ts14M(
                                  color: AppColor.primary,
                                ),
                              ),
                            ),
                            horizontalSpacing(),
                            Row(
                              spacing: 10.0,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CustomIconButton.edit(
                                  isDisabled:
                                      flatHandoverDocuments.approvalStatus
                                          .toLowerCase() ==
                                      "approved",
                                  onPressed: () {
                                    goRouter.pushNamed(
                                      AppRoutes.addFlatHandoverDocuments,
                                      extra: {
                                        "document": flatHandoverDocuments,
                                        "index": index,
                                      },
                                    );
                                  },
                                ),
                                CustomIconButton.delete(
                                  isDisabled: true,
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        buildRowTitleValueNormal(
                          title: "Last Modified By",
                          value: flatHandoverDocuments.modifiedBy,
                        ),
                        verticalSpacing(),
                        buildRowTitleValueNormal(
                          title: "Last Modified Date",
                          value: formatDateTimeAsDDMMMYYYY(
                            flatHandoverDocuments.modifiedDate,
                          ),
                        ),

                        verticalSpacing(),
                        flatHandoverDocuments.payTrackBookingFilesUrl.isNotEmpty
                            ? ApproveRejectWidget(
                              isActionAlreadyPerformed:
                                  isAlreadyApproved || isRejected,
                              actionTitle:
                                  flatHandoverDocuments.approvalStatus.isEmpty
                                      ? "Pending"
                                      : approvalStatus,
                              approveIcon: Icons.check,
                              onApprove: (onApprove) async {
                                final isSuccess = await context
                                    .read<UtilsCubit>()
                                    .updateModulesWorkflowApproval(
                                      context: context,
                                      moduleName: "FLAT HANDOVER APPROVAL",
                                      id: flatHandoverDocuments.bookingId,
                                      subId:
                                          flatHandoverDocuments
                                              .payTrackBookingFilesId,
                                      projectId:
                                          flatHandoverDocuments.projectId,
                                      isApproved: true,
                                      remark: onApprove.trim(),
                                    );
                                if (context.mounted && isSuccess) {
                                  await _flatHandoverCubit
                                      .getFlatHandoverFilesList(
                                        context: context,
                                        pageNumber: 1,
                                        projectId:
                                            flatHandoverDocuments.projectId,
                                        bookingId:
                                            flatHandoverDocuments.bookingId,
                                      );
                                }
                              },
                              onReject: (onReject) async {
                                await context
                                    .read<UtilsCubit>()
                                    .updateModulesWorkflowApproval(
                                      context: context,
                                      isApproved: false,
                                      moduleName: "FLAT HANDOVER APPROVAL",
                                      id: flatHandoverDocuments.bookingId,
                                      subId:
                                          flatHandoverDocuments
                                              .payTrackBookingFilesId,
                                      projectId:
                                          flatHandoverDocuments.projectId,
                                      remark: onReject.trim(),
                                    );
                              },
                              onThirdTap: () async {
                                final approvalLogHistoryList = await context
                                    .read<UtilsCubit>()
                                    .getApprovalLogHistory(
                                      context: context,
                                      projectId:
                                          flatHandoverDocuments.projectId,
                                      id: flatHandoverDocuments.bookingId,
                                      subId:
                                          flatHandoverDocuments
                                              .payTrackBookingFilesId,
                                      moduleName: "FLAT HANDOVER APPROVAL",
                                    );
                                if (context.mounted) {
                                  goRouter.pushNamed(
                                    AppRoutes.approvalLogHistory,
                                    queryParameters: {
                                      "title": Uri.encodeComponent(
                                        EncryptionManager.encryptData(
                                          "FLAT HANDOVER APPROVAL",
                                        ),
                                      ),
                                      "approvalList": Uri.encodeComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(
                                            approvalLogHistoryList
                                                .map((e) => e.toJson())
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                    },
                                  );
                                }
                              },
                              popupTitle: "Flat Handover",
                            )
                            : SizedBox.shrink(),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SearchWidget(
              hintText: "Search by File Name",
              onSubmit: (value) {
                _flatHandoverCubit.searchFlatHandoverFiles(
                  context,
                  widget.projectId,
                  widget.bookingId,
                  value,
                );
              },
              textController: _searchTextC,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRowTitleValueNormal({
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 170,
          child: Text(title, style: AppTextStyle.ts14R(color: Colors.grey)),
        ),
        const Text(":", style: TextStyle(fontSize: 18, color: Colors.grey)),
        const SizedBox(width: 20),
        Expanded(child: Text(value, style: AppTextStyle.ts14M())),
      ],
    );
  }
}
