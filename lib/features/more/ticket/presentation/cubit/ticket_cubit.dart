import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/more/ticket/data/model/ticket.model.dart';
import 'package:k3h_erp_app/features/more/ticket/data/model/ticket_employee.model.dart';
import 'package:k3h_erp_app/features/more/ticket/data/repository/ticket.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'ticket_state.dart';

class TicketCubit extends Cubit<TicketState> {
  TicketCubit() : super(TicketState.initial());

  // REPOSITORY
  final TicketRepository _ticketRepository = serviceLocator<TicketRepository>();

  Future searchTicket(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, ticketList: []));
    await getTicketList(context, 1);
  }

  Future applyFilterAndSort({
    required BuildContext context,
    required String platform,
    required String module,
    required String priority,
    required String department,
    required String status,
    String? sortColumn,
    String? sortDirection,
  }) async {
    emit(
      state.copyWith(
        filterPlatform: platform,
        filterModule: module,
        filterPriority: priority,
        filterDepartment: department,
        filterStatus: status,
        currentSortColumn: sortColumn ?? state.currentSortColumn,
        currentSortDirection: sortDirection ?? state.currentSortDirection,
        ticketList: [],
        currentPage: 1,
      ),
    );

    await getTicketList(context, 1);
  }

  Future getTicketList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "SystemGeneratedCode": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
      "Platform": state.filterPlatform,
      "Module": state.filterModule,
      "DepartmentName": state.filterDepartment,
      "Priority": state.filterPriority,
      "TicketStatus": state.filterStatus,
    };
    var result = await _ticketRepository.getTicketList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<TicketModel> tickets = response['data'];
        final updatedList =
            pageNumber == 1 ? tickets : [...state.ticketList, ...tickets];

        emit(
          state.copyWith(
            ticketList: updatedList,
            currentPage: pageNumber,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            isLoading: false,
          ),
        );
      },
    );
  }

  Future getTicketDetails(
    BuildContext context,
    int projectId,
    int ticketId,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _ticketRepository.getTicketList(
      pageNumber: 1,
      pageSize: 1,
      queryParams: {"TicketId": ticketId},
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
      },
      (response) {
        final List<TicketModel> tickets = response['data'];

        emit(
          state.copyWith(
            ticketModel: tickets.isNotEmpty ? tickets.first : null,
            isLoading: false,
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> getEmployeeActiveTicketsDropdown(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _ticketRepository.pullEmployeeActiveTickets(
      pageNumber: pageNumber,
      pageSize: 20,
    );

    return result.fold(
      (failure) {
        return {"itemList": <Map<String, dynamic>>[], "totalNumberOfRecord": 0};
      },
      (response) {
        final employees = response["data"] as List<TicketEmployeeModel>;

        return {
          "itemList":
              employees.map((e) {
                return {
                  "zAttributesId": e.employeeId,
                  "EmployeeId": e.employeeId,
                  "EmployeeName": e.employeeName,
                  "ActiveTickets": e.activeTickets,
                  "DisplayName": "${e.employeeName} (${e.activeTickets})",
                };
              }).toList(),
          "totalNumberOfRecord":
              response["totalNumberOfRecord"] ?? employees.length,
        };
      },
    );
  }

  Future addAssignTask(
    BuildContext context, {
    required int ticketId,
    required int assignToEmployeeId,
    required String collaboratorsEmployeeId,
    required String assignedStatus,
    required String ticketRemark,
    required DateTime resolvedTillDate,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> body = {
      "TicketId": 0.toString(),
      "AssignToEmployeeId": assignToEmployeeId.toString(),
      "CollaboratorsEmployeeId": collaboratorsEmployeeId,
      "AssignedStatus": assignedStatus,
      "TicketRemark": ticketRemark,
      "ResolvedTillDate": resolvedTillDate.toIso8601String(),
    };
    List<Map<String, dynamic>> fileList = [];

    var addResult = await _ticketRepository.assignTicket(
      body: body,
      fileList: fileList,
    );

    goRouter.pop();

    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final newItem = response['data'][0] as TicketModel;

        emit(state.copyWith(ticketModel: newItem));
        showSuccessMessage(context, subTitle: response['message']);
        goRouter.pop();
        getTicketList(context, 1);
      },
    );
  }

  Future updateAssignTask(
    BuildContext context, {
    required int ticketId,
    required int assignToEmployeeId,
    required String collaboratorsEmployeeId,
    required String assignedStatus,
    required String ticketRemark,
    required DateTime resolvedTillDate,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> body = {
      "TicketId": ticketId.toString(),
      "AssignToEmployeeId": assignToEmployeeId.toString(),
      "CollaboratorsEmployeeId": collaboratorsEmployeeId,
      "AssignedStatus": assignedStatus,
      "TicketRemark": ticketRemark,
      "ResolvedTillDate": resolvedTillDate.toIso8601String(),
    };
    List<Map<String, dynamic>> fileList = [];
    var addResult = await _ticketRepository.assignTicket(
      body: body,
      fileList: fileList,
    );

    goRouter.pop();

    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final newItem = response['data'][0] as TicketModel;

        emit(state.copyWith(ticketModel: newItem));
        showSuccessMessage(context, subTitle: response['message']);
        goRouter.pop();
        getTicketList(context, 1);
      },
    );
  }

  Future addTask(
    BuildContext context, {
    required String platform,
    required String module,
    required String ticketDescription,
    required String priority,
    required String ticketRemark,
    required MultiFilePickerModel documnetURL,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> body = {
      "Platform": platform,
      "Module": module,
      "TicketDescription": ticketDescription,
      "Priority": priority,
      "TicketRemark": ticketRemark,
    };
    List<Map<String, dynamic>> fileList = [];

    // DOCUMENT
    for (int i = 0; i < documnetURL.fileNameList.length; i++) {
      if (documnetURL.fileNameList[i].contains("http")) continue;

      fileList.add({
        "key": "AttachmentURL",
        "value": documnetURL.fileBytesList[i],
        "fileName": documnetURL.fileNameList[i],
      });
    }

    var addResult = await _ticketRepository.addUpdateTicket(
      body: body,
      fileList: fileList,
    );

    goRouter.pop();

    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final newItem = response['data'][0] as TicketModel;

        emit(state.copyWith(ticketModel: newItem));
        showSuccessMessage(context, subTitle: response['message']);
        goRouter.pop();
        getTicketList(context, 1);
      },
    );
  }

  Future updateTask(
    BuildContext context, {
    required int ticketId,
    required String uniquekey,
    required String platform,
    required String module,
    required String ticketDescription,
    required String priority,
    required String ticketRemark,
    required MultiFilePickerModel documnetURL,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> body = {
      "TicketId": ticketId.toString(),
      "Uniquekey": uniquekey,
      "Platform": platform,
      "Module": module,
      "TicketDescription": ticketDescription,
      "Priority": priority,
      "TicketRemark": ticketRemark,
      "RemoveAttachmentURL": documnetURL.deletedFileList,
    };
    List<Map<String, dynamic>> fileList = [];

    // DOCUMENT
    for (int i = 0; i < documnetURL.fileNameList.length; i++) {
      if (documnetURL.fileNameList[i].contains("http")) continue;

      fileList.add({
        "key": "AttachmentURL",
        "value": documnetURL.fileBytesList[i],
        "fileName": documnetURL.fileNameList[i],
      });
    }

    var addResult = await _ticketRepository.addUpdateTicket(
      body: body,
      fileList: fileList,
    );

    goRouter.pop();

    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final newItem = response['data'][0] as TicketModel;

        emit(state.copyWith(ticketModel: newItem));
        showSuccessMessage(context, subTitle: response['message']);
        goRouter.pop();
        getTicketList(context, 1);
      },
    );
  }
}
