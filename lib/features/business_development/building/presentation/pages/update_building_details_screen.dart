
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/features/business_development/building/data/model/building_details.model.dart';
import 'package:k3h_erp_app/features/business_development/building/presentation/cubit/building_cubit.dart';
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

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _grossPlotAreaC,
      _plotAreaPhysicalSurveyC,
      _plotAreaOldApprovedPlanC,
      _plotAreaConveyanceC,
      _plotAreaPRCardC,
      _totalCarpetAreaC,
      _totalResidentialUnitsC,
      _totalResidentialCarpetAreaC,
      _totalCommercialUnitsC,
      _totalCommercialCarpetAreaC,
      _garageCarpetAreaC,
      _terraceCarpetAreaC,
      _chairmanContactNameC,
      _chairmanMobileNumberC,
      _chairmanEmailIdC,
      _secretaryContactNameC,
      _secretaryMobileNumberC,
      _secretaryEmailIdC,
      _treasurerContactNameC,
      _treasurerMobileNumberC,
      _treasurerEmailIdC,
      _pmcContactNameC,
      _pmcMobileNumberC,
      _pmcEmailIdC,
      _brokerContactNameC,
      _brokerMobileNumberC,
      _brokerEmailIdC;

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
    _grossPlotAreaC.dispose();
    _plotAreaPhysicalSurveyC.dispose();
    _plotAreaOldApprovedPlanC.dispose();
    _plotAreaConveyanceC.dispose();
    _plotAreaPRCardC.dispose();

    // CONSTRUCTION DETAILS Controllers
    _totalCarpetAreaC.dispose();
    _totalResidentialUnitsC.dispose();
    _totalResidentialCarpetAreaC.dispose();
    _totalCommercialUnitsC.dispose();
    _totalCommercialCarpetAreaC.dispose();
    _garageCarpetAreaC.dispose();
    _terraceCarpetAreaC.dispose();
    // CONTACT DETAILS CONTROLLERS - CHAIRMAN
    _chairmanContactNameC.dispose();
    _chairmanMobileNumberC.dispose();
    _chairmanEmailIdC.dispose();

    // CONTACT DETAILS CONTROLLERS - SECRETARY
    _secretaryContactNameC.dispose();
    _secretaryMobileNumberC.dispose();
    _secretaryEmailIdC.dispose();

    // CONTACT DETAILS CONTROLLERS - TREASURER
    _treasurerContactNameC.dispose();
    _treasurerMobileNumberC.dispose();
    _treasurerEmailIdC.dispose();

    // CONTACT DETAILS CONTROLLERS - PMC
    _pmcContactNameC.dispose();
    _pmcMobileNumberC.dispose();
    _pmcEmailIdC.dispose();

    // CONTACT DETAILS CONTROLLERS - BROKER
    _brokerContactNameC.dispose();
    _brokerMobileNumberC.dispose();
    _brokerEmailIdC.dispose();

    super.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initializeControllers() {
    _grossPlotAreaC = TextEditingController();
    _plotAreaPhysicalSurveyC = TextEditingController();
    _plotAreaOldApprovedPlanC = TextEditingController();
    _plotAreaConveyanceC = TextEditingController();
    _plotAreaPRCardC = TextEditingController();

    _totalCarpetAreaC = TextEditingController();
    _totalResidentialUnitsC = TextEditingController();
    _totalResidentialCarpetAreaC = TextEditingController();
    _totalCommercialUnitsC = TextEditingController();
    _totalCommercialCarpetAreaC = TextEditingController();
    _garageCarpetAreaC = TextEditingController();
    _terraceCarpetAreaC = TextEditingController();

    _chairmanContactNameC = TextEditingController();
    _chairmanMobileNumberC = TextEditingController();
    _chairmanEmailIdC = TextEditingController();

    _secretaryContactNameC = TextEditingController();
    _secretaryMobileNumberC = TextEditingController();
    _secretaryEmailIdC = TextEditingController();

    _treasurerContactNameC = TextEditingController();
    _treasurerMobileNumberC = TextEditingController();
    _treasurerEmailIdC = TextEditingController();

    _pmcContactNameC = TextEditingController();
    _pmcMobileNumberC = TextEditingController();
    _pmcEmailIdC = TextEditingController();

    _brokerContactNameC = TextEditingController();
    _brokerMobileNumberC = TextEditingController();
    _brokerEmailIdC = TextEditingController();
  }

  // PREFILL DETAILS
  void _prefillDetails(BuildingDetailsModel buildingDetails) {
    _grossPlotAreaC.text = buildingDetails.grossPlotAreaSqFt.toString();
    _plotAreaPhysicalSurveyC.text =
        buildingDetails.plotAreaPhysicalSurveySqFt.toString();
    _plotAreaOldApprovedPlanC.text =
        buildingDetails.plotAreaOldApprovedPlanSqFt.toString();
    _plotAreaConveyanceC.text =
        buildingDetails.plotAreaConveyanceSqFt.toString();
    _plotAreaPRCardC.text = buildingDetails.plotAreaPRCardSqFt.toString();

    _totalCarpetAreaC.text = buildingDetails.totalCarpetAreaSqFt.toString();
    _totalResidentialUnitsC.text =
        buildingDetails.totalResidentialUnits.toString();
    _totalResidentialCarpetAreaC.text =
        buildingDetails.totalResidentialCarpetAreaSqFt.toString();
    _totalCommercialUnitsC.text =
        buildingDetails.totalCommercialUnits.toString();
    _totalCommercialCarpetAreaC.text =
        buildingDetails.totalCommercialCarpetAreaSqFt.toString();
    _garageCarpetAreaC.text = buildingDetails.garageCarpetAreaSqFt.toString();
    _terraceCarpetAreaC.text = buildingDetails.terraceCarpetAreaSqFt.toString();

    for (var contact in buildingDetails.buildingKeyContactDetailsData) {
      switch (contact.contactType) {
        case 'Chairman':
          _chairmanContactNameC.text = contact.contactName;
          _chairmanMobileNumberC.text = contact.mobileNumber;
          _chairmanEmailIdC.text = contact.emailId;
          break;
        case 'Secretary':
          _secretaryContactNameC.text = contact.contactName;
          _secretaryMobileNumberC.text = contact.mobileNumber;
          _secretaryEmailIdC.text = contact.emailId;
          break;
        case 'Treasurer':
          _treasurerContactNameC.text = contact.contactName;
          _treasurerMobileNumberC.text = contact.mobileNumber;
          _treasurerEmailIdC.text = contact.emailId;
          break;
        case 'PMC':
          _pmcContactNameC.text = contact.contactName;
          _pmcMobileNumberC.text = contact.mobileNumber;
          _pmcEmailIdC.text = contact.emailId;
          break;
        case 'Broker':
          _brokerContactNameC.text = contact.contactName;
          _brokerMobileNumberC.text = contact.mobileNumber;
          _brokerEmailIdC.text = contact.emailId;
          break;
      }
    }
  }

  // SAVE FORM
  void _saveForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _buildingCubit.updateBuildingDetails(
        context: context,
        buildingId: widget.buildingDetailsModel.buildingId,
        projectId: _project.projectId,
        grossPlotAreaSqFt: double.tryParse(_grossPlotAreaC.text) ?? 0.0,
        plotAreaPhysicalSurveySqFt:
            double.tryParse(_plotAreaPhysicalSurveyC.text) ?? 0.0,
        plotAreaOldApprovedPlanSqFt:
            double.tryParse(_plotAreaOldApprovedPlanC.text) ?? 0.0,
        plotAreaConveyanceSqFt:
            double.tryParse(_plotAreaConveyanceC.text) ?? 0.0,
        plotAreaPRCardSqFt: double.tryParse(_plotAreaPRCardC.text) ?? 0.0,
        totalCarpetAreaSqFt: double.tryParse(_totalCarpetAreaC.text) ?? 0.0,
        totalResidentialUnits: int.tryParse(_totalResidentialUnitsC.text) ?? 0,
        totalResidentialCarpetAreaSqFt:
            double.tryParse(_totalResidentialCarpetAreaC.text) ?? 0.0,
        totalCommercialUnits: int.tryParse(_totalCommercialUnitsC.text) ?? 0,
        totalCommercialCarpetAreaSqFt:
            double.tryParse(_totalCommercialCarpetAreaC.text) ?? 0.0,
        garageCarpetAreaSqFt: double.tryParse(_garageCarpetAreaC.text) ?? 0.0,
        terraceCarpetAreaSqFt: double.tryParse(_terraceCarpetAreaC.text) ?? 0.0,
        chairmanContactName: _chairmanContactNameC.text.trim(),
        chairmanMobileNumber: _chairmanMobileNumberC.text.trim(),
        chairmanEmailId: _chairmanEmailIdC.text.trim(),
        secretaryContactName: _secretaryContactNameC.text.trim(),
        secretaryMobileNumber: _secretaryMobileNumberC.text.trim(),
        secretaryEmailId: _secretaryEmailIdC.text.trim(),
        treasurerContactName: _treasurerContactNameC.text.trim(),
        treasurerMobileNumber: _treasurerMobileNumberC.text.trim(),
        treasurerEmailId: _treasurerEmailIdC.text.trim(),
        pmcContactName: _pmcContactNameC.text.trim(),
        pmcMobileNumber: _pmcMobileNumberC.text.trim(),
        pmcEmailId: _pmcEmailIdC.text.trim(),
        brokerContactName: _brokerContactNameC.text.trim(),
        brokerMobileNumber: _brokerMobileNumberC.text.trim(),
        brokerEmailId: _brokerEmailIdC.text.trim(),
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
                      textController: _grossPlotAreaC,
                      isRequired: true,
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 16,
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
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
                      title: 'Plot Area Physical Survey (SqMt)',
                      hint: 'Enter Plot Area Physical Survey',
                      textController: _plotAreaPhysicalSurveyC,
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 16,
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
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
                      textController: _plotAreaOldApprovedPlanC,
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 16,
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
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
                      textController: _plotAreaConveyanceC,
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 16,
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
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
                      textController: _plotAreaPRCardC,
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 16,
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
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
                      textController: _totalCarpetAreaC,
                      isRequired: true,
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 16,
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
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
                      textController: _totalResidentialUnitsC,
                      keyboardType: TextInputType.number,
                      inputFormatterList: InputValidator.digit(9),
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
                      textController: _totalResidentialCarpetAreaC,
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 16,
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
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
                      textController: _totalCommercialUnitsC,
                      keyboardType: TextInputType.number,
                      inputFormatterList: InputValidator.digit(9),
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
                      textController: _totalCommercialCarpetAreaC,
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 16,
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
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
                      title: 'Garage Carpet Area (SqFt)',
                      hint: 'Enter Garage Carpet Area',
                      textController: _garageCarpetAreaC,
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 16,
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
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
                      title: 'Terrace Carpet Area (SqFt)',
                      hint: 'Enter Terrace Carpet Area (SqFt)',
                      textController: _terraceCarpetAreaC,
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 16,
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
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
                    _buildContactSection(
                      'Chairman',
                      _chairmanContactNameC,
                      _chairmanMobileNumberC,
                      _chairmanEmailIdC,
                    ),
                    Divider(height: 10, color: AppColor.grey2),
                    _buildContactSection(
                      'Secretary',
                      _secretaryContactNameC,
                      _secretaryMobileNumberC,
                      _secretaryEmailIdC,
                    ),
                    Divider(height: 10, color: AppColor.grey2),
                    _buildContactSection(
                      'Treasurer',
                      _treasurerContactNameC,
                      _treasurerMobileNumberC,
                      _treasurerEmailIdC,
                    ),
                    Divider(height: 10, color: AppColor.grey2),
                    _buildContactSection(
                      'PMC',
                      _pmcContactNameC,
                      _pmcMobileNumberC,
                      _pmcEmailIdC,
                    ),
                    Divider(height: 10, color: AppColor.grey2),
                    _buildContactSection(
                      'Broker',
                      _brokerContactNameC,
                      _brokerMobileNumberC,
                      _brokerEmailIdC,
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
