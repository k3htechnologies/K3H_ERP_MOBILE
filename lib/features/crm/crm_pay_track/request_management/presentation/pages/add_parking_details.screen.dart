import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/parking_modification_request.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/cubit/request_management_cubit.dart';
import 'package:k3h_erp_app/features/parking/data/model/parking.model.dart';
import 'package:k3h_erp_app/features/parking/data/repository/parking.repository.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddParkingDetailsScreen extends StatefulWidget {
  final ParkingModificationRequestModel? parking;
  const AddParkingDetailsScreen({super.key, this.parking});

  @override
  State<AddParkingDetailsScreen> createState() =>
      _AddParkingDetailsScreenState();
}

class _AddParkingDetailsScreenState extends State<AddParkingDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  // REPOSITORY
  final ParkingRepository _parkingRepository =
      serviceLocator<ParkingRepository>();
  late TextEditingController _currentParkingNumberC;
  late RequestManagementCubit _requestManagementCubit;
  late ValueNotifier<List<Map<String, dynamic>>> _selectedBankNotifier;
  late ProjectModel _selectedProject;
  MultiFilePickerModel prrofOfDocumentFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  @override
  void initState() {
    super.initState();
    _currentParkingNumberC = TextEditingController();
    _selectedBankNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _requestManagementCubit = context.read<RequestManagementCubit>();
    _selectedProject = getProject();
    if (widget.parking != null) {
      if (widget.parking!.proofOfDocumentUrl.isNotEmpty) {
        prrofOfDocumentFile.fileNameList = widget.parking!.proofOfDocumentUrl
            .split(",");
      }

      if (widget.parking != null) {
        if (widget.parking!.proofOfDocumentUrl.isNotEmpty) {
          prrofOfDocumentFile.fileNameList = widget.parking!.proofOfDocumentUrl
              .split(",");
        }

        _selectedBankNotifier.value =
            widget.parking!.parkingData
                .map(
                  (e) => {
                    "zAttributesId": e.parkingId,
                    "DisplayName": e.parkingNumber,
                  },
                )
                .toList();
      }
    }
  }

  @override
  void dispose() {
    _currentParkingNumberC.dispose();
    _selectedBankNotifier.dispose();
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestManagementCubit, RequestManagementState>(
      builder: (context, state) {
        if (state.isLoading ?? false) {
          return Center(child: loader());
        }
        return Scaffold(
          appBar: CustomAppBarWithBackButton(
            screenTitle: "Parking Modification Request",
            authorization: AuthorizationModel(),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.parking == null
                      ? "Add Parking Modification Request"
                      : "Update Parking Modification Request",
                  style: AppTextStyle.ts14M(color: AppColor.grey),
                ),
                verticalSpacing(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 12.0,
                  ),
                  decoration: commonCardDecoration(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          textController:
                              _currentParkingNumberC
                                ..text = state.bookingData?.parkingNumber ?? "",
                          title: "Current Parking Number",
                          hint: "Parking Number",
                          readOnly: true,
                        ),
                        CustomMultiFilePicker(
                          isRequired: true,
                          title: "Proof Of Document",
                          filePickType: FilePickType.kycDocument,
                          initialFileList: prrofOfDocumentFile.fileNameList,
                          initialFileBytes: prrofOfDocumentFile.fileBytesList,
                          onFilePickedCallback: (bytesList, fileNameList) {
                            prrofOfDocumentFile.fileNameList = fileNameList;
                            prrofOfDocumentFile.fileBytesList = bytesList;
                          },
                          onFileDeleteCallback: (
                            fileBytesList,
                            fileNameList,
                            deleted,
                          ) {
                            prrofOfDocumentFile.fileBytesList = fileBytesList;
                            prrofOfDocumentFile.fileNameList = fileNameList;
                            prrofOfDocumentFile.deletedFileList = deleted;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Proof Of Document is required";
                            }
                            return null;
                          },
                        ),

                        ValueListenableBuilder(
                          valueListenable: _selectedBankNotifier,
                          builder: (context, selectedParking, child) {
                            return CustomMultipleSelectPopup(
                              hintText: "Select Parking",
                              title: "Parking",
                              isRequired: true,
                              isMultiSelect: true,
                              dataList: [],
                              initialValue: selectedParking,
                              onSelected: (value) {
                                _selectedBankNotifier.value = value;
                              },
                              dataFetchCallBack: _fetchParking,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Parking is required";
                                }
                                return null;
                              },
                              onClear: () {
                                _selectedBankNotifier.value = [];
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
              height: 70.0,
              padding: const EdgeInsets.all(16.0),
              child: CustomButton(
                text: widget.parking == null ? "Add" : "Update",
                onPressed: () {
                  if (!(_formKey.currentState?.validate() ?? false)) {
                    return;
                  }

                  final parkingIds = _selectedBankNotifier.value
                      .map((e) => e["zAttributesId"].toString())
                      .join(",");
                  if (widget.parking == null) {
                    _requestManagementCubit.addParkingModificationRequest(
                      context,
                      bookingId: state.bookingData!.bookingId,
                      projectId: state.bookingData!.projectId,
                      parkingId: parkingIds,
                      proofDocumentFile: prrofOfDocumentFile,
                    );
                  } else {
                    _requestManagementCubit.updateParkingModificationRequest(
                      context,
                      parkingModificationRequestId:
                          widget.parking!.parkingModificationRequestId,
                      bookingId: widget.parking!.bookingId,
                      projectId: widget.parking!.projectId,
                      uniquekey: widget.parking!.uniqueKey,
                      parkingId: parkingIds,
                      proofDocumentFile: prrofOfDocumentFile,
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
