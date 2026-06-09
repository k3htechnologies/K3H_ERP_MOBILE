import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:k3h_erp_app/features/parking/presentation/cubit/parking_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class UnitDistributionStatusScreen extends StatefulWidget {
  final String type;
  final String title;
  final String? subTitle;
  final Map<String, dynamic> queryParams;
  final int projectId;
  const UnitDistributionStatusScreen({
    super.key,
    required this.type,
    required this.title,
    this.subTitle,
    required this.queryParams,
    required this.projectId,
  });

  @override
  State<UnitDistributionStatusScreen> createState() =>
      _UnitDistributionStatusScreenState();
}

class _UnitDistributionStatusScreenState
    extends State<UnitDistributionStatusScreen> {
  late InventoryCubit _inventoryCubit;
  late ParkingCubit _parkingCubit;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_inventoryCubit.state.isLoading! &&
          _inventoryCubit.state.flatList.length <
              _inventoryCubit.state.unitTotalRecords) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _inventoryCubit.fetchUnitsByProjectId(
            _inventoryCubit.state.currentUnitPage + 1,
            queryParams: widget.queryParams,
            projectId: widget.projectId,
          );
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _inventoryCubit = context.read<InventoryCubit>();
    _parkingCubit = context.read<ParkingCubit>();
    if (widget.type == "Parking") {
      _parkingCubit = context.read<ParkingCubit>();

      _parkingCubit.getParkingWithPagination(
        context,
        pageNumber: 1,
        pageSize: 10,
        queryParams: widget.queryParams,
        projectId: widget.projectId,
      );
    } else {
      _inventoryCubit.fetchUnitsByProjectId(
        1,
        queryParams: widget.queryParams,
        projectId: widget.projectId,
      );
    }

    _onScroll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: widget.title,
        authorization: AuthorizationModel(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.subTitle != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: Builder(
                  builder: (context) {
                    final parts = widget.subTitle!.split('|');

                    final projectName = parts.isNotEmpty ? parts[0].trim() : '';
                    final building =
                        parts.length > 1
                            ? parts[1].replaceFirst('Bldg:', '').trim()
                            : '';
                    final wing =
                        parts.length > 2
                            ? parts[2].replaceFirst('Wing:', '').trim()
                            : '';

                    return RichText(
                      text: TextSpan(
                        style: AppTextStyle.ts14R(),
                        children: [
                          TextSpan(
                            text: projectName,
                            style: AppTextStyle.ts14M(),
                          ),

                          TextSpan(
                            text: " | ",
                            style: AppTextStyle.ts14R(color: AppColor.grey),
                          ),

                          TextSpan(
                            text: "Bldg: ",
                            style: AppTextStyle.ts14R(color: AppColor.grey),
                          ),

                          TextSpan(text: building, style: AppTextStyle.ts14M()),

                          TextSpan(
                            text: " | ",
                            style: AppTextStyle.ts14R(color: AppColor.grey),
                          ),

                          TextSpan(
                            text: "Wing: ",
                            style: AppTextStyle.ts14R(color: AppColor.grey),
                          ),

                          TextSpan(text: wing, style: AppTextStyle.ts14M()),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ] else
              showSiteSelectedWidget(),
            Expanded(
              child:
                  widget.type == "Parking"
                      ? _buildParkingList()
                      : _buildUnitList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitList() {
    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (context, state) {
        if ((state.isLoading ?? false) && state.flatList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.flatList.isEmpty) {
          return Center(child: noDataWidget(message: "No units found"));
        } else {
          return ListView.builder(
            controller: scrollController,
            itemCount: state.flatList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.flatList.length) {
                return state.flatList.length < state.unitTotalRecords
                    ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }

              final flat = state.flatList[index];
              return Container(
                decoration: commonCardDecoration(),
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    buildRowTitleValue(title: "Floor", value: flat.floor),
                    buildRowTitleValue(
                      title: "Unit Number",
                      value: flat.flat,
                      singleLine: false,
                    ),
                    buildRowTitleValue(
                      title: "Unit Type",
                      value: flat.flatType,
                    ),
                    buildRowTitleValue(
                      title: "Rera Carpet Area",
                      value: flat.reraCarpetAreaSqFt.addCommas(),
                    ),
                    buildRowTitleValue(
                      title: "Unit Configuration",
                      value: flat.flatConfiguration,
                    ),
                    buildRowTitleValue(
                      title: "Unit Facing",
                      value: flat.flatFacing,
                    ),
                    buildRowTitleValue(
                      title: "Owner / Alloted / Blocked / Hold By",
                      singleLine: false,
                      value:
                          (flat.flatStatus.toLowerCase() == "blocked" ||
                                  flat.flatStatus.toLowerCase() == "hold")
                              ? "${flat.flatStatus} BY ${flat.modifiedBy} on ${formatDate(flat.modifiedDate ?? DateTime.now())}"
                              : flat.ownerName,
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildParkingList() {
    return BlocBuilder<ParkingCubit, ParkingState>(
      builder: (context, state) {
        if ((state.isLoading ?? false) && state.parkingList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.parkingList.isEmpty) {
          return Center(child: noDataWidget(message: "No parking found"));
        }

        return ListView.builder(
          itemCount: state.parkingList.length,
          itemBuilder: (context, index) {
            final parking = state.parkingList[index];

            return Container(
              decoration: commonCardDecoration(),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  buildRowTitleValue(
                    title: "Parking Number",
                    value: parking.parkingNumber,
                  ),
                  buildRowTitleValue(
                    title: "Category",
                    value: parking.parkingCategory,
                  ),
                  buildRowTitleValue(title: "Type", value: parking.parkingType),
                  buildRowTitleValue(
                    title: "Size",
                    value: parking.parkingSubType,
                  ),
                  buildRowTitleValue(
                    title: "Dimensions",
                    value: parking.parkingDimensions,
                  ),
                  buildRowTitleValue(
                    title: "EV Charging",
                    value: parking.isEVChargingAvailable ? "Yes" : "No",
                  ),
                  buildRowTitleValue(
                    title: "Owner / Alloted / Blocked / Hold By",
                    singleLine: false,
                    value:
                        (parking.parkingStatus.toLowerCase() == "blocked" ||
                                parking.parkingStatus.toLowerCase() == "hold")
                            ? "${parking.parkingStatus} BY ${parking.modifiedBy} on ${formatDate(parking.modifiedDate ?? DateTime.now())}"
                            : parking.ownerName,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
