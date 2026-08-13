import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/booking_applicant_modification_request.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/flat_alteration_requests.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/cubit/request_management_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ActivityTabScreen extends StatefulWidget {
  final int bookingId;
  final int projectId;

  const ActivityTabScreen({
    super.key,
    required this.bookingId,
    required this.projectId,
  });

  @override
  State<ActivityTabScreen> createState() => _ActivityTabScreenState();
}

class _ActivityTabScreenState extends State<ActivityTabScreen> {
  late RequestManagementCubit _requestManagementCubit;
  final ValueNotifier<bool> isBookingApplicantHistoryExpanded = ValueNotifier(
    false,
  );
  final ValueNotifier<bool> isParkingHistoryExpanded = ValueNotifier(false);
  final ValueNotifier<bool> isUnitModulationCustomizationHistoryExpanded =
      ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _requestManagementCubit = context.read<RequestManagementCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestManagementCubit, RequestManagementState>(
      builder: (context, state) {
        if (state.isLoading ?? false) {
          return Center(child: loader());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: isBookingApplicantHistoryExpanded,
                builder: (context, expanded, child) {
                  return ExpansionTile(
                    initiallyExpanded: expanded,
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12,
                    ),
                    childrenPadding: EdgeInsets.zero,
                    backgroundColor: AppColor.white,
                    collapsedBackgroundColor: AppColor.white,
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    iconColor: AppColor.black,
                    collapsedIconColor: AppColor.black,
                    shape: const Border(),
                    collapsedShape: const Border(),
                    onExpansionChanged: (expanded) async {
                      isBookingApplicantHistoryExpanded.value = expanded;
                      if (!expanded) return;
                      await _requestManagementCubit
                          .getBookingApplicantModificationActivitytList(
                            context,
                            10,
                            1,
                            widget.bookingId,
                            widget.projectId,
                          );
                    },
                    title: Text(
                      "Booking Applicant History",
                      style: AppTextStyle.ts14M(),
                    ),
                    children: [_buildBookingApplicantHistoryWidget(state)],
                  );
                },
              ),
              // PARKING
              ValueListenableBuilder<bool>(
                valueListenable: isParkingHistoryExpanded,
                builder: (context, parkingExpanded, child) {
                  return ExpansionTile(
                    initiallyExpanded: parkingExpanded,
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12,
                    ),
                    childrenPadding: EdgeInsets.zero,
                    backgroundColor: AppColor.white,
                    collapsedBackgroundColor: AppColor.white,
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    iconColor: AppColor.black,
                    collapsedIconColor: AppColor.black,
                    shape: const Border(),
                    collapsedShape: const Border(),
                    onExpansionChanged: (parkingExpanded) async {
                      isParkingHistoryExpanded.value = parkingExpanded;
                      if (!parkingExpanded) return;
                      await _requestManagementCubit
                          .getParkingModificationActivityList(
                            context,
                            10,
                            1,
                            widget.bookingId,
                            widget.projectId,
                          );
                    },
                    title: Text("Parking History", style: AppTextStyle.ts14M()),
                    children: [_buildParkingHistoryWidget(state)],
                  );
                },
              ),
              ValueListenableBuilder<bool>(
                valueListenable: isUnitModulationCustomizationHistoryExpanded,
                builder: (context, unitExpanded, child) {
                  return ExpansionTile(
                    initiallyExpanded: unitExpanded,
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12,
                    ),
                    childrenPadding: EdgeInsets.zero,
                    backgroundColor: AppColor.white,
                    collapsedBackgroundColor: AppColor.white,
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    iconColor: AppColor.black,
                    collapsedIconColor: AppColor.black,
                    shape: const Border(),
                    collapsedShape: const Border(),
                    onExpansionChanged: (unitExpanded) async {
                      isUnitModulationCustomizationHistoryExpanded.value =
                          unitExpanded;
                      if (!unitExpanded) return;
                      await _requestManagementCubit
                          .getFlatAlterationActivityList(
                            context,
                            10,
                            1,
                            widget.bookingId,
                            widget.projectId,
                          );
                    },
                    title: Text(
                      "Unit / Modulation / Customization History",
                      style: AppTextStyle.ts14M(),
                    ),
                    children: [
                      _buildUnitModulationCustomizationHistoryWidget(state),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookingApplicantHistoryWidget(RequestManagementState state) {
    final groupedHistory =
        <String, List<BookingApplicantModificationRequestModel>>{};

    for (final item in state.bookingApplicantModificationRequestModel) {
      groupedHistory.putIfAbsent(item.versionNumber, () => []).add(item);
    }

    final versions = groupedHistory.entries.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.bookingApplicantModificationRequestModel.isEmpty) ...{
          Center(
            child: Center(
              child: noDataWidget(
                message: "No applicant history found",
                iconSize: 160.0,
              ),
            ),
          ),
        } else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: versions.length,
            itemBuilder: (context, index) {
              final version = versions[index];
              return GestureDetector(
                onTap: () {
                  goRouter.pushNamed(
                    AppRoutes.viewVersionWiseBookingApplicantHistory,
                    extra: {
                      "applicants": version.value,
                      "version": version.key,
                    },
                  );
                },
                child: ListTile(
                  title: Text(
                    "Version ${version.key}",
                    style: AppTextStyle.ts14M(color: AppColor.primary).copyWith(
                      decoration: TextDecoration.underline,
                      decorationColor: AppColor.primary,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColor.primary,
                    size: 18.0,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildParkingHistoryWidget(RequestManagementState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.parkingModificationRequestList.isEmpty) ...{
          Center(
            child: Center(
              child: noDataWidget(
                message: "No parking history found",
                iconSize: 160.0,
              ),
            ),
          ),
        } else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: state.parkingModificationRequestList.length,
            itemBuilder: (context, index) {
              final parkingDetail = state.parkingModificationRequestList[index];
              return GestureDetector(
                onTap: () {
                  goRouter.pushNamed(
                    AppRoutes.viewVersionWiseParkingHistory,
                    extra: {"parking": parkingDetail},
                  );
                },
                child: ListTile(
                  title: Text(
                    "Version ${parkingDetail.versionNumber}",
                    style: AppTextStyle.ts14M(color: AppColor.primary).copyWith(
                      decoration: TextDecoration.underline,
                      decorationColor: AppColor.primary,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColor.primary,
                    size: 18.0,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildUnitModulationCustomizationHistoryWidget(
    RequestManagementState state,
  ) {
    final groupedHistory = <String, List<FlatAlterationRequestsModel>>{};

    for (final item in state.flatAlterationRequestsModel) {
      groupedHistory.putIfAbsent(item.versionNumber, () => []).add(item);
    }

    final versions =
        groupedHistory.entries.toList()..sort((a, b) {
          final versionA = int.tryParse(a.key) ?? 0;
          final versionB = int.tryParse(b.key) ?? 0;

          return versionB.compareTo(versionA);
        });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.flatAlterationRequestsModel.isEmpty) ...{
          Center(
            child: noDataWidget(
              message: "No flat alteration history found",
              iconSize: 160.0,
            ),
          ),
        } else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: versions.length,
            itemBuilder: (context, index) {
              final version = versions[index];

              return GestureDetector(
                onTap: () {
                  goRouter.pushNamed(
                    AppRoutes.viewUnitModulationCustomizationHistory,
                    extra: {
                      "unitModulationCustomization": version.value,
                      "version": version.key,
                    },
                  );
                },
                child: ListTile(
                  title: Text(
                    "Version ${version.key}",
                    style: AppTextStyle.ts14M(color: AppColor.primary).copyWith(
                      decoration: TextDecoration.underline,
                      decorationColor: AppColor.primary,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColor.primary,
                    size: 18.0,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
