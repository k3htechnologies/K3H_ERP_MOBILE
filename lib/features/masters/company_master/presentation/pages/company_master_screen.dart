import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/company.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/cubit/company_master/company_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CompanyMasterScreen extends StatefulWidget {
  const CompanyMasterScreen({super.key});

  @override
  State<CompanyMasterScreen> createState() => _CompanyMasterMobileScreenState();
}

class _CompanyMasterMobileScreenState extends State<CompanyMasterScreen> {
  // CUBIT
  late CompanyMasterCubit _companyMasterCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC,
      _filterFirmsTypeC,
      _filterContactPersonC,
      _filterMobileNumberC,
      _filterCityNameC;

  @override
  void initState() {
    super.initState();
    initialiseControllers();
    _companyMasterCubit = context.read<CompanyMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.companyMaster]!;
    _companyMasterCubit.getCompanyMaster(context, 1);
    // PAGINATION
    scrollController = ScrollController();
    // SCROLL LISTENER
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchC.dispose();
    _filterFirmsTypeC.dispose();
    _filterContactPersonC.dispose();
    _filterMobileNumberC.dispose();
    _filterCityNameC.dispose();
    scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // INITIALISE TEXT EDITING CONTROLLERS
  void initialiseControllers() {
    _searchC = TextEditingController();
    scrollController = ScrollController();
    _filterFirmsTypeC = TextEditingController();
    _filterContactPersonC = TextEditingController();
    _filterMobileNumberC = TextEditingController();
    _filterCityNameC = TextEditingController();
  }

  // PAGINATION
  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 100 &&
        !_companyMasterCubit.state.isLoading! &&
        _companyMasterCubit.state.companyList.length <
            _companyMasterCubit.state.totalNumberOfRecord) {
      // TO HANDLE MULTIPLE TIME API CALLS
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        _companyMasterCubit.getCompanyMaster(
          context,
          _companyMasterCubit.state.currentPage + 1,
        );
      });
    }
  }

  // DELETE COMPANY DIALOG
  void _showPopUpToDeleteVendor(
    BuildContext context,
    CompanyModel company,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      "You are about to delete a company ",
      "Deleting this company will permanently remove its contents.",
    );
    if (result && context.mounted) {
      _companyMasterCubit.deleteCompanyMaster(
        context: context,
        companyMasterId: company.companyId,
        uniqueKey: company.uniquekey,
        index: index,
        pageNumber: _companyMasterCubit.state.currentPage,
        pageSize: 10,
      );
    }
  }

  // COMPANY FILTER
  Future<void> _showBottomSheetToFilterCompanyMaster(
    BuildContext context,
  ) async {
    final state = _companyMasterCubit.state;

    _filterFirmsTypeC.text = state.filterByFirmType;
    _filterContactPersonC.text = state.filterByContactPerson;
    _filterMobileNumberC.text = state.filterByMobileNumber;
    _filterCityNameC.text = state.filterByCityName;

    String? selectedDirection =
        state.currentSortColumn == "Company Name"
            ? state.currentSortDirection
            : null;

    final String initialFirmsType = _filterFirmsTypeC.text;
    final String initialContactPerson = _filterContactPersonC.text;
    final String initialMobileNumber = _filterMobileNumberC.text;
    final String initialCityName = _filterCityNameC.text;
    final String? initialDirection = selectedDirection;

    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_filterFirmsTypeC.text.trim() != initialFirmsType) ||
            (_filterContactPersonC.text.trim() != initialContactPerson) ||
            (_filterMobileNumberC.text.trim() != initialMobileNumber) ||
            (_filterCityNameC.text.trim() != initialCityName) ||
            (selectedDirection != initialDirection);
        applyEnabled.value = manualClose;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Company Master",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          void selectDirection(String direction) {
            innerState(() {
              selectedDirection = direction;
            });
            updateApplyState(innerState);
          }

          return SingleChildScrollView(
            padding: EdgeInsets.only(right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sort By Company Name", style: AppTextStyle.ts14M()),
                verticalSpacing(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => selectDirection("ASC"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              selectedDirection == "ASC"
                                  ? AppColor.lightBlue
                                  : Colors.transparent,
                          border: Border.all(color: AppColor.grey, width: .5),
                        ),
                        child: Text("A-Z", style: AppTextStyle.ts12R()),
                      ),
                    ),
                    horizontalSpacing(),
                    GestureDetector(
                      onTap: () => selectDirection("DESC"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              selectedDirection == "DESC"
                                  ? AppColor.lightBlue
                                  : Colors.transparent,
                          border: Border.all(color: AppColor.grey, width: .5),
                        ),
                        child: Text("Z-A", style: AppTextStyle.ts12R()),
                      ),
                    ),
                  ],
                ),
                verticalSpacing(height: 20),
                CustomTextField(
                  title: "Firms Type",
                  hint: "Enter Firms Type",
                  textController: _filterFirmsTypeC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                verticalSpacing(),
                CustomTextField(
                  title: "Contact Person",
                  hint: "Enter Contact Person",
                  textController: _filterContactPersonC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                verticalSpacing(),
                CustomTextField(
                  title: "Mobile Number",
                  hint: "Enter Mobile Number",
                  textController: _filterMobileNumberC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                verticalSpacing(),
                CustomTextField(
                  title: "City Name",
                  hint: "Enter City Name",
                  textController: _filterCityNameC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
              ],
            ),
          );
        },
      ),
      onClear: () {
        _filterFirmsTypeC.clear();
        _filterContactPersonC.clear();
        _filterMobileNumberC.clear();
        _filterCityNameC.clear();
        _companyMasterCubit.applyCompanyFilterAndSort(
          context: context,
          isClear: true,
        );
      },
      onApply: () {
        applied = true;
        _companyMasterCubit.applyCompanyFilterAndSort(
          context: context,
          companyType: _filterFirmsTypeC.text.trim(),
          contactPerson: _filterContactPersonC.text.trim(),
          mobileNumber: _filterMobileNumberC.text.trim(),
          cityName: _filterCityNameC.text.trim(),
          sortColumn: selectedDirection != null ? "Company Name" : null,
          sortDirection: selectedDirection,
        );
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // IF BOTTOM SHEET CLOSE WITHOUT APPLYING
    if (!applied && manualClose) {
      _filterFirmsTypeC.clear();
      _filterContactPersonC.clear();
      _filterMobileNumberC.clear();
      _filterCityNameC.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: 'Company Master',
        authorization: _routeAuthorizationModel,
        onExportCallback: (value) {
          if (_companyMasterCubit.state.totalNumberOfRecord == 0) {
            showErrorMessage(context, "Error", "No data found");
            return;
          }
          _companyMasterCubit.exportExcelPdf(context, value);
        },
        searchHintText: "Search by Company Name",
        onSearchSubmit: (value) {
          _companyMasterCubit.searchCompany(context, value);
        },
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addCompany);
          if (context.mounted) {
            _companyMasterCubit.getCompanyMaster(context, 1);
          }
        },
        textController: _searchC,
        onSortOptionCallback: (value) async {
          _companyMasterCubit.sortCompany(context, value, "DESC");
        },
        isFilterOn: true,
        sortOptionList: ["Created Date", "Company Name", "Company Type"],
        initialSortType: "Created Date",
        onFilterTap: () {
          _showBottomSheetToFilterCompanyMaster(context);
        },
      ),
      body: BlocBuilder<CompanyMasterCubit, CompanyMasterState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.companyList.isEmpty) {
            return Center(child: loader());
          }
          if (state.companyList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: _companyMasterCubit.state.companyList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.companyList.length) {
                return state.companyList.length < state.totalNumberOfRecord
                    ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var company = state.companyList[index];
              return Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 10),
                decoration: commonCardDecoration(),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 10,
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () async {
                              await goRouter.pushNamed(
                                AppRoutes.viewCompanyDetails,
                                queryParameters: {
                                  "company": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(company),
                                    ),
                                  ),
                                },
                              );
                            },
                            child: Text(
                              company.companyName,
                              style: AppTextStyle.ts16M(
                                color: AppColor.primary,
                              ).copyWith(
                                decoration: TextDecoration.underline,
                                decorationColor: AppColor.primary,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          spacing: 10,
                          children: [
                            CustomIconButton.edit(
                              onPressed: () async {
                                final result = await goRouter.pushNamed(
                                  AppRoutes.addCompany,
                                  queryParameters: {
                                    "company": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(company),
                                      ),
                                    ),
                                  },
                                );
                                if (result != null && result is CompanyModel) {
                                  _companyMasterCubit.updateCompany(
                                    result,
                                    index,
                                  );
                                }
                              },
                            ),
                            CustomIconButton.delete(
                              onPressed: () {
                                _showPopUpToDeleteVendor(
                                  context,
                                  company,
                                  index,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    verticalSpacing(height: 5),
                    buildRowTitleValue(
                      title: "Contact Person",
                      value: company.contactPerson,
                      singleLine: false
                    ),
                    buildRowTitleValue(
                      title: "Company Type",
                      value: company.firmsType,
                      singleLine: false
                    ),
                    buildRowTitleValue(
                      title: "Mobile Number",
                      value: company.mobileNumber,
                      customValueWidget: CustomClickToContactText(
                        value: company.mobileNumber,
                      ),
                    ),
                    buildRowTitleValue(
                      title: "Email ID",
                      value: company.emailId,
                      customValueWidget: CustomClickToContactText(
                        value: company.emailId,
                        type: ContactType.email,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
