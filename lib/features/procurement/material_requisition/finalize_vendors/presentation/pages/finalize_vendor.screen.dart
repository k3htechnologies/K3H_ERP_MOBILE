import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/cubit/utils_cubit.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/model/finalize_vendor_for_compare.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/presentation/cubit/finalize_vendor_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/model/material_requisition.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/cubit/material_requisition_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/approve_reject_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/checkbox/custom_checkbox.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class FinalizeVendorScreen extends StatefulWidget {
  final String systemGeneratedCode;
  final int projectId;
  final int materialRequisitionId;
  final String uniquekey;
  final FinalizeVendorForComparisonModel? selectedVendor;
  const FinalizeVendorScreen({
    super.key,
    required this.systemGeneratedCode,
    required this.materialRequisitionId,
    required this.projectId,
    required this.uniquekey,
    this.selectedVendor,
  });

  @override
  State<FinalizeVendorScreen> createState() => _FinalizeVendorScreenState();
}

class _FinalizeVendorScreenState extends State<FinalizeVendorScreen> {
  // CUBIT
  late FinalizeVendorCubit _finalizeVendorCubit;
  late ProjectModel _selectedProject;
  late UtilsCubit _utilsCubit;
  late MaterialRequisitionCubit _materialCubit;

  late AuthorizationModel _finalizedVendorAuthorizationModel,
      _getQuotationAuthorizationModel,
      _vendorComparisonAuthorizationModel;
  final ValueNotifier<List<dynamic>> selectedVendorList = ValueNotifier([]);
  final ValueNotifier<MaterialRequisitionModel?> materialRequisitionOverview =
      ValueNotifier(null);
  bool isQuotationFetched = false;
  @override
  void initState() {
    super.initState();
    _finalizeVendorCubit = context.read<FinalizeVendorCubit>();
    _utilsCubit = context.read<UtilsCubit>();
    _materialCubit = context.read<MaterialRequisitionCubit>();
    _getQuotationAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.getQuotation]!;
    _vendorComparisonAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.getCompare]!;
    _finalizedVendorAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.finalizedVendor]!;
    _selectedProject = getProject();
    _loadMaterialData();
  }

  Future<void> initOverview() async {
    if (materialRequisitionOverview.value?.uniquekey != null &&
        materialRequisitionOverview.value!.uniquekey.isNotEmpty) {
      final vendors = await _finalizeVendorCubit.getSelectedVenodeForCompare(
        context,
        _selectedProject.projectId,
        materialRequisitionOverview.value?.materialRequisitionId ?? 0,
        materialRequisitionOverview.value?.uniquekey ?? "",
      );
      final finalVendorId = materialRequisitionOverview.value?.finalVendor;

      for (var v in vendors) {
        v.isSelected = v.vendorId.toString() == finalVendorId;
      }
      selectedVendorList.value = vendors;
    } else {
      selectedVendorList.value = [];
    }
  }

  Future<void> _loadMaterialData() async {
    final materialCubit = context.read<MaterialRequisitionCubit>();

    await materialCubit.getMaterialRequisitionDetailsById(
      context,
      1,
      widget.projectId,
      widget.materialRequisitionId,
    );

    materialRequisitionOverview.value =
        _materialCubit.state.materialRequisitionOverview;
    await initOverview();
  }

  void _onFinalizeVendorTap() async {
    await _finalizeVendorCubit.addFinalizedVendor(
      context: context,
      projectId: _selectedProject.projectId,
      materialRequisition: MaterialRequisitionModel(
        materialRequisitionId: widget.materialRequisitionId,
        uniquekey: widget.uniquekey,
        systemGeneratedCode: widget.systemGeneratedCode,
        projectId: widget.projectId,
        projectName: '',
        attachmentsURL: '',
        remarks: '',
        clientRegistrationId: 0,
        materialRequisitionStage: '',
        materialRequisitionStatus: '',
        finalVendor: '',
        isSplit: false,
        isCopy: false,
        isRequisitionAction: false,
        createdById: 0,
        createdBy: '',
        createdDate: DateTime.now(),
        modifiedById: 0,
        modifiedBy: '',
        modifiedDate: DateTime.now(),
        paidAmount: 0,
        totalPoAmount: 0,
        totalInoviceAmount: 0,
        totalInvoice: 0,
        purchaseOrderURL: '',
        isApprovalVendorFinalization: false,
        isApprovalInvoice: false,
        vendorFinalizationApprovalStatus: '',
        invoiceApprovalStatus: '',
        materialRequisitionDetailData: [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinalizeVendorCubit, FinalizeVendorState>(
      builder: (context, state) {
        if (state.isLoading ?? true) {
          return Center(child: CircularProgressIndicator());
        }
        final vendorForFinalize = state.vendorFinalisationForComparison;
        return ValueListenableBuilder(
          valueListenable: materialRequisitionOverview,
          builder: (context, overview, child) {
            final finalizedVendor =
                vendorForFinalize.any((v) => v.isFinalized)
                    ? vendorForFinalize.firstWhere((v) => v.isFinalized)
                    : null;

            final isApproved =
                finalizedVendor?.vendorFinalizationApproval.toLowerCase() ==
                'approved';
            return SafeArea(
              child: Container(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.systemGeneratedCode,
                          style: AppTextStyle.ts16M(color: AppColor.primary),
                        ),
                      ],
                    ),
                    if (finalizedVendor == null) ...[
                      verticalSpacing(height: 10.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_getQuotationAuthorizationModel.isView) ...[
                            Expanded(
                              child: CustomButton(
                                text: "Get Quatation",
                                backgroundColor: AppColor.green,
                                isDisable:
                                    !_getQuotationAuthorizationModel.isAction,
                                onPressed: () {
                                  final systemGeneratedCode =
                                      Uri.encodeComponent(
                                        EncryptionManager.encryptData(
                                          widget.systemGeneratedCode,
                                        ),
                                      );
                                  final materialRequisitionId =
                                      Uri.encodeComponent(
                                        EncryptionManager.encryptData(
                                          widget.materialRequisitionId
                                              .toString(),
                                        ),
                                      );
                                  final projectID = Uri.encodeComponent(
                                    EncryptionManager.encryptData(
                                      widget.projectId.toString(),
                                    ),
                                  );
                                  final uniquekey = Uri.encodeComponent(
                                    EncryptionManager.encryptData(
                                      widget.uniquekey.toString(),
                                    ),
                                  );

                                  goRouter.pushNamed(
                                    AppRoutes.finalizeVendorGetQuotation,
                                    queryParameters: {
                                      'systemGeneratedCode':
                                          systemGeneratedCode,
                                      'materialRequisitionId':
                                          materialRequisitionId,
                                      'projectId': projectID,
                                      'uniquekey': uniquekey,
                                    },
                                  );
                                },
                              ),
                            ),
                            horizontalSpacing(width: 8.h),
                          ] else ...[
                            Spacer(),
                          ],
                          Expanded(
                            child: CustomButton(
                              text: "Finalize Vendor",
                              isDisable:
                                  !_finalizedVendorAuthorizationModel.isAction,
                              textColor: AppColor.green,
                              backgroundColor: AppColor.lightGreen,
                              onPressed: _onFinalizeVendorTap,
                            ),
                          ),
                          horizontalSpacing(width: 8.h),
                          if (_vendorComparisonAuthorizationModel.isView)
                            GestureDetector(
                              onTap: () {
                                if (!_vendorComparisonAuthorizationModel
                                    .isAction) {
                                  return;
                                }
                                _finalizeVendorCubit.compareVendor(
                                  context,
                                  "exportType",
                                  _selectedProject.projectId,
                                  widget.materialRequisitionId,
                                  widget.uniquekey,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: SvgPicture.asset(
                                  AppAssets.compareVendorIcon,
                                  // ignore: deprecated_member_use
                                  color:
                                      _vendorComparisonAuthorizationModel
                                              .isAction
                                          ? null
                                          : AppColor.grey2,
                                  height: 24.h,
                                  width: 24.w,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (finalizedVendor != null) ...[
                      verticalSpacing(),
                      ApproveRejectWidget(
                        isActionAlreadyPerformed: isApproved,
                        actionTitle: isApproved ? "Approved" : "Pending",
                        onApprove: (remark) async {
                          final isSuccess = await _utilsCubit
                              .updateModulesWorkflowApproval(
                                context: context,
                                moduleName: 'MATERIAL REQUISITION',
                                id: widget.materialRequisitionId,
                                projectId: widget.projectId,
                                isApproved: true,
                                remark: remark.trim(),
                              );

                          if (context.mounted && isSuccess) {
                            initOverview();
                          }
                        },
                        isMaster: true,
                        onReject: (remark) async {
                          final isSuccess = await _utilsCubit
                              .updateModulesWorkflowApproval(
                                context: context,
                                moduleName: 'MATERIAL REQUISITION',
                                id: widget.materialRequisitionId,
                                projectId: widget.projectId,
                                isApproved: false,
                                remark: remark.trim(),
                              );

                          if (context.mounted && isSuccess) {
                            initOverview();
                          }
                        },
                        onThirdTap: () async {
                          final approvalLogHistoryList = await _utilsCubit
                              .getApprovalLogHistory(
                                context: context,
                                projectId: widget.projectId,
                                id: widget.materialRequisitionId,
                                moduleName: "FINALIZED VENDOR",
                              );
                          if (context.mounted) {
                            goRouter.pushNamed(
                              AppRoutes.approvalLogHistory,
                              queryParameters: {
                                "title": Uri.encodeComponent(
                                  EncryptionManager.encryptData(
                                    "Finalized Vendor Log History",
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
                        popupTitle: "Finalized Vendor",
                      ),
                    ],
                    verticalSpacing(height: 10.h),
                    Expanded(
                      child: ListView.builder(
                        itemCount: vendorForFinalize.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final vendor = vendorForFinalize[index];
                          final vedorQuotationOfSelecetdVendor =
                              vendor
                                      .materialRequisitionQuotationTermsData
                                      .isNotEmpty
                                  ? vendor
                                      .materialRequisitionQuotationTermsData
                                      .first
                                  : null;
                          final isFinalized = vendor.isFinalized;

                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(16),
                            decoration: commonCardDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CustomCheckBox(
                                          isDisabled:
                                              !_finalizedVendorAuthorizationModel
                                                  .isAction,
                                          isSelected:
                                              isFinalized || vendor.isSelected,
                                          onChanged: (value) {
                                            if (isFinalized) return;
                                            _finalizeVendorCubit
                                                .toggleVendorSelection(
                                                  vendor.vendorId,
                                                );
                                          },
                                        ),
                                        horizontalSpacing(width: 10.w),
                                        GestureDetector(
                                          onTap: () async {
                                            final materials =
                                                materialRequisitionOverview
                                                    .value
                                                    ?.materialRequisitionDetailData ??
                                                [];

                                            final updatedVendors =
                                                await _finalizeVendorCubit
                                                    .getSelectedVenodeForCompare(
                                                      context,
                                                      _selectedProject
                                                          .projectId,
                                                      widget
                                                          .materialRequisitionId,
                                                      widget.uniquekey,
                                                    );

                                            final selectedVendor =
                                                updatedVendors.firstWhere(
                                                  (v) =>
                                                      v.vendorId ==
                                                      vendor.vendorId,
                                                  orElse: () => vendor,
                                                );

                                            await goRouter.pushNamed(
                                              AppRoutes.finalizeEditVendor,
                                              extra: {
                                                "vendor": selectedVendor,
                                                "materials": materials,
                                                "systemGeneratedCode":
                                                    widget.systemGeneratedCode,
                                                "projectId": widget.projectId,
                                                "materialRequisitionId":
                                                    widget
                                                        .materialRequisitionId,
                                                "uniquekey": widget.uniquekey,
                                              },
                                            );
                                          },
                                          child: Text(
                                            vendor.vendorName,
                                            style: AppTextStyle.ts16M(
                                              color: AppColor.primary,
                                            ).copyWith(
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: AppColor.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    CustomIconButton(
                                      onPressed: () async {
                                        copy(
                                          context: context,
                                          text: widget.systemGeneratedCode,
                                        );
                                      },
                                      backgroundColor: AppColor.white,

                                      icon: Icon(
                                        Icons.copy,
                                        size: 16,
                                        color: AppColor.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                verticalSpacing(height: 12),
                                _buildRow("Company Name", vendor.companyName),
                                _buildRow(
                                  "Base Amount",
                                  (vedorQuotationOfSelecetdVendor?.total ?? 0)
                                      .toIndianCurrency(),
                                ),
                                _buildRow(
                                  "Total Tax",
                                  vendor.taxTotal.toIndianCurrency(),
                                  valueColor: Colors.orange,
                                ),

                                _buildRow(
                                  "Grand Total",
                                  vendor.grandTotal.toIndianCurrency(),
                                  valueColor: AppColor.primary,
                                ),

                                _buildRow(
                                  "Est. Delivery",
                                  "${vedorQuotationOfSelecetdVendor?.expectedDeliveryInDays ?? 0} Days",
                                  valueColor: Colors.green,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRow(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyle.ts14R(
                color: AppColor.black.withValues(alpha: 0.5),
              ),
            ),
          ),
          Text(
            ":   ",
            style: AppTextStyle.ts14R(
              color: AppColor.black.withValues(alpha: 0.5),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyle.ts14M(color: valueColor ?? AppColor.black),
            ),
          ),
        ],
      ),
    );
  }
}
