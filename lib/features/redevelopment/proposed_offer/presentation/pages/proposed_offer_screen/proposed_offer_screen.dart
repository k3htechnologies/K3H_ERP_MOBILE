import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';

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
  final List<String> _proposedOfferTypeList = [
    "Extra Carpet Area",
    "Corpus Details",
    "Security Deposit",
    "Shifting Details",
    "Lien to Society Details",
    "Parking Allotment",
    "GST on Existing + Free Area",
    "Project Completion",
    "Rent Details",
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

  // LOAD BUILDINGS FOR PROJECT
  Future<void> _loadBuildingsForProject(int projectId) async {
    if (_proposedOfferCubit.state.buildingList.isEmpty ||
        _proposedOfferCubit.state.buildingList.any(
          (b) => b.projectId != projectId,
        )) {
      await _proposedOfferCubit.getBuildingList(context, 1, 100, projectId);
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
        extraHeight: 90,
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
                return CustomMultipleSelectPopup(
                  title: "Building",
                  isRequired: true,
                  isMultiSelect: false,
                  initialValue: selectedBuilding,
                  dataList: const [],
                  onSelected: (value) async {
                    _selectedBuildingNotifier.value = value;
                    final newBuildingId = value.first['zAttributesId'] as int;
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
                );
              },
            );
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _proposedOfferTypeList.length,
            itemBuilder: (_, index) {
              return GestureDetector(
                onTap: () {
                  if(_selectedBuildingNotifier.value.isNotEmpty){
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
                  }else{
                    showErrorMessage(context, "Error", "Please select building");
                  }
                },
                child: Container(
                  decoration: commonCardDecoration(),
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: Text(
                          _proposedOfferTypeList[index],
                          style: AppTextStyle.ts16M(),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColor.black,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
