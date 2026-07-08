import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/cubit/request_management_cubit.dart';
import 'package:k3h_erp_app/features/masters/designation_master/presentation/pages/module_access_screen.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/speech_to_text/speech_to_text.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CancelBookingScreen extends StatefulWidget {
  final BookingModel booking;
  const CancelBookingScreen({super.key, required this.booking});

  @override
  State<CancelBookingScreen> createState() => _CancelBookingScreenState();
}

class _CancelBookingScreenState extends State<CancelBookingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  MultiFilePickerModel selectedProofOfDocumentFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  late TextEditingController _remarkC;
  late ValueNotifier<bool> cancelBookingNotifier;

  late RequestManagementCubit _requestManagementCubit;

  @override
  void initState() {
    super.initState();
    _requestManagementCubit = context.read<RequestManagementCubit>();
    _remarkC = TextEditingController();
    cancelBookingNotifier = ValueNotifier(false);
  }

  @override
  void dispose() {
    cancelBookingNotifier.dispose();
    _remarkC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Cancel Booking",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomMultiFilePicker(
                title: "Proof Of Document",
                isRequired: true,
                filePickType: FilePickType.both,
                initialFileList: selectedProofOfDocumentFile.fileNameList,

                onFilePickedCallback: (bytesList, fileNameList) {
                  selectedProofOfDocumentFile.fileNameList = fileNameList;
                  selectedProofOfDocumentFile.fileBytesList = bytesList;
                },

                onFileDeleteCallback: (
                  fileBytesList,
                  fileNameList,
                  deletedFile,
                ) {
                  selectedProofOfDocumentFile.fileNameList = fileNameList;
                  selectedProofOfDocumentFile.fileBytesList = fileBytesList;
                  selectedProofOfDocumentFile.deletedFileList = deletedFile;
                },

                validator: (fileList) {
                  if ((fileList == null || fileList.isEmpty)) {
                    return "Proof Of Document is required";
                  }
                  return null;
                },
              ),
              CustomTextField(
                title: "Remark",
                hint: "Enter Remark",
                isRequired: true,
                minLines: 3,
                maxLines: 10,
                inputFormatterList: [LengthLimitingTextInputFormatter(500)],
                textController: _remarkC,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Remark is required";
                  }
                  return null;
                },
                suffixWidget: SpeechToTextIcon(controller: _remarkC),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: cancelBookingNotifier,
                builder: (context, isChecked, child) {
                  return CustomCheckBox(
                    isSelected: isChecked,
                    title: "Cancelled bookings cannot be restored",
                    onChanged: (_) {
                      cancelBookingNotifier.value =
                          !cancelBookingNotifier.value;
                    },
                  );
                },
              ),
              verticalSpacing(height: 10.0),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "By selecting this option, the",
                      style: AppTextStyle.ts14R(
                        color: AppColor.black.withValues(alpha: 0.5),
                      ),
                    ),
                    TextSpan(text: " Booking ", style: AppTextStyle.ts14B()),
                    TextSpan(
                      text: "will be ",
                      style: AppTextStyle.ts14R(
                        color: AppColor.black.withValues(alpha: 0.5),
                      ),
                    ),
                    TextSpan(text: "cancelled ", style: AppTextStyle.ts14B()),
                    TextSpan(
                      text: "and cannot be changed later.",
                      style: AppTextStyle.ts14R(
                        color: AppColor.black.withValues(alpha: 0.5),
                      ),
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
          color: AppColor.white,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            text: "Cancel Booking",
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _requestManagementCubit.cancelBooking(
                  context,
                  uniquekey: widget.booking.uniquekey,
                  projectId: widget.booking.projectId,
                  bookingId: widget.booking.bookingId,
                  inventoryFlatId: widget.booking.inventoryFlatId,
                  parkingId: widget.booking.parkingId,
                  cancelRemark: _remarkC.text.trim(),
                  proofDocument: selectedProofOfDocumentFile,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
