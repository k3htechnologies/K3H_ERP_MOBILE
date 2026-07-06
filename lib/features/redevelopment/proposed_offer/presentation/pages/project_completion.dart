import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ProjectCompletion extends StatefulWidget {
  final int projectId;
  final int buildingId;

  const ProjectCompletion({
    super.key,
    required this.projectId,
    required this.buildingId,
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
  late TextEditingController _completionTimelineController;
  late TextEditingController _gracePeriodController;

  @override
  initState() {
    super.initState();
    _cubit = context.read<ProposedOfferCubit>();
    _initializeControllers();
    _cubit.pullProjectCompletion(
      projectId: widget.projectId,
      buildingId: widget.buildingId,
    );
  }

  @override
  void dispose() {
    _completionTimelineController.dispose();
    _gracePeriodController.dispose();
    super.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initializeControllers() {
    _completionTimelineController = TextEditingController();
    _gracePeriodController = TextEditingController();
  }

  // FILL DATA
  void fillData() {
    if (_cubit.state.projectCompletion != null) {
      var projectCompletionModel = _cubit.state.projectCompletion!;
      _completionTimelineController.text =
          projectCompletionModel.completionTimelineMonths.toString();
      _gracePeriodController.text =
          projectCompletionModel.gracePeriodMonths.toString();
    }
  }

  // SAVE
  void _onSave() {
    if (_formKey.currentState!.validate()) {
      _cubit.addUpdateProjectCompletion(
        context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
        completionTimelineMonths: int.parse(_completionTimelineController.text),
        gracePeriodMonths: int.parse(_gracePeriodController.text),
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
            _completionTimelineController.clear();
            _gracePeriodController.clear();
          }
        },
        builder: (context, state) {
          if (state.isLoading == true) {
            return loader();
          }
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
              decoration: commonCardDecoration(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Project Completion", style: AppTextStyle.ts16M()),
                    verticalSpacing(height: 15),
                    CustomTextField(
                      title: "Completion Timeline (Months)",
                      isRequired: true,
                      hint: "Enter Completion Timeline (Months)",
                      textController: _completionTimelineController,
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
                      textController: _gracePeriodController,
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
                    verticalSpacing(height: 30),
                    CustomButton(text: "Save", onPressed: _onSave),
                    verticalSpacing(),
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
