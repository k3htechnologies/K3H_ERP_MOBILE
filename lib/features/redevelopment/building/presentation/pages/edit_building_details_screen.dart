import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/presentation/cubit/building_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class EditBuildingDetailsScreen extends StatefulWidget {
  final BuildingDetailsModel buildingDetailsModel;
  const EditBuildingDetailsScreen({
    super.key,
    required this.buildingDetailsModel,
  });

  @override
  State<EditBuildingDetailsScreen> createState() =>
      _EditBuildingDetailsScreenState();
}

class _EditBuildingDetailsScreenState extends State<EditBuildingDetailsScreen> {
  late BuildingCubit _buildingCubit;
  late ProjectModel _project;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // Plot Area Controllers
  late TextEditingController _grossPlotAreaController;
  late TextEditingController _plotAreaPhysicalSurveyController;
  late TextEditingController _plotAreaOldApprovedPlanController;
  late TextEditingController _plotAreaConveyanceController;
  late TextEditingController _plotAreaPRCardController;

  // Construction Details Controllers
  late TextEditingController _totalBuiltUpAreaController;
  late TextEditingController _totalResidentialUnitsController;
  late TextEditingController _totalResidentialCarpetAreaController;
  late TextEditingController _totalCommercialUnitsController;
  late TextEditingController _totalCommercialCarpetAreaController;

  // Contact Details Controllers - Chairman
  late TextEditingController _chairmanContactNameController;
  late TextEditingController _chairmanMobileNumberController;
  late TextEditingController _chairmanEmailIdController;

  // Contact Details Controllers - Secretary
  late TextEditingController _secretaryContactNameController;
  late TextEditingController _secretaryMobileNumberController;
  late TextEditingController _secretaryEmailIdController;

  // Contact Details Controllers - Treasurer
  late TextEditingController _treasurerContactNameController;
  late TextEditingController _treasurerMobileNumberController;
  late TextEditingController _treasurerEmailIdController;

  // Contact Details Controllers - PMC
  late TextEditingController _pmcContactNameController;
  late TextEditingController _pmcMobileNumberController;
  late TextEditingController _pmcEmailIdController;

  // Contact Details Controllers - Broker
  late TextEditingController _brokerContactNameController;
  late TextEditingController _brokerMobileNumberController;
  late TextEditingController _brokerEmailIdController;

  @override
  void initState() {
    super.initState();
    _buildingCubit = context.read<BuildingCubit>();
    _project = getProject();
    _initializeControllers();

    // Prefill details from the passed model
    _prefillDetails(widget.buildingDetailsModel);
  }

  @override
  void dispose() {
    // Plot Area Controllers
    _grossPlotAreaController.dispose();
    _plotAreaPhysicalSurveyController.dispose();
    _plotAreaOldApprovedPlanController.dispose();
    _plotAreaConveyanceController.dispose();
    _plotAreaPRCardController.dispose();

    // Construction Details Controllers
    _totalBuiltUpAreaController.dispose();
    _totalResidentialUnitsController.dispose();
    _totalResidentialCarpetAreaController.dispose();
    _totalCommercialUnitsController.dispose();
    _totalCommercialCarpetAreaController.dispose();

    // Contact Details Controllers - Chairman
    _chairmanContactNameController.dispose();
    _chairmanMobileNumberController.dispose();
    _chairmanEmailIdController.dispose();

    // Contact Details Controllers - Secretary
    _secretaryContactNameController.dispose();
    _secretaryMobileNumberController.dispose();
    _secretaryEmailIdController.dispose();

    // Contact Details Controllers - Treasurer
    _treasurerContactNameController.dispose();
    _treasurerMobileNumberController.dispose();
    _treasurerEmailIdController.dispose();

    // Contact Details Controllers - PMC
    _pmcContactNameController.dispose();
    _pmcMobileNumberController.dispose();
    _pmcEmailIdController.dispose();

    // Contact Details Controllers - Broker
    _brokerContactNameController.dispose();
    _brokerMobileNumberController.dispose();
    _brokerEmailIdController.dispose();

    super.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initializeControllers() {
    // Plot Area Controllers
    _grossPlotAreaController = TextEditingController();
    _plotAreaPhysicalSurveyController = TextEditingController();
    _plotAreaOldApprovedPlanController = TextEditingController();
    _plotAreaConveyanceController = TextEditingController();
    _plotAreaPRCardController = TextEditingController();

    // Construction Details Controllers
    _totalBuiltUpAreaController = TextEditingController();
    _totalResidentialUnitsController = TextEditingController();
    _totalResidentialCarpetAreaController = TextEditingController();
    _totalCommercialUnitsController = TextEditingController();
    _totalCommercialCarpetAreaController = TextEditingController();

    // Contact Details Controllers - Chairman
    _chairmanContactNameController = TextEditingController();
    _chairmanMobileNumberController = TextEditingController();
    _chairmanEmailIdController = TextEditingController();

    // Contact Details Controllers - Secretary
    _secretaryContactNameController = TextEditingController();
    _secretaryMobileNumberController = TextEditingController();
    _secretaryEmailIdController = TextEditingController();

    // Contact Details Controllers - Treasurer
    _treasurerContactNameController = TextEditingController();
    _treasurerMobileNumberController = TextEditingController();
    _treasurerEmailIdController = TextEditingController();

    // Contact Details Controllers - PMC
    _pmcContactNameController = TextEditingController();
    _pmcMobileNumberController = TextEditingController();
    _pmcEmailIdController = TextEditingController();

    // Contact Details Controllers - Broker
    _brokerContactNameController = TextEditingController();
    _brokerMobileNumberController = TextEditingController();
    _brokerEmailIdController = TextEditingController();
  }

  // PREFILL DETAILS
  void _prefillDetails(BuildingDetailsModel buildingDetails) {
    // Plot Area Fields
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

    // Construction Details Fields
    _totalBuiltUpAreaController.text =
        buildingDetails.totalBuiltUpAreaSqFt.toString();
    _totalResidentialUnitsController.text =
        buildingDetails.totalResidentialUnits.toString();
    _totalResidentialCarpetAreaController.text =
        buildingDetails.totalResidentialCarpetAreaSqFt.toString();
    _totalCommercialUnitsController.text =
        buildingDetails.totalCommercialUnits.toString();
    _totalCommercialCarpetAreaController.text =
        buildingDetails.totalCommercialCarpetAreaSqFt.toString();

    // Contact Details Fields
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
        'TotalBuiltUpAreaSqFt':
            double.tryParse(_totalBuiltUpAreaController.text) ?? 0.0,
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

  // BUILD CONTACT SECTION
  Widget _buildContactSection(
    String contactType,
    TextEditingController nameController,
    TextEditingController mobileController,
    TextEditingController emailController,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.grey30),
        borderRadius: BorderRadius.circular(8.0),
        color: AppColor.grey30.withValues(alpha: 0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            contactType,
            style: AppTextStyle.ts14M(color: AppColor.primary),
          ),
          verticalSpacing(),
          CustomTextField(
            title: 'Contact Name',
            textController: nameController,
            hint: 'Enter Contact Name',
            inputFormatterList: InputValidator.textOnly(50),
          ),
          verticalSpacing(),
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
          verticalSpacing(),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Update Building Details",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Update Building Details",
                    style: AppTextStyle.ts16SB(),
                  ),
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
                          title: 'Gross Plot Area (Sq Ft)',
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
                        verticalSpacing(),
                        CustomTextField(
                          title: 'Plot Area Physical Survey (Sq Ft)',
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
                        verticalSpacing(),
                        CustomTextField(
                          title: 'Plot Area Old Approved Plan (Sq Ft)',
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
                        verticalSpacing(),
                        CustomTextField(
                          title: 'Plot Area Conveyance (Sq Ft)',
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
                        verticalSpacing(),
                        CustomTextField(
                          title: 'Plot Area PR Card (Sq Ft)',
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
                          title: 'Total Built Up Area (Sq Ft)',
                          hint: 'Enter Total Built Up Area',
                          textController: _totalBuiltUpAreaController,
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
                        verticalSpacing(),
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
                        verticalSpacing(),
                        CustomTextField(
                          title: 'Total Residential Carpet Area (Sq Ft)',
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
                        verticalSpacing(),
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
                        verticalSpacing(),
                        CustomTextField(
                          title: 'Total Commercial Carpet Area (Sq Ft)',
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
                        verticalSpacing(),
                        // Secretary
                        _buildContactSection(
                          'Secretary',
                          _secretaryContactNameController,
                          _secretaryMobileNumberController,
                          _secretaryEmailIdController,
                        ),
                        verticalSpacing(),
                        // Treasurer
                        _buildContactSection(
                          'Treasurer',
                          _treasurerContactNameController,
                          _treasurerMobileNumberController,
                          _treasurerEmailIdController,
                        ),
                        verticalSpacing(),
                        // PMC
                        _buildContactSection(
                          'PMC',
                          _pmcContactNameController,
                          _pmcMobileNumberController,
                          _pmcEmailIdController,
                        ),
                        verticalSpacing(),
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
}
