import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/designation_master/presentation/pages/module_access_screen.dart';
import 'package:k3h_erp_app/features/payroll/resignation/data/model/resignation.model.dart';
import 'package:k3h_erp_app/features/payroll/resignation/presentation/cubit/resignation_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
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
  DateTime? resignationDate, relievingDate;

  // TEXT CONTROLLER
  late TextEditingController reasonC, offerAmountC;

  // FILE PICKER
  MultiFilePickerModel offerLetter = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  ValueNotifier<bool> isEarlyRealise = ValueNotifier(false);
  ValueNotifier<bool> isOfferInHand = ValueNotifier(false);

  //EDIT MODE
  bool get _isEditMode => widget.resignationModel != null;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeTextEditingControllers();
    _resignationCubit = context.read<ResignationCubit>();
    if (_isEditMode) {
      _prefillDataForEdit(widget.resignationModel!);
    }
  }

  void _initializeTextEditingControllers() {
    reasonC = TextEditingController();
    offerAmountC = TextEditingController();
  }

  void _prefillDataForEdit(ResignationModel resignation) {
    if (_isEditMode) {
      resignationDate = resignation.resignationDate;
      relievingDate = resignation.expectedRelievingDate;
      reasonC.text = resignation.reasonOfLeaving;
      isEarlyRealise.value = resignation.expectedRelievingDate != null;
      isOfferInHand.value = resignation.isAnyOfferInHand;
      offerAmountC.text = resignation.offerAmount.toString();
      if (resignation.offerLetterUrl.isNotEmpty) {
        offerLetter.fileNameList = [resignation.offerLetterUrl];
      }
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
          resignationDate: resignationDate!.toIso8601String(),
          expectedRelievingDate:
              isEarlyRealise.value && relievingDate != null
                  ? relievingDate!.toIso8601String()
                  : "",
          reasonOfLeaving: reasonC.text.trim(),
          isAnyOfferInHand: isOfferInHand.value,
          offerAmount: isOfferInHand.value ? offerAmountC.text.trim() : "0",
          offerLetter: offerLetter,
        );
      } else {
        _resignationCubit.addResignation(
          context: context,
          employeeId: "", // Pass the appropriate employee ID here
          resignationDate: resignationDate!.toIso8601String().split('T').first,
          expectedRelievingDate:
              isEarlyRealise.value && relievingDate != null
                  ? relievingDate!.toIso8601String().split('T').first
                  : "",
          reasonOfLeaving: reasonC.text.trim(),
          isAnyOfferInHand: isOfferInHand.value,
          offerAmount: isOfferInHand.value ? offerAmountC.text.trim() : "0",
          offerLetter: offerLetter,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: _isEditMode ? "Update Resignation" : "Add Resignation",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: commonCardDecoration(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomDatePicker(
                        title: 'Resignation Date',
                        isRequired: true,
                        initialDate: resignationDate,
                        validator: (value) {
                          if (value == null) {
                            return 'Resignation Date is required';
                          }
                          return null;
                        },
                        setValue: (value) => resignationDate = value,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: CustomDatePicker(
                        title: 'Relieving Date',
                        initialDate: relievingDate,
                        setValue: (value) => relievingDate = value,
                      ),
                    ),
                  ],
                ),
                CustomTextField(
                  textController: reasonC,
                  title: 'Reason',
                  maxLines: 10,
                  minLines: 3,
                  isRequired: true,
                  hint: 'Enter Reason',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Reason is required";
                    }
                    return null;
                  },
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: isEarlyRealise,
                  builder: (context, value, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomCheckBox(
                          isSelected: value,
                          onChanged: (newValue) {
                            isEarlyRealise.value = newValue;
                          },
                          title: "Early Realise",
                        ),
                        verticalSpacing(),
                        CustomDatePicker(
                          readOnly: !value,
                          isRequired: value,
                          title: 'Expected Relieving Date',
                          initialDate: relievingDate,
                          setValue: (value) => relievingDate = value,
                          validator: (value) {
                            if (value == null && isEarlyRealise.value) {
                              return 'Expected Relieving Date is required';
                            }
                            return null;
                          },
                        ),
                      ],
                    );
                  },
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
                          title: "Upload Offer Letter",
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
            text: _isEditMode ? "Update Resignation" : "Add Resignation",
            onPressed: _handleSubmit,
          ),
        ),
      ),
    );
  }
}
