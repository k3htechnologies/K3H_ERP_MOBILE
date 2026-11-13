import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/cubit/utils_cubit.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/features/business_development/tenant/data/model/tenant.model.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/approve_reject_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/expansion_tile/custom_expansion_tile.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class UnitDetailsCard extends StatefulWidget {
  final List<TenantModel> flats;
  final UtilsCubit utilsCubit;

  const UnitDetailsCard({
    super.key,
    required this.flats,
    required this.utilsCubit,
  });

  @override
  State<UnitDetailsCard> createState() => _UnitDetailsCardState();
}

class _UnitDetailsCardState extends State<UnitDetailsCard> {
  final ValueNotifier<bool> _isExpanded = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isExpanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assignedFlats = widget.flats;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: AppColor.primary, width: 4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: CustomExpandableCard(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        decoration: BoxDecoration(color: AppColor.white),
        onExpansionChanged: (expanded) => _isExpanded.value = expanded,
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "New Unit Details (${assignedFlats.length})",
              style: AppTextStyle.ts14M(),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<bool>(
              valueListenable: _isExpanded,
              builder: (context, expanded, _) {
                return AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child:
                      expanded
                          ? const SizedBox(width: double.infinity)
                          : Wrap(
                            spacing: 4.5,
                            runSpacing: 6,
                            children:
                                assignedFlats.map((f) {
                                  final s = flatStatusStyle(f);
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: s.bg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${f.flat} • ${s.label}',
                                      style: AppTextStyle.ts12M(color: s.fg),
                                    ),
                                  );
                                }).toList(),
                          ),
                );
              },
            ),
          ],
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: assignedFlats.length,
            separatorBuilder: (context, index) => verticalSpacing(),
            itemBuilder: (context, index) {
              final flat = assignedFlats[index];

              return FlatTile(flat: flat, utilsCubit: widget.utilsCubit);
            },
          ),
        ),
      ),
    );
  }
}

class FlatTile extends StatelessWidget {
  final TenantModel flat;
  final UtilsCubit utilsCubit;
  const FlatTile({super.key, required this.flat, required this.utilsCubit});

  @override
  Widget build(BuildContext context) {
    final s = flatStatusStyle(flat);
    final isBooked = flat.bookingId != 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CustomIconContainer(
                    containerSize: 32,
                    iconSize: 18,
                    backgroundColor: s.bg,
                    iconColor: s.fg,
                    icon:
                        isBooked
                            ? LucideIcons.userRound
                            : LucideIcons.circleCheck,
                  ),
                  if (isBooked)
                    Positioned(
                      bottom: 2,
                      right: 3,
                      child: Icon(
                        Icons.home,
                        size: 14,
                        color: AppColor.rustOrange,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(flat.flat, style: AppTextStyle.ts14M())),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: s.bg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(s.label, style: AppTextStyle.ts12M(color: s.fg)),
              ),
            ],
          ),
          Row(
            children: [
              buildColumnTitleValue(
                title: "Building",
                value: flat.buildingNumber,
                titleTextStyle: AppTextStyle.ts12M(color: AppColor.grey),
                valueTextStyle: AppTextStyle.ts12M(color: AppColor.black),
              ),
              buildColumnTitleValue(
                title: "Status",
                value: flat.bookingId != 0 ? "Booking Done" : "-",
                titleTextStyle: AppTextStyle.ts12M(color: AppColor.grey),
                customValueWidget: GestureDetector(
                  onTap: () {
                    goRouter.pushNamed(
                      AppRoutes.viewTenantBooking,
                      queryParameters: {
                        "bookingId": Uri.encodeQueryComponent(
                          EncryptionManager.encryptData(
                            flat.bookingId.toString(),
                          ),
                        ),
                        "projectId": Uri.encodeQueryComponent(
                          EncryptionManager.encryptData(
                            flat.projectId.toString(),
                          ),
                        ),
                      },
                    );
                  },
                  child: Text(
                    flat.bookingId != 0 ? "Booking Done" : "-",
                    style: AppTextStyle.ts12M(
                      color: flat.bookingId != 0 ? AppColor.primary : null,
                    ).copyWith(
                      decorationColor:
                          flat.bookingId != 0 ? AppColor.primary : null,
                      decoration:
                          flat.bookingId != 0
                              ? TextDecoration.underline
                              : TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          ApproveRejectWidget(
            isMaster: true,
            actionTitle: flat.bookingApprovalStatus,
            customWidget: buildColumnTitleValue(
              title: "Booking Approval Status",
              value: flat.buildingNumber,
              removeExpanded: true,
              titleTextStyle: AppTextStyle.ts12M(color: AppColor.grey),
              valueTextStyle: AppTextStyle.ts12M(color: AppColor.black),
              customValueWidget: approvalStatusWidget(
                flat.bookingApprovalStatus,
              ),
            ),
            showApproval: false,
            onApprove: (value) {},
            onReject: (value) {},
            onThirdTap:
                flat.bookingApprovalStatus.trim().isEmpty
                    ? null
                    : () async {
                      final approvalLogHistoryList = await utilsCubit
                          .getApprovalLogHistory(
                            context: context,
                            projectId: flat.projectId,
                            id: flat.bookingId,
                            moduleName: "TENANT BOOKING APPROVAL",
                          );

                      if (context.mounted) {
                        goRouter.pushNamed(
                          AppRoutes.approvalLogHistory,
                          queryParameters: {
                            "subTitle": Uri.encodeComponent(
                              EncryptionManager.encryptData(
                                "${flat.applicantName} ${flat.flat.isNotEmpty ? " > ${flat.flat}" : ""}",
                              ),
                            ),
                            "title": Uri.encodeComponent(
                              EncryptionManager.encryptData(
                                "Booking Log History",
                              ),
                            ),
                            "approvalList": Uri.encodeComponent(
                              EncryptionManager.encryptData(
                                jsonEncode(
                                  approvalLogHistoryList
                                      .map((e) => e.toJson())
                                      .toList(),
                                ),
                              ),
                            ),
                          },
                        );
                      }
                    },
            popupTitle: '',
          ),
        ],
      ),
    );
  }
}

/// Shared status style for a unit (label + colors)
({Color bg, Color fg, String label}) flatStatusStyle(TenantModel flat) {
  final isBooked = flat.bookingId != 0;
  final isAllotted = flat.inventoryFlatId != 0 && !isBooked;
  return (
    label:
        isBooked
            ? 'Booked'
            : isAllotted
            ? 'Allotted'
            : 'Pending',
    fg:
        isBooked
            ? AppColor.green20
            : isAllotted
            ? AppColor.purple700
            : AppColor.grey,
    bg:
        isBooked
            ? const Color(0xffDCFCE7)
            : isAllotted
            ? AppColor.lightPurpleBg2
            : Colors.grey.shade100,
  );
}
