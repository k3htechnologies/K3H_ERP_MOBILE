// DETAILS SECTION TAB VIEW
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/presentation/cubit/proposed_plans_cubit.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/data/model/form/wing_form_detail_model.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class ProposedPlanDetailsView extends StatefulWidget {
  final List<WingFormDetailModel>? details;
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

  final ValueNotifier<List<WingFormDetailModel>> wingsNotifier =
      ValueNotifier<List<WingFormDetailModel>>([]);

  Timer? _wingTimer;

  @override
  void initState() {
    super.initState();

    _initializeTextEditingControllers();

    if (widget.details != null) {
      wingsNotifier.value = List.from(widget.details!);

      for (final wing in wingsNotifier.value) {
        _attachWingListeners(wing);
      }

      _totalWingsC.text = widget.details!.length.toString();
    }

    _totalPodiumC.text = widget.totalPodiumCount.toString();

    _updateTotalUnits();
  }

  @override
  void dispose() {
    _wingTimer?.cancel();

    _totalWingsC.dispose();
    _totalPodiumC.dispose();
    _totalUnitsC.dispose();

    for (final wing in wingsNotifier.value) {
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
  void _attachWingListeners(WingFormDetailModel wing) {
    wing.totalUnits.addListener(_updateTotalUnits);
  }

  /// Remove listener
  void _detachWingListeners(WingFormDetailModel wing) {
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

    final formData = cubit.state.buildingForm;

    formData.totalUnits = total;

    cubit.updateBuildingForm(formData);
  }

  void generateWingControllers(int count) {
    final currentList = wingsNotifier.value;

    if (count > currentList.length) {
      final newWings = List.generate(
        count - currentList.length,
        (_) => WingFormDetailModel(buildingName: widget.buildingName),
      );

      for (final wing in newWings) {
        _attachWingListeners(wing);
      }

      currentList.addAll(newWings);
    } else if (count < currentList.length) {
      final removed = currentList.sublist(count);

      for (final wing in removed) {
        _detachWingListeners(wing);
        wing.dispose();
      }

      currentList.removeRange(count, currentList.length);
      final cubit = context.read<ProposedPlansCubit>();

      final formData = cubit.state.buildingForm;

      formData.totalWings = count;

      cubit.updateBuildingForm(formData);
    }

    wingsNotifier.value = List.from(currentList);

    _updateTotalUnits();
    _updateWingsState(currentList);
  }

  void _updateWingsState(List<WingFormDetailModel> wings) {
    final cubit = context.read<ProposedPlansCubit>();

    final formData = cubit.state.buildingForm;

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
                    textController: _totalWingsC,
                    onChangeFunction: (value) {
                      _wingTimer?.cancel();

                      _wingTimer = Timer(const Duration(milliseconds: 600), () {
                        final count = int.tryParse(value) ?? 0;

                        if (count <= 0) {
                          for (final wing in wingsNotifier.value) {
                            _detachWingListeners(wing);
                            wing.dispose();
                          }

                          wingsNotifier.value = [];
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
                    keyboardType: TextInputType.number,
                    textController: _totalPodiumC,
                    onChangeFunction: (v) {
                      final cubit = context.read<ProposedPlansCubit>();

                      final formData = cubit.state.buildingForm;

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
              child: ValueListenableBuilder<List<WingFormDetailModel>>(
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
                              updatedWing is WingFormDetailModel) {
                            final updatedList = List<WingFormDetailModel>.from(
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
  final WingFormDetailModel wing;
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
              Text(
                "Wing ${index + 1} Details ${wing.wingName.text.isEmpty ? '' : '- ${wing.wingName.text.trim()}'}",
                style: AppTextStyle.ts14M(),
              ),

              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
