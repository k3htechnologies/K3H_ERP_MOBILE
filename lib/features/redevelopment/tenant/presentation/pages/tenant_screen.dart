import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/presentation/cubit/tenant_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class TenantScreen extends StatefulWidget {
  const TenantScreen({super.key});

  @override
  State<TenantScreen> createState() => _TenantScreenState();
}

class _TenantScreenState extends State<TenantScreen> {
  // CUBIT
  late TenantCubit _tenantCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PROJECT
  late ProjectModel _project;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  // DEFAULT BUILDING ID
  // int selectedBuildingId = 0;
  List<Map<String, dynamic>> _selectedBuilding = [];

  // DEFAULT TAB
  int selectedIndex = 0;

  // FLAGS TO PREVENT INFINITE CALLS
  int? _lastFetchedBuildingId;

  @override
  void initState() {
    super.initState();
    _tenantCubit = context.read<TenantCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.tenant] ??
        AuthorizationModel();
    _project = getProject();
    _initialMethod();
    _initializeTextEditingController();
    _onScroll();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final buildingList = _tenantCubit.state.buildingList;
        if (buildingList.isNotEmpty) {
          final firstBuildingId = buildingList.first.buildingId;

          _selectedBuilding = [
            {
              'zAttributesId': firstBuildingId,
              'DisplayName': buildingList.first.buildingName,
            },
          ];
          _lastFetchedBuildingId = null;
          _tenantCubit.getTenantList(
            context: context,
            projectId: _project.projectId,
            buildingId: firstBuildingId,
            pageNumber: 1,
            pageSize: 10,
          );
          _lastFetchedBuildingId = firstBuildingId;
        }
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    scrollController.dispose();
    _searchC.dispose();
    super.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  Future<Map<String, dynamic>> _fetchBuildings(
    int pageNumber, {
    String? value,
  }) async {
    final buildingList = _tenantCubit.state.buildingList;

    if (value != null && value.isNotEmpty) {
      final filteredBuildings =
          buildingList
              .where(
                (building) => building.buildingName.toLowerCase().contains(
                  value.toLowerCase(),
                ),
              )
              .toList();

      return {
        "itemList":
            filteredBuildings.map((building) {
              return {
                "zAttributesId": building.buildingId,
                "DisplayName": building.buildingName,
              };
            }).toList(),
        "totalNumberOfRecord": filteredBuildings.length,
      };
    }

    return {
      "itemList":
          buildingList.map((building) {
            return {
              "zAttributesId": building.buildingId,
              "DisplayName": building.buildingName,
            };
          }).toList(),
      "totalNumberOfRecord": buildingList.length,
    };
  }

  void _initialMethod() async {
    if (_tenantCubit.state.buildingList.isEmpty) {
      await _tenantCubit.getBuildingList(context, 1, 100, _project.projectId);
    }

    if (mounted) {
      final buildingList = _tenantCubit.state.buildingList;

      if (buildingList.isNotEmpty) {
        // Always select first building
        final firstBuildingId = buildingList.first.buildingId;
        _selectedBuilding = [
          {
            'zAttributesId': firstBuildingId,
            'DisplayName': buildingList.first.buildingName,
          },
        ];

        if (mounted && _lastFetchedBuildingId != firstBuildingId) {
          _lastFetchedBuildingId = firstBuildingId;
          await _tenantCubit.getTenantList(
            context: context,
            projectId: _project.projectId,
            buildingId: firstBuildingId,
            pageNumber: 1,
            pageSize: 10,
          );
        }
      }
    }
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (!mounted || !scrollController.hasClients) return;

      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.position.pixels;

      if (currentScroll >= maxScroll - 100 &&
          maxScroll > 0 &&
          !(_tenantCubit.state.isLoading ?? false) &&
          _tenantCubit.state.tenantList.length <
              _tenantCubit.state.totalNumberOfRecord &&
          _selectedBuilding.isNotEmpty) {
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          if (_selectedBuilding.isEmpty) return;
          if (_tenantCubit.state.isLoading ?? false) return;

          _tenantCubit.getTenantList(
            context: context,
            pageNumber: _tenantCubit.state.currentPage + 1,
            pageSize: 10,
            projectId: _project.projectId,
            buildingId: _selectedBuilding.first["zAttributesId"] as int,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setStateBuilder) {
        return Scaffold(
          appBar: CustomAppBarWithBackButton(
            screenTitle: "Tenant",
            authorization: _routeAuthorizationModel,
          ),
          body: Column(
            children: [
              verticalSpacing(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    BlocBuilder<TenantCubit, TenantState>(
                      builder: (context, state) {
                        final buildingDropdownList =
                            state.buildingList.map((building) {
                              return {
                                'zAttributesId': building.buildingId,
                                'DisplayName': building.buildingName,
                              };
                            }).toList();

                        return CustomMultipleSelectPopup(
                          title: "Buildings",
                          key: ValueKey(
                            _selectedBuilding.isEmpty
                                ? 'empty'
                                : _selectedBuilding.first['zAttributesId'],
                          ),
                          isMultiSelect: false,
                          initialValue: _selectedBuilding,
                          dataList: buildingDropdownList,
                          onSelected: (value) async {
                            setStateBuilder(() {
                              _selectedBuilding = value;
                            });

                            if (value.isNotEmpty &&
                                value.first['zAttributesId'] != null) {
                              final newBuildingId =
                                  value.first['zAttributesId'] as int;
                              if (_lastFetchedBuildingId != newBuildingId) {
                                _lastFetchedBuildingId = newBuildingId;
                                await _tenantCubit.getTenantList(
                                  context: context,
                                  projectId: _project.projectId,
                                  buildingId: newBuildingId,
                                  pageNumber: 1,
                                  pageSize: 10,
                                );
                              }
                            }
                          },
                          dataFetchCallBack: _fetchBuildings,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Building is required";
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    Container(
                      height: 40,
                      color: AppColor.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: SearchWidget(
                              isFilterOn: false,
                              onSubmit: (value) {
                                _tenantCubit.searchTenant(
                                  value,
                                  context,
                                  _project.projectId,
                                  _selectedBuilding.first["zAttributesId"]
                                      as int,
                                );
                              },
                              textController: _searchC,
                            ),
                          ),
                          horizontalSpacing(),
                          CustomIconButton(
                            onPressed: () {
                              goRouter.pushNamed(AppRoutes.addTenant);
                            },
                            icon: Icon(
                              Icons.add,
                              size: 16,
                              color: AppColor.darkGreen,
                            ),
                            backgroundColor: AppColor.lightGreen,
                          ),
                          horizontalSpacing(),
                          CustomIconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.file_download,
                              size: 16,
                              color: AppColor.primary,
                            ),
                            backgroundColor: AppColor.lightBlue,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<TenantCubit, TenantState>(
                  builder: (context, state) {
                    if ((state.isLoading ?? true) && state.tenantList.isEmpty) {
                      return Center(child: loader());
                    }
                    if (state.tenantList.isEmpty) {
                      return Center(child: noDataWidget());
                    }
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      itemCount: state.tenantList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == state.tenantList.length) {
                          return state.tenantList.length <
                                  state.totalNumberOfRecord
                              ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                              : const SizedBox.shrink();
                        }
                        var tenant = state.tenantList[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: commonCardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      tenant.tenantApplicantData
                                          .firstWhere(
                                            (e) =>
                                                e.applicantType.toLowerCase() ==
                                                "applicant",
                                          )
                                          .applicantName,
                                      style: AppTextStyle.ts16M(
                                        color: AppColor.primary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      CustomIconButton.edit(
                                        onPressed: () async {
                                            await goRouter.pushNamed(
                                              AppRoutes.addTenant,
                                              queryParameters: {
                                                "tenant": Uri.encodeQueryComponent(
                                                  EncryptionManager.encryptData(
                                                    jsonEncode(tenant.toJson()),
                                                  ),
                                                ),
                                                'index': index.toString(),
                                              },
                                            );
                                            if (context.mounted) {
                                              _tenantCubit.getTenantList(
                                                context: context,
                                                pageNumber: 1,
                                                pageSize: 10,
                                                projectId: _project.projectId,
                                                buildingId: _selectedBuilding
                                                    .first["zAttributesId"]
                                                    as int,
                                              );
                                            }
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      CustomIconButton.delete(
                                        onPressed: () {
                                          // _showPopupToDeleteAssetMaster(context, asset, state.currentPage, index);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              verticalSpacing(height: 8),
                              _buildRowTitleValue(
                                title: "Existing Flat No.",
                                value: tenant.flatNumber,
                              ),
                              _buildRowTitleValue(
                                title: "Existing Flat Type",
                                value: tenant.flatType,
                              ),
                              _buildRowTitleValue(
                                title: "New Flat No",
                                value:
                                    tenant.inventoryFlatType.isEmpty
                                        ? "-"
                                        : tenant.inventoryFlatType,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // BUILD ROW TITLE VALUE
  Widget _buildRowTitleValue({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE
          SizedBox(
            width: 120,
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.ts14R(),
            ),
          ),
        ],
      ),
    );
  }
}
