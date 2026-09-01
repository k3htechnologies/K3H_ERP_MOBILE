import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation.model.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation_hearing.model.dart';
import 'package:k3h_erp_app/features/legal/litigation/presentation/cubit/litigation_cubit.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddLitigationHearingScreen extends StatefulWidget {
  final LitigationHearingModel? litigationHearingModel;
  final LitigationModel litigationModel;
  final int index;
  const AddLitigationHearingScreen({
    super.key,
    required this.litigationHearingModel,
    required this.litigationModel,
    this.index = 0,
  });

  @override
  State<AddLitigationHearingScreen> createState() =>
      _AddLitigationHearingScreenState();
}

class _AddLitigationHearingScreenState
    extends State<AddLitigationHearingScreen> {
  //CUBIT
  late LitigationCubit _litigationCubit;

  // FILE PICKER VARIABLES
  MultiFilePickerModel hearingDocument = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  // TEXT CONTROLLER
  late TextEditingController _fileName, _remarkC;

  // DATE VARIABLE
  DateTime? hearingDate;

  // EDIT MODE
  bool get _isEditMode => widget.litigationHearingModel != null;

  //FORM KEY FOR FORM VALIDATION
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _litigationCubit = context.read<LitigationCubit>();

    _initControllers();
    if (_isEditMode) _prefillLitigationHearing(widget.litigationHearingModel!);
  }

  void _initControllers() {
    _fileName = TextEditingController();
    _remarkC = TextEditingController();
  }

  void _prefillLitigationHearing(LitigationHearingModel litigationHearing) {
    _remarkC.text = litigationHearing.remark;
    _fileName.text = litigationHearing.fileName;
    hearingDocument.fileBytesList = [];
    hearingDocument.deletedFileList = "";
    hearingDocument.fileNameList =
        litigationHearing.hearingAttachementUrl
            .split(",")
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
    hearingDate = litigationHearing.hearingDate;
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;
    var body = {
      "LitigationHearingId":
          _isEditMode
              ? widget.litigationHearingModel!.litigationHearingId.toString()
              : "0",
      if (_isEditMode) "Uniquekey": widget.litigationHearingModel!.uniquekey,
      "ProjectId": widget.litigationModel.projectId.toString(),
      "LitigationId": widget.litigationModel.litigationId.toString(),
      "HearingDate": hearingDate!.toIso8601String().split('T')[0],
      "Remark": _remarkC.text.trim(),
      "FileName": _fileName.text.trim(),
      "RemoveHearingAttachementURL": hearingDocument.deletedFileList,
    };
    if (!_isEditMode) {
      _litigationCubit.addLitigationHearing(
        context: context,
        body: body,
        hearingDocument: hearingDocument,
      );
    } else {
      _litigationCubit.updateLitigationHearing(
        context: context,
        index: widget.index,
        body: body,
        hearingDocument: hearingDocument,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: _isEditMode ? "Update Hearing" : "Add Hearing",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: commonCardDecoration(),

            child: Column(
              children: [
                CustomDatePicker(
                  title: "Hearing Date",
                  isRequired: true,
                  initialDate: hearingDate,
                  startDate: DateTime.now(),
                  setValue: (value) => hearingDate = value,
                  validator: (value) {
                    if (value == null) {
                      return "Hearing Date is required.";
                    }

                    final filingDate = DateUtils.dateOnly(
                      widget.litigationModel.dateOfFilling,
                    );

                    final selectedDate = DateUtils.dateOnly(value);

                    if (!(selectedDate.isAfter(filingDate) ||
                        selectedDate == filingDate)) {
                      return "Hearing Date cannot be in the past.";
                    }

                    if (!_isEditMode &&
                        widget.litigationModel.hearingDate != null) {
                      final previousHearingDate = DateUtils.dateOnly(
                        widget.litigationModel.hearingDate!,
                      );

                      if (!selectedDate.isAfter(previousHearingDate)) {
                        return "Hearing date must be greater than previous hearing date.";
                      }
                    }

                    return null;
                  },
                ),
                CustomTextField(
                  title: "File Name",
                  hint: 'Enter File Name',
                  textController: _fileName,
                  inputFormatterList: [LengthLimitingTextInputFormatter(50)],
                  validator: (val) {
                    if ((val == null || val.trim().isEmpty) &&
                        hearingDocument.fileNameList.isNotEmpty) {
                      return 'File Name is required.';
                    }
                    return null;
                  },
                ),
                CustomMultiFilePicker(
                  title: "Files",
                  initialFileList: hearingDocument.fileNameList,
                  onFilePickedCallback: (bytesList, fileNameList) {
                    hearingDocument.fileNameList = fileNameList;
                    hearingDocument.fileBytesList = bytesList;
                  },
                  onFileDeleteCallback: (fileBytesList, fileNameList, deleted) {
                    hearingDocument.fileBytesList = fileBytesList;
                    hearingDocument.fileNameList = fileNameList;
                    hearingDocument.deletedFileList = deleted;
                  },
                  maxFiles: 5,
                  validator: (value) {
                    if ((value == null || value.isEmpty) &&
                        _fileName.text.isNotEmpty) {
                      return "File is required.";
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  title: "Remark",
                  hint: 'Enter Remarks',
                  isRequired: true,
                  textController: _remarkC,
                  minLines: 3,
                  maxLines: 5,
                  validator: (string) {
                    if (string == null || string.trim().isEmpty) {
                      return 'Remark is required.';
                    }
                    return null;
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
          padding: EdgeInsets.all(16),
          child: CustomButton(
            text: _isEditMode ? "Update" : "Add ",
            onPressed: _saveForm,
          ),
        ),
      ),
    );
  }
}
