import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/model/department.model.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/repository/department_master.repository.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/more/events/calendar/data/datasource/calendar.datasource.dart';
import 'package:k3h_erp_app/features/more/events/calendar/data/models/calendar_event.dart';
import 'package:k3h_erp_app/features/more/events/calendar/data/repository/calendar.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

part 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit()
    : _calendarRepository = CalendarRepositoryImpl(
        calendarDatasource: CalendarDatasourceImpl(),
      ),
      super(CalendarState.initial());

  // EMPLOYEE REPOSITORY
  EmployeeMasterRepository employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();

  // DEPARTMENT REPOSITORY
  DepartmentMasterRepository departmentMasterRepository =
      serviceLocator<DepartmentMasterRepository>();

  final CalendarRepository _calendarRepository;

  // GET EVENTS (RANGE)
  Future<void> getEvents({
    required BuildContext context,
    required DateTime fromDate,
    required DateTime toDate,
    Map<String, dynamic>? queryParams,
  }) async {
    emit(state.copyWith(isLoading: true));
    final result = await _calendarRepository.getEventList(
      fromDate: fromDate.toIso8601String(),
      toDate: toDate.toIso8601String(),
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            eventsList: List<CalendarEventModel>.from(response['data']),
            totalNumberOfRecord: response['totalNumberOfRecord'] ?? 0,
          ),
        );
      },
    );
  }

  // GET DATE DETAIL EVENTS (FOR SPECIFIC DATE)
  Future<void> getDateDetailEvents({
    required BuildContext context,
    required DateTime date,
  }) async {
    emit(state.copyWith(isLoadingDateDetail: true));
    final start = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final result = await _calendarRepository.getEventList(
      fromDate: start.toIso8601String(),
      toDate: end.toIso8601String(),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoadingDateDetail: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        emit(
          state.copyWith(
            isLoadingDateDetail: false,
            dateDetailEvents: List<CalendarEventModel>.from(response['data']),
          ),
        );
      },
    );
  }

  // ADD EVENT
  Future<void> addEvent({
    required BuildContext context,
    required String type,
    required String title,
    required String projects,
    required String departments,
    required String members,
    required String date,
    required String deadlineDate,
    required String startTime,
    required String endTime,
    required String room,
    required String priority,
    required String description,
    required MultiFilePickerModel document,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> requestBody = {
      "EventId": "0",
      "Type": type,
      "Title": title,
      "ProjectId": projects,
      "Departments": departments,
      "Members": members,
      "Date": date,
      "DeadlineDate": deadlineDate,
      "StartTime": startTime,
      "EndTime": endTime,
      "Room": room,
      "Priority": priority,
      "Description": description,
    };

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < document.fileNameList.length; i++) {
      if (document.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "DocumentURL",
        "value": document.fileBytesList[i],
        "fileName": document.fileNameList[i],
      });
    }

    final result = await _calendarRepository.addUpdateEvent(
      body: requestBody,
      fileList: fileList,
    );
    goRouter.pop();

    result.fold(
      (failure) => showErrorMessage(context, 'Error', failure.message),
      (response) {
        final List<CalendarEventModel> apiEvents =
            List<CalendarEventModel>.from(response['data']);

        // prepend latest event(s)
        emit(
          state.copyWith(
            eventsList: [...apiEvents, ...state.eventsList],
            totalNumberOfRecord:
                state.totalNumberOfRecord <= 0
                    ? apiEvents.length
                    : state.totalNumberOfRecord + apiEvents.length,
          ),
        );
        showSuccessMessage(context);
      },
    );
  }

  Future<void> updateEvent({
    required BuildContext context,
    required String eventId,
    required String uniqueKey,
    required String type,
    required String title,
    required String projects,
    required String departments,
    required String members,
    required String date,
    required String deadlineDate,
    required String startTime,
    required String endTime,
    required String room,
    required String priority,
    required String description,
    required MultiFilePickerModel document,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> requestBody = {
      "EventId": eventId,
      "UniqueKey": uniqueKey,
      "Type": type,
      "Title": title,
      "Projects": projects,
      "Departments": departments,
      "Members": members,
      "Date": date,
      "DeadlineDate": deadlineDate,
      "StartTime": startTime,
      "EndTime": endTime,
      "Room": room,
      "Priority": priority,
      "Description": description,
      "RemoveDocumentURL": document.deletedFileList,
    };

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < document.fileNameList.length; i++) {
      if (document.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "DocumentURL",
        "value": document.fileBytesList[i],
        "fileName": document.fileNameList[i],
      });
    }

    final result = await _calendarRepository.addUpdateEvent(
      body: requestBody,
      fileList: fileList,
    );
    goRouter.pop();

    result.fold(
      (failure) => showErrorMessage(context, 'Error', failure.message),
      (response) {
        final List<CalendarEventModel> apiEvents =
            List<CalendarEventModel>.from(response['data']);

        // prepend latest event(s)
        emit(
          state.copyWith(
            eventsList: [...apiEvents, ...state.eventsList],
            totalNumberOfRecord:
                state.totalNumberOfRecord <= 0
                    ? apiEvents.length
                    : state.totalNumberOfRecord + apiEvents.length,
          ),
        );
        showSuccessMessage(context);
      },
    );
  }

  // DELETE EVENT
  Future<void> deleteEvent({
    required BuildContext context,
    required int eventId,
    required String uniqueKey,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    final result = await _calendarRepository.deleteEvent(
      eventId: eventId,
      uniqueKey: uniqueKey,
    );
    goRouter.pop();

    result.fold(
      (failure) => showErrorMessage(context, 'Error', failure.message),
      (_) {
        final updated = List<CalendarEventModel>.from(
          state.eventsList,
        )..removeWhere((e) => e.eventId == eventId || e.uniquekey == uniqueKey);
        emit(
          state.copyWith(
            eventsList: updated,
            totalNumberOfRecord:
                state.totalNumberOfRecord > 0
                    ? state.totalNumberOfRecord - 1
                    : 0,
          ),
        );
        showSuccessMessage(context);
      },
    );
  }

  Future<Map<String, dynamic>> getMembersList(
    int pageNumber, {
    String? value,
  }) async {
    var result = await employeeMasterRepository.getEmployeeMasterList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: {'EmployeeName': value ?? ''},
    );

    return result.fold(
      (failure) {
        return {
          "itemList": <Map<String, dynamic>>[
            {'zAttributesId': -1, 'DisplayName': 'Select Members'},
          ],
          "totalNumberOfRecord": 0,
        };
      },
      (response) {
        final List<Map<String, dynamic>> employees =
            List<Map<String, dynamic>>.from(
              (response['data'] as List<UserModel>).map(
                (e) => {
                  "zAttributesId": e.employeeId,
                  "DisplayName": e.fullName,
                },
              ),
            );

        return {
          "itemList": employees,
          "totalNumberOfRecord": response["totalNumberOfRecord"],
        };
      },
    );
  }

  Future<Map<String, dynamic>> getDepartmentList(
    int pageNumber, {
    String? value,
  }) async {
    var result = await departmentMasterRepository.getDepartmentList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: {'DepartmentName': value ?? ''},
    );

    return result.fold(
      (failure) {
        return {
          "itemList": <Map<String, dynamic>>[
            {'zAttributesId': -1, 'DisplayName': 'Select Department'},
          ],
          "totalNumberOfRecord": 0,
        };
      },
      (response) {
        final List<Map<String, dynamic>> departments =
            List<Map<String, dynamic>>.from(
              (response['data'] as List<DepartmentModel>).map(
                (e) => {
                  "zAttributesId": e.departmentMasterId,
                  "DisplayName": e.departmentName,
                },
              ),
            );

        return {
          "itemList": departments,
          "totalNumberOfRecord": response["totalNumberOfRecord"],
        };
      },
    );
  }
}
