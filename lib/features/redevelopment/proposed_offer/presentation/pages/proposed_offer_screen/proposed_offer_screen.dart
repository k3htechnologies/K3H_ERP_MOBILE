import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/features/redevelopment/widgets/common_redevelopment_widgets.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

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
  // Add this list
  final List<String> _proposedOfferIcons = [
    AppAssets.extraCarpetAreaIcon,
    AppAssets.corpusDetailsIcon,
    AppAssets.securityDepositIcon,
    AppAssets.shiftingDetailsIcon,
    AppAssets.lienToSocietyIcon,
    AppAssets.parkingIcon,
    AppAssets.gstDetailsIcon,
    AppAssets.projectCompletionIcon,
    AppAssets.rentDetailsIcon,
    AppAssets.readyReckonerIcon,
    AppAssets.carpetAreaIcon,
    AppAssets.additionalInfoIcon,
    AppAssets.plotAreaIcon,
    AppAssets.bankGuaranteeIcon,
  ];
  final List<String> _proposedOfferTypeList = [
    "Extra Carpet Area",
    "Hardship Details",
    "Security Deposit",
    "Shifting Details",
    "Lien to Society Details",
    "Parking Allotment",
    "GST on Existing + Free Area",
    "Project Completion",
    "Rent Details",
    "Ready Reckoner",
    "Carpet Area",
    "Additional Information",
    "Plot Area",
    "Bank Guarantee",
  ];

  // BUILDING SELECTION
  final ValueNotifier<List<Map<String, dynamic>>> _selectedBuildingNotifier =
      ValueNotifier([]);

  // FLAGS TO PREVENT INFINITE CALLS
  int? _lastFetchedBuildingId;

  @override
  void initState() {
    super.initState();
    _project = getProject();
    _proposedOfferCubit = context.read<ProposedOfferCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadBuildingsForProject(_project.projectId);
      }
    });
  }

  Future<Map<String, dynamic>> _fetchBuildings(
    int pageNumber, {
    String? value,
  }) async {
    final buildingList =
        _proposedOfferCubit.state.buildingList
            .where((b) => b.projectId == _project.projectId)
            .toList();

    final totalCount = _proposedOfferCubit.state.buildingTotalCount;

    final pageSize = 12;

    //  SEARCH MODE
    if (value != null && value.isNotEmpty) {
      final filteredBuildings =
          buildingList
              .where(
                (building) => building.buildingName.toLowerCase().contains(
                  value.toLowerCase(),
                ),
              )
              .toList();

      final Map<int, Map<String, dynamic>> uniqueFiltered = {};

      for (final b in filteredBuildings) {
        uniqueFiltered[b.buildingId] = {
          "zAttributesId": b.buildingId,
          "DisplayName": b.buildingName,
        };
      }

      return {
        "itemList": uniqueFiltered.values.toList(),
        "totalNumberOfRecord": uniqueFiltered.length,
      };
    }

    final currentLoadedCount = buildingList.length;

    if (currentLoadedCount < totalCount) {
      await _proposedOfferCubit.getBuildingList(
        context,
        pageNumber,
        pageSize,
        _project.projectId,
      );
    }

    final updatedList =
        _proposedOfferCubit.state.buildingList
            .where((b) => b.projectId == _project.projectId)
            .toList();

    final Map<int, Map<String, dynamic>> uniqueBuildings = {};

    for (final b in updatedList) {
      uniqueBuildings[b.buildingId] = {
        "zAttributesId": b.buildingId,
        "DisplayName": b.buildingName,
      };
    }

    return {
      "itemList": uniqueBuildings.values.toList(),
      "totalNumberOfRecord":
          totalCount > 0 ? totalCount : uniqueBuildings.length,
    };
  }

  // LOAD BUILDINGS FOR PROJECT
  Future<void> _loadBuildingsForProject(int projectId) async {
    final hasBuildingsForProject = _proposedOfferCubit.state.buildingList.any(
      (b) => b.projectId == projectId,
    );

    if (!hasBuildingsForProject ||
        _proposedOfferCubit.state.buildingList.isEmpty) {
      await _proposedOfferCubit.getBuildingList(context, 1, 12, projectId);
    }
    if (mounted) {
      _selectedBuildingNotifier.value = [];
      _lastFetchedBuildingId = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Proposed Offer",
        authorization: AuthorizationModel(),
        extraHeight: 100.h,
        onProjectChangeCallback: (value) {
          _project = value;
          _selectedBuildingNotifier.value = [];
          _lastFetchedBuildingId = null;
          _loadBuildingsForProject(_project.projectId);
        },
        widgets: BlocBuilder<ProposedOfferCubit, ProposedOfferState>(
          bloc: _proposedOfferCubit,
          builder: (context, state) {
            return ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: _selectedBuildingNotifier,
              builder: (context, selectedBuilding, child) {
                return Column(
                  children: [
                    verticalSpacing(),
                    showSiteSelectedWidget(projectName: _project.projectName),
                    CustomMultipleSelectPopup(
                      title: "Building",
                      isRequired: true,
                      isMultiSelect: false,
                      initialValue: selectedBuilding,
                      dataList: const [],
                      onSelected: (value) async {
                        _selectedBuildingNotifier.value = value;
                        final newBuildingId =
                            value.first['zAttributesId'] as int;
                        if (_lastFetchedBuildingId != newBuildingId) {
                          _lastFetchedBuildingId = newBuildingId;
                        }
                      },
                      dataFetchCallBack: _fetchBuildings,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Building is required";
                        }
                        return null;
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      body: SafeArea(
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
                          _selectedBuildingNotifier.value.first['zAttributesId']
                              .toString(),
                      "projectId": _project.projectId.toString(),
                      "projectName": _project.projectName,
                      "buildingName":
                          _selectedBuildingNotifier.value.first['DisplayName']
                              .toString(),
                    },
                  );
                } else {
                  showErrorMessage(context, "Error", "Please select building");
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
                  children: [
                    Expanded(
                      child: ProposedOfferTile(
                        icon: _proposedOfferIcons[index],
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
    );
  }
}
