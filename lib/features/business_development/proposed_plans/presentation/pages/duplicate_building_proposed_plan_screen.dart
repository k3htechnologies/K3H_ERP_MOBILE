import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/proposed_plans/presentation/cubit/proposed_plans_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class DuplicateBuildingProposedPlanScreen extends StatefulWidget {
  const DuplicateBuildingProposedPlanScreen({
    super.key,
    required this.projectId,
    required this.selectedBuildingIndex,
    required this.buildingName,
  });
  final int projectId;
  final int selectedBuildingIndex;
  final String buildingName;
  @override
  State<DuplicateBuildingProposedPlanScreen> createState() =>
      _DuplicateBuildingProposedPlanScreenState();
}

class _DuplicateBuildingProposedPlanScreenState
    extends State<DuplicateBuildingProposedPlanScreen> {
  final ValueNotifier<List<Map<String, dynamic>>> _selectedBuildings =
      ValueNotifier([]);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Future<Map<String, dynamic>> _fetchBuildings(
    int pageNumber, {
    String? value,
  }) async {
    final state = context.read<ProposedPlansCubit>().state;
    final selectedBuildingId =
        state
            .proposedPlansList
            .first
            .buildingProposedPlanData[widget.selectedBuildingIndex]
            .buildingProposedPlanId;
    final buildings =
        state.proposedPlansList.first.buildingProposedPlanData
            .where(
              (building) =>
                  building.buildingProposedPlanId != selectedBuildingId &&
                  (value == null ||
                      value.isEmpty ||
                      building.buildingName.toLowerCase().contains(
                        value.toLowerCase(),
                      )),
            )
            .map(
              (building) => {
                "zAttributesId": building.buildingProposedPlanId,
                "DisplayName": building.buildingName,
              },
            )
            .toList();
    return {"itemList": buildings, "totalNumberOfRecord": buildings.length};
  }

  String get selectedBuilding => _selectedBuildings.value
      .map((v) => v["zAttributesId"].toString())
      .toSet()
      .join(",");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Proposed Plan",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Duplicate Details",
                style: AppTextStyle.ts14M(color: AppColor.grey),
              ),
              verticalSpacing(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: commonCardDecoration(),
                child: Column(
                  children: [
                    CustomTextField(
                      title: 'Source Building',
                      textController: TextEditingController(
                        text: widget.buildingName,
                      ),
                      readOnly: true,
                    ),
                    ValueListenableBuilder(
                      valueListenable: _selectedBuildings,
                      builder: (context, value, child) {
                        return CustomMultipleSelectPopup(
                          title: "Applicable Buildings",
                          hintText: "Select Buildings",
                          isRequired: true,
                          initialValue: _selectedBuildings.value,
                          isMultiSelect: true,
                          onSelected: (value) {
                            _selectedBuildings.value = value;
                          },
                          dataFetchCallBack: _fetchBuildings,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Applicable Buildings is required";
                            }
                            return null;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            text: 'Duplicate',
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              final state = context.read<ProposedPlansCubit>().state;
              final building =
                  state.proposedPlansList.first.buildingProposedPlanData[widget
                      .selectedBuildingIndex];
              context.read<ProposedPlansCubit>().copyBuildingProposedPlan(
                context: context,
                projectId: widget.projectId,
                proposedOfferProposedPlanId:
                    state.proposedPlansList.first.proposedOfferProposedPlanId,
                sourceBuildingProposedPlanId: building.buildingProposedPlanId,
                copyBuildingProposedPlanId: selectedBuilding,
              );
            },
          ),
        ),
      ),
    );
  }
}
