import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/designation_master/presentation/pages/module_access_screen.dart';
import 'package:k3h_erp_app/features/payroll/resignation/data/model/resignation.model.dart';
import 'package:k3h_erp_app/features/payroll/resignation/presentation/cubit/resignation_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddResignationScreen extends StatefulWidget {
  final ResignationModel? resignationModel;
  final int index;
  const AddResignationScreen({
    super.key,
    required this.resignationModel,
    this.index = 0,
  });

  @override
  State<AddResignationScreen> createState() => _AddResignationScreenState();
}

class _AddResignationScreenState extends State<AddResignationScreen> {
  // CUBIT
  late ResignationCubit _resignationCubit;

  // FORM KEY
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // DATE VARIABLE
  DateTime? resignationDate, expectedRelievingDate;

  // TEXT CONTROLLER
  late TextEditingController reasonC, offerAmountC;

  // FILE PICKER
  MultiFilePickerModel offerLetter = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  ValueNotifier<bool> isOfferInHand = ValueNotifier(false);

  //EDIT MODE
  bool get _isEditMode => widget.resignationModel != null;
  late UserModel userModel;
  @override
  void initState() {
    super.initState();
    _initializeTextEditingControllers();
    _resignationCubit = context.read<ResignationCubit>();
    getCurrentUser();
    if (_isEditMode) {
      _populateFormFields(widget.resignationModel!);
    }
  }

  void _initializeTextEditingControllers() {
    reasonC = TextEditingController();
    offerAmountC = TextEditingController();
  }

  void _populateFormFields(ResignationModel resignation) {
    resignationDate = resignation.resignationDate;
    reasonC.text = resignation.reasonOfLeaving;

    expectedRelievingDate = resignation.expectedRelievingDate;
    isOfferInHand.value = resignation.isAnyOfferInHand;
    if (resignation.offerAmount > 0.0) {
      offerAmountC.text = resignation.offerAmount.toString();
    }
    if (resignation.offerLetterUrl.isNotEmpty) {
      offerLetter.fileNameList = resignation.offerLetterUrl.split(",");
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_isEditMode) {
        _resignationCubit.updateLeave(
          index: widget.index,
          context: context,
          employeeResignationId:
              widget.resignationModel!.employeeResignationId.toString(),
          uniquekey: widget.resignationModel!.uniqueKey,
          employeeId: widget.resignationModel!.employeeId.toString(),
          resignationDate: DateTime.now().toIso8601String(),
          expectedRelievingDate:
              expectedRelievingDate != null
                  ? expectedRelievingDate!.toIso8601String()
                  : "",
          reasonOfLeaving: reasonC.text.trim(),
          isAnyOfferInHand: isOfferInHand.value,
          offerAmount: isOfferInHand.value ? offerAmountC.text.trim() : "0",
          offerLetter: offerLetter,
        );
      } else {
        _resignationCubit.addResignation(
          context: context,
          employeeId: userModel.employeeId.toString(),
          resignationDate: DateTime.now().toIso8601String().split('T').first,
          expectedRelievingDate:
              expectedRelievingDate != null
                  ? expectedRelievingDate!.toIso8601String().split('T').first
                  : "",
          reasonOfLeaving: reasonC.text.trim(),
          isAnyOfferInHand: isOfferInHand.value,
          offerAmount: isOfferInHand.value ? offerAmountC.text.trim() : "0",
          offerLetter: offerLetter,
        );
      }
    }
  }

  Future getCurrentUser() async {
    var userJson = jsonDecode(
      LocalStorageManager().getString(StorageKey.currentUser) ?? "",
    );
    userModel = UserModel.fromJson(userJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Resignation",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditMode ? "Update Resignation" : "Add Resignation",
              style: AppTextStyle.ts14M(),
            ),
            verticalSpacing(),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: commonCardDecoration(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomDatePicker(
                      title: 'Resignation Date',
                      isRequired: true,
                      readOnly: true,
                      initialDate: DateTime.now(),
                      validator: (value) {
                        if (value == null) {
                          return 'Resignation Date is required';
                        }
                        return null;
                      },
                      setValue: (value) => resignationDate = value,
                    ),
                    CustomTextField(
                      textController: reasonC,
                      title: 'Reason Of Leaving',
                      maxLines: 10,
                      minLines: 3,
                      isRequired: true,
                      hint: 'Enter Reason Of Leaving',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Reason Of Leaving is required";
                        }
                        return null;
                      },
                    ),
                    CustomDatePicker(
                      title: 'Expected Relieving Date',
                      initialDate: expectedRelievingDate,
                      startDate: DateTime.now(),
                      setValue: (value) => expectedRelievingDate = value,
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: isOfferInHand,
                      builder: (context, value, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomCheckBox(
                              isSelected: value,
                              onChanged: (newValue) {
                                isOfferInHand.value = newValue;
                              },
                              title: "Offer In Hand",
                            ),
                            verticalSpacing(),
                            CustomTextField(
                              textController: offerAmountC,
                              title: 'Offer Amount',
                              isRequired: value,
                              readOnly: !value,
                              hint: 'Enter Offer Amount',
                              inputFormatterList: InputValidator.digit(8),
                              validator: (value) {
                                if ((value == null || value.trim().isEmpty) &&
                                    isOfferInHand.value) {
                                  return "Offer Amoun is required";
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                            ),
                            CustomMultiFilePicker(
                              title: "Offer Letter",
                              filePickType: FilePickType.kycDocument,
                              isRequired: value,
                              readOnly: !value,
                              validator: (val) {
                                if ((val == null || val.isEmpty) &&
                                    isOfferInHand.value) {
                                  return "Offer Letter is required";
                                }
                                return null;
                              },
                              initialFileList: offerLetter.fileNameList,
                              onFilePickedCallback: (bytesList, fileNameList) {
                                offerLetter.fileNameList = fileNameList;
                                offerLetter.fileBytesList = bytesList;
                              },
                              onFileDeleteCallback: (
                                fileBytesList,
                                fileNameList,
                                deleted,
                              ) {
                                offerLetter.fileBytesList = fileBytesList;
                                offerLetter.fileNameList = fileNameList;
                                offerLetter.deletedFileList = deleted;
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              size: 16,
              color: AppColor.white,
            ),
            text: _isEditMode ? "Update" : "Add",
            onPressed: _handleSubmit,
          ),
        ),
      ),
    );
  }
}
