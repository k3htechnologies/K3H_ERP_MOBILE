import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/presentation/cubit/building_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class UpdateBuildingDetailsScreen extends StatefulWidget {
  final BuildingDetailsModel buildingDetailsModel;
  const UpdateBuildingDetailsScreen({
    super.key,
    required this.buildingDetailsModel,
  });

  @override
  State<UpdateBuildingDetailsScreen> createState() =>
      _UpdateBuildingDetailsScreenState();
}

class _UpdateBuildingDetailsScreenState
    extends State<UpdateBuildingDetailsScreen> {
  late BuildingCubit _buildingCubit;
  late ProjectModel _project;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // PLOT AREA KEYS
  late TextEditingController _grossPlotAreaController;
  late TextEditingController _plotAreaPhysicalSurveyController;
  late TextEditingController _plotAreaOldApprovedPlanController;
  late TextEditingController _plotAreaConveyanceController;
  late TextEditingController _plotAreaPRCardController;

  // CONSTRUCTION DETAILS KEYS
  late TextEditingController _totalCarpetAreaController;
  late TextEditingController _totalResidentialUnitsController;
  late TextEditingController _totalResidentialCarpetAreaController;
  late TextEditingController _totalCommercialUnitsController;
  late TextEditingController _totalCommercialCarpetAreaController;

  // CONTACT DETAILS KEYS
  // CONTRACT DETAILS CONTROLLERS - CHAIRMAN
  late TextEditingController _chairmanContactNameController;
  late TextEditingController _chairmanMobileNumberController;
  late TextEditingController _chairmanEmailIdController;

  // CONTACT DETAILS CONTROLLERS - SECRETARY
  late TextEditingController _secretaryContactNameController;
  late TextEditingController _secretaryMobileNumberController;
  late TextEditingController _secretaryEmailIdController;

  // CONTACT DETAILS CONTROLLERS - TREASURER
  late TextEditingController _treasurerContactNameController;
  late TextEditingController _treasurerMobileNumberController;
  late TextEditingController _treasurerEmailIdController;

  // CONTACT DETAILS CONTROLLERS - PMC
  late TextEditingController _pmcContactNameController;
  late TextEditingController _pmcMobileNumberController;
  late TextEditingController _pmcEmailIdController;

  // CONTACT DETAILS CONTROLLERS - BROKER
  late TextEditingController _brokerContactNameController;
  late TextEditingController _brokerMobileNumberController;
  late TextEditingController _brokerEmailIdController;

  @override
  void initState() {
    super.initState();
    _buildingCubit = context.read<BuildingCubit>();
    _project = getProject();
    _initializeControllers();

    _prefillDetails(widget.buildingDetailsModel);
  }

  @override
  void dispose() {
    // PLOT AREA Controllers
    _grossPlotAreaController.dispose();
    _plotAreaPhysicalSurveyController.dispose();
    _plotAreaOldApprovedPlanController.dispose();
    _plotAreaConveyanceController.dispose();
    _plotAreaPRCardController.dispose();

    // CONSTRUCTION DETAILS Controllers
    _totalCarpetAreaController.dispose();
    _totalResidentialUnitsController.dispose();
    _totalResidentialCarpetAreaController.dispose();
    _totalCommercialUnitsController.dispose();
    _totalCommercialCarpetAreaController.dispose();

    // CONTACT DETAILS CONTROLLERS - CHAIRMAN
    _chairmanContactNameController.dispose();
    _chairmanMobileNumberController.dispose();
    _chairmanEmailIdController.dispose();

    // CONTACT DETAILS CONTROLLERS - SECRETARY
    _secretaryContactNameController.dispose();
    _secretaryMobileNumberController.dispose();
    _secretaryEmailIdController.dispose();

    // CONTACT DETAILS CONTROLLERS - TREASURER
    _treasurerContactNameController.dispose();
    _treasurerMobileNumberController.dispose();
    _treasurerEmailIdController.dispose();

    // CONTACT DETAILS CONTROLLERS - PMC
    _pmcContactNameController.dispose();
    _pmcMobileNumberController.dispose();
    _pmcEmailIdController.dispose();

    // CONTACT DETAILS CONTROLLERS - BROKER
    _brokerContactNameController.dispose();
    _brokerMobileNumberController.dispose();
    _brokerEmailIdController.dispose();

    super.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initializeControllers() {
    _grossPlotAreaController = TextEditingController();
    _plotAreaPhysicalSurveyController = TextEditingController();
    _plotAreaOldApprovedPlanController = TextEditingController();
    _plotAreaConveyanceController = TextEditingController();
    _plotAreaPRCardController = TextEditingController();

    _totalCarpetAreaController = TextEditingController();
    _totalResidentialUnitsController = TextEditingController();
    _totalResidentialCarpetAreaController = TextEditingController();
    _totalCommercialUnitsController = TextEditingController();
    _totalCommercialCarpetAreaController = TextEditingController();

    _chairmanContactNameController = TextEditingController();
    _chairmanMobileNumberController = TextEditingController();
    _chairmanEmailIdController = TextEditingController();

    _secretaryContactNameController = TextEditingController();
    _secretaryMobileNumberController = TextEditingController();
    _secretaryEmailIdController = TextEditingController();

    _treasurerContactNameController = TextEditingController();
    _treasurerMobileNumberController = TextEditingController();
    _treasurerEmailIdController = TextEditingController();

    _pmcContactNameController = TextEditingController();
    _pmcMobileNumberController = TextEditingController();
    _pmcEmailIdController = TextEditingController();

    _brokerContactNameController = TextEditingController();
    _brokerMobileNumberController = TextEditingController();
    _brokerEmailIdController = TextEditingController();
  }

  // PREFILL DETAILS
  void _prefillDetails(BuildingDetailsModel buildingDetails) {
    _grossPlotAreaController.text =
        buildingDetails.grossPlotAreaSqFt.toString();
    _plotAreaPhysicalSurveyController.text =
        buildingDetails.plotAreaPhysicalSurveySqFt.toString();
    _plotAreaOldApprovedPlanController.text =
        buildingDetails.plotAreaOldApprovedPlanSqFt.toString();
    _plotAreaConveyanceController.text =
        buildingDetails.plotAreaConveyanceSqFt.toString();
    _plotAreaPRCardController.text =
        buildingDetails.plotAreaPRCardSqFt.toString();

    _totalCarpetAreaController.text =
        buildingDetails.totalCarpetAreaSqFt.toString();
    _totalResidentialUnitsController.text =
        buildingDetails.totalResidentialUnits.toString();
    _totalResidentialCarpetAreaController.text =
        buildingDetails.totalResidentialCarpetAreaSqFt.toString();
    _totalCommercialUnitsController.text =
        buildingDetails.totalCommercialUnits.toString();
    _totalCommercialCarpetAreaController.text =
        buildingDetails.totalCommercialCarpetAreaSqFt.toString();

    for (var contact in buildingDetails.buildingKeyContactDetailsData) {
      switch (contact.contactType) {
        case 'Chairman':
          _chairmanContactNameController.text = contact.contactName;
          _chairmanMobileNumberController.text = contact.mobileNumber;
          _chairmanEmailIdController.text = contact.emailId;
          break;
        case 'Secretary':
          _secretaryContactNameController.text = contact.contactName;
          _secretaryMobileNumberController.text = contact.mobileNumber;
          _secretaryEmailIdController.text = contact.emailId;
          break;
        case 'Treasurer':
          _treasurerContactNameController.text = contact.contactName;
          _treasurerMobileNumberController.text = contact.mobileNumber;
          _treasurerEmailIdController.text = contact.emailId;
          break;
        case 'PMC':
          _pmcContactNameController.text = contact.contactName;
          _pmcMobileNumberController.text = contact.mobileNumber;
          _pmcEmailIdController.text = contact.emailId;
          break;
        case 'Broker':
          _brokerContactNameController.text = contact.contactName;
          _brokerMobileNumberController.text = contact.mobileNumber;
          _brokerEmailIdController.text = contact.emailId;
          break;
      }
    }
  }

  // SAVE FORM
  void _saveForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final formData = {
        'BuildingId': widget.buildingDetailsModel.buildingId,
        'ProjectId': _project.projectId,
        'GrossPlotAreaSqFt':
            double.tryParse(_grossPlotAreaController.text) ?? 0.0,
        'PlotAreaPhysicalSurveySqFt':
            double.tryParse(_plotAreaPhysicalSurveyController.text) ?? 0.0,
        'PlotAreaOldApprovedPlanSqFt':
            double.tryParse(_plotAreaOldApprovedPlanController.text) ?? 0.0,
        'PlotAreaConveyanceSqFt':
            double.tryParse(_plotAreaConveyanceController.text) ?? 0.0,
        'PlotAreaPRCardSqFt':
            double.tryParse(_plotAreaPRCardController.text) ?? 0.0,
        'TotalCarpetAreaSqFt':
            double.tryParse(_totalCarpetAreaController.text) ?? 0.0,
        'TotalResidentialUnits':
            int.tryParse(_totalResidentialUnitsController.text) ?? 0,
        'TotalResidentialCarpetAreaSqFt':
            double.tryParse(_totalResidentialCarpetAreaController.text) ?? 0.0,
        'TotalCommercialUnits':
            int.tryParse(_totalCommercialUnitsController.text) ?? 0,
        'TotalCommercialCarpetAreaSqFt':
            double.tryParse(_totalCommercialCarpetAreaController.text) ?? 0.0,
        'BuildingKeyContactDetailsJSON': jsonEncode([
          {
            'ContactType': 'Chairman',
            'ContactName': _chairmanContactNameController.text.trim(),
            'MobileNumber': _chairmanMobileNumberController.text.trim(),
            'EmailId': _chairmanEmailIdController.text.trim(),
          },
          {
            'ContactType': 'Secretary',
            'ContactName': _secretaryContactNameController.text.trim(),
            'MobileNumber': _secretaryMobileNumberController.text.trim(),
            'EmailId': _secretaryEmailIdController.text.trim(),
          },
          {
            'ContactType': 'Treasurer',
            'ContactName': _treasurerContactNameController.text.trim(),
            'MobileNumber': _treasurerMobileNumberController.text.trim(),
            'EmailId': _treasurerEmailIdController.text.trim(),
          },
          {
            'ContactType': 'PMC',
            'ContactName': _pmcContactNameController.text.trim(),
            'MobileNumber': _pmcMobileNumberController.text.trim(),
            'EmailId': _pmcEmailIdController.text.trim(),
          },
          {
            'ContactType': 'Broker',
            'ContactName': _brokerContactNameController.text.trim(),
            'MobileNumber': _brokerMobileNumberController.text.trim(),
            'EmailId': _brokerEmailIdController.text.trim(),
          },
        ]),
      };

      _buildingCubit.updateBuildingDetails(
        context: context,
        buildingDetailsData: formData,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Building",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Update Building Details", style: AppTextStyle.ts14M()),
              verticalSpacing(),
              // PLOT AREA SECTION
              Container(
                padding: const EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Plot Area Details",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    CustomTextField(
                      title: 'Gross Plot Area (SqFt)',
                      hint: 'Enter Gross Plot Area',
                      textController: _grossPlotAreaController,
                      isRequired: true,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(7),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Gross Plot Area is required';
                        }
                        final numValue = double.tryParse(value);
                        if (numValue == null || numValue <= 0) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Plot Area Physical Survey (SqFt)',
                      hint: 'Enter Plot Area Physical Survey',
                      textController: _plotAreaPhysicalSurveyController,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(7),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final numValue = double.tryParse(value);
                          if (numValue == null || numValue < 0) {
                            return 'Please enter a valid number';
                          }
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Plot Area Old Approved Plan (SqFt)',
                      hint: 'Enter Plot Area Old Approved Plan',
                      textController: _plotAreaOldApprovedPlanController,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(7),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final numValue = double.tryParse(value);
                          if (numValue == null || numValue < 0) {
                            return 'Please enter a valid number';
                          }
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Plot Area Conveyance (SqFt)',
                      hint: 'Enter Plot Area Conveyance',
                      textController: _plotAreaConveyanceController,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(7),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final numValue = double.tryParse(value);
                          if (numValue == null || numValue < 0) {
                            return 'Please enter a valid number';
                          }
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Plot Area PR Card (SqFt)',
                      hint: 'Enter Plot Area PR Card',
                      textController: _plotAreaPRCardController,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(7),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final numValue = double.tryParse(value);
                          if (numValue == null || numValue < 0) {
                            return 'Please enter a valid number';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              verticalSpacing(),
              // CONSTRUCTION DETAILS SECTION
              Container(
                padding: const EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Construction Details",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    CustomTextField(
                      title: 'Total Built Up Area (SqFt)',
                      hint: 'Enter Total Built Up Area',
                      textController: _totalCarpetAreaController,
                      isRequired: true,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(7),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Total Built Up Area is required';
                        }
                        final numValue = double.tryParse(value);
                        if (numValue == null || numValue <= 0) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Total Residential Units',
                      hint: 'Enter Total Residential Units',
                      textController: _totalResidentialUnitsController,
                      keyboardType: TextInputType.number,
                      inputFormatterList: InputValidator.digit(4),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final numValue = int.tryParse(value);
                          if (numValue == null || numValue < 0) {
                            return 'Please enter a valid number';
                          }
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Total Residential Carpet Area (SqFt)',
                      hint: 'Enter Total Residential Carpet Area',
                      textController: _totalResidentialCarpetAreaController,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(7),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final numValue = double.tryParse(value);
                          if (numValue == null || numValue < 0) {
                            return 'Please enter a valid number';
                          }
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Total Commercial Units',
                      hint: 'Enter Total Commercial Units',
                      textController: _totalCommercialUnitsController,
                      keyboardType: TextInputType.number,
                      inputFormatterList: InputValidator.digit(4),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final numValue = int.tryParse(value);
                          if (numValue == null || numValue < 0) {
                            return 'Please enter a valid number';
                          }
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Total Commercial Carpet Area (SqFt)',
                      hint: 'Enter Total Commercial Carpet Area',
                      textController: _totalCommercialCarpetAreaController,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(7),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final numValue = double.tryParse(value);
                          if (numValue == null || numValue < 0) {
                            return 'Please enter a valid number';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              verticalSpacing(),
              // CONTACT DETAILS SECTION
              Container(
                padding: const EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Building Key Contact Details',
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    // Chairman
                    _buildContactSection(
                      'Chairman',
                      _chairmanContactNameController,
                      _chairmanMobileNumberController,
                      _chairmanEmailIdController,
                    ),
                    Divider(height: 10, color: AppColor.grey2),
                    // Secretary
                    _buildContactSection(
                      'Secretary',
                      _secretaryContactNameController,
                      _secretaryMobileNumberController,
                      _secretaryEmailIdController,
                    ),
                    Divider(height: 10, color: AppColor.grey2),
                    // Treasurer
                    _buildContactSection(
                      'Treasurer',
                      _treasurerContactNameController,
                      _treasurerMobileNumberController,
                      _treasurerEmailIdController,
                    ),
                    Divider(height: 10, color: AppColor.grey2),
                    // PMC
                    _buildContactSection(
                      'PMC',
                      _pmcContactNameController,
                      _pmcMobileNumberController,
                      _pmcEmailIdController,
                    ),
                    Divider(height: 10, color: AppColor.grey2),
                    // Broker
                    _buildContactSection(
                      'Broker',
                      _brokerContactNameController,
                      _brokerMobileNumberController,
                      _brokerEmailIdController,
                    ),
                  ],
                ),
              ),
              verticalSpacing(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            text: "Update Building Details",
            onPressed: _saveForm,
          ),
        ),
      ),
    );
  }

  // BUILD CONTACT SECTION
  Widget _buildContactSection(
    String contactType,
    TextEditingController nameController,
    TextEditingController mobileController,
    TextEditingController emailController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpacing(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          decoration: BoxDecoration(
            color: AppColor.lightGrey,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColor.grey2),
          ),
          child: Text(contactType, style: AppTextStyle.ts14M()),
        ),
        verticalSpacing(),
        CustomTextField(
          title: 'Contact Name',
          textController: nameController,
          hint: 'Enter Contact Name',
          inputFormatterList: InputValidator.textOnly(50),
        ),
        CustomTextField(
          title: 'Mobile Number',
          textController: mobileController,
          hint: 'Enter Mobile Number',
          keyboardType: TextInputType.number,
          inputFormatterList: InputValidator.digit(10),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!InputValidator.isValidMobileNumber(value)) {
                return 'Invalid Mobile Number';
              }
            }
            return null;
          },
        ),
        CustomTextField(
          title: 'Email ID',
          textController: emailController,
          hint: 'Enter Email ID',
          inputFormatterList: InputValidator.emailInputFormatters(),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!InputValidator.isValidEmail(value)) {
                return 'Email id is invalid';
              }
            }
            return null;
          },
        ),
      ],
    );
  }
}
