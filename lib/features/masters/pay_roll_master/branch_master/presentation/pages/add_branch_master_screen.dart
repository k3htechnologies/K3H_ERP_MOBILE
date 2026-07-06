import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/designation_master/presentation/pages/module_access_screen.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/data/model/branch_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/presentation/cubit/branch_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/project_master/presentation/pages/add_bank_details_screen.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart'
    hide UpperCaseTextFormatter;
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddBranchMasterScreen extends StatefulWidget {
  final BranchMasterModel? branch;
  final int index;
  const AddBranchMasterScreen({super.key, this.branch, this.index = 0});

  @override
  State<AddBranchMasterScreen> createState() => _AddBranchMasterScreenState();
}

class _AddBranchMasterScreenState extends State<AddBranchMasterScreen> {
  // CUBIT
  late BranchMasterCubit _branchMasterCubit;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _branchNameC, _branchCodeC, _locationC;

  bool get _isEditMode => widget.branch != null;

  // FORM KEY
  final _branchMasterAddUpdateKey = GlobalKey<FormState>();

  // HEAD OFFICE CHECK BOX DEFAULT VALUE
  bool isHeadOffice = false;

  @override
  void initState() {
    super.initState();
    initializeTextEditingController();
    _branchMasterCubit = context.read<BranchMasterCubit>();
    if (_isEditMode && widget.branch != null) {
      _prefillToAddUpdateBranchMaster(widget.branch!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _branchNameC.dispose();
    _branchCodeC.dispose();
    _locationC.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void initializeTextEditingController() {
    _branchNameC = TextEditingController();
    _branchCodeC = TextEditingController();
    _locationC = TextEditingController();
  }

  // PREFILL TO ADD UPDATE BRANCH MASTER
  void _prefillToAddUpdateBranchMaster(BranchMasterModel branchModel) {
    _branchNameC.text = branchModel.branchName;
    _branchCodeC.text = branchModel.branchCode;
    _locationC.text = branchModel.location;
    isHeadOffice = branchModel.isHeadOffice;
  }

  // SUBMIT FORM
  void _submitForm() {
    if (!_branchMasterAddUpdateKey.currentState!.validate()) {
      return;
    }

    if (_isEditMode && widget.branch != null) {
      _branchMasterCubit.updateBranchMaster(
        context: context,
        branchMasterId: widget.branch!.branchMasterId,
        uniqueKey: widget.branch!.uniquekey,
        branchName: _branchNameC.text.trim(),
        branchCode: _branchCodeC.text.trim(),
        location: _locationC.text.trim(),
        isHeadOffice: isHeadOffice,
        index: widget.index,
      );
    } else {
      _branchMasterCubit.addBranchMaster(
        context: context,
        branchName: _branchNameC.text.trim(),
        branchCode: _branchCodeC.text.trim(),
        location: _locationC.text.trim(),
        isHeadOffice: isHeadOffice,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Branch Master",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Form(
          key: _branchMasterAddUpdateKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(
                _isEditMode ? "Update Branch" : "Add Branch",
                style: AppTextStyle.ts16SB(),
              ),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    CustomTextField(
                      title: 'Branch Name',
                      textController: _branchNameC,
                      isRequired: true,
                      hint: 'Enter Branch Name',
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(50),
                      ],
                      validator: (string) {
                        if (string == null || string.trim().isEmpty) {
                          return 'Branch Name is required';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Branch Code',
                      hint: 'Enter Branch Code',
                      textController: _branchCodeC,
                      isRequired: true,
                      inputFormatterList: [
                        UpperCaseTextFormatter(),
                        LengthLimitingTextInputFormatter(4),
                        AlphaNumericWithoutSpacesFormatter(),
                      ],
                      validator: (string) {
                        if (string == null || string.trim().isEmpty) {
                          return 'Branch Code is required';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Location',
                      hint: 'Enter Location',
                      minLines: 3,
                      maxLines: 3,
                      textController: _locationC,
                      isRequired: true,
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(200),
                      ],
                      validator: (string) {
                        if (string == null || string.trim().isEmpty) {
                          return 'Location is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    StatefulBuilder(
                      builder: (context, innerState) {
                        return CustomCheckBox(
                          onChanged: (value) {
                            innerState(() {
                              isHeadOffice = value;
                            });
                          },
                          isSelected: isHeadOffice,
                          title: "Head Office",
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
          padding: EdgeInsets.all(16),
          child: CustomButton(
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              size: 18,
              color: AppColor.white,
            ),
            text: _isEditMode ? "Update" : "Add",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
