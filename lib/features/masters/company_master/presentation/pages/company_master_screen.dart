import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/company.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/cubit/company_master/company_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CompanyMasterScreen extends StatefulWidget {
  const CompanyMasterScreen({super.key});

  @override
  State<CompanyMasterScreen> createState() => _CompanyMasterMobileScreenState();
}

class _CompanyMasterMobileScreenState extends State<CompanyMasterScreen> {
  // BLOC
  late CompanyMasterCubit _companyMasterCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  @override
  void initState() {
    super.initState();
    initialiseControllers();
    _companyMasterCubit = context.read<CompanyMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.companyMaster]!;
    _companyMasterCubit.getCompanyMaster(context, 1, 10);
    // PAGINATION
    scrollController = ScrollController();
    // SCROLL LISTENER
    scrollController.addListener(_onScroll);
  }

  void initialiseControllers() {
    _searchC = TextEditingController();
    scrollController = ScrollController();
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
          10,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: 'Company',
        authorization: _routeAuthorizationModel,
        onExportCallback: (value) {
          _companyMasterCubit.exportExcelPdf(context, value);
        },
        onSearchSubmit: (value) {
          _companyMasterCubit.searchCompany(context, value);
        },
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addCompany);
          if (context.mounted) {
            // After add, reload from first page to avoid duplicate rows
            _companyMasterCubit.getCompanyMaster(context, 1, 10);
          }
        },
        textController: _searchC,
        onSortOptionCallback: (value) async {
          _companyMasterCubit.sortCompany(context, value, "DESC");
        },
        sortOptionList: ["Created Date", "Company Name", "Company Type"],
        initialSortType: "Created Date",
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
                  spacing: 10.0,
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
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.lightBlue,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    company.companyName,
                                    style: AppTextStyle.ts16M(
                                      color: AppColor.primary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  horizontalSpacing(),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: AppColor.primary,
                                    size: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          spacing: 10,
                          children: [
                            CustomIconButton(
                              onPressed: () async {
                                await goRouter.pushNamed(
                                  AppRoutes.addCompany,
                                  queryParameters: {
                                    "company": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(company),
                                      ),
                                    ),
                                  },
                                );
                                if (context.mounted) {
                                  _companyMasterCubit.getCompanyMaster(
                                    context,
                                    1,
                                    10,
                                  );
                                }
                              },
                              icon: Icon(
                                Icons.edit,
                                size: 16,
                                color: AppColor.grey,
                              ),
                              backgroundColor: AppColor.lightGrey,
                            ),
                            CustomIconButton(
                              onPressed: () {
                                _showPopUpToDeleteVendor(
                                  context,
                                  company,
                                  index,
                                );
                              },
                              icon: SvgPicture.asset(
                                AppAssets.deleteIcon2,
                                height: 16,
                                colorFilter: ColorFilter.mode(
                                  AppColor.error,
                                  BlendMode.srcIn,
                                ),
                              ),
                              backgroundColor: AppColor.lightRed,
                            ),
                          ],
                        ),
                      ],
                    ),
                    _buildRowTitleVale(
                      title: "Company Type",
                      value: company.companyType,
                    ),
                    _buildRowTitleVale(
                      title: "Contact Person",
                      value: company.contactPerson,
                    ),
                    _buildRowTitleVale(
                      title: "Email ID",
                      value: company.emailId,
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

  Widget _buildRowTitleVale({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // TITLE
          SizedBox(
            width: 140,
            child: Text(title, style: AppTextStyle.ts14R(color: AppColor.grey)),
          ),

          // COLON
          SizedBox(
            width: 20,
            child: Text(
              ":",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColor.grey),
            ),
          ),

          // VALUE
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.ts14R(),
            ),
          ),
        ],
      ),
    );
  }
}
