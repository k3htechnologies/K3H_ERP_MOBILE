// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/temporary_accomodation_alternative_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/features/redevelopment/widgets/common_redevelopment_widgets.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class TemporaryAccommodationAlternativeDetails extends StatefulWidget {
  final int projectId;
  final int buildingId;
  final String buildingName;
  final AuthorizationModel routeAuthorizationModel;

  const TemporaryAccommodationAlternativeDetails({
    super.key,
    required this.projectId,
    required this.buildingId,
    required this.routeAuthorizationModel,
    required this.buildingName,
  });

  @override
  State<TemporaryAccommodationAlternativeDetails> createState() =>
      _TemporaryAccommodationAlternativeDetailsState();
}

class _TemporaryAccommodationAlternativeDetailsState
    extends State<TemporaryAccommodationAlternativeDetails> {
  // CUBIT
  late ProposedOfferCubit _cubit;
  bool get disableAction => !widget.routeAuthorizationModel.isAction;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ProposedOfferCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit.pullTemporaryAccommodationAlternativeDetails(
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
  Future<void> _showPopupToDeleteTemporaryAccommodationAlternativeDetails(
    BuildContext context,
    TemporaryAlternativeAccommodationDetailsModel obj,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a rent detail?',
      'Deleting this rent detail will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _cubit.deleteRentDetails(
        context: context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
        proposedOfferTemporaryAccommodationAlternativeDetailsId:
            obj.proposedOfferTemporaryAlternateAccommodationDetailsId,
        uniqueKey: obj.uniquekey,
        index: index,
      );
    }
  }

  void _showGeneratePDFConfirmation({
    required TemporaryAlternativeAccommodationDetailsModel rent,
  }) async {
    final generatePDf = await DialogHelper.showConfirmationDialog(
      context: context,
      title: 'Are sure you want generate TAA?',
      message:
          'Once the Temporary Accommodation Alternative is generated, it cannot be deleted',
      confirmText: "Generate",
    );
    if (generatePDf && mounted) {
      _cubit.generateProposedOffer(
        context,
        buildingId: rent.buildingId,
        projectId: rent.projectId,
        isAdditionalTemporaryAlternateAccommodation:
            rent.isAdditionalTemporaryAlternateAccommodation,
        chargeType: 'TAA',
        tenure: rent.tenure,
        isPayBrokerage: rent.isPayBrokerage,
      );
    }
  }

  bool shouldShowGenerateButton(
    TemporaryAlternativeAccommodationDetailsModel current,
    List<TemporaryAlternativeAccommodationDetailsModel> list,
  ) {
    // First row of this tenure
    final firstItem = list.firstWhere((e) => e.tenure == current.tenure);

    // Show button only on first row
    if (!identical(firstItem, current)) {
      return false;
    }

    // Get all items of this tenure
    final tenureItems = list.where((e) => e.tenure == current.tenure);

    // If ANY item in this tenure has missing dates, hide Generate
    final hasMissingDates = tenureItems.any(
      (e) =>
          e.temporaryAlternateAccommodationStartDate == null ||
          e.temporaryAlternateAccommodationEndDate == null,
    );

    if (hasMissingDates) {
      return false;
    }

    return true;
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
                    'Temporary Accommodation Alternative Details List',
                    style: AppTextStyle.ts14M(color: AppColor.grey),
                  ),
                ),
                CustomIconButton.add(
                  isDisabled: disableAction,
                  onPressed: () async {
                    goRouter.pushNamed(
                      AppRoutes
                          .addUpdateTemporaryAccommodationAlternativeDetails,
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

                  if (state.temporaryAccommodationAlternativeDetails.isEmpty) {
                    return Center(
                      child: noDataWidget(message: 'No TAA Details Found'),
                    );
                  }
                  return SingleChildScrollView(
                    child: Column(
                      children: List.generate(
                        state.temporaryAccommodationAlternativeDetails.length,
                        (index) {
                          final rent =
                              state
                                  .temporaryAccommodationAlternativeDetails[index];

                          return ProposedOfferInfoCard(
                            title:
                                rent.tenure.isNotEmpty
                                    ? rent.tenure
                                    : 'Additional TAA',
                            tag: rent.type,
                            disable: disableAction,
                            onEdit: () {
                              goRouter.pushNamed(
                                AppRoutes
                                    .addUpdateTemporaryAccommodationAlternativeDetails,
                                queryParameters: {
                                  'rent': Uri.encodeComponent(
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
                              _showPopupToDeleteTemporaryAccommodationAlternativeDetails(
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
                                      title: "Amount",
                                      value: (rent.amount).toIndianCurrency(),
                                    ),
                                    buildColumnTitleValue(
                                      title: "Unit / SqFt / Lumsum",
                                      value: rent.unitSqFtLumsum,
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 10,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildColumnTitleValue(
                                      title: "Carpet Area (SqFt)",
                                      value: rent.carpetAreaSqFt.toString(),
                                    ),
                                    buildColumnTitleValue(
                                      title: "TAA Start Date",
                                      value: formatDateTimeAsDDMMMYYYY(
                                        rent.temporaryAlternateAccommodationStartDate,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 10,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildColumnTitleValue(
                                      title: "TAA End Date",
                                      value: formatDateTimeAsDDMMMYYYY(
                                        rent.temporaryAlternateAccommodationEndDate,
                                      ),
                                    ),
                                    buildColumnTitleValue(
                                      title: "Additional TAA",
                                      value:
                                          rent.isAdditionalTemporaryAlternateAccommodation
                                              ? 'Yes'
                                              : 'No',
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 10,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildColumnTitleValue(
                                      title: "Pay Brokerage",
                                      value:
                                          rent.isPayBrokerage == true
                                              ? 'Yes'
                                              : 'No',
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          top: 12.0,
                                        ),
                                        child: Visibility(
                                          visible: shouldShowGenerateButton(
                                            rent,
                                            state
                                                .temporaryAccommodationAlternativeDetails,
                                          ),
                                          child: CustomButton(
                                            text: "Generate",
                                            isDisable: disableAction,
                                            onPressed: () {
                                              _showGeneratePDFConfirmation(
                                                rent: rent,
                                              );
                                            },
                                          ),
                                        ),
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
