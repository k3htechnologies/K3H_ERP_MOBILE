import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/cubit/request_management_cubit.dart';
import 'package:k3h_erp_app/features/parking/data/model/parking.model.dart';
import 'package:k3h_erp_app/features/parking/data/repository/parking.repository.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddParkingDetailsScreen extends StatefulWidget {
  const AddParkingDetailsScreen({super.key});

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
  @override
  void initState() {
    super.initState();
    _currentParkingNumberC = TextEditingController();
    _selectedBankNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _requestManagementCubit = context.read<RequestManagementCubit>();
    _selectedProject = getProject();
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
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Swap Parking",
        authorization: AuthorizationModel(),
      ),
      body: BlocBuilder<RequestManagementCubit, RequestManagementState>(
        builder: (context, state) {
          if (state.isLoading ?? false) {
            return Center(child: CircularProgressIndicator());
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
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
                        ValueListenableBuilder(
                          valueListenable: _selectedBankNotifier,
                          builder: (context, selectedParking, child) {
                            return CustomMultipleSelectPopup(
                              hintText: "Select Parking Type",
                              title: "Parking Type",
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
                                  return "Parking Type is required";
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
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButton(
                      text: "Add",
                      onPressed: () {
                        if (!(_formKey.currentState?.validate() ?? false)) {
                          return;
                        }

                        final selectedParking =
                            _selectedBankNotifier.value.first;
                        _requestManagementCubit.addParkingModificationRequest(
                          context,
                          bookingId: state.bookingData?.bookingId ?? 0,
                          projectId: state.bookingData?.projectId ?? 0,
                          parkingId:
                              selectedParking['zAttributesId'].toString(),
                          uniquekey: state.bookingData!.uniquekey,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
