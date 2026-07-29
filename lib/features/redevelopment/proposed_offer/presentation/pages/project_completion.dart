import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/features/redevelopment/widgets/common_redevelopment_widgets.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ProjectCompletion extends StatefulWidget {
  final int projectId;
  final int buildingId;
  final ValueChanged<VoidCallback> onSave;

  const ProjectCompletion({
    super.key,
    required this.projectId,
    required this.buildingId,
    required this.onSave,
  });

  @override
  State<ProjectCompletion> createState() => _ProjectCompletionState();
}

class _ProjectCompletionState extends State<ProjectCompletion> {
  // CUBIT
  late ProposedOfferCubit _cubit;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // TEXT EDITING CONTROLLERS
  late TextEditingController _completionTimelineC, _gracePeriodC, _remarkC;

  @override
  initState() {
    super.initState();
    _cubit = context.read<ProposedOfferCubit>();
    _initializeControllers();
    _cubit.pullProjectCompletion(
      projectId: widget.projectId,
      buildingId: widget.buildingId,
    );
    widget.onSave(_onSave);
  }

  @override
  void dispose() {
    _completionTimelineC.dispose();
    _gracePeriodC.dispose();
    _remarkC.dispose();
    super.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initializeControllers() {
    _completionTimelineC = TextEditingController();
    _gracePeriodC = TextEditingController();
    _remarkC = TextEditingController();
  }

  // FILL DATA
  void fillData() {
    if (_cubit.state.projectCompletion != null) {
      var projectCompletionModel = _cubit.state.projectCompletion!;
      _completionTimelineC.text =
          projectCompletionModel.completionTimelineMonths.toString();
      _gracePeriodC.text = projectCompletionModel.gracePeriodMonths.toString();
      _remarkC.text = projectCompletionModel.remark;
    }
  }

  // SAVE
  void _onSave() {
    if (_formKey.currentState!.validate()) {
      _cubit.addUpdateProjectCompletion(
        context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
        completionTimelineMonths: int.parse(_completionTimelineC.text),
        gracePeriodMonths: int.parse(_gracePeriodC.text),
        remark: _remarkC.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocConsumer<ProposedOfferCubit, ProposedOfferState>(
        listener: (context, state) {
          if (state.projectCompletion != null) {
            fillData();
          } else {
            _completionTimelineC.clear();
            _gracePeriodC.clear();
          }
        },
        builder: (context, state) {
          if (state.isLoading == true) {
            return loader();
          }
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: commonCardDecoration(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProposedOfferTile(
                      svgIcon: AppAssets.projectCompletionIcon,
                      title: "Project Completion",
                    ),
                    verticalSpacing(height: 15),
                    CustomTextField(
                      title: "Completion Timeline (Months)",
                      isRequired: true,
                      hint: "Enter Completion Timeline (Months)",
                      textController: _completionTimelineC,
                      keyboardType: TextInputType.number,
                      inputFormatterList: InputValidator.digit(2),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Completion timeline is required";
                        }
                        if (int.parse(value) <= 0) {
                          return "Timeline should be greater than 0";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Grace Period (Months)",
                      isRequired: true,
                      hint: "Enter Grace Period (Months)",
                      textController: _gracePeriodC,
                      keyboardType: TextInputType.number,
                      inputFormatterList: InputValidator.digit(2),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Grace period is required";
                        }
                        if (int.parse(value) <= 0) {
                          return "Grace period should be greater than 0";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Remark',
                      hint: 'Enter Remark',
                      textController: _remarkC,
                      minLines: 3,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
