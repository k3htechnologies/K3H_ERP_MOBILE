import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/loan_details/presentation/cubit/loan_details_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track_booking_files.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddBankLoanDocumentScreen extends StatefulWidget {
  final int projectId;
  final int bookingId;
  final PayTrackBookingFilesModel? payTrackBookingFilesModel;
  final int index;
  const AddBankLoanDocumentScreen({
    super.key,
    required this.projectId,
    required this.bookingId,
    this.payTrackBookingFilesModel,
    this.index = 0,
  });

  @override
  State<AddBankLoanDocumentScreen> createState() =>
      _AddBankLoanDocumentScreenState();
}

class _AddBankLoanDocumentScreenState extends State<AddBankLoanDocumentScreen> {
  late LoanDetailsCubit _loanDetailsCubit;
  late TextEditingController _fileName;
  //EDIT MODE
  bool get _isEditMode => widget.payTrackBookingFilesModel != null;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  MultiFilePickerModel selectedUploadedFilePopUpFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  @override
  void initState() {
    super.initState();

    _loanDetailsCubit = context.read<LoanDetailsCubit>();
    _fileName = TextEditingController();

    if (_isEditMode) {
      _prefillBankDocumnets(widget.payTrackBookingFilesModel!);
    }
  }

  void _prefillBankDocumnets(
    PayTrackBookingFilesModel payTrackBookingFilesModel,
  ) {
    _fileName.text = payTrackBookingFilesModel.fileName;

    selectedUploadedFilePopUpFile.fileNameList =
        payTrackBookingFilesModel.payTrackBookingFilesUrl.isEmpty
            ? []
            : payTrackBookingFilesModel.payTrackBookingFilesUrl.split(",");

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _fileName.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isEditMode && widget.payTrackBookingFilesModel != null) {
      _loanDetailsCubit.updateBankDocument(
        context: context,
        payTrackBookingFilesId:
            widget.payTrackBookingFilesModel!.payTrackBookingFilesId,
        uniqueKey: widget.payTrackBookingFilesModel!.uniquekey,
        projectId: widget.projectId,
        bookingId: widget.bookingId,
        fileName: _fileName.text.trim(),
        bankDocuments: selectedUploadedFilePopUpFile,
        index: widget.index,
      );
    } else {
      _loanDetailsCubit.addBankDocument(
        context: context,
        projectId: widget.projectId,
        bookingId: widget.bookingId,
        fileName: _fileName.text,
        bankDocuments: selectedUploadedFilePopUpFile,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle:
            _isEditMode
                ? "Update Bank Loan Document"
                : "Add Bank Loan Document",
        authorization: AuthorizationModel(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                textController: _fileName,
                title: "File Name",
                hint: "Enter File Name",
                isRequired: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "File Name is required";
                  }
                  return null;
                },
              ),
              CustomMultiFilePicker(
                title: "File",
                isRequired: true,
                filePickType: FilePickType.both,
                initialFileList: selectedUploadedFilePopUpFile.fileNameList,
                onFilePickedCallback: (bytesList, fileNameList) {
                  selectedUploadedFilePopUpFile.fileNameList = fileNameList;
                  selectedUploadedFilePopUpFile.fileBytesList = bytesList;
                },

                onFileDeleteCallback: (
                  fileBytesList,
                  fileNameList,
                  deletedFile,
                ) {
                  selectedUploadedFilePopUpFile.fileNameList = fileNameList;
                  selectedUploadedFilePopUpFile.fileBytesList = fileBytesList;
                  selectedUploadedFilePopUpFile.deletedFileList = deletedFile;
                },

                validator: (fileList) {
                  if ((fileList == null || fileList.isEmpty)) {
                    return "File is required";
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          color: AppColor.white,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            text: _isEditMode ? "Update" : "Add",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
