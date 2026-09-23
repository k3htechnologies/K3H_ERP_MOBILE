// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/data/model/temporary_accomodation_alternative_details.model.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/pages/widgets/proposed_offer_info_card.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
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
    extends State<TemporaryAccommodationAlternativeDetails>
    with TickerProviderStateMixin {
  late final ProposedOfferCubit _cubit;
  TabController? _tabController;

  bool get disableAction => !widget.routeAuthorizationModel.isAction;

  String _encryptParam(String value) =>
      Uri.encodeComponent(EncryptionManager.encryptData(value));

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
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _showPopupToDeleteTemporaryAlternateAccommodationDetails(
    BuildContext context,
    TemporaryAlternativeAccommodationDetailsModel obj,
    int index,
  ) async {
    final result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a TAA detail?',
      'Deleting this TAA detail will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _cubit.deleteTemporaryAlternateAccommodationDetails(
        context: context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
        proposedOfferTemporaryAlternateAccommodationDetailsId:
            obj.proposedOfferTemporaryAlternateAccommodationDetailsId,
        uniqueKey: obj.uniquekey,
        index: index,
      );
    }
  }

  Future<void> _showGeneratePDFConfirmation({
    required TemporaryAlternativeAccommodationDetailsModel rent,
  }) async {
    final generatePdf = await DialogHelper.showConfirmationDialog(
      context: context,
      title: 'Are sure you want generate TAA?',
      message:
          'Once the Temporary Accommodation Alternative is generated, it cannot be deleted',
      confirmText: "Generate",
    );
    if (generatePdf && mounted) {
      _cubit.generateProposedOffer(
        context,
        buildingId: rent.buildingId,
        projectId: rent.projectId,
        isAdditionalTemporaryAlternateAccommodation:
            rent.isAdditionalTemporaryAlternateAccommodation,
        chargeType: 'TAA',
        tenure: rent.tenure,
        isPayBrokerage: rent.isPayBrokerage,
        isPayTAA: rent.isPayTAA,
      );
    }
  }

  bool shouldShowGenerateButton(
    TemporaryAlternativeAccommodationDetailsModel current,
    List<TemporaryAlternativeAccommodationDetailsModel> list,
  ) {
    final tenureItems =
        list.where((e) {
          if (current.tenure.isEmpty) return e.tenure.isEmpty;
          return e.tenure == current.tenure;
        }).toList();

    if (tenureItems.isEmpty) return false;
    if (!identical(tenureItems.first, current)) return false;

    final hasMissingDates = tenureItems.any(
      (e) =>
          e.temporaryAlternateAccommodationStartDate == null ||
          e.temporaryAlternateAccommodationEndDate == null,
    );
    return !hasMissingDates;
  }

  Future<void> _handleAdd() async {
    final previousIds =
        _cubit.state.temporaryAccommodationAlternativeDetails
            .map((e) => e.proposedOfferTemporaryAlternateAccommodationDetailsId)
            .toSet();

    await goRouter.pushNamed(
      AppRoutes.addUpdateTemporaryAccommodationAlternativeDetails,
      queryParameters: {
        'projectId': _encryptParam(widget.projectId.toString()),
        'buildingId': _encryptParam(widget.buildingId.toString()),
        'buildingName': _encryptParam(widget.buildingName),
      },
    );

    if (!mounted) return;

    // addTemporaryAccommodationAlternativeDetails() triggers a background
    // refresh (pullTemporaryAccommodationAlternativeDetails) that isn't
    // awaited internally, so wait for that refresh to land.
    var latestState = _cubit.state;
    if (latestState.isLoading ?? false) {
      latestState = await _cubit.stream.firstWhere(
        (s) => !(s.isLoading ?? false),
      );
    }

    if (!mounted) return;

    final newList = latestState.temporaryAccommodationAlternativeDetails;
    final addedItems =
        newList
            .where(
              (e) =>
                  !previousIds.contains(
                    e.proposedOfferTemporaryAlternateAccommodationDetailsId,
                  ),
            )
            .toList();

    if (addedItems.isEmpty) return;

    final addedTenure =
        addedItems.first.tenure.isNotEmpty
            ? addedItems.first.tenure
            : "Additional TAA";
    final tenures = latestState.temporaryAccommodationTenures;

    // Wait one frame so BlocListener has already rebuilt _tabController
    // with the correct tab count before we try to animate to it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final tabIndex = tenures.indexOf(addedTenure);
      if (tabIndex != -1 &&
          _tabController != null &&
          tabIndex < _tabController!.length) {
        _tabController!.animateTo(tabIndex);
      }
    });
  }

  Future<void> _handleUpdate(
    TemporaryAlternativeAccommodationDetailsModel rent,
    int originalIndex,
  ) async {
    await goRouter.pushNamed(
      AppRoutes.addUpdateTemporaryAccommodationAlternativeDetails,
      queryParameters: {
        'rent': _encryptParam(jsonEncode(rent.toJson())),
        'index': originalIndex.toString(),
        'projectId': _encryptParam(widget.projectId.toString()),
        'buildingId': _encryptParam(widget.buildingId.toString()),
        'buildingName': _encryptParam(widget.buildingName),
      },
    );

    if (!mounted) return;

    final currentState = _cubit.state;
    final list = currentState.temporaryAccommodationAlternativeDetails;

    if (originalIndex >= list.length) return;

    final updatedTenure =
        list[originalIndex].tenure.isNotEmpty
            ? list[originalIndex].tenure
            : "Additional TAA";

    final tabIndex = currentState.temporaryAccommodationTenures.indexOf(
      updatedTenure,
    );

    if (tabIndex != -1 &&
        _tabController != null &&
        tabIndex < _tabController!.length) {
      _tabController!.animateTo(tabIndex);
    }
  }

  void _onTenuresChanged(ProposedOfferState state) {
    final tenures = state.temporaryAccommodationTenures;

    if (tenures.isEmpty) {
      _tabController?.dispose();
      _tabController = null;
      return;
    }

    final currentIndex = _tabController?.index ?? 0;
    _tabController?.dispose();
    _tabController = TabController(
      length: tenures.length,
      vsync: this,
      initialIndex: currentIndex < tenures.length ? currentIndex : 0,
    );
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
                    'Temporary Alternative Accommodation List',
                    style: AppTextStyle.ts14M(color: AppColor.grey),
                  ),
                ),
                CustomIconButton.add(
                  isDisabled: disableAction,
                  onPressed: () => _handleAdd(),
                ),
              ],
            ),
            verticalSpacing(),
            Expanded(
              child: BlocListener<ProposedOfferCubit, ProposedOfferState>(
                listenWhen:
                    (previous, current) =>
                        previous.temporaryAccommodationTenures !=
                        current.temporaryAccommodationTenures,
                listener: (context, state) => _onTenuresChanged(state),
                child: BlocBuilder<ProposedOfferCubit, ProposedOfferState>(
                  builder: (context, state) {
                    if (state.isLoading ?? true) {
                      return loader();
                    }
                    if (state
                        .temporaryAccommodationAlternativeDetails
                        .isEmpty) {
                      return Center(
                        child: noDataWidget(message: 'No TAA Details Found'),
                      );
                    }

                    final allDetails =
                        state.temporaryAccommodationAlternativeDetails;
                    final tenures = state.temporaryAccommodationTenures;

                    if (_tabController == null ||
                        _tabController!.length != tenures.length) {
                      return loader();
                    }

                    return Column(
                      children: [
                        ChipStyleTabBar(
                          controller: _tabController!,
                          tabs: tenures,
                          margin: EdgeInsets.zero,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _buildGenerateButton(tenures, allDetails),
                                ],
                              ),
                              Expanded(
                                child: _buildTabView(tenures, allDetails),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton(
    List<String> tenures,
    List<TemporaryAlternativeAccommodationDetailsModel> allDetails,
  ) {
    return ValueListenableBuilder(
      valueListenable: _tabController!.animation!,
      builder: (_, __, ___) {
        final selectedTenure = tenures[_tabController!.index];
        final filteredList =
            allDetails.where((e) {
              if (selectedTenure == "Additional TAA") return e.tenure.isEmpty;
              return e.tenure == selectedTenure;
            }).toList();
        final rent = filteredList.isNotEmpty ? filteredList.first : null;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Visibility(
            visible: rent != null && shouldShowGenerateButton(rent, allDetails),
            child: CustomButton(
              text: "Generate",
              isDisable: disableAction,
              onPressed: () {
                if (rent != null) {
                  _showGeneratePDFConfirmation(rent: rent);
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailCard(
    TemporaryAlternativeAccommodationDetailsModel rent,
    int originalIndex,
  ) {
    return ProposedOfferInfoCard(
      title: rent.tenure.isNotEmpty ? rent.tenure : 'Additional TAA',
      tag: rent.type,
      disable: disableAction,
      onEdit: () => _handleUpdate(rent, originalIndex),
      onDelete:
          () => _showPopupToDeleteTemporaryAlternateAccommodationDetails(
            context,
            rent,
            originalIndex,
          ),
      child: Column(
        spacing: 10,
        children: [
          Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Amount",
                value: rent.amount.toIndianCurrency(),
              ),
              buildColumnTitleValue(
                title: "Unit / SqFt / Lumpsum",
                value: rent.unitSqFtLumsum,
              ),
            ],
          ),
          Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "TAA Start Date",
                value: formatDateTimeAsDDMMMYYYY(
                  rent.temporaryAlternateAccommodationStartDate,
                ),
              ),
              buildColumnTitleValue(
                title: "TAA End Date",
                value: formatDateTimeAsDDMMMYYYY(
                  rent.temporaryAlternateAccommodationEndDate,
                ),
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
                title: "Additional TAA",
                value:
                    rent.isAdditionalTemporaryAlternateAccommodation
                        ? "Yes"
                        : "No",
              ),
            ],
          ),
          Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Pay Brokerage",
                value: rent.isPayBrokerage ? "Yes" : "No",
              ),
              buildColumnTitleValue(
                title: "Pay TAA",
                value: rent.isPayTAA ? "Yes" : "No",
              ),
            ],
          ),
          Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Last Modified By",
                value:
                    rent.modifiedBy.isEmpty ? rent.createdBy : rent.modifiedBy,
              ),
              buildColumnTitleValue(
                title: "Last Modified Date",
                value: formatDateTimeAsDDMMMYYYY(
                  rent.modifiedDate ?? rent.createdDate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabView(
    List<String> tenures,
    List<TemporaryAlternativeAccommodationDetailsModel> allDetails,
  ) {
    return TabBarView(
      controller: _tabController,
      children:
          tenures.map((tenure) {
            final filteredList =
                allDetails.where((e) {
                  if (tenure == "Additional TAA") return e.tenure.isEmpty;
                  return e.tenure == tenure;
                }).toList();

            return ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final rent = filteredList[index];
                final originalIndex = allDetails.indexOf(rent);
                return _buildDetailCard(rent, originalIndex);
              },
            );
          }).toList(),
    );
  }
}
