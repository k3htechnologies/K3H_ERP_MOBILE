import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/data/model/local_term_sheet.model.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/presentation/cubit/term_sheet_cubit.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddTermSheetScreen extends StatefulWidget {
  const AddTermSheetScreen({super.key});

  @override
  State<AddTermSheetScreen> createState() => _AddTermSheetScreenState();
}

class _AddTermSheetScreenState extends State<AddTermSheetScreen> {
  late TermSheetCubit _termSheetCubit;

  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();

  //NOTIFIERS
  final ValueNotifier<List<Map<String, dynamic>>> _selectedProjectNotifier =
      ValueNotifier([]);
  final ValueNotifier<List<LocalTermSheetModel>> _termSheetListNotifier =
      ValueNotifier([]);

  late UserModel? _user;

  @override
  void initState() {
    super.initState();
    _termSheetCubit = context.read<TermSheetCubit>();
    getCurrentUser();
  }

  @override
  void dispose() {
    _selectedProjectNotifier.dispose();
    _termSheetListNotifier.dispose();
    super.dispose();
  }

  void _sumbit() {
    if (_selectedProjectNotifier.value.isEmpty) {
      showErrorMessage(context, "Error", "Please select a project");
      return;
    }

    final state = _termSheetCubit.state;

    if (state.localTermSheetList.isEmpty) {
      showErrorMessage(context, "Error", "Please add at least one Term Sheet");
      return;
    }

    if (state.companyByProject.isEmpty) {
      showErrorMessage(context, "Error", "Company details not found");
      return;
    }

    final projectId =
        _selectedProjectNotifier.value.first["zAttributesId"].toString();

    final companyId = state.companyByProject.first.companyId.toString();

    _termSheetCubit.addTermSheet(
      context: context,
      projectId: projectId,
      companyId: companyId,

      // IMPORTANT
      termSheetList: state.localTermSheetList,
    );
  }

  Future getCurrentUser() async {
    var userJson = jsonDecode(
      LocalStorageManager().getString(StorageKey.currentUser) ?? "",
    );
    _user = UserModel.fromJson(userJson);
  }

  //  FETCH PROJECTS
  Future<Map<String, dynamic>> _fetchProjects(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _projectMasterRepository.getProjectList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty
              ? {"ProjectName": value, "EmployeeId": _user!.employeeId}
              : {"EmployeeId": _user!.employeeId},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final project = response['data'] as List<ProjectModel>;

        return {
          "itemList":
              project.map((pr) {
                return {
                  "zAttributesId": pr.projectId,
                  "DisplayName": pr.projectName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBarWithBackButton(
          screenTitle: "Term Sheet",
          authorization: AuthorizationModel(),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  ValueListenableBuilder(
                    valueListenable: _selectedProjectNotifier,
                    builder: (context, value, child) {
                      return CustomMultipleSelectPopup(
                        title: 'Project',
                        isMultiSelect: false,
                        hintText: "All Project",
                        initialValue: value,
                        onSelected: (value) {
                          _selectedProjectNotifier.value = value;

                          if (value.isNotEmpty) {
                            final projectId = value.first["zAttributesId"];

                            _termSheetCubit.getProjectWithCompany(
                              context: context,
                              projectId: projectId,
                            );
                          } else {
                            _termSheetCubit.clearProjectCompany();
                          }
                        },
                        dataFetchCallBack: _fetchProjects,
                      );
                    },
                  ),
                  BlocBuilder<TermSheetCubit, TermSheetState>(
                    buildWhen:
                        (previous, current) =>
                            previous.companyByProject !=
                                current.companyByProject ||
                            previous.isFetchingCompany !=
                                current.isFetchingCompany,
                    builder: (context, state) {
                      final isProjectSelected =
                          _selectedProjectNotifier.value.isNotEmpty;
                      if (!isProjectSelected) {
                        return const SizedBox.shrink();
                      }
                      if (state.isFetchingCompany) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (state.companyByProject.isEmpty) {
                        return Center(
                          child: noDataWidget(
                            message: "No Company's Found",
                            iconSize: 120.0,
                          ),
                        );
                      }

                      final company = state.companyByProject.first;
                      final List<Map<String, dynamic>> items = [];

                      items.addAll([
                        {"title": "Company Name", "value": company.companyName},
                        {"title": "City", "value": company.cityName},
                        {"title": "Firms Type", "value": company.firmsType},
                        {
                          "title": "Contact Person",
                          "value": company.contactPerson,
                        },
                        {
                          "title": "Mobile Number",
                          "value": company.mobileNumber,
                          "widget": CustomClickToContactText(
                            value: company.mobileNumber,
                            type: ContactType.phone,
                          ),
                        },
                        {
                          "title": "E-Mail ID",
                          "value": company.emailId,
                          "widget": CustomClickToContactText(
                            value: company.emailId,
                            type: ContactType.email,
                          ),
                        },
                        {"title": "PAN Number", "value": company.panNumber},
                        {"title": "GST Number", "value": company.gstNumber},
                        {"title": "CIN Number", "value": company.cinNumber},
                        {"title": "TAN Number", "value": company.tanNumber},
                      ]);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [infoCard(items)],
                      );
                    },
                  ),
                  verticalSpacing(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Term Sheet",
                        style: AppTextStyle.ts14M(
                          color: AppColor.greyTitleAndValueColor,
                        ),
                      ),
                      horizontalSpacing(),
                      CustomButton.add(
                        onPressed: () async {
                          final result = await goRouter
                              .pushNamed<LocalTermSheetModel>(
                                AppRoutes.addLocalTermSheet,
                                extra: {"isEdit": false, "termSheet": null},
                              );

                          if (result != null && context.mounted) {
                            _termSheetCubit.addTermSheetLocally(result);
                          }
                        },
                      ),
                    ],
                  ),
                  verticalSpacing(),
                  BlocBuilder<TermSheetCubit, TermSheetState>(
                    buildWhen:
                        (previous, current) =>
                            previous.localTermSheetList !=
                            current.localTermSheetList,
                    builder: (context, state) {
                      final termSheetList = state.localTermSheetList;

                      if (termSheetList.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return ListView.builder(
                        itemCount: termSheetList.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final termSheet = termSheetList[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: commonCardDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: buildRowWrapper(
                                        child: buildColumnTitleValue(
                                          title:
                                              "Name Of Institution / Bank / NBFC",
                                          value:
                                              termSheet
                                                  .nameOfInstitutionBankNBFC,
                                        ),
                                      ),
                                    ),

                                    horizontalSpacing(),

                                    Row(
                                      children: [
                                        CustomIconButton.edit(
                                          onPressed: () async {
                                            final result = await goRouter
                                                .pushNamed<LocalTermSheetModel>(
                                                  AppRoutes.addLocalTermSheet,
                                                  extra: {
                                                    "isEdit": true,
                                                    "termSheet": termSheet,
                                                  },
                                                );

                                            if (result != null &&
                                                context.mounted) {
                                              _termSheetCubit
                                                  .updateTermSheetLocally(
                                                    index: index,
                                                    termSheet: result,
                                                  );
                                            }
                                          },
                                        ),

                                        horizontalSpacing(),
                                        CustomIconButton.delete(
                                          onPressed: () {
                                            _termSheetCubit
                                                .deleteTermSheetLocally(index);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                verticalSpacing(),

                                Row(
                                  children: [
                                    Expanded(
                                      child: buildRowWrapper(
                                        child: buildColumnTitleValue(
                                          title: "Loan Taken By",
                                          value: termSheet.loanTakenBy,
                                        ),
                                      ),
                                    ),
                                    horizontalSpacing(),
                                    Expanded(
                                      child: buildRowWrapper(
                                        child: buildColumnTitleValue(
                                          title: "Facility Amount",
                                          value:
                                              termSheet.facilityAmount
                                                  .toIndianCurrency(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                verticalSpacing(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: buildRowWrapper(
                                        child: buildColumnTitleValue(
                                          title: "Rate Of Interest",
                                          value:
                                              "${termSheet.rateOfInterestInPercentage.toString()} %",
                                        ),
                                      ),
                                    ),

                                    horizontalSpacing(),

                                    Expanded(
                                      child: buildRowWrapper(
                                        child: buildColumnTitleValue(
                                          title: "Term Sheet Date",
                                          value: formatDateTimeAsDDMMMYYYY(
                                            termSheet.termSheetDate,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            height: 70.0,
            padding: const EdgeInsets.all(16.0),
            child: CustomButton(
              leading: Icon(Icons.add, size: 18, color: AppColor.white),
              text: "Add",
              onPressed: _sumbit,
            ),
          ),
        ),
      ),
    );
  }
}
