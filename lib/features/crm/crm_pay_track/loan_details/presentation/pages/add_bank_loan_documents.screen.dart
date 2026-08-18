import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/loan_details/presentation/cubit/loan_details_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track_booking_files.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

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

  late ValueNotifier<MultiFilePickerModel> _uploadedFileNotifier;
  @override
  void initState() {
    super.initState();

    _loanDetailsCubit = context.read<LoanDetailsCubit>();
    _fileName = TextEditingController();
    _uploadedFileNotifier = ValueNotifier(
      MultiFilePickerModel(
        fileBytesList: [],
        fileNameList: [],
        deletedFileList: "",
      ),
    );

    if (_isEditMode) {
      _prefillBankDocumnets(widget.payTrackBookingFilesModel!);
    }
  }

  void _prefillBankDocumnets(
    PayTrackBookingFilesModel payTrackBookingFilesModel,
  ) {
    _fileName.text = payTrackBookingFilesModel.fileName;

    _uploadedFileNotifier.value = MultiFilePickerModel(
      fileBytesList: [],
      fileNameList:
          payTrackBookingFilesModel.payTrackBookingFilesUrl.isEmpty
              ? []
              : payTrackBookingFilesModel.payTrackBookingFilesUrl.split(","),
      deletedFileList: "",
    );
  }

  @override
  void dispose() {
    _fileName.dispose();
    _uploadedFileNotifier.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isEditMode && widget.payTrackBookingFilesModel != null) {
      _loanDetailsCubit.updateBankDocument(
        context: context,
        bookingLoanDetailsId:
            widget.payTrackBookingFilesModel!.bookingLoanDetailsId,
        payTrackBookingFilesId:
            widget.payTrackBookingFilesModel!.payTrackBookingFilesId,
        uniqueKey: widget.payTrackBookingFilesModel!.uniquekey,
        projectId: widget.projectId,
        bookingId: widget.bookingId,
        fileName: _fileName.text.trim(),
        bankDocuments: _uploadedFileNotifier.value,
        index: widget.index,
      );
    } else {
      _loanDetailsCubit.addBankDocument(
        context: context,
        projectId: widget.projectId,
        bookingId: widget.bookingId,
        fileName: _fileName.text,
        bankDocuments: _uploadedFileNotifier.value,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Bank Loan Document",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditMode
                  ? "Update Bank Loan Document"
                  : "Add Bank Loan Document",
              style: AppTextStyle.ts14M(color: AppColor.grey),
            ),
            verticalSpacing(),
            Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      textController: _fileName,
                      title: "File Name",
                      hint: "Enter File Name",
                      isRequired: true,
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(150),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "File Name is required";
                        }
                        return null;
                      },
                    ),
                    ValueListenableBuilder<MultiFilePickerModel>(
                      valueListenable: _uploadedFileNotifier,
                      builder: (context, value, child) {
                        return CustomMultiFilePicker(
                          title: "File",
                          isRequired: true,
                          filePickType: FilePickType.both,
                          initialFileList:
                              _uploadedFileNotifier.value.fileNameList,
                          onFilePickedCallback: (bytesList, fileNameList) {
                            _uploadedFileNotifier.value.fileNameList =
                                fileNameList;
                            _uploadedFileNotifier.value.fileBytesList =
                                bytesList;
                          },

                          onFileDeleteCallback: (
                            fileBytesList,
                            fileNameList,
                            deletedFile,
                          ) {
                            _uploadedFileNotifier.value.fileNameList =
                                fileNameList;
                            _uploadedFileNotifier.value.fileBytesList =
                                fileBytesList;
                            _uploadedFileNotifier.value.deletedFileList =
                                deletedFile;
                          },

                          validator: (fileList) {
                            if ((fileList == null || fileList.isEmpty)) {
                              return "File is required";
                            }

                            return null;
                          },
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
