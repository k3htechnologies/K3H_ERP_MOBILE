// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/data/model/ready_reckover_details.model.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/pages/widgets/proposed_offer_info_card.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ReadyReckonerRateDetails extends StatefulWidget {
  final int projectId;
  final int buildingId;
  final AuthorizationModel routeAuthorizationModel;
  final String buildingName;
  const ReadyReckonerRateDetails({
    super.key,
    required this.projectId,
    required this.buildingId,
    required this.routeAuthorizationModel,
    required this.buildingName,
  });

  @override
  State<ReadyReckonerRateDetails> createState() =>
      _ReadyReckonerRateDetailsState();
}

class _ReadyReckonerRateDetailsState extends State<ReadyReckonerRateDetails> {
  // CUBIT
  late ProposedOfferCubit _cubit;
  bool get disableAction => !widget.routeAuthorizationModel.isAction;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ProposedOfferCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit.pullReadyReckonerRateDetails(
        context: context,
        projectId: widget.projectId,
        buildingId: widget.buildingId,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // DIALOGUE TO DELETE RENT DETAILS
  Future<void> _showPopupToDeleteTemporaryAlternateAccommodationDetails(
    BuildContext context,
    ReadyReckonerRateDetailsModel obj,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a rent detail?',
      'Deleting this rent detail will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _cubit.deleteReadyReckonerRateDetails(
        context: context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
        proposedOfferReadyReckonerRateDetailsId:
            obj.proposedOfferReadyReckonerRateDetailsId,
        uniqueKey: obj.uniquekey,
        index: index,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Ready Reckoner Rate Details List',
                    style: AppTextStyle.ts14M(color: AppColor.grey),
                  ),
                ),
                CustomIconButton.add(
                  isDisabled: disableAction,
                  onPressed: () async {
                    goRouter.pushNamed(
                      AppRoutes.addUpdateReadyReckonerDetails,
                      queryParameters: {
                        'projectId': Uri.encodeComponent(
                          EncryptionManager.encryptData(
                            widget.projectId.toString(),
                          ),
                        ),
                        'buildingId': Uri.encodeComponent(
                          EncryptionManager.encryptData(
                            widget.buildingId.toString(),
                          ),
                        ),
                        'buildingName': Uri.encodeComponent(
                          EncryptionManager.encryptData(widget.buildingName),
                        ),
                      },
                    );
                  },
                ),
              ],
            ),
            verticalSpacing(),
            Expanded(
              child: BlocBuilder<ProposedOfferCubit, ProposedOfferState>(
                builder: (context, state) {
                  if (state.isLoading ?? true) {
                    return loader();
                  }

                  if (state.readyReckonerRateDetails.isEmpty) {
                    return Center(
                      child: noDataWidget(
                        message: 'No Ready Reckoner Details Found',
                      ),
                    );
                  }
                  return SingleChildScrollView(
                    child: Column(
                      children: List.generate(
                        state.readyReckonerRateDetails.length,
                        (index) {
                          final rent = state.readyReckonerRateDetails[index];

                          return ProposedOfferInfoCard(
                            leading: buildColumnTitleValue(
                              title: "Financial Year",
                              value: rent.financialYear,
                            ),
                            disable: disableAction,
                            onEdit: () {
                              goRouter.pushNamed(
                                AppRoutes.addUpdateReadyReckonerDetails,
                                queryParameters: {
                                  'readyReckoner': Uri.encodeComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(rent.toJson()),
                                    ),
                                  ),
                                  'index': index.toString(),
                                  'projectId': Uri.encodeComponent(
                                    EncryptionManager.encryptData(
                                      widget.projectId.toString(),
                                    ),
                                  ),
                                  'buildingId': Uri.encodeComponent(
                                    EncryptionManager.encryptData(
                                      widget.buildingId.toString(),
                                    ),
                                  ),
                                  'buildingName': Uri.encodeComponent(
                                    EncryptionManager.encryptData(
                                      widget.buildingName,
                                    ),
                                  ),
                                },
                              );
                            },
                            onDelete: () {
                              _showPopupToDeleteTemporaryAlternateAccommodationDetails(
                                context,
                                rent,
                                index,
                              );
                            },
                            child: Column(
                              spacing: 10,
                              children: [
                                Row(
                                  spacing: 10,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildColumnTitleValue(
                                      title: "Zone",
                                      value: rent.zone,
                                    ),
                                    buildColumnTitleValue(
                                      title: "Sub Zone",
                                      value: rent.subZone,
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 10,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildColumnTitleValue(
                                      title: "Effective Start Date",
                                      value: formatDateTimeAsDDMMMYYYY(
                                        rent.effectiveStartDate,
                                      ),
                                    ),
                                    buildColumnTitleValue(
                                      title: "Effective End Date",
                                      value: formatDateTimeAsDDMMMYYYY(
                                        rent.effectiveEndDate,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 10,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildColumnTitleValue(
                                      title: "Residential Rate (₹)",
                                      value:
                                          rent.residentialRate
                                              .toIndianCurrency(),
                                    ),
                                    buildColumnTitleValue(
                                      title: "Commercial Rate (₹)",
                                      value:
                                          rent.commercialRate
                                              .toIndianCurrency(),
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 10,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildColumnTitleValue(
                                      title: "Shop Rate (₹)",
                                      value: rent.shopRate.toIndianCurrency(),
                                    ),
                                    buildColumnTitleValue(
                                      title: "Industrial Rate (₹)",
                                      value:
                                          rent.industrialRate
                                              .toIndianCurrency(),
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 10,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildColumnTitleValue(
                                      title: "Land Rate (₹)",
                                      value: rent.landRate.toIndianCurrency(),
                                    ),
                                    buildColumnTitleValue(
                                      title: "Remark",
                                      value: rent.remark,
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 10,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildColumnTitleValue(
                                      title: "Last Modified By",
                                      value: rent.modifiedBy,
                                    ),
                                    buildColumnTitleValue(
                                      title: "Last Modified Date",
                                      value: formatDateTimeAsDDMMMYYYY(
                                        rent.modifiedDate,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
