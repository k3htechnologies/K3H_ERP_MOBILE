import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/business_development/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/business_development/building/data/repository/building.repository.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/card_header_tile.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProposedOfferScreen extends StatefulWidget {
  const ProposedOfferScreen({super.key});

  @override
  State<ProposedOfferScreen> createState() => _ProposedOfferScreenState();
}

class _ProposedOfferScreenState extends State<ProposedOfferScreen> {
  // CUBIT
  late ProposedOfferCubit _proposedOfferCubit;

  // PROJECT
  late ProjectModel _project;

  // PROPOSED OFFER TYPE LIST
  final List<dynamic> _proposedOfferIcons = [
    LucideIcons.building,
    AppAssets.readyReckonerIcon,
    AppAssets.carpetAreaIcon,
    AppAssets.extraCarpetAreaIcon,
    AppAssets.hardshipDetailsIcon,
    AppAssets.tempAccomAlternativeIcon,
    AppAssets.shiftingDetailsIcon,
    AppAssets.gstDetailsIcon,
    AppAssets.parkingIcon,
    AppAssets.securityDepositIcon,
    AppAssets.bankGuaranteeIcon,
    AppAssets.lienToSocietyIcon,
    AppAssets.projectCompletionIcon,
    AppAssets.additionalInfoIcon,
  ];
  final List<String> _proposedOfferTypeList = [
    "Building Overview",
    "Ready Reckoner Rate",
    "Carpet / Plot Area",
    "Extra Carpet Area",
    "Hardship Offer Details",
    "Temp Accom Alternative",
    "Shifting Details",
    "GST on Existing + Free Area",
    "Parking Allotment",
    "Security Deposit",
    "Bank Guarantee",
    "Lien to Society Details",
    "Project Completion",
    "Additional Information",
  ];

  // BUILDING SELECTION
  final ValueNotifier<List<Map<String, dynamic>>> _selectedBuildingNotifier =
      ValueNotifier([]);

  // BUILDING REPOSITORY
  final BuildingRepository _buildingRepository =
      serviceLocator<BuildingRepository>();
  late AuthorizationModel _routeAuthorizationModel;

  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.proposedOffer]!;
    _project = getProject();
    _proposedOfferCubit = context.read<ProposedOfferCubit>();
  }

  Future<Map<String, dynamic>> _fetchBuildings(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _buildingRepository.pullBuilding(
      pageNumber: pageNumber,
      pageSize: 15,
      projectId: _project.projectId,
      queryParams:
          value != null && value.isNotEmpty
              ? {"BuildingName": value, "isCheckPermission": false}
              : {"isCheckPermission": false},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final project =
            response['data'] as List<BusinessDevelopmentBuildingModel>;

        return {
          "itemList":
              project.map((pr) {
                return {
                  "zAttributesId": pr.buildingId,
                  "DisplayName": pr.buildingName,
                  "building": pr,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  void _showGeneratePDFConfirmation() async {
    if (_project.projectId == 0) {
      showErrorMessage(context, "Error", "Please Select a Project");
      return;
    }
    if (_selectedBuildingNotifier.value.isEmpty) {
      showErrorMessage(context, "Error", "Please Select a building");
      return;
    }
    final generatePDf = await DialogHelper.showConfirmationDialog(
      context: context,
      title: 'Generate PDF',
      message: 'Are you sure you want to generate the PDF?',
      confirmText: "Generate",
    );
    if (generatePDf && mounted) {
      _proposedOfferCubit.exportPdf(
        context,
        buildingId: _selectedBuildingNotifier.value.first['zAttributesId'],
        projectId: _project.projectId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Proposed Offer",
        isMenuButton: true,
        authorization: _routeAuthorizationModel,
        onProjectChangeCallback: (value) {
          _project = value;
          _selectedBuildingNotifier.value = [];
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: _selectedBuildingNotifier,
              builder: (context, selectedBuilding, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      verticalSpacing(),
                      showSiteSelectedWidget(projectName: _project.projectName),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          Expanded(
                            child: CustomMultipleSelectPopup(
                              title: "Building",
                              isRequired: true,
                              isMultiSelect: false,
                              initialValue: selectedBuilding,
                              hintText: "Select Building",
                              dataList: const [],
                              onClear: () {
                                _selectedBuildingNotifier.value = [];
                                _proposedOfferCubit.updateBuildingDetails(
                                  null,
                                  clearBuildingDetails: true,
                                );
                              },
                              onSelected: (value) async {
                                _selectedBuildingNotifier.value = value;

                                _proposedOfferCubit.updateBuildingDetails(
                                  value.first['building'],
                                );
                              },
                              dataFetchCallBack: _fetchBuildings,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Building is required";
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 24.h),
                            child: CustomIconButton(
                              size: 30,
                              icon: Icon(
                                Icons.picture_as_pdf,
                                color:
                                    _routeAuthorizationModel.isAction
                                        ? AppColor.primary
                                        : AppColor.grey2,
                                size: 24,
                              ),
                              isDisable: !_routeAuthorizationModel.isAction,
                              onPressed: _showGeneratePDFConfirmation,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                shrinkWrap: true,
                itemCount: _proposedOfferTypeList.length,
                itemBuilder: (_, index) {
                  return GestureDetector(
                    onTap: () {
                      if (_selectedBuildingNotifier.value.isNotEmpty) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        goRouter.pushNamed(
                          AppRoutes.proposedOfferSecondaryScreen,
                          queryParameters: {
                            "type": _proposedOfferTypeList[index],
                            "buildingId":
                                _selectedBuildingNotifier
                                    .value
                                    .first['zAttributesId']
                                    .toString(),
                            "projectId": _project.projectId.toString(),
                            "projectName": _project.projectName,
                            "buildingName":
                                _selectedBuildingNotifier
                                    .value
                                    .first['DisplayName']
                                    .toString(),
                          },
                        );
                      } else {
                        if (_project.projectId == 0) {
                          showErrorMessage(
                            context,
                            "Error",
                            "Please Select a Project",
                          );
                          return;
                        }
                        showErrorMessage(
                          context,
                          "Error",
                          "Please select building",
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: CardHeaderTile(
                              icon: index == 0 ? LucideIcons.building2 : null,
                              svgIcon:
                                  index == 0
                                      ? null
                                      : _proposedOfferIcons[index],
                              title: _proposedOfferTypeList[index],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.grey.shade600,
                            size: 22,
                          ),
                        ],
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
