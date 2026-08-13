import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_state.dart';
import 'package:k3h_erp_app/features/parking/data/model/parking.model.dart';
import 'package:k3h_erp_app/features/parking/data/repository/parking.repository.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';

import 'package:k3h_erp_app/widgets/checkbox/custom_checkbox.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class UpdateRegistrationDateParkingScreen extends StatefulWidget {
  final int projectId;
  final int bookingId;
  const UpdateRegistrationDateParkingScreen({
    super.key,
    required this.projectId,
    required this.bookingId,
  });

  @override
  State<UpdateRegistrationDateParkingScreen> createState() =>
      _UpdateRegistrationDateParkingScreenState();
}

class _UpdateRegistrationDateParkingScreenState
    extends State<UpdateRegistrationDateParkingScreen> {
  final formKey = GlobalKey<FormState>();

  // REPOSITORY
  final ParkingRepository _parkingRepository =
      serviceLocator<ParkingRepository>();
  late PayTrackCubit _payTrackCubit;

  late ProjectModel _selectedProject;

  late ValueNotifier<List<Map<String, dynamic>>> _selectedBankNotifier;
  late ValueNotifier<bool> markAsFinalRegiserationNotifier;

  MultiFilePickerModel selectedChequeForPopUpFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  DateTime? finalRegisterationDate;

  @override
  void initState() {
    super.initState();
    _selectedBankNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    markAsFinalRegiserationNotifier = ValueNotifier(false);
    _payTrackCubit = context.read<PayTrackCubit>();
    _selectedProject = getProject();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _payTrackCubit.getPayTrackListByBookingId(
        context,
        1,
        widget.projectId,
        widget.bookingId,
      );

      final payTrack = _payTrackCubit.state.payTrackOverview;

      finalRegisterationDate = payTrack?.finalRegistrationDate;

      markAsFinalRegiserationNotifier.value =
          payTrack?.isFinalRegistrationCompleted ?? false;

      _selectedBankNotifier.value =
          (payTrack?.parkingData ?? [])
              .map(
                (e) => {
                  "zAttributesId": e.parkingId,
                  "DisplayName": e.parkingNumber,
                },
              )
              .toList();

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _selectedBankNotifier.dispose();
    markAsFinalRegiserationNotifier.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchParking(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _parkingRepository.getParkingWithPagination(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: _selectedProject.projectId,
      queryParams: {"ParkingNumber": value},
    );
    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final banks = response['data'] as List<ParkingModel>;

        return {
          "itemList":
              banks.map((bank) {
                return {
                  "zAttributesId": bank.parkingId,
                  "DisplayName": bank.parkingNumber,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  void _verifyAndSubmitForm() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final payTrack = _payTrackCubit.state.bookingData;

    if (payTrack == null) {
      showErrorMessage(context, "Error", "Booking data not found.");
      return;
    }

    _payTrackCubit.updateRegistrationDateAndParking(
      context,
      projectId: widget.projectId,
      bookingId: widget.bookingId,
      uniquekey: payTrack.uniquekey,

      finalRegistrationDate: finalRegisterationDate,

      parkingId: _selectedBankNotifier.value
          .map((e) => e["zAttributesId"].toString())
          .join(","),

      isFinalRegistrationCompleted: markAsFinalRegiserationNotifier.value,

      finalRegistrationDocument: selectedChequeForPopUpFile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PayTrackCubit, PayTrackState>(
      builder: (context, state) {
        final payTrack = state.payTrackOverview;

        return Scaffold(
          appBar: CustomAppBarWithBackButton(
            screenTitle:
                "${payTrack?.applicantName} > ${payTrack?.bookingType}-${payTrack?.flat}",
            authorization: AuthorizationModel(),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Update Registration Date & Parking",
                  style: AppTextStyle.ts14M(color: AppColor.black),
                ),
                verticalSpacing(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.lightGreyBackground,
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(width: 0.2, color: AppColor.black),
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ValueListenableBuilder<bool>(
                          valueListenable: markAsFinalRegiserationNotifier,
                          builder: (context, isChecked, child) {
                            return CustomDatePicker(
                              title: "Final Registration Date",
                              isRequired: isChecked,
                              initialDate: finalRegisterationDate,
                              setValue:
                                  (value) => finalRegisterationDate = value,
                              validator: (value) {
                                if (isChecked && value == null) {
                                  return "Final Registration Date is required";
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        ValueListenableBuilder(
                          valueListenable: _selectedBankNotifier,
                          builder: (context, selectedParking, child) {
                            return CustomMultipleSelectPopup(
                              hintText: "Select Parking",
                              title: "Parking",
                              isMultiSelect: true,
                              dataList: [],
                              initialValue: selectedParking,
                              onSelected: (value) {
                                _selectedBankNotifier.value = value;
                              },
                              dataFetchCallBack: _fetchParking,
                            );
                          },
                        ),
                        ValueListenableBuilder<bool>(
                          valueListenable: markAsFinalRegiserationNotifier,
                          builder: (context, isChecked, child) {
                            return CustomCheckBox(
                              isSelected: isChecked,
                              title:
                                  "Mark as Final Registeration (Cannot Be Changed)",
                              onChanged: (_) {
                                markAsFinalRegiserationNotifier.value =
                                    !markAsFinalRegiserationNotifier.value;
                              },
                            );
                          },
                        ),
                        verticalSpacing(),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "By selecting this option, the ",
                                style: AppTextStyle.ts14R(
                                  color: AppColor.black.withValues(alpha: 0.5),
                                ),
                              ),
                              TextSpan(
                                text: "Registration ",
                                style: AppTextStyle.ts14B(),
                              ),
                              TextSpan(
                                text:
                                    "will be finalized and cannot be changed later.",
                                style: AppTextStyle.ts14R(
                                  color: AppColor.black.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ValueListenableBuilder<bool>(
                          valueListenable: markAsFinalRegiserationNotifier,
                          builder: (context, isChecked, child) {
                            if (!isChecked) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              children: [
                                verticalSpacing(),
                                CustomMultiFilePicker(
                                  title: "Final Registered Agreement",
                                  isRequired: true,
                                  filePickType: FilePickType.both,
                                  initialFileList:
                                      selectedChequeForPopUpFile.fileNameList,
                                  onFilePickedCallback: (
                                    bytesList,
                                    fileNameList,
                                  ) {
                                    selectedChequeForPopUpFile.fileNameList =
                                        fileNameList;
                                    selectedChequeForPopUpFile.fileBytesList =
                                        bytesList;
                                  },
                                  onFileDeleteCallback: (
                                    fileBytesList,
                                    fileNameList,
                                    deletedFile,
                                  ) {
                                    selectedChequeForPopUpFile.fileNameList =
                                        fileNameList;
                                    selectedChequeForPopUpFile.fileBytesList =
                                        fileBytesList;
                                    selectedChequeForPopUpFile.deletedFileList =
                                        deletedFile;
                                  },
                                  validator: (fileList) {
                                    if (fileList == null || fileList.isEmpty) {
                                      return "Final Registered Agreement is required";
                                    }
                                    return null;
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
              color: AppColor.white,
              padding: EdgeInsets.all(16),
              child: CustomButton(
                text: "Save",
                onPressed: _verifyAndSubmitForm,
              ),
            ),
          ),
        );
      },
    );
  }
}
