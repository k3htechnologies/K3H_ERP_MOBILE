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
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_floating_action_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CompanyMasterScreen extends StatefulWidget {
  const CompanyMasterScreen({super.key});

  @override
  State<CompanyMasterScreen> createState() =>
      _CompanyMasterMobileScreenState();
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
            _companyMasterCubit.getCompanyMaster(
              context,
              _companyMasterCubit.state.currentPage,
              10,
            );
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
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  border: Border.all(
                    color: AppColor.grey.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Company Name:",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.ts12R(color: AppColor.grey),
                            ),
                            Text(
                              company.companyName,
                              style: AppTextStyle.ts14R(),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Company Type :",
                              style: AppTextStyle.ts12R(color: AppColor.grey),
                            ),
                            Text(
                              company.companyType,
                              style: AppTextStyle.ts14R(),
                            ),
                          ],
                        ),
                      ),

                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            CustomButton(
                              text: "View",
                              backgroundColor: AppColor.slightDarkBlue,
                              onPressed: () {
                                goRouter.pushNamed(
                                  AppRoutes.viewCompanyMobile,
                                  queryParameters: {
                                    "company_master": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(
                                          _companyMasterCubit
                                              .state
                                              .companyList[index],
                                        ),
                                      ),
                                    ),
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    List<CompanyModel> data =
                                    (await goRouter.pushNamed(
                                      AppRoutes.addCompany,
                                      extra: company,
                                    )
                                    as List<CompanyModel>);
                                    _companyMasterCubit.updateCompany(
                                      data[0],
                                      index,
                                    );
                                  },
                                  child: SvgPicture.asset(
                                    AppAssets.editIcon,
                                    height: 24,
                                  ),
                                ),
                                horizontalSpacing(width: 20),
                                GestureDetector(
                                  onTap: () async {
                                    var result = await DialogHelper.deleteDialog(
                                      context,
                                      "You are about to delete a company_master ",
                                      "Deleting this company_master will permanently remove its contents.",
                                    );
                                    if (result) {
                                      final companyId =
                                          state.companyList[index].companyId;
                                      final uniqueKey =
                                          state.companyList[index].uniquekey;
                                      if (context.mounted) {
                                        _companyMasterCubit.deleteCompanyMaster(
                                          context: context,
                                          companyMasterId: companyId,
                                          uniqueKey: uniqueKey,
                                          pageNumber: 1,
                                          pageSize: 10,
                                          index: index,
                                        );
                                      }
                                    }
                                  },
                                  child: SvgPicture.asset(
                                    AppAssets.deleteIcon,
                                    height: 24,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: CommonFloatingActionButton(
        onPressed: () {
          goRouter.pushNamed(AppRoutes.addCompany);
        },
      ),
    );
  }
}