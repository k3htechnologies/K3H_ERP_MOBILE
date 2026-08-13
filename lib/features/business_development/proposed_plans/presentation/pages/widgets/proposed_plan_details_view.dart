import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/proposed_plans/presentation/cubit/proposed_plans_cubit.dart';
import 'package:k3h_erp_app/features/business_development/proposed_plans/data/model/form/wing_detail_form_model.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class ProposedPlanDetailsView extends StatefulWidget {
  final List<WingDetailFormModel>? details;
  final int totalPodiumCount;
  final int totalUnitC;
  final String buildingName;
  const ProposedPlanDetailsView({
    super.key,
    this.details,
    required this.totalPodiumCount,
    required this.totalUnitC,
    required this.buildingName,
  });
  @override
  State<ProposedPlanDetailsView> createState() =>
      _ProposedPlanDetailsViewState();
}

class _ProposedPlanDetailsViewState extends State<ProposedPlanDetailsView> {
  late TextEditingController _totalWingsC;
  late TextEditingController _totalPodiumC;
  late TextEditingController _totalUnitsC;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ValueNotifier<List<WingDetailFormModel>> wingsNotifier =
      ValueNotifier<List<WingDetailFormModel>>([]);
  List<WingDetailFormModel> _cachedWings = [];
  Timer? _wingTimer;
  late final AuthorizationModel _routeAuthorizationModel;
  @override
  void initState() {
    super.initState();
    _initializeTextEditingControllers();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.proposedPlan] ??
        AuthorizationModel();
    if (widget.details != null) {
      _cachedWings = List.from(widget.details!);
      wingsNotifier.value = List.from(_cachedWings);
      for (final wing in _cachedWings) {
        _attachWingListeners(wing);
      }
      _totalWingsC.text = widget.details!.length.toString();
    }
    _totalPodiumC.text = widget.totalPodiumCount.toString();
    _totalUnitsC.text = widget.totalUnitC.toString();
  }

  @override
  void dispose() {
    _wingTimer?.cancel();
    _totalWingsC.dispose();
    _totalPodiumC.dispose();
    _totalUnitsC.dispose();
    for (final wing in _cachedWings) {
      _detachWingListeners(wing);
      wing.dispose();
    }
    wingsNotifier.dispose();
    super.dispose();
  }

  void _initializeTextEditingControllers() {
    _totalWingsC = TextEditingController();
    _totalPodiumC = TextEditingController();
    _totalUnitsC = TextEditingController();
  }

  /// Attach listener to every wing
  void _attachWingListeners(WingDetailFormModel wing) {
    wing.totalUnits.addListener(_updateTotalUnits);
  }

  /// Remove listener
  void _detachWingListeners(WingDetailFormModel wing) {
    wing.totalUnits.removeListener(_updateTotalUnits);
  }

  /// Sum all wing total units
  void _updateTotalUnits() {
    int total = 0;
    for (final wing in wingsNotifier.value) {
      total += int.tryParse(wing.totalUnits.text) ?? 0;
    }
    _totalUnitsC.text = total.toString();
    final cubit = context.read<ProposedPlansCubit>();
    final formData = cubit.state.proposedPlanForm;
    formData.totalUnits = total;
    cubit.updateBuildingForm(formData);
  }

  void generateWingControllers(int count) {
    // Create new wings only if cache doesn't have enough.
    while (_cachedWings.length < count) {
      final wing = WingDetailFormModel(buildingName: widget.buildingName);
      _attachWingListeners(wing);
      _cachedWings.add(wing);
    }
    // Show only the requested number of wings.
    final visibleWings = _cachedWings.take(count).toList();
    wingsNotifier.value = visibleWings;
    final cubit = context.read<ProposedPlansCubit>();
    final form = cubit.state.proposedPlanForm;
    form.totalWings = count;
    form.wings = visibleWings;
    cubit.updateBuildingForm(form);
    _updateTotalUnits();
  }

  void _updateWingsState(List<WingDetailFormModel> wings) {
    final cubit = context.read<ProposedPlansCubit>();
    final formData = cubit.state.proposedPlanForm;
    formData.wings = wings;
    cubit.updateBuildingForm(formData);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Details", style: AppTextStyle.ts14M(color: AppColor.grey)),
            const SizedBox(height: 10),
            Container(
              decoration: commonCardDecoration(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  CustomTextField(
                    title: "Total Wings",
                    hint: "Enter Total Wings",
                    keyboardType: TextInputType.number,
                    inputFormatterList: InputValidator.digit(2),
                    textController: _totalWingsC,
                    readOnly: !_routeAuthorizationModel.isAction,
                    onChangeFunction: (value) {
                      _wingTimer?.cancel();
                      _wingTimer = Timer(const Duration(milliseconds: 600), () {
                        final count = int.tryParse(value) ?? 0;
                        if (count <= 0) {
                          for (final wing in wingsNotifier.value) {
                            _detachWingListeners(wing);
                          }
                          wingsNotifier.value = [];
                          final cubit = context.read<ProposedPlansCubit>();
                          final form = cubit.state.proposedPlanForm;
                          form.totalWings = 0;
                          form.wings = [];
                          cubit.updateBuildingForm(form);
                          _updateTotalUnits();
                          return;
                        }
                        if (count != wingsNotifier.value.length) {
                          generateWingControllers(count);
                        }
                      });
                    },
                  ),
                  CustomTextField(
                    title: "Number Of Podium",
                    hint: "Enter Number Of Podium",
                    readOnly: !_routeAuthorizationModel.isAction,
                    keyboardType: TextInputType.number,
                    inputFormatterList: InputValidator.digit(2),
                    textController: _totalPodiumC,
                    onChangeFunction: (v) {
                      final cubit = context.read<ProposedPlansCubit>();
                      final formData = cubit.state.proposedPlanForm;
                      formData.totalPodium = int.tryParse(v) ?? 0;
                      cubit.updateBuildingForm(formData);
                    },
                  ),
                  CustomTextField(
                    title: "Total Units",
                    hint: "Total Units",
                    readOnly: true,
                    keyboardType: TextInputType.number,
                    textController: _totalUnitsC,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ValueListenableBuilder<List<WingDetailFormModel>>(
                valueListenable: wingsNotifier,
                builder: (context, wings, child) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: wings.length,
                    itemBuilder: (context, index) {
                      final wing = wings[index];
                      return WingCard(
                        index: index,
                        wing: wing,
                        onTap: () async {
                          final updatedWing = await goRouter.pushNamed(
                            AppRoutes.wingDetails,
                            extra: {"index": index, "wing": wing},
                          );
                          if (updatedWing != null &&
                              updatedWing is WingDetailFormModel) {
                            final updatedList = List<WingDetailFormModel>.from(
                              wingsNotifier.value,
                            );
                            _detachWingListeners(wingsNotifier.value[index]);
                            _attachWingListeners(updatedWing);
                            updatedList[index] = updatedWing;
                            wingsNotifier.value = updatedList;
                            _updateTotalUnits();
                            _updateWingsState(updatedList);
                          }
                        },
                      );
                    },
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

class WingCard extends StatelessWidget {
  final int index;
  final WingDetailFormModel wing;
  final VoidCallback onTap;
  const WingCard({
    super.key,
    required this.index,
    required this.wing,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Wing ${index + 1} Details ${wing.wingName.text.isEmpty ? '' : '- ${wing.wingName.text.trim()}'}",
                  style: AppTextStyle.ts14M(),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
