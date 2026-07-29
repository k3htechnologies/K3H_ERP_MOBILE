import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/data/model/amenity_category.model.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/expandable_tile/expandable_category_tile.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AmenitiesTab extends StatefulWidget {
  final List<AmenityCategory> amenitiesList;
  final Function(int, AmenityCategory) onUpdate;
  final ValueChanged<bool> onSearchResultChanged;

  const AmenitiesTab({
    super.key,
    required this.amenitiesList,
    required this.onUpdate,
    required this.onSearchResultChanged,
  });

  @override
  State<AmenitiesTab> createState() => _AmenitiesTabState();
}

class _AmenitiesTabState extends State<AmenitiesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final TextEditingController _searchController;

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

    _filterAmenities();
  }

  @override
  void didUpdateWidget(covariant AmenitiesTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filterAmenities();
    });
  }

  void _filterAmenities() {
    final query = _searchController.text.trim().toLowerCase();

    final entries = widget.amenitiesList.asMap().entries.toList();

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

    widget.onSearchResultChanged(_filteredAmenities.value.isNotEmpty);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterAmenities);
    _searchController.dispose();
    _filteredAmenities.dispose();
    super.dispose();
  }

  int get _selectedAmenitiesCount {
    return widget.amenitiesList.fold(
      0,
      (count, category) =>
          count + category.subCategories.where((sub) => sub.isSelected).length,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Amenities Category",
                  style: AppTextStyle.ts14M(color: AppColor.grey),
                ),
                TextSpan(
                  text: " ($_selectedAmenitiesCount)",
                  style: AppTextStyle.ts14M(color: AppColor.black),
                ),
              ],
            ),
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
                  key: ValueKey(widget.amenitiesList.hashCode),
                  itemCount: filteredAmenities.length,
                  itemBuilder: (context, index) {
                    final entry = filteredAmenities[index];

                    return ExpandableCategoryTile(
                      key: ValueKey('${entry.key}-${entry.value.hashCode}'),
                      category: entry.value,

                      canAction: _routeAuthorizationModel.isAction,
                      onCategoryChanged: (updatedCategory) {
                        widget.onUpdate(entry.key, updatedCategory);
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
