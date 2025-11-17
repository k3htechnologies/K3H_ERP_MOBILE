import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/model/designation.model.dart';
import 'package:k3h_erp_app/features/masters/designation_master/presentation/cubit/designation_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_floating_action_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class DesignationMasterScreen extends StatefulWidget {
  const DesignationMasterScreen({super.key});

  @override
  State<DesignationMasterScreen> createState() =>
      _DesignationMasterScreenState();
}

class _DesignationMasterScreenState
    extends State<DesignationMasterScreen> {
  // CUBIT
  late DesignationMasterCubit _designationMasterCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // FORM KEY
  final GlobalKey<FormState> _designationMasterAddUpdateKey =
      GlobalKey<FormState>();

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC, _designationC, _noticePeriodC;

  @override
  void initState() {
    super.initState();
    _designationMasterCubit = BlocProvider.of<DesignationMasterCubit>(context);
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.designationMaster]!;
    _initializeTextEditingController();
    _onScroll();
    _designationMasterCubit.getDesignationList(context, 1, 10);
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
    _designationC.dispose();
    _noticePeriodC.dispose();
  }

  // <---- INITIALIZING TEXT CONTROLLERS ---->
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _designationC = TextEditingController();
    _noticePeriodC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    // SCROLL LISTENER
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_designationMasterCubit.state.isLoading! &&
          _designationMasterCubit.state.designationList.length <
              _designationMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _designationMasterCubit.getDesignationList(
            context,
            _designationMasterCubit.state.currentPage + 1,
            10,
          );
        });
      }
    });
  }

  // <--- CLEAR DESIGNATION ---->
  void _clearDialogToAddUpdateDesignationMaster() {
    _designationC.clear();
    _noticePeriodC.clear();
  }

  // <---- PREFILL BOTTOM SHEET TO ADD/UPDATE DESIGNATION MASTER ---->
  void _prefillBottomSheetToAddUpdateDesignationMaster(
    DesignationMasterModel designation,
  ) {
    _designationC.text = designation.designationName;
    _noticePeriodC.text = designation.noticePeriod.toString();
  }

  // <---- API CALL TO ADD/UPDATE DESIGNATION MASTER ---->
  Future<void> _addUpdateDesignation(
    DesignationMasterModel? designation, {
    int index = 0,
  }) async {
    if (_designationMasterAddUpdateKey.currentState!.validate()) {
      designation != null
          ? _designationMasterCubit.updateDesignationMaster(
            index: index,
            designationMasterId: designation.designationMasterId,
            uniqueKey: designation.uniquekey,
            designationName: _designationC.text,
            noticePeriod: _noticePeriodC.text,
            context: context,
          )
          : _designationMasterCubit.addDesignationMaster(
            designationName: _designationC.text,
            noticePeriod: _noticePeriodC.text,
            context: context,
          );
    }
  }

  // <---- BOTTOM SHEET TO ADD/UPDATE DESIGNATION MASTER ---->
  Future<void> _showBottomSheetToAddUpdateDesignationMaster(
    BuildContext context,
    DesignationMasterState state, {
    DesignationMasterModel? designation,
    int? index,
  }) async {
    if (designation != null) {
      _prefillBottomSheetToAddUpdateDesignationMaster(designation);
    }
    await DialogHelper.showCustomBottomSheet(
      context,
      "Add Designation",
      Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 8,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _designationMasterAddUpdateKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: [
                        CustomTextField(
                          title: "Designation*",
                          inputFormatterList: [
                            LengthLimitingTextInputFormatter(50),
                          ],
                          textController: _designationC,
                          validator: (value) {
                            if (designation == null &&
                                (value == null || value.isEmpty)) {
                              return 'Designation is required';
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          title: "Notice Period* (in days)",
                          textController: _noticePeriodC,
                          inputFormatterList: InputValidator.digit(3),
                          validator: (value) {
                            if (designation == null &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Notice Period is required';
                            }
                            final numValue = int.tryParse(value ?? '');
                            if (numValue == null ||
                                numValue < 1 ||
                                numValue > 365) {
                              return 'Enter a valid number (1 to 365)';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: CustomButton.save(
                        onPressed: () {
                          _addUpdateDesignation(designation, index: index ?? 0);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
    _clearDialogToAddUpdateDesignationMaster();
  }

  // <---- DELETE DESIGNATION ---->
  Future<void> _showPopupToDeleteDesignationMaster(
    int designationMasterId,
    String uniqueKey,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      "You are about to delete a designation?",
      "Deleting this designation will permanently remove its contents.",
    );
    if (result && mounted) {
      _designationMasterCubit.deleteDesignationMaster(
        context: context,
        designationMasterId: designationMasterId,
        uniqueKey: uniqueKey,
        pageNumber: _designationMasterCubit.state.currentPage,
        pageSize: 10,
        index: index,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.greyBackground,
      appBar: CustomAppBar(
        screenTitle: 'Designation',
        authorization: _routeAuthorizationModel,
        onExportCallback: (value) {
          _designationMasterCubit.exportExcelPdf(context, value);
        },
        onAddCallback:
            () async => await _showBottomSheetToAddUpdateDesignationMaster(
              context,
              _designationMasterCubit.state,
            ),
        onSearchSubmit: (value) {
          _designationMasterCubit.searchDesignation(context, value);
        },
        textController: _searchC,
        onSortOptionCallback: (value) async {
          _designationMasterCubit.sortDesignation(context, value, "DESC");
        },
        sortOptionList: ["Created Date", "Designation Name", "Modified Date"],
        initialSortType: "Created Date",
      ),
      body: BlocBuilder<DesignationMasterCubit, DesignationMasterState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.designationList.isEmpty) {
            return Center(child: loader());
          }
          if (state.designationList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            itemCount: _designationMasterCubit.state.designationList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.designationList.length) {
                return state.designationList.length < state.totalNumberOfRecord
                    ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var designation = state.designationList[index];
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  border: Border.all(
                    color: AppColor.grey.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10, left: 8, right: 8),
                      child: Row(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Designation :",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyle.ts12R(
                                    color: AppColor.grey,
                                  ),
                                ),
                                Text(
                                  designation.designationName,
                                  style: AppTextStyle.ts14R(),
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Notice Period :",
                                  style: AppTextStyle.ts12R(
                                    color: AppColor.grey,
                                  ),
                                ),
                                Text(
                                  designation.noticePeriod.toString(),
                                  style: AppTextStyle.ts14R(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10, left: 8, right: 8),
                      child: Row(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Created By/Date :",
                                  style: AppTextStyle.ts12R(
                                    color: AppColor.grey,
                                  ),
                                ),
                                Text(
                                  "${designation.createdBy} \n${formatDateTimeAsDDMMYYYY(designation.createdDate)}",
                                  style: AppTextStyle.ts14R(),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Modified By/Date :",
                                  style: AppTextStyle.ts12R(
                                    color: AppColor.grey,
                                  ),
                                ),
                                Text(
                                  "${designation.modifiedBy.isNotEmpty ? designation.modifiedBy : "-"} \n${designation.modifiedDate != null ? formatDateTimeAsDDMMYYYY(designation.modifiedDate!) : '-'}",
                                  style: AppTextStyle.ts14R(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    verticalSpacing(),
                    Container(
                      clipBehavior: Clip.hardEdge,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColor.grey.withValues(alpha: 0.05),
                        border: Border(
                          top: BorderSide(
                            color: AppColor.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showBottomSheetToAddUpdateDesignationMaster(
                                context,
                                state,
                                index: index,
                                designation: designation,
                              );
                            },
                            child: SvgPicture.asset(
                              AppAssets.editIcon,
                              height: 24,
                            ),
                          ),
                          horizontalSpacing(width: 20),
                          GestureDetector(
                            onTap: () {
                              _showPopupToDeleteDesignationMaster(
                                designation.designationMasterId,
                                designation.uniquekey,
                                index,
                              );
                            },
                            child: SvgPicture.asset(
                              AppAssets.deleteIcon,
                              height: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: CommonFloatingActionButton(
        onPressed: () async {
          await _showBottomSheetToAddUpdateDesignationMaster(
            context,
            _designationMasterCubit.state,
          );
        },
      ),
    );
  }
}
