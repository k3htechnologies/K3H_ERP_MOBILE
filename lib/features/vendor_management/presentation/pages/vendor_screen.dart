import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/vendor_management/data/model/vendor.model.dart';
import 'package:k3h_erp_app/features/vendor_management/presentation/cubit/vendor/vendor_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class VendorScreen extends StatefulWidget {
  const VendorScreen({super.key});

  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  // CUBIT
  late VendorCubit _vendorCubit;

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
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.vendor]!;
    _vendorCubit = context.read<VendorCubit>();
    _initializeTextEditingController();
    _onScroll();
    _vendorCubit.getVendors(context, 1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
    scrollController.dispose();
  }

  // DELETE VENDOR DIALOG
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

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_vendorCubit.state.isLoading! &&
          _vendorCubit.state.vendorList.length <
              _vendorCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _vendorCubit.getVendors(context, _vendorCubit.state.currentPage + 1);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: 'Vendor Management',
        authorization: _routeAuthorizationModel,
        onExportCallback: (value) {
          _vendorCubit.exportExcelPdf(context, value);
        },
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addVendor);
          if (context.mounted) {
            _vendorCubit.getVendors(context, 1);
          }
        },
        onSearchSubmit: (value) {
          _vendorCubit.searchVendor(context, value);
        },
        textController: _searchC,
      ),
      body: BlocBuilder<VendorCubit, VendorState>(
        builder: (context, state) {
          if (state.isLoading == true && state.vendorList.isEmpty) {
            return loader();
          }
          if (state.vendorList.isEmpty) {
            return noDataWidget();
          }
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: state.vendorList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.vendorList.length) {
                return state.vendorList.length < state.totalNumberOfRecord
                    ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var vendor = state.vendorList[index];
              return Container(
                decoration: commonCardDecoration(),
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(16.0),
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
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: AppColor.primary),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    vendor.vendorName,
                                    style: AppTextStyle.ts16M(
                                      color: AppColor.primary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          spacing: 10,
                          children: [
                            CustomIconButton.edit(
                              onPressed: () async {
                                await goRouter.pushNamed(
                                  AppRoutes.addVendor,
                                  queryParameters: {
                                    "vendor": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(vendor),
                                      ),
                                    ),
                                  },
                                );
                                if (context.mounted) {
                                  _vendorCubit.getVendors(
                                    context,
                                    state.currentPage,
                                  );
                                }
                              },
                            ),
                            CustomIconButton.delete(
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
                    _buildRowTitleVale(
                      title: "Company Name",
                      value: vendor.companyName,
                    ),
                    _buildRowTitleVale(
                      title: "Company Type",
                      value: vendor.companyType,
                    ),
                    _buildRowTitleVale(
                      title: "Mobile Number",
                      value: vendor.mobileNumber,
                    ),
                    _buildRowTitleVale(
                      title: "Email ID",
                      value: vendor.emailId,
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

  // <---- BUILD ROW TITLE AND VALUE WIDGET ---->
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
