import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/files/presentation/cubit/files_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track_booking_files.model.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddFilesScreen extends StatefulWidget {
  final int projectId;
  final int bookingId;
  final bool isEdit;
  final PayTrackBookingFilesModel? filesModel;
  final int index;
  const AddFilesScreen({
    super.key,
    required this.projectId,
    required this.bookingId,
    required this.isEdit,
    this.filesModel,
    this.index = 0,
  });

  @override
  State<AddFilesScreen> createState() => _AddFilesScreenState();
}

class _AddFilesScreenState extends State<AddFilesScreen> {
  late FilesCubit _filesCubit;

  //EDIT MODE
  bool get _isEditMode => widget.filesModel != null;
  late TextEditingController _fileNameC;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  MultiFilePickerModel selectedFileForUpload = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  @override
  void initState() {
    super.initState();
    _filesCubit = context.read<FilesCubit>();
    _fileNameC = TextEditingController();
    if (_isEditMode) {}
    _prefillFiles(widget.filesModel!);
  }

  @override
  void dispose() {
    super.dispose();
    _fileNameC.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (widget.isEdit) {
      _filesCubit.updatePayTrackBookingFile(
        context: context,
        payTrackBookingFilesId: widget.filesModel!.payTrackBookingFilesId,
        uniqueKey: widget.filesModel!.uniquekey,
        projectId: widget.projectId,
        bookingId: widget.bookingId,
        fileName: _fileNameC.text.trim(),
        fileType: "FILES",
        payTrackFiles: selectedFileForUpload,
        index: widget.index,
      );
    } else {
      _filesCubit.addPayTrackBookingFile(
        context: context,
        projectId: widget.projectId,
        bookingId: widget.bookingId,
        fileName: _fileNameC.text.trim(),
        filePicker: selectedFileForUpload,
        fileType: "FILES",
      );
    }
  }

  void _prefillFiles(PayTrackBookingFilesModel filesData) {
    _fileNameC.text = filesData.fileName;
    selectedFileForUpload.fileNameList =
        filesData.payTrackBookingFilesUrl.isEmpty
            ? []
            : filesData.payTrackBookingFilesUrl.split(",");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: widget.isEdit ? "Update Files" : "Add Files",
        authorization: AuthorizationModel(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      title: "File Name",
                      hint: "Enter File Name",
                      textController: _fileNameC,
                      isRequired: true,
                    ),
                    CustomMultiFilePicker(
                      title: "File",
                      filePickType: FilePickType.kycDocument,
                      initialFileList: selectedFileForUpload.fileNameList,
                      initialFileBytes: selectedFileForUpload.fileBytesList,
                      onFilePickedCallback: (bytesList, fileNameList) {
                        selectedFileForUpload.fileNameList = fileNameList;
                        selectedFileForUpload.fileBytesList = bytesList;
                      },
                      onFileDeleteCallback: (
                        fileBytesList,
                        fileNameList,
                        deleted,
                      ) {
                        selectedFileForUpload.fileBytesList = fileBytesList;
                        selectedFileForUpload.fileNameList = fileNameList;
                        selectedFileForUpload.deletedFileList = deleted;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  text: widget.isEdit ? "Update" : "Submit",
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
