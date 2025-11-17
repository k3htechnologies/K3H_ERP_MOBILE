import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/model/department.model.dart';
import 'package:k3h_erp_app/features/masters/department_master/presentation/cubit/department_master_cubit.dart';
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

class DepartmentMasterScreen extends StatefulWidget {
  const DepartmentMasterScreen({super.key});

  @override
  State<DepartmentMasterScreen> createState() =>
      _DepartmentMasterMobileScreenState();
}

class _DepartmentMasterMobileScreenState
    extends State<DepartmentMasterScreen> {
  // CUBIT
  late DepartmentMasterCubit _departmentMasterCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // FORM KEY
  final GlobalKey<FormState> _departmentMasterAddUpdateKey =
      GlobalKey<FormState>();

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC, _departmentNameC, _departmentCodeC;

  @override
  void initState() {
    super.initState();
    _departmentMasterCubit = context.read<DepartmentMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.departmentMaster]!;
    _initializeTextEditingController();
    _onScroll();
    _departmentMasterCubit.getDepartmentList(context, 1, 10);
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
    _departmentNameC.dispose();
    _departmentCodeC.dispose();
  }

  void _initializeTextEditingController() {
    _departmentNameC = TextEditingController();
    _departmentCodeC = TextEditingController();
    _searchC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_departmentMasterCubit.state.isLoading! &&
          _departmentMasterCubit.state.departmentList.length <
              _departmentMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _departmentMasterCubit.getDepartmentList(
            context,
            _departmentMasterCubit.state.currentPage + 1,
            10,
          );
        });
      }
    });
  }

  // <---- CLEAR DEPARTMENT ---->
  void _clearDialogueToAddUpdateDepartmentMaster() {
    _departmentNameC.clear();
    _departmentCodeC.clear();
  }

  // <---- PREFILL DEPARTMENT ---->
  void _prefillDialogueToAddUpdateDepartmentMaster(
    DepartmentModel departmentModel,
  ) {
    _departmentNameC.text = departmentModel.departmentName;
    _departmentCodeC.text = departmentModel.departmentCode;
  }

  // <---- API CALLS TO ADD/UPDATE DEPARTMENT ---->
  Future<void> _addUpdateDepartment(
    BuildContext context,
    DepartmentModel? departmentModel,
    DepartmentMasterState state,
    int index,
  ) async {
    if (_departmentMasterAddUpdateKey.currentState!.validate()) {
      departmentModel != null
          ? _departmentMasterCubit.updateDepartmentMaster(
            context: context,
            departmentName: _departmentNameC.text,
            departmentCode: _departmentCodeC.text,
            uniqueKey: departmentModel.uniquekey,
            departmentMasterId: departmentModel.departmentMasterId,
            index: index,
          )
          : _departmentMasterCubit.addDepartmentMaster(
            context: context,
            departmentName: _departmentNameC.text,
            departmentCode: _departmentCodeC.text,
          );
    }
  }

  // <---- DIALOGUE TO ADD/UPDATE DEPARTMENT ---->
  Future<void> _showBottomSheetToAddUpdateDepartmentMaster(
    BuildContext context,
    DepartmentMasterState state, {
    DepartmentModel? department,
    int? index,
  }) async {
    if (department != null) {
      _prefillDialogueToAddUpdateDepartmentMaster(department);
    }
    await DialogHelper.showCustomBottomSheet(
      context,
      "Add Department",
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
                key: _departmentMasterAddUpdateKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    verticalSpacing(),
                    Column(
                      children: [
                        CustomTextField(
                          title: 'Department Name*',
                          textController: _departmentNameC,
                          inputFormatterList: [
                            LengthLimitingTextInputFormatter(50),
                          ],
                          validator: (string) {
                            if (string == null || string.trim().isEmpty) {
                              return 'Department Name is required';
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          title: 'Department Code*',
                          textController: _departmentCodeC,
                          inputFormatterList: [
                            UpperCaseTextFormatter(),
                            LengthLimitingTextInputFormatter(4),
                            AlphaNumericWithoutSpacesFormatter(),
                          ],
                          validator: (string) {
                            if (string == null || string.trim().isEmpty) {
                              return 'Department Code is required';
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
                          _addUpdateDepartment(
                            context,
                            department,
                            state,
                            index ?? 0,
                          );
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
    _clearDialogueToAddUpdateDepartmentMaster();
  }

  // <---- DELETE DEPARTMENT ---->
  Future<void> _showPopupToDeleteDepartmentMaster(
    BuildContext context,
    DepartmentModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a department?',
      'Deleting this department will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _departmentMasterCubit.deleteDepartmentMaster(
        context: context,
        departmentMasterId: obj.departmentMasterId,
        uniqueKey: obj.uniquekey,
        pageNumber: currentPage,
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
        screenTitle: 'Department',
        authorization: _routeAuthorizationModel,
        onExportCallback: (value) {
          _departmentMasterCubit.exportExcelPdf(context, value);
        },
        onAddCallback:
            () async => await _showBottomSheetToAddUpdateDepartmentMaster(
              context,
              _departmentMasterCubit.state,
            ),
        onSearchSubmit: (value) {
          _departmentMasterCubit.searchDepartment(context, value);
        },
        textController: _searchC,
        onSortOptionCallback: (value) async {
          _departmentMasterCubit.sortDepartment(context, value, "DESC");
        },
        sortOptionList: ["Created Date", "Department Name", "Modified Date"],
        initialSortType: "Created Date",
      ),
      body: BlocBuilder<DepartmentMasterCubit, DepartmentMasterState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.departmentList.isEmpty) {
            return Center(child: loader());
          }
          if (state.departmentList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            itemCount: _departmentMasterCubit.state.departmentList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.departmentList.length) {
                return state.departmentList.length < state.totalNumberOfRecord
                    ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var department = state.departmentList[index];
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
                    Container(
                      padding: EdgeInsets.only(top: 10, left: 8, right: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Department Name:",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyle.ts12R(
                                    color: AppColor.grey,
                                  ),
                                ),
                                Text(
                                  department.departmentName,
                                  style: AppTextStyle.ts14R(),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Created By/Date :",
                                  style: AppTextStyle.ts12R(
                                    color: AppColor.grey,
                                  ),
                                ),
                                Text(
                                  "${department.createdBy} \n${formatDateTimeAsDDMMYYYY(department.createdDate)}",
                                  style: AppTextStyle.ts14R(),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Department Code :",
                                  style: AppTextStyle.ts12R(
                                    color: AppColor.grey,
                                  ),
                                ),
                                Text(
                                  department.departmentCode,
                                  style: AppTextStyle.ts14R(),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Modified By/Date :",
                                  style: AppTextStyle.ts12R(
                                    color: AppColor.grey,
                                  ),
                                ),
                                Text(
                                  "${department.modifiedBy.isNotEmpty ? department.modifiedBy : "-"} \n${department.modifiedDate != null ? formatDateTimeAsDDMMYYYY(department.modifiedDate!) : '-'}",
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
                              _showBottomSheetToAddUpdateDepartmentMaster(
                                context,
                                state,
                                index: index,
                                department: department,
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
                              _showPopupToDeleteDepartmentMaster(
                                context,
                                department,
                                state.currentPage,
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
          await _showBottomSheetToAddUpdateDepartmentMaster(
            context,
            _departmentMasterCubit.state,
          );
        },
      ),
    );
  }
}
