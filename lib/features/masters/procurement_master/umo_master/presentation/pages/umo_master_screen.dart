import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/umo_master/presentation/cubit/umo_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class UOMMasterScreen extends StatefulWidget {
  const UOMMasterScreen({super.key});

  @override
  State<UOMMasterScreen> createState() => _UOMMasterScreenState();
}

class _UOMMasterScreenState extends State<UOMMasterScreen> {
  // CUBIT
  late UOMMasterCubit _uomMasterCubit;

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
    _uomMasterCubit = context.read<UOMMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.uomMaster]!;
    _initializeTextEditingController();
    _onScroll();
    _uomMasterCubit.getUOMMasterList(context, 1);
  }

  @override
  void dispose() {
    scrollController.dispose();
    _searchC.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // INITIALIZE TEXT CONTROLLER
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_uomMasterCubit.state.isLoading! &&
          _uomMasterCubit.state.uomList.length <
              _uomMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _uomMasterCubit.getUOMMasterList(
            context,
            _uomMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightGreyBackground,
      appBar: CustomAppBar(
        screenTitle: 'UOM',
        authorization: _routeAuthorizationModel,
        onSearchSubmit: (value) {
          _uomMasterCubit.searchUOM(context, value);
        },
        textController: _searchC,
        onExportCallback: (value) {
          if (_uomMasterCubit.state.totalNumberOfRecord == 0) {
            showErrorMessage(context, "Error", "No data found");
            return;
          }
          _uomMasterCubit.exportExcelPdf(context, value);
        },
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _searchC.clear();
            _uomMasterCubit.searchUOM(context, "");
          },
          child: BlocBuilder<UOMMasterCubit, UOMMasterState>(
            builder: (context, state) {
              if ((state.isLoading ?? true) && state.uomList.isEmpty) {
                return Center(child: loader());
              }
              if (state.uomList.isEmpty) {
                return ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: noDataWidget(message: "No UOMs Data Found"),
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  // Header Row
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      border: Border(
                        bottom: BorderSide(
                          color: AppColor.grey.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text('UOM Name', style: AppTextStyle.ts14SB()),
                        ),
                        Expanded(
                          child: Text(
                            'UOM Code',
                            style: AppTextStyle.ts14SB(),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // List
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.zero,
                      itemCount: _uomMasterCubit.state.uomList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == state.uomList.length) {
                          return state.uomList.length <
                                  state.totalNumberOfRecord
                              ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                              : const SizedBox.shrink();
                        }
                        var uom = state.uomList[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.white,
                            border: Border(
                              bottom: BorderSide(
                                color: AppColor.grey.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  uom.uom,
                                  style: AppTextStyle.ts14R(),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  uom.uomCode,
                                  style: AppTextStyle.ts14R(),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
