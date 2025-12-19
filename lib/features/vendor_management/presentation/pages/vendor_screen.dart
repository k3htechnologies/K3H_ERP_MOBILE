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

  // TEXTEDITING CONTROLLERS
  late TextEditingController _searchC;

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

  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.vendor]!;
    _vendorCubit = context.read<VendorCubit>();
    _initializeTextEditingController();
    _onScroll();
    _vendorCubit.getVendors(context, 1, 10);
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
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _vendorCubit.getVendors(
            context,
            _vendorCubit.state.currentPage + 1,
            10,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.greyBackground,
      appBar: CustomAppBar(
        screenTitle: 'Vendor',
        authorization: _routeAuthorizationModel,
        onExportCallback: (value) {
          _vendorCubit.exportExcelPdf(context, value);
        },
        onAddCallback: () async {
          final result = await goRouter.pushNamed(AppRoutes.addVendor);
          if (result != null && context.mounted) {
            _vendorCubit.getVendors(context, 1, 10);
          }
        },
        onSearchSubmit: (value) {
          _vendorCubit.searchVendor(context, value);
        },
        textController: _searchC,
        onSortOptionCallback: (value) async {},
        sortOptionList: ["Created Date"],
        initialSortType: "Created Date",
      ),
      body: BlocBuilder<VendorCubit, VendorState>(
        builder: (context, state) {
          if (state.isLoading == true) {
            return loader();
          }
          if (state.vendorList.isEmpty) {
            return noDataWidget();
          }
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
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
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ElevatedButton(
                  onPressed: () {},
                  clipBehavior: Clip.hardEdge,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    backgroundColor: AppColor.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColor.grey30),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                    elevation: 0.0,
                  ),
                  child: Column(
                    spacing: 10.0,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: 2.0,
                              children: [
                                Text(
                                  'Name :',
                                  style: AppTextStyle.ts12R(
                                    color: AppColor.grey,
                                  ),
                                ),
                                Text(
                                  vendor.vendorName,
                                  style: AppTextStyle.ts12M(),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              spacing: 2.0,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Company Name :',
                                  style: AppTextStyle.ts12R(
                                    color: AppColor.grey,
                                  ),
                                ),
                                Text(
                                  vendor.companyName,
                                  style: AppTextStyle.ts12M(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        children: [
                          Expanded(
                            child: Column(
                              spacing: 2.0,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Company Type :',
                                  style: AppTextStyle.ts12R(
                                    color: AppColor.grey,
                                  ),
                                ),
                                Text(
                                  vendor.companyType,
                                  style: AppTextStyle.ts12M(),
                                ),
                              ],
                            ),
                          ),
                          CustomIconButton(
                            onPressed: () async {
                              final result = await goRouter.pushNamed(
                                AppRoutes.addVendor,
                                queryParameters: {
                                  "vendor": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(vendor),
                                    ),
                                  ),
                                },
                              );
                              if (result == true && context.mounted) {
                                _vendorCubit.getVendors(context, 1, 10);
                              }
                            },
                            icon: Icon(Icons.edit),
                          ),
                          CustomIconButton(
                            onPressed: () {
                              _showPopUpToDeleteVendor(context, vendor, index);
                            },
                            icon: Icon(Icons.delete),
                          ),
                          CustomIconButton(
                            onPressed: () {
                              goRouter.pushNamed(
                                AppRoutes.viewVendorDetailsMobile,
                                queryParameters: {
                                  "vendor": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(vendor),
                                    ),
                                  ),
                                },
                              );
                            },
                            icon: Icon(Icons.remove_red_eye_outlined,)
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
