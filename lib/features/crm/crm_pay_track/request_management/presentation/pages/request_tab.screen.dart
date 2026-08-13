// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/cubit/utils_cubit.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/booking_applicant_modification_request.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/flat_alteration_requests.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/parking_modification_request.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/cubit/request_management_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/widgets/document_preview.screen.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/approve_reject_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class RequestTabScreen extends StatefulWidget {
  final int projectId;
  final int bookingId;
  final String? approvalStatus;
  const RequestTabScreen({
    super.key,
    required this.projectId,
    required this.bookingId,
    this.approvalStatus,
  });

  @override
  State<RequestTabScreen> createState() => _RequestTabScreenState();
}

class _RequestTabScreenState extends State<RequestTabScreen> {
  late RequestManagementCubit _requestManagementCubit;
  late UtilsCubit _utilsCubit;
  // FILE VARIABLES
  MultiFilePickerModel selectedPANForPopUpFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel selectedAadhaarForPopUpFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel selectedVotingForPopUpFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel selectedPOAForPopUpFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel selectedPaymentProofForPopUpFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel selectedNreNroBankDetailsForPopUpFile =
      MultiFilePickerModel(
        fileBytesList: [],
        fileNameList: [],
        deletedFileList: "",
      );
  MultiFilePickerModel selectedDrivingLicenseForPopUpFile =
      MultiFilePickerModel(
        fileBytesList: [],
        fileNameList: [],
        deletedFileList: "",
      );
  MultiFilePickerModel selectedProofOfDocumentForPopUpFile =
      MultiFilePickerModel(
        fileBytesList: [],
        fileNameList: [],
        deletedFileList: "",
      );
  MultiFilePickerModel selectedStatementOfSourceOfFundsForPopUpFile =
      MultiFilePickerModel(
        fileBytesList: [],
        fileNameList: [],
        deletedFileList: "",
      );
  MultiFilePickerModel selectedIncomeForm16ITRForPopUpFile =
      MultiFilePickerModel(
        fileBytesList: [],
        fileNameList: [],
        deletedFileList: "",
      );

  MultiFilePickerModel selectedNomineeFormPhotoForPopUpFile =
      MultiFilePickerModel(
        fileBytesList: [],
        fileNameList: [],
        deletedFileList: "",
      );
  MultiFilePickerModel selectedCancelledChequePhotoForPopUpFile =
      MultiFilePickerModel(
        fileBytesList: [],
        fileNameList: [],
        deletedFileList: "",
      );
  MultiFilePickerModel selectedPhotoPhotoForPopUpFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel selectedPassportPhotoForPopUpFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel selectedGstNumberPhotForPopUpFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  late AuthorizationModel _modifiedRequestsAuthorization;
  @override
  void initState() {
    super.initState();
    _modifiedRequestsAuthorization =
        Authorization.routeAuthorizationMap[AppRoutes.modificationRequest] ??
        AuthorizationModel();
    _requestManagementCubit = context.read<RequestManagementCubit>();
    _utilsCubit = context.read<UtilsCubit>();
    _initiate();
  }

  void _initiate() async {
    await _requestManagementCubit.getBookingApplicantModificationRequestList(
      context,
      10,
      1,
      widget.bookingId,
      widget.projectId,
    );
    if (mounted) {
      await _requestManagementCubit.getParkingModificationRequestList(
        context,
        10,
        1,
        widget.bookingId,
        widget.projectId,
      );
    }
    if (mounted) {
      await _requestManagementCubit.getFlatAlterationRequestList(
        context,
        10,
        1,
        widget.bookingId,
        widget.projectId,
      );
    }
  }

  Future<void> _showPopupToDeleteFlatAlterationRequest(
    BuildContext context,
    FlatAlterationRequestsModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Unit / Modulation / Customization Remark ?',
      'Deleting this Unit / Modulation / Customization Remark will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      _requestManagementCubit.deleteFlatAlterationRequest(
        context: context,
        flatAlterationRequestId: obj.flatAlterationRequestId,
        uniqueKey: obj.uniqueKey,
        bookingId: widget.bookingId,
        projectId: widget.projectId,
        index: index,
      );
    }
  }

  Future<void> _showPopupToDeleteParkingAlterationRequest(
    BuildContext context,
    ParkingModificationRequestModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Parking Modification ?',
      'Deleting this Parking Modification will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      _requestManagementCubit.deleteParkingModificationRequest(
        context: context,
        parkingModificationRequestId: obj.parkingModificationRequestId,
        uniqueKey: obj.uniqueKey,
        bookingId: widget.bookingId,
        projectId: widget.projectId,
        index: index,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestManagementCubit, RequestManagementState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            spacing: 10.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildApplicantDetailsWidget(context, state),
              if (state.bookingData!.parkingData.isNotEmpty)
                _buildParkingDetailsWidget(context, state),
              _buildFlatSpecificationRemarkgDetailsWidget(context, state),
            ],
          ),
        );
      },
    );
  }

  void setFileLists(MultiFilePickerModel target, String url) {
    if (url.isEmpty) {
      target.fileNameList = [];
      target.fileBytesList = [];
    } else {
      target.fileNameList = url.split(",");
    }
  }

  Widget _buildApplicantDetailsWidget(
    BuildContext context,
    RequestManagementState state,
  ) {
    final applicantList = List<BookingApplicantModificationRequestModel>.from(
      state.bookingApplicantModificationRequestModel,
    );

    final hasApplicantData = applicantList.isNotEmpty;
    final isAnyApplicantPartiallyApproved = applicantList.any(
      (e) => e.approvalStatus.trim().toLowerCase() == "partial approved",
    );
    BookingApplicantModificationRequestModel? applicantRequest;

    for (final e in applicantList) {
      if (e.applicantType.trim().toLowerCase() == "applicant") {
        applicantRequest = e;
        break;
      }
    }

    final isApplicantApproved =
        applicantRequest != null &&
        applicantRequest.approvalStatus.trim().toLowerCase() == "approved";
    return Column(
      spacing: 10.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Applicant Details", style: AppTextStyle.ts16SB()),
            horizontalSpacing(),
            _modifiedRequestsAuthorization.isAction
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (applicantList.isNotEmpty &&
                        state.hasUnsavedApplicantChanges &&
                        !state.isSavingApplicantRequest &&
                        !isAnyApplicantPartiallyApproved)
                      CustomButton(
                        text: "Save",
                        onPressed: () {
                          final hasApplicant = applicantList.any(
                            (e) =>
                                e.applicantType.trim().toLowerCase() ==
                                "applicant",
                          );

                          if (!hasApplicant) {
                            showErrorMessage(
                              context,
                              "Error",
                              "At least one Applicant is required.",
                            );
                            return;
                          }
                          _requestManagementCubit
                              .updateBookingApplicantModificationRequest(
                                context,
                                bookingId: widget.bookingId,
                                projectId: widget.projectId,
                              );
                        },
                      ),

                    horizontalSpacing(),
                    if (_modifiedRequestsAuthorization.isAction &&
                        widget.approvalStatus?.toUpperCase() == "APPROVED" &&
                        !isAnyApplicantPartiallyApproved &&
                        (state.hasUnsavedApplicantChanges ||
                            applicantRequest == null ||
                            isApplicantApproved))
                      CustomButton(
                        leading: Icon(
                          Icons.add,
                          size: 18,
                          color: AppColor.white,
                        ),
                        text: "Add",
                        onPressed: () async {
                          final result = await goRouter.pushNamed(
                            AppRoutes.addApplicantDetailsRequests,
                            extra: {
                              "bookingId": widget.bookingId,
                              "projectId": widget.projectId,
                              "aadharFile": selectedAadhaarForPopUpFile,
                              "panFile": selectedPANForPopUpFile,
                              "passportFile": selectedPassportPhotoForPopUpFile,
                              "photoFile": selectedPhotoPhotoForPopUpFile,
                              "gstFile": selectedGstNumberPhotForPopUpFile,
                              "votingFile": selectedVotingForPopUpFile,
                              "drivingFile": selectedDrivingLicenseForPopUpFile,
                              "poaFile": selectedPOAForPopUpFile,
                              "paymentProofFile":
                                  selectedPaymentProofForPopUpFile,
                              "proofDocumentFile":
                                  selectedProofOfDocumentForPopUpFile,
                              "statementFile":
                                  selectedStatementOfSourceOfFundsForPopUpFile,
                              "incomeFile": selectedIncomeForm16ITRForPopUpFile,
                              "nomineeFile":
                                  selectedNomineeFormPhotoForPopUpFile,
                              "cancelledChequeFile":
                                  selectedCancelledChequePhotoForPopUpFile,
                              "nreFile": selectedNreNroBankDetailsForPopUpFile,
                            },
                          );

                          if (result is Map &&
                              result["isSuccess"] == true &&
                              result["applicant"] != null) {
                            selectedAadhaarForPopUpFile = result["aadhaarFile"];

                            selectedPANForPopUpFile = result["panFile"];

                            selectedPassportPhotoForPopUpFile =
                                result["passportFile"];

                            selectedPhotoPhotoForPopUpFile =
                                result["photoFile"];

                            selectedGstNumberPhotForPopUpFile =
                                result["gstFile"];

                            selectedVotingForPopUpFile = result["votingFile"];

                            selectedDrivingLicenseForPopUpFile =
                                result["drivingFile"];

                            selectedPOAForPopUpFile = result["poaFile"];

                            selectedPaymentProofForPopUpFile =
                                result["paymentProofFile"];

                            selectedProofOfDocumentForPopUpFile =
                                result["proofDocumentFile"];

                            selectedStatementOfSourceOfFundsForPopUpFile =
                                result["statementFile"];

                            selectedIncomeForm16ITRForPopUpFile =
                                result["incomeFile"];

                            selectedNomineeFormPhotoForPopUpFile =
                                result["nomineeFile"];

                            selectedCancelledChequePhotoForPopUpFile =
                                result["cancelledChequeFile"];

                            selectedNreNroBankDetailsForPopUpFile =
                                result["nreFile"];

                            if (result["isEdit"] == true) {
                              _requestManagementCubit.updateApplicantLocally(
                                result["index"],
                                result["applicant"],
                              );
                            } else {
                              _requestManagementCubit.addApplicantLocally(
                                result["applicant"],
                              );
                            }
                          }
                        },
                      ),
                  ],
                )
                : SizedBox.shrink(),
          ],
        ),
        if (hasApplicantData) ...{
          ListView.builder(
            itemCount: applicantList.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final applicantData = applicantList[index];

              final applicant = applicantData;

              final isApplicant =
                  applicant.applicantType.trim().toLowerCase() == "applicant";

              final isDraftRequest = state.hasUnsavedApplicantChanges;
              final canDelete = isDraftRequest || isApplicant;
              return Container(
                margin: EdgeInsets.only(
                  bottom: index == applicantList.length - 1 ? 0 : 10,
                ),
                padding: EdgeInsets.all(12.0),
                decoration: commonCardDecoration(),
                child: Column(
                  spacing: 6.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Type",
                            value: applicant.applicantType,
                          ),
                        ),
                        horizontalSpacing(),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isDraftRequest)
                                CustomIconButton.edit(
                                  isDisabled:
                                      applicant.approvalStatus.toLowerCase() ==
                                          "partial approved" ||
                                      applicant.approvalStatus.toLowerCase() ==
                                          "approved",
                                  onPressed: () async {
                                    final result = await goRouter.pushNamed(
                                      AppRoutes.addApplicantDetailsRequests,
                                      extra: {
                                        "bookingId": widget.bookingId,
                                        "projectId": widget.projectId,
                                        "index": index,
                                        "isEdit": true,
                                      },
                                    );
                                    if (result is Map &&
                                        result["isSuccess"] == true &&
                                        result["applicant"] != null) {
                                      selectedProofOfDocumentForPopUpFile =
                                          result["proofDocumentFile"];
                                      selectedAadhaarForPopUpFile =
                                          result["aadhaarFile"];
                                      selectedPANForPopUpFile =
                                          result["panFile"];
                                      selectedPassportPhotoForPopUpFile =
                                          result["passportFile"];
                                      selectedPhotoPhotoForPopUpFile =
                                          result["photoFile"];
                                      selectedGstNumberPhotForPopUpFile =
                                          result["gstFile"];
                                      selectedVotingForPopUpFile =
                                          result["votingFile"];
                                      selectedDrivingLicenseForPopUpFile =
                                          result["drivingFile"];
                                      selectedPOAForPopUpFile =
                                          result["poaFile"];
                                      selectedPaymentProofForPopUpFile =
                                          result["paymentProofFile"];
                                      selectedStatementOfSourceOfFundsForPopUpFile =
                                          result["statementFile"];
                                      selectedIncomeForm16ITRForPopUpFile =
                                          result["incomeFile"];
                                      selectedNomineeFormPhotoForPopUpFile =
                                          result["nomineeFile"];
                                      selectedCancelledChequePhotoForPopUpFile =
                                          result["cancelledChequeFile"];
                                      selectedNreNroBankDetailsForPopUpFile =
                                          result["nreFile"];

                                      _requestManagementCubit
                                          .updateApplicantLocally(
                                            result["index"],
                                            result["applicant"],
                                          );
                                    }
                                  },
                                ),
                              if (isDraftRequest) horizontalSpacing(),
                              if (canDelete)
                                CustomIconButton.delete(
                                  isDisabled:
                                      isAnyApplicantPartiallyApproved ||
                                      applicant.approvalStatus.toLowerCase() ==
                                          "partial approved" ||
                                      applicant.approvalStatus.toLowerCase() ==
                                          "approved",
                                  onPressed: () async {
                                    final isDelete = await DialogHelper.deleteDialog(
                                      context,
                                      "You are about to delete a Booking Applicant ?",
                                      "Deleting this Booking Applicant will permanently remove all associated data.",
                                    );

                                    if (!isDelete) return;

                                    final isDraftRequest =
                                        applicant
                                            .bookingApplicantModificationRequestId ==
                                        0;

                                    if (isDraftRequest) {
                                      _requestManagementCubit
                                          .deleteApplicantLocally(index);
                                    } else {
                                      if (context.mounted) {
                                        _requestManagementCubit
                                            .deleteBookingApplicantModificationRequest(
                                              context: context,
                                              model: applicant,
                                              bookingId: widget.bookingId,
                                              projectId: widget.projectId,
                                              index: index,
                                            );
                                      }
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    buildRowTitleValue(
                      title: "Applicant Name",
                      value: applicant.applicantName,
                      singleLine: false,
                      customValueWidget: DocumentPreviewText(
                        title: "Profile Photo",
                        text: applicant.applicantName,
                        fileUrl: applicant.photoUrl,
                      ),
                    ),
                    buildRowTitleValue(
                      title: "Mobile No. ",
                      value: applicant.applicantMobileNumber,
                      customValueWidget: CustomClickToContactText(
                        countryCode: applicant.applicantMobileNumberCountryCode,
                        value: applicant.applicantMobileNumber,
                        type: ContactType.phone,
                      ),
                    ),
                    buildRowTitleValue(
                      title: "E-mail ID",
                      value: applicant.applicantEmailId,
                      singleLine: false,
                      customValueWidget: CustomClickToContactText(
                        countryCode: applicant.applicantEmailId,
                        value: applicant.applicantEmailId,
                        type: ContactType.email,
                      ),
                    ),
                    if (applicant.proofOfDocumentUrl.isNotEmpty)
                      buildRowTitleValue(
                        title: "Proof Of Document",
                        value: applicant.proofOfDocumentUrl,
                        customValueWidget: DocumentPreviewText(
                          title: "Proof Of Document",
                          text: "View",
                          fileUrl: applicant.proofOfDocumentUrl,
                        ),
                      ),
                    buildRowTitleValue(
                      title: "Aadhaar Card No.",
                      value: applicant.aadharCardNumber,
                      customValueWidget: DocumentPreviewText(
                        title: "Aadhaar Card",
                        text: applicant.aadharCardNumber,
                        fileUrl: applicant.aadharCardUrl,
                      ),
                    ),
                    buildRowTitleValue(
                      title: "PAN Card No.",
                      value: applicant.panNumber,
                      customValueWidget: DocumentPreviewText(
                        title: "PAN Card",
                        text: applicant.panNumber,
                        fileUrl: applicant.panCardUrl,
                      ),
                    ),
                    if (applicant.passportNumber.isNotEmpty &&
                        applicant.passportUrl.isNotEmpty)
                      buildRowTitleValue(
                        title: "Passport Number",
                        value: applicant.passportNumber,
                        customValueWidget: DocumentPreviewText(
                          title: "Passport Number",
                          text: applicant.passportNumber,
                          fileUrl: applicant.passportUrl,
                        ),
                      ),
                    if (applicant.drivingLicenseNumber.isNotEmpty &&
                        applicant.drivingLicenseUrl.isNotEmpty)
                      buildRowTitleValue(
                        title: "Driving License Number",
                        value: applicant.drivingLicenseNumber,
                        customValueWidget: DocumentPreviewText(
                          title: "Driving License Number",
                          text: applicant.drivingLicenseNumber,
                          fileUrl: applicant.drivingLicenseUrl,
                        ),
                      ),
                    if (applicant.votingIdNumber.isNotEmpty &&
                        applicant.votingIdUrl.isNotEmpty)
                      buildRowTitleValue(
                        title: "Voting ID Number",
                        value: applicant.votingIdNumber,
                        customValueWidget: DocumentPreviewText(
                          title: "Voting ID Number",
                          text: applicant.votingIdNumber,
                          fileUrl: applicant.votingIdUrl,
                        ),
                      ),
                    if (applicant.gstNumber.isNotEmpty &&
                        applicant.gstNumberUrl.isNotEmpty)
                      buildRowTitleValue(
                        title: "GST Number",
                        value: applicant.gstNumber,
                        customValueWidget: DocumentPreviewText(
                          title: "GST Number",
                          text: applicant.gstNumber,
                          fileUrl: applicant.gstNumberUrl,
                        ),
                      ),
                    if (applicant.cancelledChequeUrl.isNotEmpty)
                      buildRowTitleValue(
                        title: "Cancelled Cheque",
                        value: applicant.cancelledChequeUrl,
                        customValueWidget: DocumentPreviewText(
                          title: "Cancelled Cheque",
                          text: "View",
                          fileUrl: applicant.cancelledChequeUrl,
                        ),
                      ),
                    if (applicant.poaurl.isNotEmpty)
                      buildRowTitleValue(
                        title: "POA (if NRI Execution)",
                        value: applicant.poaurl,
                        customValueWidget: DocumentPreviewText(
                          title: "POA (if NRI Execution)",
                          text: "View",
                          fileUrl: applicant.poaurl,
                        ),
                      ),
                    if (applicant.incomeForm16Itrurl.isNotEmpty)
                      buildRowTitleValue(
                        title: "Income Docs (Form 16 / ITR)",
                        value: applicant.incomeForm16Itrurl,
                        customValueWidget: DocumentPreviewText(
                          title: "Income Docs (Form 16 / ITR)",
                          text: "View",
                          fileUrl: applicant.incomeForm16Itrurl,
                        ),
                      ),
                    if (applicant.nreNroBankDetailsUrl.isNotEmpty)
                      buildRowTitleValue(
                        title: "NRE / NRO Bank Details",
                        value: applicant.nreNroBankDetailsUrl,
                        customValueWidget: DocumentPreviewText(
                          title: "NRE / NRO Bank Details",
                          text: "View",
                          fileUrl: applicant.nreNroBankDetailsUrl,
                        ),
                      ),
                    if (applicant.nomineeFormUrl.isNotEmpty)
                      buildRowTitleValue(
                        title: "Nominee Form",
                        value: applicant.nomineeFormUrl,
                        customValueWidget: DocumentPreviewText(
                          title: "Nominee Form",
                          text: "View",
                          fileUrl: applicant.nomineeFormUrl,
                        ),
                      ),
                    if (applicant.statementOfSourceOfFundsUrl.isNotEmpty)
                      buildRowTitleValue(
                        title: "Statement of Source of Funds",
                        value: applicant.statementOfSourceOfFundsUrl,
                        customValueWidget: DocumentPreviewText(
                          title: "Statement of Source of Funds",
                          text: "View",
                          fileUrl: applicant.statementOfSourceOfFundsUrl,
                        ),
                      ),
                    if (applicant.paymentProofUrl.isNotEmpty)
                      buildRowTitleValue(
                        title: "Payment Proof",
                        value: applicant.paymentProofUrl,
                        customValueWidget: DocumentPreviewText(
                          title: "Payment Proof",
                          text: "View",
                          fileUrl: applicant.paymentProofUrl,
                        ),
                      ),
                    _modifiedRequestsAuthorization.isAction &&
                            !isDraftRequest &&
                            isApplicant
                        ? ApproveRejectWidget(
                          showApproval: applicant.isApproval,
                          actionTitle:
                              applicant.approvalStatus.isEmpty
                                  ? "Pending"
                                  : applicant.approvalStatus,
                          subTitle: applicant.applicantName,
                          onApprove: (remark) async {
                            final isSuccess = await _utilsCubit
                                .updateModulesWorkflowApproval(
                                  context: context,
                                  moduleName:
                                      "BOOKING APPLICANT MODIFICATION APPROVAL",
                                  id: widget.bookingId,
                                  subId:
                                      applicant
                                          .bookingApplicantModificationRequestId,
                                  projectId: widget.projectId,
                                  isApproved: true,
                                  remark: remark.trim(),
                                );

                            if (context.mounted && isSuccess) {
                              _requestManagementCubit
                                  .getBookingApplicantModificationRequestList(
                                    context,
                                    10,
                                    1,
                                    widget.bookingId,
                                    widget.projectId,
                                  );
                            }
                          },
                          onReject: (remark) async {
                            final isSuccess = await _utilsCubit
                                .updateModulesWorkflowApproval(
                                  context: context,
                                  moduleName:
                                      "BOOKING APPLICANT MODIFICATION APPROVAL",
                                  id: widget.bookingId,
                                  subId:
                                      applicant
                                          .bookingApplicantModificationRequestId,
                                  projectId: widget.projectId,
                                  isApproved: false,
                                  remark: remark.trim(),
                                );

                            if (context.mounted && isSuccess) {
                              _requestManagementCubit
                                  .getBookingApplicantModificationRequestList(
                                    context,
                                    10,
                                    1,
                                    widget.bookingId,
                                    widget.projectId,
                                  );
                            }
                          },
                          onThirdTap: () async {
                            final approvalLogHistoryList = await _utilsCubit
                                .getApprovalLogHistory(
                                  context: context,
                                  id: widget.bookingId,
                                  subId:
                                      applicant
                                          .bookingApplicantModificationRequestId,
                                  projectId: widget.projectId,
                                  moduleName:
                                      "BOOKING APPLICANT MODIFICATION APPROVAL",
                                );
                            if (context.mounted) {
                              goRouter.pushNamed(
                                AppRoutes.approvalLogHistory,
                                queryParameters: {
                                  "title": Uri.encodeComponent(
                                    EncryptionManager.encryptData(
                                      "Applicant Details Log History",
                                    ),
                                  ),
                                  "approvalList": Uri.encodeComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(
                                        approvalLogHistoryList
                                            .map((e) => e.toJson())
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                },
                              );
                            }
                          },
                          popupTitle: "BOOKING APPLICANT MODIFICATION APPROVAL",
                        )
                        : SizedBox.shrink(),
                  ],
                ),
              );
            },
          ),
        } else ...{
          Center(
            child: noDataWidget(message: "No Applicant Found", iconSize: 160.0),
          ),
        },
      ],
    );
  }

  Widget _buildParkingDetailsWidget(
    BuildContext context,
    RequestManagementState state,
  ) {
    final hasParkingData =
        state.parkingModificationRequestList.isNotEmpty &&
        state.parkingModificationRequestList.first.parkingData.isNotEmpty;
    final hasPendingParkingRequest = state.parkingModificationRequestList.any((
      e,
    ) {
      final status = e.approvalStatus.trim().toLowerCase();

      return status == "" ||
          status == "pending" ||
          status == "partial approved";
    });
    return Column(
      spacing: 10.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Parking Details", style: AppTextStyle.ts16SB()),
            if (_modifiedRequestsAuthorization.isAction &&
                widget.approvalStatus?.toUpperCase() == "APPROVED" &&
                !hasPendingParkingRequest)
              CustomButton(
                leading: Icon(Icons.add, size: 18, color: AppColor.white),
                text: "Add",
                onPressed: () {
                  goRouter.pushNamed(AppRoutes.swapBookedParking);
                },
              ),
          ],
        ),
        if (hasParkingData) ...{
          SizedBox(
            height: 250.0,
            child: ListView.builder(
              itemCount: state.parkingModificationRequestList.length,
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final parkingData = state.parkingModificationRequestList[index];
                final request = state.parkingModificationRequestList[index];

                if (parkingData.parkingData.isEmpty) {
                  return const SizedBox.shrink();
                }

                final parking = parkingData.parkingData.first;
                final parkingStatus = parkingData.approvalStatus;

                final isEditDeleteDisabled =
                    parkingStatus.trim().toLowerCase() == "partial approved" ||
                    parkingStatus.trim().toLowerCase() == "approved";
                return Container(
                  margin: EdgeInsets.only(
                    bottom:
                        index == state.parkingModificationRequestList.length - 1
                            ? 0
                            : 10,
                  ),
                  padding: const EdgeInsets.all(12.0),
                  decoration: commonCardDecoration(),
                  child: Column(
                    spacing: 6.0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _modifiedRequestsAuthorization.isAction
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomIconButton.edit(
                                isDisabled: isEditDeleteDisabled,
                                onPressed: () async {
                                  goRouter.pushNamed(
                                    AppRoutes.swapBookedParking,
                                    extra: parkingData,
                                  );
                                },
                              ),
                              horizontalSpacing(),
                              CustomIconButton.delete(
                                isDisabled: isEditDeleteDisabled,
                                onPressed: () {
                                  _showPopupToDeleteParkingAlterationRequest(
                                    context,
                                    parkingData,
                                    state.currentPage,
                                    index,
                                  );
                                },
                              ),
                            ],
                          )
                          : SizedBox.shrink(),
                      _modifiedRequestsAuthorization.isAction
                          ? buildColumnTitleValueNormal(
                            title: "Approval Status",
                            value: parkingStatus,
                            customValueWidget: ApproveRejectWidget(
                              showApproval: parkingData.isApproval,
                              actionTitle:
                                  parkingStatus.isEmpty
                                      ? "Pending"
                                      : parkingStatus,
                              subTitle: parking.parkingNumber,
                              onApprove: (remark) async {
                                final isSuccess = await _utilsCubit
                                    .updateModulesWorkflowApproval(
                                      context: context,
                                      moduleName:
                                          "PARKING MODIFICATION APPROVAL",
                                      id: widget.bookingId,
                                      subId:
                                          parkingData
                                              .parkingModificationRequestId,
                                      projectId: widget.projectId,
                                      isApproved: true,
                                      remark: remark.trim(),
                                    );

                                if (context.mounted && isSuccess) {
                                  _requestManagementCubit
                                      .getParkingModificationRequestList(
                                        context,
                                        100,
                                        1,
                                        widget.bookingId,
                                        widget.projectId,
                                      );
                                }
                              },
                              onReject: (remark) async {
                                final isSuccess = await _utilsCubit
                                    .updateModulesWorkflowApproval(
                                      context: context,
                                      moduleName:
                                          "PARKING MODIFICATION APPROVAL",
                                      id: widget.bookingId,
                                      subId:
                                          parkingData
                                              .parkingModificationRequestId,
                                      projectId: widget.projectId,
                                      isApproved: false,
                                      remark: remark.trim(),
                                    );

                                if (context.mounted && isSuccess) {
                                  _requestManagementCubit
                                      .getParkingModificationRequestList(
                                        context,
                                        100,
                                        1,
                                        widget.bookingId,
                                        widget.projectId,
                                      );
                                }
                              },
                              onThirdTap: () async {
                                final approvalLogHistoryList = await _utilsCubit
                                    .getApprovalLogHistory(
                                      context: context,
                                      id: widget.bookingId,
                                      subId:
                                          parkingData
                                              .parkingModificationRequestId,
                                      projectId: widget.projectId,
                                      moduleName:
                                          "PARKING MODIFICATION APPROVAL",
                                    );
                                if (context.mounted) {
                                  goRouter.pushNamed(
                                    AppRoutes.approvalLogHistory,
                                    queryParameters: {
                                      "title": Uri.encodeComponent(
                                        EncryptionManager.encryptData(
                                          "Parking Details Log History",
                                        ),
                                      ),
                                      "approvalList": Uri.encodeComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(
                                            approvalLogHistoryList
                                                .map((e) => e.toJson())
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                    },
                                  );
                                }
                              },
                              popupTitle: "PARKING MODIFICATION APPROVAL",
                            ),
                          )
                          : SizedBox.shrink(),
                      _modifiedRequestsAuthorization.isAction
                          ? verticalSpacing()
                          : SizedBox.shrink(),
                      ...List.generate(request.parkingData.length, (
                        parkingIndex,
                      ) {
                        final request =
                            state.parkingModificationRequestList[index];
                        final parking = request.parkingData[parkingIndex];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildRowTitleValue(
                              title: "Parking Number",
                              value: parking.parkingNumber,
                            ),
                            buildRowTitleValue(
                              title: "Category",
                              value: parking.parkingCategory,
                            ),
                            buildRowTitleValue(
                              title: "Type",
                              value: parking.parkingType,
                            ),
                            buildRowTitleValue(
                              title: "Size",
                              value: parking.parkingSubType,
                            ),
                            buildRowTitleValue(
                              title: "Dimension",
                              value: parking.parkingDimensions,
                            ),
                            buildRowTitleValue(
                              title: "EV Charging",
                              value:
                                  parking.isEvChargingAvailable ? "Yes" : "No",
                            ),
                            buildRowTitleValue(
                              title: "Proof Of Document",
                              value: request.proofOfDocumentUrl,
                              customValueWidget: DocumentPreviewText(
                                title: "Proof Of Document",
                                text: "View",
                                fileUrl: request.proofOfDocumentUrl,
                              ),
                            ),

                            Divider(thickness: 1, color: AppColor.lightGrey),
                          ],
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        } else ...{
          Center(
            child: noDataWidget(
              message: "No Parking Data Found",
              iconSize: 160.0,
            ),
          ),
        },
      ],
    );
  }

  Widget _buildFlatSpecificationRemarkgDetailsWidget(
    BuildContext context,
    RequestManagementState state,
  ) {
    final hasFlatSpecificationRemark =
        state.flatAlterationRequestsModel.isNotEmpty;
    final hasPendingFlatAlterationRequest = state.flatAlterationRequestsModel
        .any((e) {
          final status = e.approvalStatus.trim().toLowerCase();

          return status.isEmpty ||
              status == "pending" ||
              status == "partial approved";
        });
    return Column(
      spacing: 10.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Unit / Modulation / Customization Details",
                style: AppTextStyle.ts16SB(),
              ),
            ),
            if (_modifiedRequestsAuthorization.isAction &&
                widget.approvalStatus?.toUpperCase() == "APPROVED" &&
                !hasPendingFlatAlterationRequest)
              CustomButton(
                leading: Icon(Icons.add, size: 18, color: AppColor.white),
                text: "Add",
                onPressed: () {
                  goRouter.pushNamed(
                    AppRoutes.addFlatSpecificationRemarkScreen,
                  );
                },
              ),
          ],
        ),
        if (hasFlatSpecificationRemark) ...{
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: state.flatAlterationRequestsModel.length,
            itemBuilder: (context, index) {
              final remark = state.flatAlterationRequestsModel[index];
              final approvalStatus = remark.approvalStatus.trim().toLowerCase();

              final isEditDeleteDisabled =
                  approvalStatus == "approved" ||
                  approvalStatus == "partial approved";
              return Container(
                margin: EdgeInsets.only(
                  bottom:
                      index == state.flatAlterationRequestsModel.length - 1
                          ? 0
                          : 10,
                ),
                padding: EdgeInsets.all(12.0),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _modifiedRequestsAuthorization.isAction
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomIconButton.edit(
                              isDisabled: isEditDeleteDisabled,
                              onPressed: () async {
                                goRouter.pushNamed(
                                  AppRoutes.addFlatSpecificationRemarkScreen,
                                  extra: remark,
                                );
                              },
                            ),
                            horizontalSpacing(),
                            CustomIconButton.delete(
                              isDisabled: isEditDeleteDisabled,
                              onPressed: () {
                                _showPopupToDeleteFlatAlterationRequest(
                                  context,
                                  remark,
                                  state.currentPage,
                                  index,
                                );
                              },
                            ),
                          ],
                        )
                        : SizedBox.shrink(),
                    _modifiedRequestsAuthorization.isAction
                        ? verticalSpacing()
                        : SizedBox.shrink(),
                    buildColumnTitleValueNormal(
                      title: "Unit / Modulation / Customization Remark",
                      value: remark.flatAlterationRemark,
                      customValueWidget: DocumentPreviewText(
                        title: "Proof of Document",
                        text: remark.flatAlterationRemark,
                        fileUrl: remark.proofOfDocumentUrl,
                      ),
                    ),
                    _modifiedRequestsAuthorization.isAction
                        ? buildColumnTitleValueNormal(
                          title: "Approval Status",
                          value: remark.approvalStatus,
                          customValueWidget: ApproveRejectWidget(
                            showApproval: remark.isApproval,
                            actionTitle:
                                remark.approvalStatus.isEmpty
                                    ? "Pending"
                                    : remark.approvalStatus,
                            approveIcon: Icons.check,
                            onApprove: (value) async {
                              final isSuccess = await _utilsCubit
                                  .updateModulesWorkflowApproval(
                                    context: context,
                                    moduleName: "FLAT ALTERATION APPROVAL",
                                    id: widget.bookingId,
                                    subId: remark.flatAlterationRequestId,
                                    projectId: widget.projectId,
                                    isApproved: true,
                                    remark: value.trim(),
                                  );

                              if (context.mounted && isSuccess) {
                                _requestManagementCubit
                                    .getFlatAlterationRequestList(
                                      context,
                                      10,
                                      1,
                                      widget.bookingId,
                                      widget.projectId,
                                    );
                              }
                            },
                            onReject: (value) async {
                              final isSuccess = await _utilsCubit
                                  .updateModulesWorkflowApproval(
                                    context: context,
                                    moduleName: "FLAT ALTERATION APPROVAL",
                                    id: widget.bookingId,
                                    subId: remark.flatAlterationRequestId,
                                    projectId: widget.projectId,
                                    isApproved: false,
                                    remark: value.trim(),
                                  );

                              if (context.mounted && isSuccess) {
                                _requestManagementCubit
                                    .getFlatAlterationRequestList(
                                      context,
                                      10,
                                      1,
                                      widget.bookingId,
                                      widget.projectId,
                                    );
                              }
                            },
                            onThirdTap: () async {
                              final approvalLogHistoryList = await _utilsCubit
                                  .getApprovalLogHistory(
                                    context: context,
                                    id: widget.bookingId,
                                    subId: remark.flatAlterationRequestId,
                                    projectId: widget.projectId,
                                    moduleName: "FLAT ALTERATION APPROVAL",
                                  );
                              if (context.mounted) {
                                goRouter.pushNamed(
                                  AppRoutes.approvalLogHistory,
                                  queryParameters: {
                                    "title": Uri.encodeComponent(
                                      EncryptionManager.encryptData(
                                        "Unit/ Modulation/ Customization Remark Log History",
                                      ),
                                    ),
                                    "approvalList": Uri.encodeComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(
                                          approvalLogHistoryList
                                              .map((e) => e.toJson())
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  },
                                );
                              }
                            },
                            popupTitle:
                                "Unit / Modulation / Customization Remark",
                          ),
                        )
                        : SizedBox.shrink(),
                  ],
                ),
              );
            },
          ),
        } else ...{
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: noDataWidget(
                    message: "No data available",
                    iconSize: 160.0,
                  ),
                ),
              ],
            ),
          ),
        },
      ],
    );
  }
}
