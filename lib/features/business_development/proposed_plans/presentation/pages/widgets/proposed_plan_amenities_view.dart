import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/proposed_plans/data/model/amenity_category.model.dart';
import 'package:k3h_erp_app/features/business_development/proposed_plans/presentation/cubit/proposed_plans_cubit.dart';
import 'package:k3h_erp_app/features/business_development/proposed_plans/presentation/pages/widgets/amenity_category_tile.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AmenitiesDetailsView extends StatefulWidget {
  final String initialAmenities;
  final ValueChanged<bool>? onSearchResultChanged;
  const AmenitiesDetailsView({
    super.key,
    this.initialAmenities = '',
    this.onSearchResultChanged,
  });
  @override
  State<AmenitiesDetailsView> createState() => AmenitiesDetailsViewState();
}

class AmenitiesDetailsViewState extends State<AmenitiesDetailsView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late final TextEditingController _searchController;
  final ValueNotifier<List<AmenityCategory>> _amenitiesList =
      ValueNotifier<List<AmenityCategory>>([]);
  final ValueNotifier<List<MapEntry<int, AmenityCategory>>> _filteredAmenities =
      ValueNotifier([]);
  late final AuthorizationModel _routeAuthorizationModel;
  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.proposedPlan] ??
        AuthorizationModel();
    _searchController = TextEditingController();
    _searchController.addListener(_filterAmenities);
    _amenitiesList.value = _buildDefaultAmenities();
    _resetToInitial(widget.initialAmenities);
  }

  @override
  void didUpdateWidget(covariant AmenitiesDetailsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialAmenities != widget.initialAmenities) {
      _resetToInitial(widget.initialAmenities);
    }
  }

  void _resetToInitial(String amenitiesCsv) {
    applyAmenitiesSelection(amenitiesCsv);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncSelectionToBuildingForm();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterAmenities);
    _searchController.dispose();
    _amenitiesList.dispose();
    _filteredAmenities.dispose();
    super.dispose();
  }

  String get selectedAmenitiesCsv => _selectedAmenityNames().join(',');
  void clearSelection() => applyAmenitiesSelection('');
  void applyAmenitiesSelection(String amenitiesCsv) {
    final selected =
        amenitiesCsv
            .split(',')
            .map((e) => e.trim().toLowerCase())
            .where((e) => e.isNotEmpty)
            .toSet();
    _amenitiesList.value =
        _amenitiesList.value
            .map(
              (category) => category.copyWith(
                subCategories:
                    category.subCategories
                        .map(
                          (sub) => sub.copyWith(
                            isSelected: selected.contains(
                              sub.name.trim().toLowerCase(),
                            ),
                          ),
                        )
                        .toList(),
              ),
            )
            .toList();
    _filterAmenities();
  }

  List<String> _selectedAmenityNames() => [
    for (final category in _amenitiesList.value)
      for (final sub in category.subCategories)
        if (sub.isSelected) sub.name,
  ];
  void _updateAmenityCategory(int index, AmenityCategory updated) {
    final updatedList = List<AmenityCategory>.from(_amenitiesList.value);
    updatedList[index] = updated;
    _amenitiesList.value = updatedList;
    _syncSelectionToBuildingForm();
    _filterAmenities();
  }

  void _syncSelectionToBuildingForm() {
    final cubit = context.read<ProposedPlansCubit>();
    final formData = cubit.state.proposedPlanForm;
    formData.amenities = selectedAmenitiesCsv;
    cubit.updateBuildingForm(formData);
  }

  void _filterAmenities() {
    final query = _searchController.text.trim().toLowerCase();
    final entries = _amenitiesList.value.asMap().entries.toList();
    if (query.isEmpty) {
      _filteredAmenities.value = entries;
    } else {
      _filteredAmenities.value =
          entries.where((entry) {
            final category = entry.value;
            return category.title.toLowerCase().contains(query) ||
                category.subCategories.any(
                  (sub) => sub.name.toLowerCase().contains(query),
                );
          }).toList();
    }
    widget.onSearchResultChanged?.call(_filteredAmenities.value.isNotEmpty);
  }

  List<AmenityCategory> _buildDefaultAmenities() => [
    AmenityCategory(
      title: "Safety & Security",
      subCategories: [
        AmenitySubCategory(name: "24x7 Security"),
        AmenitySubCategory(name: "CCTV Surveillance"),
        AmenitySubCategory(name: "Fire Fighting System"),
        AmenitySubCategory(name: "First Aid Room"),
        AmenitySubCategory(name: "Intercom Facility"),
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
        AmenitySubCategory(name: "Conference Room"),
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
  int get _selectedAmenitiesCount => _selectedAmenityNames().length;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<List<AmenityCategory>>(
            valueListenable: _amenitiesList,
            builder: (context, _, __) {
              return RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Select Amenities",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    TextSpan(
                      text: " ($_selectedAmenitiesCount)",
                      style: AppTextStyle.ts14M(color: AppColor.black),
                    ),
                  ],
                ),
              );
            },
          ),
          verticalSpacing(height: 15),
          SearchWidget(
            textController: _searchController,
            hintText: "Search Amenities",
            onSubmit: (_) => _filterAmenities(),
          ),
          verticalSpacing(height: 15),
          Expanded(
            child: ValueListenableBuilder<List<MapEntry<int, AmenityCategory>>>(
              valueListenable: _filteredAmenities,
              builder: (context, filteredAmenities, child) {
                if (filteredAmenities.isEmpty) {
                  return Center(
                    child: noDataWidget(message: "No amenities found"),
                  );
                }
                return ListView.builder(
                  itemCount: filteredAmenities.length,
                  itemBuilder: (context, index) {
                    final entry = filteredAmenities[index];
                    return AmenityCategoryTile(
                      key: ValueKey('${entry.key}-${entry.value.hashCode}'),
                      category: entry.value,
                      canAction: _routeAuthorizationModel.isAction,
                      onCategoryChanged: (updatedCategory) {
                        _updateAmenityCategory(entry.key, updatedCategory);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
