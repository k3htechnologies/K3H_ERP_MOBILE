// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/cubit/utils_cubit.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/vendor_management/data/model/vendor.model.dart';
import 'package:k3h_erp_app/features/vendor_management/presentation/cubit/vendor/vendor_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class VendorScreen extends StatefulWidget {
  const VendorScreen({super.key});
  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  late VendorCubit _vendorCubit;
  late AuthorizationModel _routeAuthorizationModel;
  late UtilsCubit _utilsCubit;
  late ScrollController scrollController;
  Timer? _debounce;
  late TextEditingController _searchC,
      _filterVendorCodeC,
      _filterCompanyNameC,
      _filterCompanyTypeC,
      _filterMobileNumberC,
      _filterCityC,
      _filterGstNumberC,
      _filterAadhaarCardNumberC,
      _filterPanCardNumberC;
  final ValueNotifier<int> _filterCount = ValueNotifier(0);
  late UserModel? _user;

  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.vendor] ??
        AuthorizationModel();
    _vendorCubit = context.read<VendorCubit>();
    _utilsCubit = context.read<UtilsCubit>();
    getCurrentUser();
    _initializeTextEditingController();
    _onScroll();
    _vendorCubit.getVendors(context, 1);
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
    _filterCompanyNameC.dispose();
    _filterCompanyTypeC.dispose();
    _filterMobileNumberC.dispose();
    _filterCityC.dispose();
    _filterGstNumberC.dispose();
    _filterAadhaarCardNumberC.dispose();
    _filterPanCardNumberC.dispose();
    _filterCount.dispose();
    _filterVendorCodeC.dispose();
    scrollController.dispose();
  }

  Future getCurrentUser() async {
    var userJson = jsonDecode(
      LocalStorageManager().getString(StorageKey.currentUser) ?? "",
    );
    _user = UserModel.fromJson(userJson);
  }

  void _showPopUpToDeleteVendor(
    BuildContext context,
    VendorModel vendor,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      "You are about to delete a vendor ",
      "Deleting this vendor will permanently remove its contents.",
    );
    if (result && context.mounted) {
      _vendorCubit.deleteVendor(
        context: context,
        vendorId: vendor.vendorId,
        uniqueKey: vendor.uniquekey,
        index: index,
      );
    }
  }

  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _filterVendorCodeC = TextEditingController();
    _filterCompanyTypeC = TextEditingController();
    _filterCompanyNameC = TextEditingController();
    _filterMobileNumberC = TextEditingController();
    _filterCityC = TextEditingController();
    _filterGstNumberC = TextEditingController();
    _filterAadhaarCardNumberC = TextEditingController();
    _filterPanCardNumberC = TextEditingController();
  }

  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_vendorCubit.state.isLoading! &&
          _vendorCubit.state.vendorList.length <
              _vendorCubit.state.totalNumberOfRecord) {
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _vendorCubit.getVendors(context, _vendorCubit.state.currentPage + 1);
        });
      }
    });
  }

  Future<void> _showBottomSheetToFilterVendorMaster(
    BuildContext context,
  ) async {
    final state = _vendorCubit.state;
    _searchC.text = state.searchText;
    _filterVendorCodeC.text = state.filterByVendorCode;
    _filterCompanyNameC.text = state.filterByCompanyName;
    _filterCompanyTypeC.text = state.filterByCompanyType;
    _filterMobileNumberC.text = state.filterByMobileNumber;
    _filterCityC.text = state.filterByCity;
    _filterGstNumberC.text = state.filterByGstNumber;
    _filterAadhaarCardNumberC.text = state.filterByAadhaarCardNumber;
    _filterPanCardNumberC.text = state.filterByPanCardNumber;
    String? selectedDirection =
        state.currentSortColumn == "Vendor Name"
            ? state.currentSortDirection
            : null;
    final String initialVendorName = _searchC.text;
    final String initialVendorCode = _filterVendorCodeC.text;
    final String initialCompanyName = _filterCompanyNameC.text;
    final String initialCompanyType = _filterCompanyTypeC.text;
    final String initialMobileNumber = _filterMobileNumberC.text;
    final String initialCity = _filterCityC.text;
    final String initialGSTNumber = _filterGstNumberC.text;
    final String initialAadhaarNumber = _filterAadhaarCardNumberC.text;
    final String initialPanNumber = _filterPanCardNumberC.text;
    final String? initialDirection = selectedDirection;
    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;
    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_searchC.text.trim() != initialVendorName) ||
            (_filterVendorCodeC.text.trim() != initialVendorCode) ||
            (_filterCompanyNameC.text.trim() != initialCompanyName) ||
            (_filterCompanyTypeC.text.trim() != initialCompanyType) ||
            (_filterMobileNumberC.text.trim() != initialMobileNumber) ||
            (_filterCityC.text.trim() != initialCity) ||
            (_filterGstNumberC.text.trim() != initialGSTNumber) ||
            (_filterAadhaarCardNumberC.text.trim() != initialAadhaarNumber) ||
            (_filterPanCardNumberC.text.trim() != initialPanNumber) ||
            (selectedDirection != initialDirection);
        applyEnabled.value = manualClose;
      });
    }

    await DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Vendor",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          void selectDirection(String direction) {
            innerState(() {
              selectedDirection = direction;
            });
            updateApplyState(innerState);
          }

          return SingleChildScrollView(
            padding: EdgeInsets.only(right: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sort By Vendor Name", style: AppTextStyle.ts14M()),
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
                  title: "Vendor Name",
                  hint: "Enter Vendor Name",
                  textController: _searchC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "vendor Code",
                  hint: "Enter Vendor Code",
                  textController: _filterVendorCodeC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Company Name",
                  hint: "Enter Company Name",
                  textController: _filterCompanyNameC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Company Type",
                  hint: "Enter Company Type",
                  textController: _filterCompanyTypeC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Mobile Number",
                  hint: "Enter Mobile Number",
                  keyboardType: TextInputType.number,
                  textController: _filterMobileNumberC,
                  inputFormatterList: InputValidator.digit(10),
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "City",
                  hint: "Enter City",
                  textController: _filterCityC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "GST Number",
                  hint: "Enter GST Number",
                  textController: _filterGstNumberC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Aadhaar Card Number",
                  hint: "Enter Aadhaar Card Number",
                  keyboardType: TextInputType.number,
                  textController: _filterAadhaarCardNumberC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Pan Card Number",
                  hint: "Enter Pan Card Number",
                  textController: _filterPanCardNumberC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
              ],
            ),
          );
        },
      ),
      onClear: () {
        _searchC.clear();
        _filterVendorCodeC.clear();
        _filterCompanyNameC.clear();
        _filterCompanyTypeC.clear();
        _filterMobileNumberC.clear();
        _filterCityC.clear();
        _filterGstNumberC.clear();
        _filterAadhaarCardNumberC.clear();
        _filterPanCardNumberC.clear();
        _vendorCubit.sortVendor(context: context, isClear: true);
      },
      onApply: () {
        applied = true;
        _vendorCubit.sortVendor(
          context: context,
          vendorName: _searchC.text.trim(),
          vendorCode: _filterVendorCodeC.text.trim(),
          companyName: _filterCompanyNameC.text.trim(),
          companyType: _filterCompanyTypeC.text.trim(),
          mobileNumber: _filterMobileNumberC.text.trim(),
          city: _filterCityC.text.trim(),
          gstNumber: _filterGstNumberC.text.trim(),
          aadhaarCardNumber: _filterAadhaarCardNumberC.text.trim(),
          panCardNumber: _filterPanCardNumberC.text.trim(),
          sortColumn: selectedDirection != null ? "Vendor Name" : null,
          sortDirection: selectedDirection,
        );
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );
    if (!applied && manualClose) {
      _searchC.clear();
      _filterVendorCodeC.clear();
      _filterCompanyNameC.clear();
      _filterCompanyTypeC.clear();
      _filterMobileNumberC.clear();
      _filterCityC.clear();
      _filterGstNumberC.clear();
      _filterAadhaarCardNumberC.clear();
      _filterPanCardNumberC.clear();
    }
  }

  void _showPopUpToShareLink() {
    final String magicLinkType = "VENDOR MANAGEMENT";
    final int clientRegistrationId = _user?.clientRegistrationId ?? 0;
    _utilsCubit
        .getMagicLinkWithValidate(
          context: context,
          magicLinkType: magicLinkType,
          clientRegistrationId: clientRegistrationId,
        )
        .then((magicLink) {
          if (magicLink.isNotEmpty) {
            DialogHelper.showCustomDialogue(
              context,
              title: "Share Link",
              spacingBetweenContentAndBottomSection: 0,
              childContent: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    title: "Magic Link",
                    hint: "Enter Link",
                    minLines: 6,
                    maxLines: 6,
                    textController: TextEditingController(text: magicLink),
                    readOnly: true,
                  ),
                ],
              ),
              bottomSection: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 10,
                children: [
                  Expanded(
                    child: CustomButton(
                      text: "Copy Link",
                      onPressed: () {
                        copy(
                          context: context,
                          text: magicLink,
                          snackBarTitle: "Magic Link",
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: CustomButton(
                      text: "Share Link",
                      backgroundColor: AppColor.grey.withValues(alpha: .8),
                      onPressed: () {
                        share(
                          context: context,
                          text: magicLink,
                          title: "Share Link",
                          subject: "Check out this link!",
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VendorCubit, VendorState>(
      listener: (context, state) {
        _filterCount.value = _vendorCubit.updateFilterCount(state);
      },
      child: Scaffold(
        appBar: CustomAppBar(
          screenTitle: 'Vendor Management',
          authorization: _routeAuthorizationModel,
          filterCountNotifier: _filterCount,
          onExportCallback: (value) {
            if (_vendorCubit.state.totalNumberOfRecord == 0) {
              showErrorMessage(context, "Error", "No Data Found");
              return;
            }
            _vendorCubit.exportExcelPdf(context, value);
          },
          onAddCallback: () async {
            await goRouter.pushNamed(AppRoutes.addVendor);
          },
          searchHintText: "Search by Vendor Name",
          onSearchSubmit: (value) {
            _vendorCubit.searchVendor(context, value);
          },
          textController: _searchC,
          isFilterOn: true,
          onFilterTap: () {
            _showBottomSheetToFilterVendorMaster(context);
          },
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    isDisable: !_routeAuthorizationModel.isAction,
                    onPressed: () {
                      _showPopUpToShareLink();
                    },
                    leading: Icon(
                      Icons.share,
                      size: 16,
                      color:
                          !_routeAuthorizationModel.isAction
                              ? AppColor.grey2
                              : AppColor.white,
                    ),
                    text: "Share",
                  ),
                ],
              ),
              verticalSpacing(height: 10),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _searchC.clear();
                    await _vendorCubit.searchVendor(context, "");
                  },
                  child: BlocBuilder<VendorCubit, VendorState>(
                    builder: (context, state) {
                      if (state.isLoading == true && state.vendorList.isEmpty) {
                        return loader();
                      }
                      if (state.vendorList.isEmpty) {
                        return Center(
                          child: noDataWidget(message: "No Vendors Data Found"),
                        );
                      }
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: state.vendorList.length + 1,
                        itemBuilder: (context, index) {
                          if (index == state.vendorList.length) {
                            return state.vendorList.length <
                                    state.totalNumberOfRecord
                                ? Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                                : const SizedBox.shrink();
                          }
                          var vendor = state.vendorList[index];
                          return Container(
                            decoration: commonCardDecoration(),
                            margin: EdgeInsets.only(bottom: 10),
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  spacing: 10,
                                  children: [
                                    Flexible(
                                      child: GestureDetector(
                                        onTap: () async {
                                          await goRouter.pushNamed(
                                            AppRoutes.viewVendorDetails,
                                            queryParameters: {
                                              "vendor": Uri.encodeQueryComponent(
                                                EncryptionManager.encryptData(
                                                  jsonEncode(vendor),
                                                ),
                                              ),
                                              "index": "$index",
                                            },
                                          );
                                        },
                                        child: Text(
                                          vendor.vendorName,
                                          style: AppTextStyle.ts16M(
                                            color: AppColor.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      spacing: 10,
                                      children: [
                                        if (vendor.verifiedNonVerified
                                                .toLowerCase() !=
                                            'verified') ...[
                                          CustomIconButton(
                                            onPressed: () {},
                                            icon: Icon(
                                              Icons.warning_amber_outlined,
                                              color: AppColor.yellow,
                                              size: 16,
                                            ),
                                            backgroundColor: AppColor.yellow
                                                .withValues(alpha: .2),
                                          ),
                                        ],
                                        CustomIconButton.edit(
                                          isDisabled:
                                              !_routeAuthorizationModel
                                                  .isAction,
                                          onPressed: () async {
                                            await goRouter.pushNamed(
                                              AppRoutes.addVendor,
                                              queryParameters: {
                                                "vendor": Uri.encodeQueryComponent(
                                                  EncryptionManager.encryptData(
                                                    jsonEncode(vendor),
                                                  ),
                                                ),
                                                "index": index.toString(),
                                              },
                                            );
                                          },
                                        ),
                                        CustomIconButton.delete(
                                          isDisabled:
                                              !_routeAuthorizationModel
                                                  .isAction,
                                          onPressed: () {
                                            _showPopUpToDeleteVendor(
                                              context,
                                              vendor,
                                              index,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                buildRowTitleValue(
                                  title: "Vendor Code",
                                  fixesWidth: 120.w,
                                  value: vendor.systemGeneratedCode,
                                  customValueWidget: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          vendor.systemGeneratedCode,
                                          style: AppTextStyle.ts14M(),
                                        ),
                                      ),
                                      horizontalSpacing(width: 2),
                                      InkWell(
                                        onTap: () {
                                          copy(
                                            context: context,
                                            text: vendor.systemGeneratedCode,
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Icon(
                                            Icons.copy,
                                            size: 16,
                                            color: AppColor.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                buildRowTitleValue(
                                  fixesWidth: 120.w,
                                  title: "Company Name",
                                  value: vendor.companyName,
                                  singleLine: false,
                                ),
                                buildRowTitleValue(
                                  fixesWidth: 120.w,
                                  title: "Company Type",
                                  value: vendor.companyType,
                                  singleLine: false,
                                ),
                                buildRowTitleValue(
                                  fixesWidth: 120.w,
                                  title: "Mobile Number",
                                  value: vendor.mobileNumber,
                                  customValueWidget: CustomClickToContactText(
                                    countryCode: vendor.mobileNumberCountryCode,
                                    value: vendor.mobileNumber,
                                  ),
                                ),
                                buildRowTitleValue(
                                  fixesWidth: 120.w,
                                  title: "Email ID",
                                  value: vendor.emailId,
                                  customValueWidget: CustomClickToContactText(
                                    value: vendor.emailId,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
