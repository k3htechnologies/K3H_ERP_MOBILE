import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/data/model/proposed_plans.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/presentation/cubit/proposed_plans_cubit.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/presentation/models/amenity_category.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/expandable_tile/expandable_category_tile.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ProposedPlansScreen extends StatefulWidget {
  const ProposedPlansScreen({super.key});

  @override
  State<ProposedPlansScreen> createState() => _ProposedPlansScreenState();
}

class _ProposedPlansScreenState extends State<ProposedPlansScreen>
    with SingleTickerProviderStateMixin {
  // CUBIT
  late ProposedPlansCubit _proposedPlansCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // TAB CONTROLLER
  late TabController _tabController;

  // PROJECT
  late ProjectModel _project;

  // FORM KEY
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // TEXT EDITING CONTROLLER
  late TextEditingController _totalNumberOfFloorsC,
      _totalNumberOfUnitsC,
      _totalParkingC;

  // FILE VARIABLES
  MultiFilePickerModel planFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  // AMENITIES DATA
  List<AmenityCategory> amenitiesList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _project = getProject();
    _proposedPlansCubit = context.read<ProposedPlansCubit>();
    _tabController.addListener(_handleTabChange);
    _routeAuthorizationModel = AuthorizationModel();
    _initializeTextEditingControllers();
    _initializeAmenitiesData();
    _proposedPlansCubit.onTabChanged(
      _tabController.index,
      context,
      _project.projectId,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _disposeTextEditingControllers();
    super.dispose();
  }

  // INITIALISING TEXT CONTROLLERS
  void _initializeTextEditingControllers() {
    _totalNumberOfFloorsC = TextEditingController();
    _totalNumberOfUnitsC = TextEditingController();
    _totalParkingC = TextEditingController();
  }

  // DISPOSE METHOD TO DISPOSE ALL TEXT CONTROLLERS
  void _disposeTextEditingControllers() {
    _totalNumberOfFloorsC.dispose();
    _totalNumberOfUnitsC.dispose();
    _totalParkingC.dispose();
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _proposedPlansCubit.onTabChanged(
        _tabController.index,
        context,
        _project.projectId,
      );
    }
  }

  // PREFILL FROM STATE
  void _prefillFromModel(ProposedPlansModel proposedPlan) {
    setState(() {
      // Only prefill if user has not already typed something
      if (_totalNumberOfFloorsC.text.isEmpty) {
        _totalNumberOfFloorsC.text =
            proposedPlan.totalNumberOfFloors.toString();
      }
      if (_totalNumberOfUnitsC.text.isEmpty) {
      _totalNumberOfUnitsC.text = proposedPlan.totalUnits.toString();
      }
      if (_totalParkingC.text.isEmpty) {
      _totalParkingC.text = proposedPlan.totalParking.toString();
      }
      if (proposedPlan.planDocumentUrl.isNotEmpty) {
      planFile.fileNameList = proposedPlan.planDocumentUrl.split(",");
      } else {
        planFile.fileNameList = [];
      }
      // Prefill amenities if available
      if (proposedPlan.amenities.isNotEmpty) {
        _prefillAmenities(proposedPlan.amenities);
      }
    });
  }

  // PREFILL AMENITIES FROM API RESPONSE
  void _prefillAmenities(String amenitiesString) {
    if (amenitiesString.isEmpty) return;

    // Split comma-separated amenities
    final List<String> selectedAmenities = amenitiesString
        .split(",")
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Create updated amenities list with selected items marked
    final updatedAmenitiesList = amenitiesList.map((category) {
      final updatedSubCategories = category.subCategories.map((subCategory) {
        return AmenitySubCategory(
          name: subCategory.name,
          isSelected: selectedAmenities.contains(subCategory.name),
        );
      }).toList();
      return AmenityCategory(
        title: category.title,
        subCategories: updatedSubCategories,
        isExpanded: category.isExpanded,
      );
    }).toList();

    amenitiesList = updatedAmenitiesList;
  }

  // CLEAR FORM WHEN NO DATA FOR PROJECT
  void _clearForm() {
    setState(() {
      _totalNumberOfFloorsC.clear();
      _totalNumberOfUnitsC.clear();
      _totalParkingC.clear();
      planFile.fileNameList = [];
      planFile.fileBytesList = [];
      planFile.deletedFileList = "";
      // Clear all selected amenities
      _clearAmenities();
    });
  }

  // CLEAR ALL SELECTED AMENITIES
  void _clearAmenities() {
    // Create updated amenities list with all items unselected
    amenitiesList = amenitiesList.map((category) {
      final updatedSubCategories = category.subCategories.map((subCategory) {
        return AmenitySubCategory(
          name: subCategory.name,
          isSelected: false,
        );
      }).toList();
      return AmenityCategory(
        title: category.title,
        subCategories: updatedSubCategories,
        isExpanded: category.isExpanded,
      );
    }).toList();
  }

  // INITIALIZE STATIC AMENITIES DATA
  void _initializeAmenitiesData() {
    amenitiesList = [
      AmenityCategory(
        title: "Safety & Security",
        subCategories: [
          AmenitySubCategory(name: "24* 7 Security"),
          AmenitySubCategory(name: "CCTV Surveillance"),
          AmenitySubCategory(name: "Intercom Facility"),
          AmenitySubCategory(name: "Fire Fighting System"),
          AmenitySubCategory(name: "First Aid Room"),
          AmenitySubCategory(name: "Security Cabin"),
          AmenitySubCategory(name: "Earthquake Resistant Structure"),
        ],
      ),
      AmenityCategory(
        title: "Sports & Fitness",
        subCategories: [
          AmenitySubCategory(name: "Swimming Pool"),
          AmenitySubCategory(name: "Gym"),
          AmenitySubCategory(name: "Yoga Room"),
          AmenitySubCategory(name: "Jogging Track"),
          AmenitySubCategory(name: "Badminton Court"),
          AmenitySubCategory(name: "BasketBall Court"),
          AmenitySubCategory(name: "Tennis Court"),
          AmenitySubCategory(name: "Squash Court"),
          AmenitySubCategory(name: "Table Tennis"),
          AmenitySubCategory(name: "Kids Pool"),
          AmenitySubCategory(name: "Indoor Games"),
          AmenitySubCategory(name: "Cycling Track"),
        ],
      ),
      AmenityCategory(
        title: "Community & Social Spaces",
        subCategories: [
          AmenitySubCategory(name: "Club House"),
          AmenitySubCategory(name: "Banquet Hall"),
          AmenitySubCategory(name: "Amphitheatre"),
          AmenitySubCategory(name: "Library"),
          AmenitySubCategory(name: "Reading Room"),
          AmenitySubCategory(name: "Society Office"),
          AmenitySubCategory(name: "Conference Room"),
          AmenitySubCategory(name: "Temple/Prayer Hall"),
        ],
      ),
      AmenityCategory(
        title: "Kids & Family",
        subCategories: [
          AmenitySubCategory(name: "Children Play Area"),
          AmenitySubCategory(name: "Creche"),
          AmenitySubCategory(name: "Day Care Center"),
          AmenitySubCategory(name: "School Bus Bay"),
        ],
      ),
      AmenityCategory(
        title: "Pets - Friendly Facilities",
        subCategories: [
          AmenitySubCategory(name: "Pet Park"),
          AmenitySubCategory(name: "Pet Care Area"),
        ],
      ),
      AmenityCategory(
        title: "Work & Business",
        subCategories: [
          AmenitySubCategory(name: "Co-Working Space"),
          AmenitySubCategory(name: "Society Office"),
        ],
      ),
      AmenityCategory(
        title: "Convenience & Utilities",
        subCategories: [
          AmenitySubCategory(name: "Lift"),
          AmenitySubCategory(name: "Power Backup"),
          AmenitySubCategory(name: "Water Supply"),
          AmenitySubCategory(name: "Parking"),
          AmenitySubCategory(name: "Visitor Parking"),
          AmenitySubCategory(name: "Covered Parking"),
          AmenitySubCategory(name: "EV Charging Points"),
          AmenitySubCategory(name: "Laundry Service"),
          AmenitySubCategory(name: "Garbage Disposal System"),
          AmenitySubCategory(name: "Sewage Treatment Plant"),
          AmenitySubCategory(name: "Rainwater Harvesting"),
          AmenitySubCategory(name: "Service Lift"),
        ],
      ),
      AmenityCategory(
        title: "Health & Wellness",
        subCategories: [
          AmenitySubCategory(name: "Spa"),
          AmenitySubCategory(name: "Steam Room"),
          AmenitySubCategory(name: "Meditation Area"),
          AmenitySubCategory(name: "Jacuzzi"),
        ],
      ),
      AmenityCategory(
        title: "Commercial & Services",
        subCategories: [
          AmenitySubCategory(name: "ATM"),
          AmenitySubCategory(name: "Pharmacy"),
          AmenitySubCategory(name: "Convenience Store"),
          AmenitySubCategory(name: "Co-working Space"),
          AmenitySubCategory(name: "Cafeteria"),
        ],
      ),
    ];
  }

  // UPDATE AMENITY CATEGORY
  void _updateAmenityCategory(int index, AmenityCategory updatedCategory) {
    setState(() {
      amenitiesList[index] = updatedCategory;
    });
  }

  // GET SELECTED AMENITIES AS LIST
  List<String> _getSelectedAmenities() {
    final List<String> selectedAmenities = [];
    for (var category in amenitiesList) {
      for (var subCategory in category.subCategories) {
        if (subCategory.isSelected) {
          selectedAmenities.add(subCategory.name);
        }
      }
    }
    return selectedAmenities;
  }

  // GET SELECTED AMENITIES AS COMMA-SEPARATED STRING
  String _getSelectedAmenitiesString() {
    final selectedAmenities = _getSelectedAmenities();
    return selectedAmenities.join(",");
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProposedPlansCubit, ProposedPlansState>(
      listenWhen: (previous, current) =>
          previous.proposedPlansList != current.proposedPlansList,
      listener: (context, state) {
        // When data changes for current project:
        // - if list has data, prefill
        // - if list is empty, clear the form
        if (state.proposedPlansList.isNotEmpty) {
          final proposedPlan = state.proposedPlansList.first;
          _prefillFromModel(proposedPlan);
        } else {
          _clearForm();
        }
      },
      child: Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Proposed Plan",
        authorization: _routeAuthorizationModel,
        onProjectChangeCallback: (project) {
          _project = project;
          _proposedPlansCubit.onTabChanged(
            _tabController.index,
            context,
            _project.projectId,
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IntrinsicWidth(
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColor.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: AppColor.primary,
                    unselectedLabelColor: AppColor.grey,
                    indicator: BoxDecoration(
                      color: AppColor.lightBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelStyle: AppTextStyle.ts14M(),
                    unselectedLabelStyle: AppTextStyle.ts14M(),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.zero,
                    tabs: const [Tab(text: 'Details'), Tab(text: 'Amenities')],
                  ),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                  children: [_detailsSectionTabView(), _amenitiesSectionTabView()],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BlocBuilder<ProposedPlansCubit, ProposedPlansState>(
        builder: (context, state) {
          return state.currentTabIndex == 0
              ? SafeArea(
                child: Container(
                  height: 70,
                  padding: EdgeInsets.all(16),
                  child: CustomButton(
                        text: state.proposedPlansList.isEmpty
                            ? "Add Proposed Plan"
                            : "Update Proposed Plan",
                        onPressed: () {
                          _handleAddOrUpdateProposedPlan(state);
                        },
                  ),
                ),
              )
              : SizedBox();
        },
        ),
      ),
    );
  }

  // DETAILS SECTION TAB VIEW
  Widget _detailsSectionTabView() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Container(
          margin: EdgeInsets.all(16),
          decoration: commonCardDecoration(),
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Proposed Plan Details", style: AppTextStyle.ts14M()),
              verticalSpacing(height: 15),
              CustomTextField(
              title: "Total Number Of Floors",
              isRequired: true,
              hint: "Enter Total Number Of Floors",
              keyboardType: TextInputType.number,
              textController: _totalNumberOfFloorsC,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please enter total number of floors";
                }
                return null;
              },
            ),
            CustomTextField(
              title: "Total Number Of Units",
              isRequired: true,
              hint: "Enter Total Number Of Units",
              keyboardType: TextInputType.number,
              textController: _totalNumberOfUnitsC,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please enter total number of units";
                }
                return null;
              },
            ),
            CustomTextField(
              title: "Total Parking",
              isRequired: true,
              hint: "Enter Total Parking",
              keyboardType: TextInputType.number,
              textController: _totalParkingC,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please enter total parking";
                }
                return null;
              },
            ),
            CustomMultiFilePicker(
              key: ValueKey(planFile.fileNameList.join(",")),
              initialFileList: planFile.fileNameList,
              title: "Plan",
              isRequired: true,
              onFilePickedCallback: (fileByteList, fileNameList) {
                planFile.fileBytesList = fileByteList;
                planFile.fileNameList = fileNameList;
              },
              onFileDeleteCallback: (fileBytesList, fileNameList, deletedUrl) {
                planFile.fileBytesList = fileBytesList;
                planFile.fileNameList = fileNameList;
                planFile.deletedFileList = deletedUrl;
              },
              validator: (file) {
                if (file == null || file.isEmpty) {
                  return "Plan File required";
                }
                return null;
              },
            ),
          ],
        ),
      ),
      ),
    );
  }

  // HANDLE ADD OR UPDATE PROPOSED PLAN
  void _handleAddOrUpdateProposedPlan(ProposedPlansState state) {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get selected amenities as comma-separated string
    final amenitiesString = _getSelectedAmenitiesString();

    if (state.proposedPlansList.isEmpty) {
      // ADD NEW PROPOSED PLAN
      _proposedPlansCubit.addProposedPlans(
        context: context,
        projectId: _project.projectId.toString(),
        totalNumberOfFloors: _totalNumberOfFloorsC.text,
        totalUnits: _totalNumberOfUnitsC.text,
        totalParking: _totalParkingC.text,
        amenities: amenitiesString,
        planFile: planFile,
      );
    } else {
      // UPDATE EXISTING PROPOSED PLAN
      final existingPlan = state.proposedPlansList.first;
      _proposedPlansCubit.updateProposedPlans(
        context: context,
        proposedOfferProposedPlanId:
            existingPlan.proposedOfferProposedPlanId.toString(),
        uniquekey: existingPlan.uniquekey,
        projectId: _project.projectId.toString(),
        totalNumberOfFloors: _totalNumberOfFloorsC.text,
        totalUnits: _totalNumberOfUnitsC.text,
        totalParking: _totalParkingC.text,
        amenities: amenitiesString,
        planFile: planFile,
      );
    }
  }

  // AMENITIES SECTION TAB VIEW
  Widget _amenitiesSectionTabView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Amenities Category", style: AppTextStyle.ts14M()),
          verticalSpacing(height: 15),
          ...amenitiesList.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            return ExpandableCategoryTile(
              category: category,
              onCategoryChanged: (updatedCategory) {
                _updateAmenityCategory(index, updatedCategory);
              },
            );
          }),
        ],
      ),
    );
  }
}
