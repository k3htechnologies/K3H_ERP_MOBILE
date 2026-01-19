import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_master/data/model/holiday_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_master/presentation/cubit/holiday_master_cubit.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddHolidayMasterScreen extends StatefulWidget {
  final HolidayMasterModel? holidayMaster;
  final int index;
  const AddHolidayMasterScreen({super.key, this.holidayMaster, this.index = 0});

  @override
  State<AddHolidayMasterScreen> createState() => _AddHolidayMasterScreenState();
}

class _AddHolidayMasterScreenState extends State<AddHolidayMasterScreen> {
  // CUBIT
  late HolidayMasterCubit holidayMasterCubit;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _holidayNameC;

  //
  MultiFilePickerModel holidayFile = MultiFilePickerModel(
    fileNameList: [],
    fileBytesList: [],
    deletedFileList: "",
  );

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  bool get _isEditMode => widget.holidayMaster != null;

  @override
  void initState() {
    super.initState();
    holidayMasterCubit = context.read<HolidayMasterCubit>();
    _initializeTextEditingControllers(widget.holidayMaster);
    if (_isEditMode && widget.holidayMaster != null) {
      _populateFormFields(widget.holidayMaster!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _holidayNameC.dispose();
  }

  // INITIALISING TEXT CONTROLLERS
  void _initializeTextEditingControllers(HolidayMasterModel? holidayMaster) {
    _holidayNameC = TextEditingController(text: holidayMaster?.holidayName);
  }

  void _populateFormFields(HolidayMasterModel holiday) {
    _holidayNameC.text = holiday.holidayName;
    holidayFile.fileNameList = holiday.holidayUrl.split(",");
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isEditMode && widget.holidayMaster != null) {
      holidayMasterCubit.updateAssetMapping(
        index: widget.index,
        context: context,
        holidayMasterId: widget.holidayMaster!.holidayMasterId.toString(),
        holidayName: _holidayNameC.text.trim(),
        uniqueKey: widget.holidayMaster!.uniquekey,
        holidayFile: holidayFile,
      );
    } else {
      holidayMasterCubit.addHoliday(
        context: context,
        holidayName: _holidayNameC.text.trim(),
        holidayFile: holidayFile,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Holiday",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode ? "Update Holiday" : "Add Holiday",
                style: AppTextStyle.ts16SB(),
              ),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    CustomTextField(
                      textController: _holidayNameC,
                      title: "Holiday Name",
                      hint: "Enter Holiday Name",
                      isRequired: true,
                      inputFormatterList: InputValidator.textDigit(200),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Holiday Name is required";
                        }
                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
                      initialFileList: holidayFile.fileNameList,
                      title: "Holiday Image",
                      isRequired: true,
                      onFilePickedCallback: (fileByteList, fileNameList) {
                        holidayFile.fileBytesList = fileByteList;
                        holidayFile.fileNameList = fileNameList;
                      },
                      onFileDeleteCallback: (
                        fileBytesList,
                        fileNameList,
                        deletedUrl,
                      ) {
                        holidayFile.fileBytesList = fileBytesList;
                        holidayFile.fileNameList = fileNameList;
                        holidayFile.deletedFileList = deletedUrl;
                      },
                      validator: (file) {
                        if (file == null || file.isEmpty) {
                          return "Holiday Image is required";
                        }
                        return null;
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
            text: _isEditMode ? "Update Holiday" : "Add Holiday",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
