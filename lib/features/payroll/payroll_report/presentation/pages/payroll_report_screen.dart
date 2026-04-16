import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/payroll/attendance/data/model/attendance.model.dart';
import 'package:k3h_erp_app/features/payroll/payroll_report/data/model/payroll_report.model.dart';
import 'package:k3h_erp_app/features/payroll/payroll_report/presentation/cubit/payroll_report_cubit.dart';
import 'package:k3h_erp_app/features/payroll/payroll_report/presentation/pages/route_map_screen.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/approve_reject_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class PayrollReportScreen extends StatefulWidget {
  const PayrollReportScreen({super.key});

  @override
  State<PayrollReportScreen> createState() => _PayrollReportScreenState();
}

class _PayrollReportScreenState extends State<PayrollReportScreen>
    with TickerProviderStateMixin {
  // TAB CONTROLLER
  late TabController _tabController;
  late TabController _regularizationTabController;
  late TabController _compOffTabController;
  late TabController _leaveTabController;
  late TabController _outdoorTabController;
  late TabController _resignationTabController;

  late ProjectModel _project;

  // CUBIT
  late PayrollReportCubit _payrollReportCubit;

  // TEXT CONTROLLER
  late TextEditingController _searchC;

  // SELECTED DATE
  late ValueNotifier<DateTime> _selectedDateNotifier;

  // ATTENDANCE PAGINATION
  late ScrollController _attendanceScrollController;
  Timer? _attendanceDebounce;
  // REGULARIZATION PAGINATION
  late ScrollController _regularizationReportController;
  late ScrollController _regularizationApprovalController;
  Timer? _regularizationReportDebounce;
  Timer? _regularizationApprovalDebounce;

  // COMPOFF PAGINATION
  late ScrollController _compOffReportController;
  late ScrollController _compOffApprovalController;
  Timer? _compOffReportDebounce;
  Timer? _compOffApprovalDebounce;

  // LEAVE PAGINATION
  late ScrollController _leaveReportController;
  late ScrollController _leaveApprovalController;
  Timer? _leaveReportDebounce;
  Timer? _leaveApprovalDebounce;

  // OUTDOOR PAGINATION
  late ScrollController _outdoorReportController;
  late ScrollController _outdoorApprovalController;
  Timer? _outdoorReportDebounce;
  Timer? _outdoorApprovalDebounce;

  // RESIGNATION PAGINATION
  late ScrollController _resignationReportController;
  late ScrollController _resignationApprovalController;
  Timer? _resignationReportDebounce;
  Timer? _resignationApprovalDebounce;

  // FILTER
  final ValueNotifier<DateTime?> _startDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  final ValueNotifier<DateTime?> _endDateNotifier = ValueNotifier<DateTime?>(
    null,
  );

  @override
  void initState() {
    super.initState();

    _project = getProject();
    _payrollReportCubit = context.read<PayrollReportCubit>();
    _searchC = TextEditingController();
    _selectedDateNotifier = ValueNotifier(DateTime.now());

    // TAB CONTROLLERS
    _tabController = TabController(length: 6, vsync: this);
    _regularizationTabController = TabController(length: 2, vsync: this);
    _compOffTabController = TabController(length: 2, vsync: this);
    _leaveTabController = TabController(length: 2, vsync: this);
    _outdoorTabController = TabController(length: 2, vsync: this);
    _resignationTabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);

    // SCROLL CONTROLLERS
    _attendanceScrollController = ScrollController();

    // Report & Approval ScrollControllers
    _regularizationReportController = ScrollController();
    _regularizationApprovalController = ScrollController();

    _compOffReportController = ScrollController();
    _compOffApprovalController = ScrollController();

    _leaveReportController = ScrollController();
    _leaveApprovalController = ScrollController();

    _outdoorReportController = ScrollController();
    _outdoorApprovalController = ScrollController();

    _resignationReportController = ScrollController();
    _resignationApprovalController = ScrollController();

    // Attach all pagination listeners
    _initializePagination();

    // Selected date listener
    _selectedDateNotifier.addListener(_onSelectedDateChanged);

    // Load data for the default tab
    _loadDataForTab(_tabController.index);

    // Attach inner tab listeners
    _initializeInnerTabListeners();
  }

  /// Initializes pagination listeners for both reports and approvals
  void _initializePagination() {
    _setupAttendancePagination();

    // REGULARIZATION
    _setupRegularizationPagination();
    _setupRegularizationApprovalPagination();

    // COMPOFF
    _setupCompOffPagination();
    _setupCompOffApprovalPagination();

    // LEAVE
    _setupLeavePagination();
    _setupLeaveApprovalPagination();

    // OUTDOOR
    _setupOutdoorPagination();
    _setupOutdoorApprovalPagination();

    // RESIGNATION
    _setupResignationPagination();
    _setupResignationApprovalPagination();
  }

  /// INITIALIZES INNER TAB LISTENERS
  void _initializeInnerTabListeners() {
    // LEAVE
    _leaveTabController.addListener(() {
      final startDate =
          _payrollReportCubit.state.filterStartDate ??
          _selectedDateNotifier.value;
      final endDate =
          _payrollReportCubit.state.filterEndDate ??
          _selectedDateNotifier.value;

      if (!_leaveTabController.indexIsChanging) {
        final innerIndex = _leaveTabController.index;
        _payrollReportCubit.onLeaveInnerTabChanged(innerIndex);

        _payrollReportCubit.getLeaveList(
          context: context,
          pageNumber: 1,
          startDate: startDate,
          endDate: endDate,
          canApprove: innerIndex == 1,
        );
      }
    });

    // COMPOFF
    _compOffTabController.addListener(() {
      final startDate =
          _payrollReportCubit.state.filterStartDate ??
          _selectedDateNotifier.value;
      final endDate =
          _payrollReportCubit.state.filterEndDate ??
          _selectedDateNotifier.value;

      if (!_compOffTabController.indexIsChanging) {
        final innerIndex = _compOffTabController.index;
        _payrollReportCubit.onCompOffInnerTabChanged(innerIndex);

        _payrollReportCubit.getCompOffList(
          context: context,
          pageNumber: 1,
          startDate: startDate,
          endDate: endDate,
          canApprove: innerIndex == 1,
        );
      }
    });

    // REGULARIZATION
    _regularizationTabController.addListener(() {
      final startDate =
          _payrollReportCubit.state.filterStartDate ??
          _selectedDateNotifier.value;
      final endDate =
          _payrollReportCubit.state.filterEndDate ??
          _selectedDateNotifier.value;

      if (!_regularizationTabController.indexIsChanging) {
        final innerIndex = _regularizationTabController.index;
        _payrollReportCubit.onRegularizationInnerTabChanged(innerIndex);

        _payrollReportCubit.getAttendanceRegularizationList(
          context: context,
          pageNumber: 1,
          startDate: startDate,
          endDate: endDate,
          canApprove: innerIndex == 1,
        );
      }
    });

    // OUTDOOR
    _outdoorTabController.addListener(() {
      final startDate =
          _payrollReportCubit.state.filterStartDate ??
          _selectedDateNotifier.value;
      final endDate =
          _payrollReportCubit.state.filterEndDate ??
          _selectedDateNotifier.value;

      if (!_outdoorTabController.indexIsChanging) {
        final innerIndex = _outdoorTabController.index;
        _payrollReportCubit.onOutdoorInnerTabChanged(innerIndex);

        _payrollReportCubit.getOutdoorList(
          context: context,
          pageNumber: 1,
          startDate: startDate,
          endDate: endDate,
          canApprove: innerIndex == 1,
        );
      }
    });

    // RESIGNATION
    _resignationTabController.addListener(() {
      final startDate =
          _payrollReportCubit.state.filterStartDate ??
          _selectedDateNotifier.value;
      final endDate =
          _payrollReportCubit.state.filterEndDate ??
          _selectedDateNotifier.value;

      if (!_resignationTabController.indexIsChanging) {
        final innerIndex = _resignationTabController.index;
        _payrollReportCubit.onResignationInnerTabChanged(innerIndex);

        _payrollReportCubit.getResignationList(
          context: context,
          pageNumber: 1,
          startDate: startDate,
          endDate: endDate,
          canApprove: innerIndex == 1,
        );
      }
    });
  }

  @override
  void dispose() {
    _selectedDateNotifier.removeListener(_onSelectedDateChanged);

    // DISPOSE TAB CONTROLLERS
    _tabController.dispose();
    _regularizationTabController.dispose();
    _compOffTabController.dispose();
    _leaveTabController.dispose();
    _outdoorTabController.dispose();
    _resignationTabController.dispose();

    // DISPOSE TEXTCONTROLLERS
    _searchC.dispose();
    _selectedDateNotifier.dispose();

    //CANCEL DEBOUNCE TIMERS
    _attendanceDebounce?.cancel();
    _regularizationReportDebounce?.cancel();
    _regularizationApprovalDebounce?.cancel();
    _compOffReportDebounce?.cancel();
    _compOffApprovalDebounce?.cancel();
    _leaveReportDebounce?.cancel();
    _leaveApprovalDebounce?.cancel();
    _outdoorReportDebounce?.cancel();
    _outdoorApprovalDebounce?.cancel();
    _resignationReportDebounce?.cancel();
    _resignationApprovalDebounce?.cancel();

    // DISPOSE SCROLLCONTROLLERS
    _attendanceScrollController.dispose();
    _regularizationReportController.dispose();
    _regularizationApprovalController.dispose();
    _compOffReportController.dispose();
    _compOffApprovalController.dispose();
    _leaveReportController.dispose();
    _leaveApprovalController.dispose();
    _outdoorReportController.dispose();
    _outdoorApprovalController.dispose();
    _resignationReportController.dispose();
    _resignationApprovalController.dispose();

    // DISPOSE DATE FILTERS
    _startDateNotifier.dispose();
    _endDateNotifier.dispose();

    super.dispose();
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      final index = _tabController.index;
      _payrollReportCubit.onTabChanged(index, context);
      _loadDataForTab(index);
    }
  }

  // FORWARD ARROW CLICKED
  void _onForwardArrowClicked() {
    _selectedDateNotifier.value = _selectedDateNotifier.value.add(
      const Duration(days: 1),
    );
  }

  // BACK ARROW CLICKED
  void _onBackArrowClicked() {
    _selectedDateNotifier.value = _selectedDateNotifier.value.subtract(
      const Duration(days: 1),
    );
  }

  // WHEN SELECTED DATE CHANGES, REFETCH CURRENT TAB DATA
  void _onSelectedDateChanged() {
    final startDate =
        _payrollReportCubit.state.filterStartDate ??
        _selectedDateNotifier.value;
    final endDate =
        _payrollReportCubit.state.filterEndDate ?? _selectedDateNotifier.value;

    _payrollReportCubit.resetApprovalTabSelection();
    switch (_tabController.index) {
      case 0:
        _payrollReportCubit.getAttendanceList(
          context,
          1,
          startDate: startDate,
          endDate: endDate,
        );
        break;
      case 1:
        if (!_regularizationTabController.indexIsChanging) {
          _payrollReportCubit.getAttendanceRegularizationList(
            context: context,
            pageNumber: 1,

            startDate: startDate,
            endDate: endDate,
            canApprove: _regularizationTabController.index == 1,
          );
        }
        break;
      case 2:
        if (!_compOffTabController.indexIsChanging) {
          _payrollReportCubit.getCompOffList(
            context: context,
            pageNumber: 1,

            startDate: startDate,
            endDate: endDate,
            canApprove: _compOffTabController.index == 1,
          );
        }
        break;

      case 3:
        if (!_leaveTabController.indexIsChanging) {
          _payrollReportCubit.getLeaveList(
            context: context,
            pageNumber: 1,

            startDate: startDate,
            endDate: endDate,
            canApprove: _leaveTabController.index == 1,
          );
        }
        break;
      case 4:
        if (!_outdoorTabController.indexIsChanging) {
          _payrollReportCubit.getOutdoorList(
            context: context,
            pageNumber: 1,

            startDate: startDate,
            endDate: endDate,
            canApprove: _outdoorTabController.index == 1,
          );
        }
        break;
      case 5:
        if (!_resignationTabController.indexIsChanging) {
          _payrollReportCubit.getResignationList(
            context: context,
            pageNumber: 1,

            startDate: startDate,
            endDate: endDate,
            canApprove: _resignationTabController.index == 1,
          );
        }
        break;
      default:
        break;
    }
  }

  // LOAD DATA BASED ON CURRENT TAB
  void _loadDataForTab(int index) {
    final startDate =
        _payrollReportCubit.state.filterStartDate ??
        _selectedDateNotifier.value;
    final endDate =
        _payrollReportCubit.state.filterEndDate ?? _selectedDateNotifier.value;
    _payrollReportCubit.resetApprovalTab();

    switch (index) {
      case 0: // Attendance
        if (_payrollReportCubit.state.attendanceList.isEmpty) {
          _payrollReportCubit.getAttendanceList(
            context,
            1,
            startDate: startDate,
            endDate: endDate,
          );
        }
        break;

      case 1: // REGULARIZE
        _regularizationTabController.index = 0;
        _payrollReportCubit.getAttendanceRegularizationList(
          context: context,
          pageNumber: 1,
          startDate: startDate,
          endDate: endDate,
        );
        break;

      case 2: // Comp Off
        _compOffTabController.index = 0;
        _payrollReportCubit.getCompOffList(
          context: context,
          pageNumber: 1,

          startDate: startDate,
          endDate: endDate,
        );
        break;

      case 3: // Leave
        _leaveTabController.index = 0;
        _payrollReportCubit.getLeaveList(
          context: context,
          pageNumber: 1,
          startDate: startDate,
          endDate: endDate,
        );
        break;

      case 4: // Outdoor
        _outdoorTabController.index = 0;
        _payrollReportCubit.getOutdoorList(
          context: context,
          pageNumber: 1,
          startDate: startDate,
          endDate: endDate,
        );
        break;

      case 5: // Resignation
        _resignationTabController.index = 0;
        _payrollReportCubit.getResignationList(
          context: context,
          pageNumber: 1,

          startDate: startDate,
          endDate: endDate,
        );
        break;

      default:
        break;
    }
  }

  // <---- ATTENDANCE PAGINATION ---->
  void _setupAttendancePagination() {
    _attendanceScrollController.addListener(() {
      final state = _payrollReportCubit.state;
      if (_attendanceScrollController.position.pixels >=
              _attendanceScrollController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          state.attendanceList.length < state.totalNumberOfRecordAttendance) {
        if (_attendanceDebounce?.isActive ?? false) {
          _attendanceDebounce?.cancel();
        }
        final startDate =
            _payrollReportCubit.state.filterStartDate ??
            _selectedDateNotifier.value;
        final endDate =
            _payrollReportCubit.state.filterEndDate ??
            _selectedDateNotifier.value;

        _attendanceDebounce = Timer(const Duration(milliseconds: 300), () {
          _payrollReportCubit.getAttendanceList(
            context,
            state.currentPageAttendance + 1,
            startDate: startDate,
            endDate: endDate,
          );
        });
      }
    });
  }

  // <---- REGULARIZATION PAGINATION ---->
  void _setupRegularizationPagination() {
    _regularizationReportController.addListener(() {
      final state = _payrollReportCubit.state;
      if (_regularizationReportController.position.pixels >=
              _regularizationReportController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          state.regularizationList.length <
              state.totalNumberOfRecordRegularization) {
        if (_regularizationReportDebounce?.isActive ?? false) {
          _regularizationReportDebounce?.cancel();
        }
        final startDate =
            _payrollReportCubit.state.filterStartDate ??
            _selectedDateNotifier.value;
        final endDate =
            _payrollReportCubit.state.filterEndDate ??
            _selectedDateNotifier.value;

        _regularizationReportDebounce = Timer(
          const Duration(milliseconds: 300),
          () {
            _payrollReportCubit.getAttendanceRegularizationList(
              context: context,
              pageNumber: state.currentPageRegularization + 1,
              startDate: startDate,
              endDate: endDate,
            );
          },
        );
      }
    });
  }

  // <---- COMPOFF PAGINATION ---->
  void _setupCompOffPagination() {
    _compOffReportController.addListener(() {
      final state = _payrollReportCubit.state;
      if (_compOffReportController.position.pixels >=
              _compOffReportController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          state.compOffList.length < state.totalNumberOfRecordCompOff) {
        if (_compOffReportDebounce?.isActive ?? false) {
          _compOffReportDebounce?.cancel();
        }
        final startDate =
            _payrollReportCubit.state.filterStartDate ??
            _selectedDateNotifier.value;
        final endDate =
            _payrollReportCubit.state.filterEndDate ??
            _selectedDateNotifier.value;
        _compOffReportDebounce = Timer(const Duration(milliseconds: 300), () {
          _payrollReportCubit.getCompOffList(
            context: context,
            pageNumber: state.currentPageCompOff + 1,
            startDate: startDate,
            endDate: endDate,
          );
        });
      }
    });
  }

  // <---- LEAVE PAGINATION ---->
  void _setupLeavePagination() {
    _leaveReportController.addListener(() {
      final state = _payrollReportCubit.state;
      if (_leaveReportController.position.pixels >=
              _leaveReportController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          state.leaveList.length < state.totalNumberOfRecordLeave) {
        if (_leaveReportDebounce?.isActive ?? false) {
          _leaveReportDebounce?.cancel();
        }
        final startDate =
            _payrollReportCubit.state.filterStartDate ??
            _selectedDateNotifier.value;
        final endDate =
            _payrollReportCubit.state.filterEndDate ??
            _selectedDateNotifier.value;
        _leaveReportDebounce = Timer(const Duration(milliseconds: 300), () {
          _payrollReportCubit.getLeaveList(
            context: context,
            pageNumber: state.currentPageLeave + 1,
            startDate: startDate,
            endDate: endDate,
          );
        });
      }
    });
  }

  // <---- OUTDOOR PAGINATION ---->
  void _setupOutdoorPagination() {
    _outdoorReportController.addListener(() {
      final state = _payrollReportCubit.state;
      if (_outdoorReportController.position.pixels >=
              _outdoorReportController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          state.outdoorList.length < state.totalNumberOfRecordOutdoor) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_outdoorReportDebounce?.isActive ?? false) {
          _outdoorReportDebounce?.cancel();
        }
        final startDate =
            _payrollReportCubit.state.filterStartDate ??
            _selectedDateNotifier.value;
        final endDate =
            _payrollReportCubit.state.filterEndDate ??
            _selectedDateNotifier.value;
        _outdoorReportDebounce = Timer(const Duration(milliseconds: 300), () {
          _payrollReportCubit.getOutdoorList(
            context: context,
            pageNumber: state.currentPageOutdoor + 1,
            startDate: startDate,
            endDate: endDate,
          );
        });
      }
    });
  }

  // <---- RESIGNATION PAGINATION ---->
  void _setupResignationPagination() {
    _resignationReportController.addListener(() {
      final state = _payrollReportCubit.state;
      if (_resignationReportController.position.pixels >=
              _resignationReportController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          state.resignationList.length < state.totalNumberOfRecordResignation) {
        if (_resignationReportDebounce?.isActive ?? false) {
          _resignationReportDebounce?.cancel();
        }
        final startDate =
            _payrollReportCubit.state.filterStartDate ??
            _selectedDateNotifier.value;
        final endDate =
            _payrollReportCubit.state.filterEndDate ??
            _selectedDateNotifier.value;
        _resignationReportDebounce = Timer(
          const Duration(milliseconds: 300),
          () {
            _payrollReportCubit.getResignationList(
              context: context,
              pageNumber: state.currentPageResignation + 1,
              startDate: startDate,
              endDate: endDate,
            );
          },
        );
      }
    });
  }

  // <---- LEAVE APPROVAL PAGINATION ---->
  void _setupLeaveApprovalPagination() {
    _leaveApprovalController.addListener(() {
      final state = _payrollReportCubit.state;
      if (_leaveApprovalController.position.pixels >=
              _leaveApprovalController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          state.approvalLeaveList.length <
              state.totalNumberOfRecordApprovalLeave) {
        if (_leaveApprovalDebounce?.isActive ?? false) {
          _leaveApprovalDebounce?.cancel();
        }
        final startDate =
            _payrollReportCubit.state.filterStartDate ??
            _selectedDateNotifier.value;
        final endDate =
            _payrollReportCubit.state.filterEndDate ??
            _selectedDateNotifier.value;
        _leaveApprovalDebounce = Timer(const Duration(milliseconds: 300), () {
          _payrollReportCubit.getLeaveList(
            context: context,
            pageNumber: state.currentPageApprovalLeave + 1,
            startDate: startDate,
            endDate: endDate,
            canApprove: true,
          );
        });
      }
    });
  }

  // <---- COMPOFF APPROVAL PAGINATION ---->
  void _setupCompOffApprovalPagination() {
    _compOffApprovalController.addListener(() {
      final state = _payrollReportCubit.state;
      if (_compOffApprovalController.position.pixels >=
              _compOffApprovalController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          state.approvalCompOffList.length <
              state.totalNumberOfRecordApprovalCompOff) {
        if (_compOffApprovalDebounce?.isActive ?? false) {
          _compOffApprovalDebounce?.cancel();
        }
        final startDate =
            _payrollReportCubit.state.filterStartDate ??
            _selectedDateNotifier.value;
        final endDate =
            _payrollReportCubit.state.filterEndDate ??
            _selectedDateNotifier.value;
        _compOffApprovalDebounce = Timer(const Duration(milliseconds: 300), () {
          _payrollReportCubit.getCompOffList(
            context: context,
            pageNumber: state.currentPageApprovalCompOff + 1,
            startDate: startDate,
            endDate: endDate,
            canApprove: true,
          );
        });
      }
    });
  }

  // <---- OUTDOOR APPROVAL PAGINATION ---->
  void _setupOutdoorApprovalPagination() {
    _outdoorApprovalController.addListener(() {
      final state = _payrollReportCubit.state;
      if (_outdoorApprovalController.position.pixels >=
              _outdoorApprovalController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          state.approvalOutdoorList.length <
              state.totalNumberOfRecordApprovalOutdoor) {
        if (_outdoorApprovalDebounce?.isActive ?? false) {
          _outdoorApprovalDebounce?.cancel();
        }
        final startDate =
            _payrollReportCubit.state.filterStartDate ??
            _selectedDateNotifier.value;
        final endDate =
            _payrollReportCubit.state.filterEndDate ??
            _selectedDateNotifier.value;
        _outdoorApprovalDebounce = Timer(const Duration(milliseconds: 300), () {
          _payrollReportCubit.getOutdoorList(
            context: context,
            pageNumber: state.currentPageApprovalOutdoor + 1,
            startDate: startDate,
            endDate: endDate,
            canApprove: true,
          );
        });
      }
    });
  }

  // <---- RESIGNATION APPROVAL PAGINATION ---->
  void _setupResignationApprovalPagination() {
    _resignationApprovalController.addListener(() {
      final state = _payrollReportCubit.state;
      if (_resignationApprovalController.position.pixels >=
              _resignationApprovalController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          state.approvalResignationList.length <
              state.totalNumberOfRecordApprovalResignation) {
        if (_resignationApprovalDebounce?.isActive ?? false) {
          _resignationApprovalDebounce?.cancel();
        }
        final startDate =
            _payrollReportCubit.state.filterStartDate ??
            _selectedDateNotifier.value;
        final endDate =
            _payrollReportCubit.state.filterEndDate ??
            _selectedDateNotifier.value;
        _resignationApprovalDebounce = Timer(
          const Duration(milliseconds: 300),
          () {
            _payrollReportCubit.getResignationList(
              context: context,
              pageNumber: state.currentPageApprovalResignation + 1,
              startDate: startDate,
              endDate: endDate,
              canApprove: true,
            );
          },
        );
      }
    });
  }

  // <---- REGULARIZATION APPROVAL PAGINATION ---->
  void _setupRegularizationApprovalPagination() {
    _regularizationApprovalController.addListener(() {
      final state = _payrollReportCubit.state;
      if (_regularizationApprovalController.position.pixels >=
              _regularizationApprovalController.position.maxScrollExtent -
                  100 &&
          !(state.isLoading ?? false) &&
          state.approvalRegularizationList.length <
              state.totalNumberOfRecordApprovalRegularization) {
        if (_regularizationApprovalDebounce?.isActive ?? false) {
          _regularizationApprovalDebounce?.cancel();
        }
        final startDate =
            _payrollReportCubit.state.filterStartDate ??
            _selectedDateNotifier.value;
        final endDate =
            _payrollReportCubit.state.filterEndDate ??
            _selectedDateNotifier.value;
        _regularizationApprovalDebounce = Timer(
          const Duration(milliseconds: 300),
          () {
            _payrollReportCubit.getAttendanceRegularizationList(
              context: context,
              pageNumber: state.currentPageApprovalRegularization + 1,
              startDate: startDate,
              endDate: endDate,
              canApprove: true,
            );
          },
        );
      }
    });
  }

  void _prefillFilterFromState() {
    final s = _payrollReportCubit.state;
    _startDateNotifier.value = s.filterStartDate;
    _endDateNotifier.value = s.filterEndDate;
  }

  // PAYROLL REPORT FILTER
  Future<void> _showBottomSheetToFilterPayrollReport(
    BuildContext context,
  ) async {
    _prefillFilterFromState();
    final state = _payrollReportCubit.state;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(
      state.filterStartDate != null || state.filterEndDate != null,
    );
    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter Payroll Master",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpacing(),
              Row(
                children: [
                  Expanded(
                    child: ValueListenableBuilder<DateTime?>(
                      valueListenable: _startDateNotifier,
                      builder: (context, startDate, child) {
                        return CustomDatePicker(
                          title: "Start Date",
                          initialDate: startDate,
                          setValue: (value) {
                            _startDateNotifier.value = value;
                            applyEnabled.value = true;
                          },
                          validator: (value) => null,
                        );
                      },
                    ),
                  ),
                  horizontalSpacing(),
                  Expanded(
                    child: ValueListenableBuilder<DateTime?>(
                      valueListenable: _endDateNotifier,
                      builder: (context, endDate, child) {
                        return ValueListenableBuilder<DateTime?>(
                          valueListenable: _startDateNotifier,
                          builder: (context, startDate, child) {
                            return CustomDatePicker(
                              title: "End Date",
                              isRequired: false,
                              initialDate: endDate,
                              setValue: (value) {
                                _endDateNotifier.value = value;
                                applyEnabled.value = true;
                              },
                              validator: (value) {
                                if (value == null) return null;
                                if (startDate != null) {
                                  final startDateOnly = DateTime(
                                    startDate.year,
                                    startDate.month,
                                    startDate.day,
                                  );
                                  final endDateOnly = DateTime(
                                    value.year,
                                    value.month,
                                    value.day,
                                  );
                                  if (endDateOnly.isBefore(startDateOnly)) {
                                    return 'End Date cannot be before Start Date';
                                  }
                                }
                                return null;
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      onClear: () {
        _startDateNotifier.value = null;
        _endDateNotifier.value = null;
        _payrollReportCubit.clearFilterOnPayrollReport(context);
      },
      onApply: () {
        final startDate = _startDateNotifier.value;
        final endDate = _endDateNotifier.value;
        if (startDate != null && endDate != null) {
          final startOnly = DateTime(
            startDate.year,
            startDate.month,
            startDate.day,
          );
          final endOnly = DateTime(endDate.year, endDate.month, endDate.day);
          if (endOnly.isBefore(startOnly)) {
            showErrorMessage(
              context,
              "Invalid dates",
              "End Date cannot be before Start Date",
            );
            return;
          }
        }
        _payrollReportCubit.applyFilterOnPayrollReport(
          context: context,
          startDate: startDate,
          endDate: endDate,
        );
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.greyBackground,
      appBar: CustomAppBar(
        screenTitle: "Report",
        authorization: AuthorizationModel(),
        onSearchSubmit: (value) {
          _payrollReportCubit.searchPayrollReport(context, value);
        },
        textController: _searchC,
        isFilterOn: true,
        onFilterTap: () {
          _showBottomSheetToFilterPayrollReport(context);
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChipStyleTabBar(
            controller: _tabController,
            tabs: [
              "Attendance",
              "Regularize",
              "Comp-Off",
              "Leave",
              "Outdoor",
              "Resignation",
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: BlocBuilder<PayrollReportCubit, PayrollReportState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: _onBackArrowClicked,
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 18,
                          color: AppColor.black.withValues(alpha: .5),
                        ),
                      ),
                      horizontalSpacing(width: 20),

                      ValueListenableBuilder<DateTime>(
                        valueListenable: _selectedDateNotifier,
                        builder: (context, date, _) {
                          final startDate = state.filterStartDate;
                          final endDate = state.filterEndDate;

                          if (startDate != null && endDate != null) {
                            return Text(
                              "${formatDateTimeAsDDMMMYYYY(startDate)} - "
                              "${formatDateTimeAsDDMMMYYYY(endDate)}",
                              style: AppTextStyle.ts14M(),
                            );
                          }

                          if (startDate != null && endDate == null) {
                            return Text(
                              formatDateTimeAsDDMMMYYYY(startDate),
                              style: AppTextStyle.ts14M(),
                            );
                          }

                          return Text(
                            formatDateTimeAsDDMMMYYYY(date),
                            style: AppTextStyle.ts14M(),
                          );
                        },
                      ),

                      horizontalSpacing(width: 20),

                      InkWell(
                        onTap: _onForwardArrowClicked,
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: AppColor.black.withValues(alpha: .5),
                        ),
                      ),

                      Spacer(),
                    ],
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                buildAttendanceSection(),
                buildRegularizeSection(),
                buildCompOffSection(),
                buildLeaveSection(),
                buildOutdoorSection(),
                buildResignationSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BUILD ATTENDANCE SECTION
  Widget buildAttendanceSection() {
    return BlocBuilder<PayrollReportCubit, PayrollReportState>(
      builder: (context, state) {
        final isLoading = state.isLoading ?? true;

        if (isLoading && state.attendanceList.isEmpty) {
          return Center(child: loader());
        }

        if (state.attendanceList.isEmpty) {
          return Center(child: noDataWidget(message: "No Attendance Found"));
        }

        final Map<String, List<AttendanceModel>> groupedData = {};

        for (final item in state.attendanceList) {
          final key = item.fullName;
          if (!groupedData.containsKey(key)) {
            groupedData[key] = [];
          }
          groupedData[key]!.add(item);
        }

        final employees = groupedData.keys.toList();

        return ListView.builder(
          controller: _attendanceScrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: employees.length + 1,
          itemBuilder: (context, index) {
            /// Pagination loader
            if (index == employees.length) {
              return state.attendanceList.length <
                      state.totalNumberOfRecordAttendance
                  ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : const SizedBox.shrink();
            }

            final employeeName = employees[index];
            final employeeRecords = groupedData[employeeName]!;

            employeeRecords.sort(
              (a, b) => b.attendanceDate.compareTo(a.attendanceDate),
            );

            return _buildEmployeeExpansionTile(
              employeeName: employeeName,
              records: employeeRecords,
              state: state,
            );
          },
        );
      },
    );
  }

  Widget _buildEmployeeExpansionTile({
    required String employeeName,
    required List<AttendanceModel> records,
    required PayrollReportState state,
  }) {
    final bool isFilterApplied =
        state.filterStartDate != null || state.filterEndDate != null;

    AttendanceModel? todayRecord;
    if (!isFilterApplied) {
      final today = DateTime.now();
      try {
        todayRecord = records.firstWhere(
          (e) =>
              e.attendanceDate.year == today.year &&
              e.attendanceDate.month == today.month &&
              e.attendanceDate.day == today.day,
        );
      } catch (_) {
        todayRecord = records.first;
      }
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: commonCardDecoration(),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 6.0),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        iconColor: AppColor.black.withValues(alpha: 0.50),
        collapsedIconColor: AppColor.black.withValues(alpha: 0.50),
        shape: const Border(),
        collapsedShape: const Border(),
        title: _buildEmployeeHeader(
          employeeName: employeeName,
          record: todayRecord ?? records.first,
          isFilterApplied: isFilterApplied,
        ),
        children: [
          ..._buildEmployeeAttendanceList(
            isFilterApplied
                ? records
                : (todayRecord != null ? [todayRecord] : []),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeHeader({
    required String employeeName,
    required AttendanceModel record,
    required bool isFilterApplied,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Row(
            children: [
              CircleAvatar(radius: 18, child: Text(employeeName[0])),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employeeName,
                      style: AppTextStyle.ts16M(color: AppColor.primary),
                    ),
                    Text(
                      "Software Developer",
                      style: AppTextStyle.ts10R(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildEmployeeAttendanceList(List<AttendanceModel> list) {
    return list.map((attendance) {
      final bool hasLocation =
          attendance.startLatitude != 0 &&
          attendance.startLongitude != 0 &&
          attendance.endLatitude != 0 &&
          attendance.endLongitude != 0;

      return Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    formatDateTimeAsDDMMMYYYY(attendance.attendanceDate),
                    style: AppTextStyle.ts14M().copyWith(color: AppColor.black),
                  ),
                ),
                _statusChip(attendance.attendanceStatus),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _infoItem(
                    "Punch In Time",
                    attendance.punchIn != null
                        ? DateFormat('hh:mm a').format(attendance.punchIn!)
                        : "-",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _infoItem(
                    "Punch Out Time",
                    attendance.punchOut != null
                        ? DateFormat('hh:mm a').format(attendance.punchOut!)
                        : "-",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _infoItem(
                    "Punch In Address",
                    attendance.punchInAddress.isEmpty
                        ? "-"
                        : attendance.punchInAddress,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _infoItem(
                    "Punch Out Address",
                    attendance.punchOutAddress.isEmpty
                        ? "-"
                        : attendance.punchOutAddress,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _infoItem(
                    "Working Hours",
                    attendance.workingHours.isEmpty
                        ? "-"
                        : attendance.workingHours,
                  ),
                ),
                if (hasLocation) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        log("📍 POLYLINE: ${attendance.polyline}");
                        log("📍 DISTANCE: ${attendance.distance}");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => MapScreen(
                                  startLatitude: attendance.startLatitude,
                                  startLongitude: attendance.startLongitude,
                                  endLatitude: attendance.endLatitude,
                                  endLongitude: attendance.endLongitude,
                                  polyline: attendance.polyline,
                                  distance: attendance.distance.toDouble(),
                                  attendanceDataModel: attendance,
                                ),
                          ),
                        );
                      },
                      child: Text(
                        "View Location",
                        style: AppTextStyle.ts12M().copyWith(
                          color: AppColor.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColor.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Divider(color: AppColor.grey, thickness: 0.50),
            verticalSpacing(),
          ],
        ),
      );
    }).toList();
  }

  Widget _infoItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.ts12R(
            color: AppColor.grey.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyle.ts12M().copyWith(color: AppColor.black),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _statusChip(String status) {
    final normalized = status.toLowerCase().trim();

    Color bg;
    Color text;
    Color border;

    switch (normalized) {
      case "late in":
        text = const Color(0xFFE65100);
        bg = text.withValues(alpha: 0.12);
        border = text;
        break;

      case "early leave":
        text = const Color(0xFFF0B357);
        bg = text.withValues(alpha: 0.15);
        border = text;
        break;

      case "present":
        text = const Color(0xFF1B9E4B);
        bg = text.withValues(alpha: 0.12);
        border = text;
        break;

      case "absent":
        text = const Color(0xFFFF2D2D);
        bg = text.withValues(alpha: 0.12);
        border = text;
        break;

      case "halfday":
      case "half day":
        text = const Color(0xFF1389A5);
        bg = text.withValues(alpha: 0.12);
        border = text;
        break;

      case "checkout missing":
        text = const Color(0xFF8E3B52);
        bg = text.withValues(alpha: 0.12);
        border = text;
        break;

      case "week-off":
      case "week off":
      case "weekoff":
        text = const Color(0xFF3F5067);
        bg = text.withValues(alpha: 0.12);
        border = text;
        break;

      case "comp-off":
      case "comp off":
        text = const Color(0xFF4B5BD3);
        bg = text.withValues(alpha: 0.12);
        border = text;
        break;

      case "leave":
        text = const Color(0xFFD81B60);
        bg = text.withValues(alpha: 0.12);
        border = text;
        break;

      case "holiday":
        text = const Color(0xFF7B1FA2);
        bg = text.withValues(alpha: 0.12);
        border = text;
        break;

      default:
        text = AppColor.primary;
        bg = AppColor.lightBlue;
        border = AppColor.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Text(
        status.isEmpty ? "Pending" : status,
        style: AppTextStyle.ts12SB(color: text),
      ),
    );
  }

  // BUILD REGULARIZE SECTION
  Widget buildRegularizeSection() {
    return BlocBuilder<PayrollReportCubit, PayrollReportState>(
      builder: (context, state) {
        return Column(
          children: [
            // APPROVE/REJECT WIDGET ON APPROVAL TAB
            // INNER TAB BAR
            ChipStyleTabBar(
              controller: _regularizationTabController,
              isSecondaryStyle: true,
              tabs: ['Report', 'Approval'],
            ),

            // TABBAR VIEW
            Expanded(
              child: TabBarView(
                controller: _regularizationTabController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  // REPORT TAB
                  Builder(
                    builder: (context) {
                      final isLoading = state.isLoading ?? true;

                      if (isLoading && state.regularizationList.isEmpty) {
                        return Center(child: loader());
                      }

                      if (state.regularizationList.isEmpty) {
                        return Center(
                          child: noDataWidget(
                            message: 'No Regularize Report Available',
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _regularizationReportController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        itemCount: state.regularizationList.length + 1,
                        itemBuilder: (context, index) {
                          if (index == state.regularizationList.length) {
                            return state.regularizationList.length <
                                    state.totalNumberOfRecordRegularization
                                ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                                : const SizedBox.shrink();
                          }

                          final reg = state.regularizationList[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: commonCardDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      reg.createdBy,
                                      style: AppTextStyle.ts16M(),
                                    ),
                                    CustomButton(
                                      onPressed: () async {
                                        final approvalList =
                                            await _payrollReportCubit
                                                .getApprovalStatus(
                                                  requestId:
                                                      reg.createdById
                                                          .toString(),
                                                  id:
                                                      reg.attendanceRegularizationId,
                                                  moduleName:
                                                      _payrollReportCubit
                                                          .getModuleName(),
                                                );

                                        final mappedList =
                                            approvalList
                                                .toApprovalLogHistoryList();

                                        if (context.mounted) {
                                          goRouter.pushNamed(
                                            AppRoutes.approvalLogHistory,
                                            queryParameters: {
                                              "subTitle": Uri.encodeComponent(
                                                EncryptionManager.encryptData(
                                                  "${reg.createdBy} > ${formatDateTimeAsDDMMMYYYY(reg.attendanceDate)}",
                                                ),
                                              ),
                                              "title": Uri.encodeComponent(
                                                EncryptionManager.encryptData(
                                                  "Regularize Approval History",
                                                ),
                                              ),
                                              "approvalList": Uri.encodeComponent(
                                                EncryptionManager.encryptData(
                                                  jsonEncode(
                                                    mappedList
                                                        .map((e) => e.toJson())
                                                        .toList(),
                                                  ),
                                                ),
                                              ),
                                            },
                                          );
                                        }
                                      },
                                      leading: Icon(
                                        Icons.watch_later_outlined,
                                        size: 16,
                                        color: AppColor.white,
                                      ),
                                      text: "History",
                                    ),
                                  ],
                                ),
                                verticalSpacing(height: 10),
                                buildRowTitleValue(
                                  title: "Punch In",
                                  value:
                                      reg.punchIn != null
                                          ? DateFormat(
                                            'hh:mm a',
                                          ).format(reg.punchIn!)
                                          : "-",
                                ),
                                buildRowTitleValue(
                                  title: "Punch Out",
                                  value:
                                      reg.punchOut != null
                                          ? DateFormat(
                                            'hh:mm a',
                                          ).format(reg.punchOut!)
                                          : "-",
                                ),
                                buildRowTitleValue(
                                  title: "Date",
                                  value: formatDateTimeAsDDMMMYYYY(
                                    reg.attendanceDate,
                                  ),
                                ),
                                buildRowTitleValue(
                                  title: "Reason",
                                  value: reg.reason,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),

                  // APPROVAL TAB
                  Builder(
                    builder: (context) {
                      final isLoading = state.isLoading ?? true;

                      if (isLoading &&
                          state.approvalRegularizationList.isEmpty) {
                        return Center(child: loader());
                      }

                      if (state.approvalRegularizationList.isEmpty) {
                        return Center(
                          child: noDataWidget(
                            message: "No Regularize Approval Report Available",
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _regularizationReportController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        itemCount: state.approvalRegularizationList.length + 1,
                        itemBuilder: (context, index) {
                          if (index ==
                              state.approvalRegularizationList.length) {
                            return state.approvalRegularizationList.length <
                                    state
                                        .totalNumberOfRecordApprovalRegularization
                                ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                                : const SizedBox.shrink();
                          }

                          final reg = state.approvalRegularizationList[index];

                          return Column(
                            children: [
                              if (state.regularizationInnerTabIndex == 1 &&
                                  index == 0) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: ApproveRejectWidget(
                                    actionTitle: "Pending",
                                    isActionAlreadyPerformed: false,
                                    popupTitle: "Confirm Approval",
                                    subTitle:
                                        "You are about to approve ${state.selectedRegularizationIds.length} records(s).",
                                    isMaster: true,
                                    canOpenDialog: () {
                                      if (state
                                          .selectedRegularizationIds
                                          .isEmpty) {
                                        showErrorMessage(
                                          context,
                                          "Error",
                                          "Please select at least one record or use Select All",
                                        );
                                        return false;
                                      }
                                      return true;
                                    },

                                    onApprove: (val) async {
                                      final isSuccess =
                                          await _payrollReportCubit
                                              .approveRejectSelected(
                                                context: context,
                                                isApproved: true,
                                                remark: val.trim(),
                                                projectId: _project.projectId,
                                              );
                                      if (context.mounted && isSuccess) {
                                        final startDate =
                                            _payrollReportCubit
                                                .state
                                                .filterStartDate ??
                                            _selectedDateNotifier.value;
                                        final endDate =
                                            _payrollReportCubit
                                                .state
                                                .filterEndDate ??
                                            _selectedDateNotifier.value;

                                        _payrollReportCubit.getResignationList(
                                          context: context,
                                          pageNumber: 1,
                                          startDate: startDate,
                                          endDate: endDate,
                                          canApprove:
                                              _regularizationTabController
                                                  .index ==
                                              1,
                                        );
                                      }
                                    },
                                    onReject: (val) async {
                                      final isSuccess =
                                          await _payrollReportCubit
                                              .approveRejectSelected(
                                                context: context,
                                                isApproved: false,
                                                remark: val.trim(),
                                                projectId: _project.projectId,
                                              );
                                      if (context.mounted && isSuccess) {
                                        final startDate =
                                            _payrollReportCubit
                                                .state
                                                .filterStartDate ??
                                            _selectedDateNotifier.value;
                                        final endDate =
                                            _payrollReportCubit
                                                .state
                                                .filterEndDate ??
                                            _selectedDateNotifier.value;

                                        _payrollReportCubit.getResignationList(
                                          context: context,
                                          pageNumber: 1,
                                          startDate: startDate,
                                          endDate: endDate,
                                          canApprove:
                                              _regularizationTabController
                                                  .index ==
                                              1,
                                        );
                                      }
                                    },
                                    customWidget: _selectAllWidget(),
                                  ),
                                ),
                                verticalSpacing(),
                              ],

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: state.selectedRegularizationIds
                                        .contains(
                                          reg.attendanceRegularizationId,
                                        ),
                                    onChanged: (_) {
                                      _payrollReportCubit.toggleSelection(
                                        id: reg.attendanceRegularizationId,
                                        listLength:
                                            state
                                                .approvalRegularizationList
                                                .length,
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 8),

                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: commonCardDecoration(),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                reg.createdBy,
                                                style: AppTextStyle.ts16M(),
                                              ),
                                              CustomButton(
                                                onPressed: () async {
                                                  final approvalList =
                                                      await _payrollReportCubit
                                                          .getApprovalStatus(
                                                            requestId:
                                                                reg.createdById
                                                                    .toString(),
                                                            id:
                                                                reg.attendanceRegularizationId,
                                                            moduleName:
                                                                _payrollReportCubit
                                                                    .getModuleName(),
                                                          );

                                                  final mappedList =
                                                      approvalList
                                                          .toApprovalLogHistoryList();

                                                  if (context.mounted) {
                                                    goRouter.pushNamed(
                                                      AppRoutes
                                                          .approvalLogHistory,
                                                      queryParameters: {
                                                        "subTitle": Uri.encodeComponent(
                                                          EncryptionManager.encryptData(
                                                            "${reg.createdBy} > ${formatDateTimeAsDDMMMYYYY(reg.attendanceDate)}",
                                                          ),
                                                        ),
                                                        "title": Uri.encodeComponent(
                                                          EncryptionManager.encryptData(
                                                            "Regularize Approval History",
                                                          ),
                                                        ),
                                                        "approvalList":
                                                            Uri.encodeComponent(
                                                              EncryptionManager.encryptData(
                                                                jsonEncode(
                                                                  mappedList
                                                                      .map(
                                                                        (e) =>
                                                                            e.toJson(),
                                                                      )
                                                                      .toList(),
                                                                ),
                                                              ),
                                                            ),
                                                      },
                                                    );
                                                  }
                                                },
                                                leading: Icon(
                                                  Icons.watch_later_outlined,
                                                  size: 16,
                                                  color: AppColor.white,
                                                ),
                                                text: "History",
                                              ),
                                            ],
                                          ),

                                          verticalSpacing(height: 10),
                                          buildRowTitleValue(
                                            title: "Punch In",
                                            value:
                                                reg.punchIn != null
                                                    ? DateFormat(
                                                      'hh:mm a',
                                                    ).format(reg.punchIn!)
                                                    : "-",
                                          ),
                                          buildRowTitleValue(
                                            title: "Punch Out",
                                            value:
                                                reg.punchOut != null
                                                    ? DateFormat(
                                                      'hh:mm a',
                                                    ).format(reg.punchOut!)
                                                    : "-",
                                          ),
                                          buildRowTitleValue(
                                            title: "Date",
                                            value: formatDateTimeAsDDMMMYYYY(
                                              reg.attendanceDate,
                                            ),
                                          ),
                                          buildRowTitleValue(
                                            title: "Reason",
                                            value: reg.reason,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // BUILD COMP-OFF SECTION
  Widget buildCompOffSection() {
    return BlocBuilder<PayrollReportCubit, PayrollReportState>(
      builder: (context, state) {
        return Column(
          children: [
            ChipStyleTabBar(
              controller: _compOffTabController,
              isSecondaryStyle: true,
              tabs: ['Report', 'Approval'],
            ),
            Expanded(
              child: TabBarView(
                controller: _compOffTabController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  // REPORT
                  Builder(
                    builder: (context) {
                      final isLoading = state.isLoading ?? true;

                      if (isLoading) {
                        return Center(child: loader());
                      }

                      if (state.compOffList.isEmpty) {
                        return Center(
                          child: noDataWidget(
                            message: 'No Comp-Off Report Available',
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _compOffReportController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        itemCount: state.compOffList.length + 1,
                        itemBuilder: (context, index) {
                          if (index == state.compOffList.length) {
                            return state.compOffList.length <
                                    state.totalNumberOfRecordCompOff
                                ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                                : const SizedBox.shrink();
                          }

                          final compOff = state.compOffList[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: commonCardDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      compOff.createdBy,
                                      style: AppTextStyle.ts16M(),
                                    ),
                                    CustomButton(
                                      onPressed: () async {
                                        final approvalList =
                                            await _payrollReportCubit
                                                .getApprovalStatus(
                                                  requestId:
                                                      compOff.createdById
                                                          .toString(),
                                                  id: compOff.compOffId,
                                                  moduleName:
                                                      _payrollReportCubit
                                                          .getModuleName(),
                                                );

                                        final mappedList =
                                            approvalList
                                                .toApprovalLogHistoryList();

                                        if (context.mounted) {
                                          goRouter.pushNamed(
                                            AppRoutes.approvalLogHistory,
                                            queryParameters: {
                                              "subTitle": Uri.encodeComponent(
                                                EncryptionManager.encryptData(
                                                  "${compOff.createdBy} > ${formatDateTimeAsDDMMMYYYY(compOff.compOffDate)}",
                                                ),
                                              ),
                                              "title": Uri.encodeComponent(
                                                EncryptionManager.encryptData(
                                                  "CompOff Approval History",
                                                ),
                                              ),
                                              "approvalList": Uri.encodeComponent(
                                                EncryptionManager.encryptData(
                                                  jsonEncode(
                                                    mappedList
                                                        .map((e) => e.toJson())
                                                        .toList(),
                                                  ),
                                                ),
                                              ),
                                            },
                                          );
                                        }
                                      },
                                      leading: Icon(
                                        Icons.watch_later_outlined,
                                        size: 16,
                                        color: AppColor.white,
                                      ),
                                      text: "History",
                                    ),
                                  ],
                                ),
                                verticalSpacing(height: 10),
                                buildRowTitleValue(
                                  title: "CompOff Date",
                                  value: formatDateTimeAsDDMMMYYYY(
                                    compOff.compOffDate,
                                  ),
                                ),
                                buildRowTitleValue(
                                  title: "Working Date",
                                  value: formatDateTimeAsDDMMMYYYY(
                                    compOff.workingDate,
                                  ),
                                ),
                                buildRowTitleValue(
                                  title: "Reason",
                                  value: compOff.reason,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),

                  // APPROVAL
                  Builder(
                    builder: (context) {
                      final isLoading = state.isLoading ?? true;

                      if (isLoading) {
                        return Center(child: loader());
                      }

                      if (state.approvalCompOffList.isEmpty) {
                        return Center(
                          child: noDataWidget(
                            message: 'No Comp-Off Approval Report Available',
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _compOffReportController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        itemCount: state.approvalCompOffList.length + 1,
                        itemBuilder: (context, index) {
                          if (index == state.approvalCompOffList.length) {
                            return state.approvalCompOffList.length <
                                    state.totalNumberOfRecordApprovalCompOff
                                ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                                : const SizedBox.shrink();
                          }

                          final compOff = state.approvalCompOffList[index];

                          return Column(
                            children: [
                              if (state.compOffInnerTabIndex == 1 &&
                                  index == 0) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: ApproveRejectWidget(
                                    actionTitle: "Pending",
                                    isActionAlreadyPerformed: false,
                                    popupTitle: "Confirm Approval",
                                    subTitle:
                                        "You are about to approve ${state.selectedCompOffIds.length} records(s).",
                                    isMaster: true,
                                    canOpenDialog: () {
                                      if (state.selectedCompOffIds.isEmpty) {
                                        showErrorMessage(
                                          context,
                                          "Error",
                                          "Please select at least one record or use Select All",
                                        );
                                        return false;
                                      }
                                      return true;
                                    },
                                    onApprove: (val) async {
                                      final isSuccess =
                                          await _payrollReportCubit
                                              .approveRejectSelected(
                                                context: context,
                                                isApproved: true,
                                                remark: val.trim(),
                                                projectId: _project.projectId,
                                              );
                                      if (context.mounted && isSuccess) {
                                        final startDate =
                                            _payrollReportCubit
                                                .state
                                                .filterStartDate ??
                                            _selectedDateNotifier.value;
                                        final endDate =
                                            _payrollReportCubit
                                                .state
                                                .filterEndDate ??
                                            _selectedDateNotifier.value;
                                        _payrollReportCubit.getCompOffList(
                                          context: context,
                                          pageNumber: 1,
                                          startDate: startDate,
                                          endDate: endDate,
                                          canApprove:
                                              _compOffTabController.index == 1,
                                        );
                                      }
                                    },
                                    onReject: (val) async {
                                      final isSuccess =
                                          await _payrollReportCubit
                                              .approveRejectSelected(
                                                context: context,
                                                isApproved: false,
                                                remark: val.trim(),
                                                projectId: _project.projectId,
                                              );
                                      if (context.mounted && isSuccess) {
                                        final startDate =
                                            _payrollReportCubit
                                                .state
                                                .filterStartDate ??
                                            _selectedDateNotifier.value;
                                        final endDate =
                                            _payrollReportCubit
                                                .state
                                                .filterEndDate ??
                                            _selectedDateNotifier.value;

                                        _payrollReportCubit.getCompOffList(
                                          context: context,
                                          pageNumber: 1,
                                          startDate: startDate,
                                          endDate: endDate,
                                          canApprove:
                                              _compOffTabController.index == 1,
                                        );
                                      }
                                    },
                                    customWidget: _selectAllWidget(),
                                  ),
                                ),
                                verticalSpacing(),
                              ],

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: state.selectedCompOffIds.contains(
                                      compOff.compOffId,
                                    ),
                                    onChanged: (_) {
                                      _payrollReportCubit.toggleSelection(
                                        id: compOff.compOffId,
                                        listLength:
                                            state.approvalCompOffList.length,
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 8),

                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: commonCardDecoration(),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                compOff.createdBy,
                                                style: AppTextStyle.ts16M(),
                                              ),
                                              CustomButton(
                                                onPressed: () async {
                                                  final approvalList =
                                                      await _payrollReportCubit
                                                          .getApprovalStatus(
                                                            requestId:
                                                                compOff
                                                                    .createdById
                                                                    .toString(),
                                                            id:
                                                                compOff
                                                                    .compOffId,
                                                            moduleName:
                                                                _payrollReportCubit
                                                                    .getModuleName(),
                                                          );

                                                  final mappedList =
                                                      approvalList
                                                          .toApprovalLogHistoryList();

                                                  if (context.mounted) {
                                                    goRouter.pushNamed(
                                                      AppRoutes
                                                          .approvalLogHistory,
                                                      queryParameters: {
                                                        "subTitle": Uri.encodeComponent(
                                                          EncryptionManager.encryptData(
                                                            "${compOff.createdBy} > ${formatDateTimeAsDDMMMYYYY(compOff.compOffDate)}",
                                                          ),
                                                        ),
                                                        "title": Uri.encodeComponent(
                                                          EncryptionManager.encryptData(
                                                            "CompOff Approval History",
                                                          ),
                                                        ),
                                                        "approvalList":
                                                            Uri.encodeComponent(
                                                              EncryptionManager.encryptData(
                                                                jsonEncode(
                                                                  mappedList
                                                                      .map(
                                                                        (e) =>
                                                                            e.toJson(),
                                                                      )
                                                                      .toList(),
                                                                ),
                                                              ),
                                                            ),
                                                      },
                                                    );
                                                  }
                                                },
                                                leading: Icon(
                                                  Icons.watch_later_outlined,
                                                  size: 16,
                                                  color: AppColor.white,
                                                ),
                                                text: "History",
                                              ),
                                            ],
                                          ),

                                          verticalSpacing(height: 10),
                                          buildRowTitleValue(
                                            title: "CompOff Date",
                                            value: formatDateTimeAsDDMMMYYYY(
                                              compOff.compOffDate,
                                            ),
                                          ),
                                          buildRowTitleValue(
                                            title: "Working Date",
                                            value: formatDateTimeAsDDMMMYYYY(
                                              compOff.workingDate,
                                            ),
                                          ),
                                          buildRowTitleValue(
                                            title: "Reason",
                                            value: compOff.reason,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // BUILD LEAVE SECTION
  Widget buildLeaveSection() {
    return BlocBuilder<PayrollReportCubit, PayrollReportState>(
      builder: (context, state) {
        return Column(
          children: [
            ChipStyleTabBar(
              controller: _leaveTabController,
              isSecondaryStyle: true,
              tabs: ['Report', 'Approval'],
            ),
            Expanded(
              child: TabBarView(
                controller: _leaveTabController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  //REPORT
                  Builder(
                    builder: (context) {
                      final isLoading = state.isLoading ?? true;

                      if (isLoading) {
                        return Center(child: loader());
                      }

                      if (state.leaveList.isEmpty) {
                        return Center(
                          child: noDataWidget(
                            message: "No Leave Report Available",
                          ),
                        );
                      }
                      return ListView.builder(
                        controller: _leaveReportController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        itemCount: state.leaveList.length + 1,
                        itemBuilder: (context, index) {
                          if (index == state.leaveList.length) {
                            return state.leaveList.length <
                                    state.totalNumberOfRecordLeave
                                ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                                : const SizedBox.shrink();
                          }

                          final leave = state.leaveList[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: commonCardDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      leave.createdBy,
                                      style: AppTextStyle.ts16M(),
                                    ),
                                    CustomButton(
                                      onPressed: () async {
                                        final approvalList =
                                            await _payrollReportCubit
                                                .getApprovalStatus(
                                                  requestId:
                                                      leave.createdById
                                                          .toString(),
                                                  id: leave.leaveId,
                                                  moduleName:
                                                      _payrollReportCubit
                                                          .getModuleName(),
                                                );

                                        final mappedList =
                                            approvalList
                                                .toApprovalLogHistoryList();

                                        if (context.mounted) {
                                          goRouter.pushNamed(
                                            AppRoutes.approvalLogHistory,
                                            queryParameters: {
                                              "subTitle": Uri.encodeComponent(
                                                EncryptionManager.encryptData(
                                                  "${leave.createdBy} > ${leave.leaveType}",
                                                ),
                                              ),
                                              "title": Uri.encodeComponent(
                                                EncryptionManager.encryptData(
                                                  "Leave Approval History",
                                                ),
                                              ),
                                              "approvalList": Uri.encodeComponent(
                                                EncryptionManager.encryptData(
                                                  jsonEncode(
                                                    mappedList
                                                        .map((e) => e.toJson())
                                                        .toList(),
                                                  ),
                                                ),
                                              ),
                                            },
                                          );
                                        }
                                      },
                                      leading: Icon(
                                        Icons.watch_later_outlined,
                                        size: 16,
                                        color: AppColor.white,
                                      ),
                                      text: "History",
                                    ),
                                  ],
                                ),

                                verticalSpacing(height: 10),
                                buildRowTitleValue(
                                  title: "Leave Type",
                                  value: leave.leaveType,
                                ),
                                buildRowTitleValue(
                                  title: "Start Date",
                                  value: formatDateTimeAsDDMMMYYYY(
                                    leave.startDate,
                                  ),
                                ),
                                buildRowTitleValue(
                                  title: "End Date",
                                  value: formatDateTimeAsDDMMMYYYY(
                                    leave.endDate,
                                  ),
                                ),
                                buildRowTitleValue(
                                  title: "No Of Days",
                                  value: leave.noOfDays.toString(),
                                ),
                                buildRowTitleValue(
                                  title: "Reason",
                                  value: leave.reason,
                                ),
                                buildRowTitleValue(
                                  title: "Leave Status",
                                  value: leave.leaveStatus,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // APPROVAL
                  Builder(
                    builder: (context) {
                      final isLoading = state.isLoading ?? true;

                      if (isLoading) {
                        return Center(child: loader());
                      }

                      if (state.approvalLeaveList.isEmpty) {
                        return Center(
                          child: noDataWidget(
                            message: "No Leave Approval Report Available",
                          ),
                        );
                      }
                      return ListView.builder(
                        controller: _leaveReportController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        itemCount: state.approvalLeaveList.length + 1,
                        itemBuilder: (context, index) {
                          if (index == state.approvalLeaveList.length) {
                            return state.approvalLeaveList.length <
                                    state.totalNumberOfRecordApprovalLeave
                                ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                                : const SizedBox.shrink();
                          }

                          final leave = state.approvalLeaveList[index];
                          final selectedIds = state.selectedLeaveIds;
                          return Column(
                            children: [
                              if (state.leaveInnerTabIndex == 1 &&
                                  index == 0) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: ApproveRejectWidget(
                                    actionTitle: "Pending",
                                    isActionAlreadyPerformed: false,
                                    isMaster: true,
                                    popupTitle: "Confirm Approval",
                                    subTitle:
                                        "You are about to approve ${selectedIds.length} records(s).",
                                    canOpenDialog: () {
                                      if (selectedIds.isEmpty) {
                                        showErrorMessage(
                                          context,
                                          "Error",
                                          "Please select at least one record or use Select All",
                                        );
                                        return false;
                                      }
                                      return true;
                                    },

                                    onApprove: (val) async {
                                      final isSuccess =
                                          await _payrollReportCubit
                                              .approveRejectSelected(
                                                context: context,
                                                isApproved: true,
                                                remark: val.trim(),
                                                projectId: _project.projectId,
                                              );
                                      if (context.mounted && isSuccess) {
                                        final startDate =
                                            _payrollReportCubit
                                                .state
                                                .filterStartDate ??
                                            _selectedDateNotifier.value;
                                        final endDate =
                                            _payrollReportCubit
                                                .state
                                                .filterEndDate ??
                                            _selectedDateNotifier.value;

                                        _payrollReportCubit.getLeaveList(
                                          context: context,
                                          pageNumber: 1,
                                          startDate: startDate,
                                          endDate: endDate,
                                          canApprove:
                                              _leaveTabController.index == 1,
                                        );
                                      }
                                    },

                                    onReject: (val) async {
                                      final isSuccess =
                                          await _payrollReportCubit
                                              .approveRejectSelected(
                                                context: context,
                                                isApproved: false,
                                                remark: val.trim(),
                                                projectId: _project.projectId,
                                              );
                                      if (context.mounted && isSuccess) {
                                        final startDate =
                                            _payrollReportCubit
                                                .state
                                                .filterStartDate ??
                                            _selectedDateNotifier.value;
                                        final endDate =
                                            _payrollReportCubit
                                                .state
                                                .filterEndDate ??
                                            _selectedDateNotifier.value;

                                        _payrollReportCubit.getLeaveList(
                                          context: context,
                                          pageNumber: 1,
                                          startDate: startDate,
                                          endDate: endDate,
                                          canApprove:
                                              _leaveTabController.index == 1,
                                        );
                                      }
                                    },
                                    customWidget: _selectAllWidget(),
                                  ),
                                ),

                                verticalSpacing(),
                              ],
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: selectedIds.contains(leave.leaveId),
                                    onChanged: (_) {
                                      _payrollReportCubit.toggleSelection(
                                        id: leave.leaveId,
                                        listLength:
                                            state.approvalLeaveList.length,
                                      );
                                    },
                                  ),

                                  const SizedBox(width: 8),

                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: commonCardDecoration(),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                leave.createdBy,
                                                style: AppTextStyle.ts16M(),
                                              ),
                                              CustomButton(
                                                onPressed: () async {
                                                  final approvalList =
                                                      await _payrollReportCubit
                                                          .getApprovalStatus(
                                                            requestId:
                                                                leave
                                                                    .createdById
                                                                    .toString(),
                                                            id: leave.leaveId,
                                                            moduleName:
                                                                _payrollReportCubit
                                                                    .getModuleName(),
                                                          );

                                                  final mappedList =
                                                      approvalList
                                                          .toApprovalLogHistoryList();

                                                  if (context.mounted) {
                                                    goRouter.pushNamed(
                                                      AppRoutes
                                                          .approvalLogHistory,
                                                      queryParameters: {
                                                        "subTitle": Uri.encodeComponent(
                                                          EncryptionManager.encryptData(
                                                            "${leave.createdBy} > ${leave.leaveType}",
                                                          ),
                                                        ),
                                                        "title": Uri.encodeComponent(
                                                          EncryptionManager.encryptData(
                                                            "Leave Approval History",
                                                          ),
                                                        ),
                                                        "approvalList":
                                                            Uri.encodeComponent(
                                                              EncryptionManager.encryptData(
                                                                jsonEncode(
                                                                  mappedList
                                                                      .map(
                                                                        (e) =>
                                                                            e.toJson(),
                                                                      )
                                                                      .toList(),
                                                                ),
                                                              ),
                                                            ),
                                                      },
                                                    );
                                                  }
                                                },
                                                leading: Icon(
                                                  Icons.watch_later_outlined,
                                                  size: 16,
                                                  color: AppColor.white,
                                                ),
                                                text: "History",
                                              ),
                                            ],
                                          ),

                                          verticalSpacing(height: 10),
                                          buildRowTitleValue(
                                            title: "Leave Type",
                                            value: leave.leaveType,
                                          ),
                                          buildRowTitleValue(
                                            title: "Start Date",
                                            value: formatDateTimeAsDDMMMYYYY(
                                              leave.startDate,
                                            ),
                                          ),
                                          buildRowTitleValue(
                                            title: "End Date",
                                            value: formatDateTimeAsDDMMMYYYY(
                                              leave.endDate,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // BUILD OUTDOOR SECTION
  Widget buildOutdoorSection() {
    return BlocBuilder<PayrollReportCubit, PayrollReportState>(
      builder: (context, state) {
        return Column(
          children: [
            ChipStyleTabBar(
              controller: _outdoorTabController,
              isSecondaryStyle: true,
              tabs: ['Report', 'Approval'],
            ),
            Expanded(
              child: TabBarView(
                controller: _outdoorTabController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  // REPORT
                  Builder(
                    builder: (context) {
                      final isLoading = state.isLoading ?? true;

                      if (isLoading && state.outdoorList.isEmpty) {
                        return Center(child: loader());
                      }

                      if (state.outdoorList.isEmpty) {
                        return Center(
                          child: noDataWidget(
                            message: "No Outdoor Report Available",
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _outdoorReportController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        itemCount: state.outdoorList.length + 1,
                        itemBuilder: (context, index) {
                          if (index == state.outdoorList.length) {
                            return state.outdoorList.length <
                                    state.totalNumberOfRecordOutdoor
                                ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                                : const SizedBox.shrink();
                          }

                          final outdoor = state.outdoorList[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: commonCardDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      outdoor.createdBy,
                                      style: AppTextStyle.ts16M(),
                                    ),
                                    CustomButton(
                                      onPressed: () async {
                                        final approvalList =
                                            await _payrollReportCubit
                                                .getApprovalStatus(
                                                  requestId:
                                                      outdoor.createdById
                                                          .toString(),
                                                  id: outdoor.outdoorId,
                                                  moduleName:
                                                      _payrollReportCubit
                                                          .getModuleName(),
                                                );

                                        final mappedList =
                                            approvalList
                                                .toApprovalLogHistoryList();

                                        if (context.mounted) {
                                          goRouter.pushNamed(
                                            AppRoutes.approvalLogHistory,
                                            queryParameters: {
                                              "subTitle": Uri.encodeComponent(
                                                EncryptionManager.encryptData(
                                                  "${outdoor.createdBy} > ${formatDateTimeAsDDMMMYYYY(outdoor.outDoorDate)}",
                                                ),
                                              ),
                                              "title": Uri.encodeComponent(
                                                EncryptionManager.encryptData(
                                                  "Outdoor Approval History",
                                                ),
                                              ),
                                              "approvalList": Uri.encodeComponent(
                                                EncryptionManager.encryptData(
                                                  jsonEncode(
                                                    mappedList
                                                        .map((e) => e.toJson())
                                                        .toList(),
                                                  ),
                                                ),
                                              ),
                                            },
                                          );
                                        }
                                      },
                                      leading: Icon(
                                        Icons.watch_later_outlined,
                                        size: 16,
                                        color: AppColor.white,
                                      ),
                                      text: "History",
                                    ),
                                  ],
                                ),

                                verticalSpacing(height: 10),
                                buildRowTitleValue(
                                  title: "Date",
                                  value: formatDateTimeAsDDMMMYYYY(
                                    outdoor.outDoorDate,
                                  ),
                                ),
                                buildRowTitleValue(
                                  title: "Time",
                                  value: DateFormat(
                                    'hh:mm a',
                                  ).format(outdoor.outDoorTime),
                                ),
                                buildRowTitleValue(
                                  title: "Company",
                                  value: outdoor.companyName,
                                ),
                                buildRowTitleValue(
                                  title: "Department",
                                  value: outdoor.departmentName,
                                ),
                                buildRowTitleValue(
                                  title: "Accompanied By",
                                  value: outdoor.accompaniedByName,
                                ),
                                buildRowTitleValue(
                                  title: "Purpose",
                                  value: outdoor.purpose,
                                ),
                                if (outdoor.conclusion.isNotEmpty)
                                  buildRowTitleValue(
                                    title: "Conclusion",
                                    value: outdoor.conclusion,
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),

                  // APPROVAL
                  Builder(
                    builder: (context) {
                      final isLoading = state.isLoading ?? true;

                      if (isLoading && state.approvalOutdoorList.isEmpty) {
                        return Center(child: loader());
                      }

                      if (state.approvalOutdoorList.isEmpty) {
                        return Center(
                          child: noDataWidget(
                            message: "No Outdoor Approval Report Available",
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _outdoorReportController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        itemCount: state.approvalOutdoorList.length + 1,
                        itemBuilder: (context, index) {
                          if (index == state.approvalOutdoorList.length) {
                            return state.approvalOutdoorList.length <
                                    state.totalNumberOfRecordApprovalOutdoor
                                ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                                : const SizedBox.shrink();
                          }

                          final outdoor = state.approvalOutdoorList[index];

                          return Column(
                            children: [
                              if (state.outdoorInnerTabIndex == 1 &&
                                  index == 0) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: ApproveRejectWidget(
                                    actionTitle: "Pending",
                                    isActionAlreadyPerformed: false,
                                    popupTitle: "Confirm Approval",
                                    subTitle:
                                        "You are about to approve ${state.selectedOutdoorIds.length} records(s).",
                                    canOpenDialog: () {
                                      if (state.selectedOutdoorIds.isEmpty) {
                                        showErrorMessage(
                                          context,
                                          "Error",
                                          "Please select at least one record or use Select All",
                                        );
                                        return false;
                                      }
                                      return true;
                                    },

                                    isMaster: true,
                                    onApprove: (val) async {
                                      final isSuccess =
                                          await _payrollReportCubit
                                              .approveRejectSelected(
                                                context: context,
                                                isApproved: true,
                                                remark: val.trim(),
                                                projectId: _project.projectId,
                                              );
                                      if (context.mounted && isSuccess) {
                                        final startDate =
                                            _payrollReportCubit
                                                .state
                                                .filterStartDate ??
                                            _selectedDateNotifier.value;
                                        final endDate =
                                            _payrollReportCubit
                                                .state
                                                .filterEndDate ??
                                            _selectedDateNotifier.value;

                                        _payrollReportCubit.getOutdoorList(
                                          context: context,
                                          pageNumber: 1,
                                          startDate: startDate,
                                          endDate: endDate,
                                          canApprove:
                                              _outdoorTabController.index == 1,
                                        );
                                      }
                                    },
                                    onReject: (val) async {
                                      final isSuccess =
                                          await _payrollReportCubit
                                              .approveRejectSelected(
                                                context: context,
                                                isApproved: false,
                                                remark: val.trim(),
                                                projectId: _project.projectId,
                                              );
                                      if (context.mounted && isSuccess) {
                                        final startDate =
                                            _payrollReportCubit
                                                .state
                                                .filterStartDate ??
                                            _selectedDateNotifier.value;
                                        final endDate =
                                            _payrollReportCubit
                                                .state
                                                .filterEndDate ??
                                            _selectedDateNotifier.value;

                                        _payrollReportCubit.getOutdoorList(
                                          context: context,
                                          pageNumber: 1,
                                          startDate: startDate,
                                          endDate: endDate,
                                          canApprove:
                                              _outdoorTabController.index == 1,
                                        );
                                      }
                                    },
                                    customWidget: _selectAllWidget(),
                                  ),
                                ),
                                verticalSpacing(),
                              ],

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: state.selectedOutdoorIds.contains(
                                      outdoor.outdoorId,
                                    ),
                                    onChanged: (_) {
                                      _payrollReportCubit.toggleSelection(
                                        id: outdoor.outdoorId,
                                        listLength:
                                            state.approvalOutdoorList.length,
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 8),

                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: commonCardDecoration(),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                outdoor.createdBy,
                                                style: AppTextStyle.ts16M(),
                                              ),
                                              CustomButton(
                                                onPressed: () async {
                                                  final approvalList =
                                                      await _payrollReportCubit
                                                          .getApprovalStatus(
                                                            requestId:
                                                                outdoor
                                                                    .createdById
                                                                    .toString(),
                                                            id:
                                                                outdoor
                                                                    .outdoorId,
                                                            moduleName:
                                                                _payrollReportCubit
                                                                    .getModuleName(),
                                                          );

                                                  final mappedList =
                                                      approvalList
                                                          .toApprovalLogHistoryList();

                                                  if (context.mounted) {
                                                    goRouter.pushNamed(
                                                      AppRoutes
                                                          .approvalLogHistory,
                                                      queryParameters: {
                                                        "subTitle": Uri.encodeComponent(
                                                          EncryptionManager.encryptData(
                                                            "${outdoor.createdBy} > ${formatDateTimeAsDDMMMYYYY(outdoor.outDoorDate)}",
                                                          ),
                                                        ),
                                                        "title": Uri.encodeComponent(
                                                          EncryptionManager.encryptData(
                                                            "Outdoor Approval History",
                                                          ),
                                                        ),
                                                        "approvalList":
                                                            Uri.encodeComponent(
                                                              EncryptionManager.encryptData(
                                                                jsonEncode(
                                                                  mappedList
                                                                      .map(
                                                                        (e) =>
                                                                            e.toJson(),
                                                                      )
                                                                      .toList(),
                                                                ),
                                                              ),
                                                            ),
                                                      },
                                                    );
                                                  }
                                                },
                                                leading: Icon(
                                                  Icons.watch_later_outlined,
                                                  size: 16,
                                                  color: AppColor.white,
                                                ),
                                                text: "History",
                                              ),
                                            ],
                                          ),

                                          verticalSpacing(height: 10),
                                          buildRowTitleValue(
                                            title: "Date",
                                            value: formatDateTimeAsDDMMMYYYY(
                                              outdoor.outDoorDate,
                                            ),
                                          ),
                                          buildRowTitleValue(
                                            title: "Time",
                                            value: DateFormat(
                                              'hh:mm a',
                                            ).format(outdoor.outDoorTime),
                                          ),
                                          buildRowTitleValue(
                                            title: "Company",
                                            value: outdoor.companyName,
                                          ),
                                          buildRowTitleValue(
                                            title: "Department",
                                            value: outdoor.departmentName,
                                          ),
                                          buildRowTitleValue(
                                            title: "Accompanied By",
                                            value: outdoor.accompaniedByName,
                                          ),
                                          buildRowTitleValue(
                                            title: "Purpose",
                                            value: outdoor.purpose,
                                          ),
                                          if (outdoor.conclusion.isNotEmpty)
                                            buildRowTitleValue(
                                              title: "Conclusion",
                                              value: outdoor.conclusion,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // BUILD RESIGNATION SECTION
  Widget buildResignationSection() {
    return BlocBuilder<PayrollReportCubit, PayrollReportState>(
      builder: (context, state) {
        return Column(
          children: [
            ChipStyleTabBar(
              controller: _resignationTabController,
              isSecondaryStyle: true,
              tabs: ['Report', 'Approval'],
            ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _resignationTabController,
                children: [
                  // REPORT
                  Builder(
                    builder: (context) {
                      final isLoading = state.isLoading ?? true;

                      if (isLoading && state.resignationList.isEmpty) {
                        return Center(child: loader());
                      }

                      if (state.resignationList.isEmpty) {
                        return Center(
                          child: noDataWidget(
                            message: "No Resignation Report Available",
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _resignationReportController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        itemCount: state.resignationList.length + 1,
                        itemBuilder: (context, index) {
                          if (index == state.resignationList.length) {
                            return state.resignationList.length <
                                    state.totalNumberOfRecordResignation
                                ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                                : const SizedBox.shrink();
                          }

                          final resignation = state.resignationList[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: commonCardDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      resignation.createdBy,
                                      style: AppTextStyle.ts16M(),
                                    ),
                                    CustomButton(
                                      onPressed: () async {
                                        final approvalList =
                                            await _payrollReportCubit
                                                .getApprovalStatus(
                                                  requestId:
                                                      resignation.createdById
                                                          .toString(),
                                                  id:
                                                      resignation
                                                          .employeeResignationId,
                                                  moduleName:
                                                      _payrollReportCubit
                                                          .getModuleName(),
                                                );

                                        final mappedList =
                                            approvalList
                                                .toApprovalLogHistoryList();

                                        if (context.mounted) {
                                          goRouter.pushNamed(
                                            AppRoutes.approvalLogHistory,
                                            queryParameters: {
                                              "subTitle": Uri.encodeComponent(
                                                EncryptionManager.encryptData(
                                                  "${resignation.createdBy} > ${formatDateTimeAsDDMMMYYYY(resignation.resignationDate)}",
                                                ),
                                              ),
                                              "title": Uri.encodeComponent(
                                                EncryptionManager.encryptData(
                                                  "Resignation Approval History",
                                                ),
                                              ),
                                              "approvalList": Uri.encodeComponent(
                                                EncryptionManager.encryptData(
                                                  jsonEncode(
                                                    mappedList
                                                        .map((e) => e.toJson())
                                                        .toList(),
                                                  ),
                                                ),
                                              ),
                                            },
                                          );
                                        }
                                      },
                                      leading: Icon(
                                        Icons.watch_later_outlined,
                                        size: 16,
                                        color: AppColor.white,
                                      ),
                                      text: "History",
                                    ),
                                  ],
                                ),

                                verticalSpacing(height: 10),
                                buildRowTitleValue(
                                  title: "Resignation Date",
                                  value: formatDateTimeAsDDMMMYYYY(
                                    resignation.resignationDate,
                                  ),
                                ),
                                buildRowTitleValue(
                                  title: "Expected Relieving Date",
                                  value: formatDateTimeAsDDMMMYYYY(
                                    resignation.expectedRelievingDate,
                                  ),
                                ),
                                buildRowTitleValue(
                                  title: "Reason Of Leaving",
                                  value: resignation.reasonOfLeaving,
                                ),
                                buildRowTitleValue(
                                  title: "Offer In Hand",
                                  value:
                                      resignation.isAnyOfferInHand
                                          ? "Yes"
                                          : "No",
                                ),
                                buildRowTitleValue(
                                  title: "Offer Amount",
                                  value: resignation.offerAmount.toString(),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),

                  // APPROVAL
                  Builder(
                    builder: (context) {
                      final isLoading = state.isLoading ?? true;

                      if (isLoading && state.approvalResignationList.isEmpty) {
                        return Center(child: loader());
                      }

                      if (state.approvalResignationList.isEmpty) {
                        return Center(
                          child: noDataWidget(
                            message: "No Resignation Report Available",
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _resignationReportController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        itemCount: state.approvalResignationList.length + 1,
                        itemBuilder: (context, index) {
                          if (index == state.approvalResignationList.length) {
                            return state.approvalResignationList.length <
                                    state.totalNumberOfRecordApprovalResignation
                                ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                                : const SizedBox.shrink();
                          }

                          final resignation =
                              state.approvalResignationList[index];

                          return Column(
                            children: [
                              if (state.resignationInnerTabIndex == 1 &&
                                  index == 0) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: ApproveRejectWidget(
                                    actionTitle: "Pending",
                                    isActionAlreadyPerformed: false,
                                    popupTitle: "Confirm Approval",
                                    subTitle:
                                        "You are about to approve ${state.selectedResignationIds.length} records(s).",
                                    isMaster: true,
                                    canOpenDialog: () {
                                      if (state
                                          .selectedResignationIds
                                          .isEmpty) {
                                        showErrorMessage(
                                          context,
                                          "Error",
                                          "Please select at least one record or use Select All",
                                        );
                                        return false;
                                      }
                                      return true;
                                    },

                                    onApprove: (val) async {
                                      final isSuccess =
                                          await _payrollReportCubit
                                              .approveRejectSelected(
                                                context: context,
                                                isApproved: true,
                                                remark: val.trim(),
                                                projectId: _project.projectId,
                                              );
                                      if (context.mounted && isSuccess) {
                                        final startDate =
                                            _payrollReportCubit
                                                .state
                                                .filterStartDate ??
                                            _selectedDateNotifier.value;
                                        final endDate =
                                            _payrollReportCubit
                                                .state
                                                .filterEndDate ??
                                            _selectedDateNotifier.value;

                                        _payrollReportCubit.getResignationList(
                                          context: context,
                                          pageNumber: 1,
                                          startDate: startDate,
                                          endDate: endDate,
                                          canApprove:
                                              _resignationTabController.index ==
                                              1,
                                        );
                                      }
                                    },
                                    onReject: (val) async {
                                      final isSuccess =
                                          await _payrollReportCubit
                                              .approveRejectSelected(
                                                context: context,
                                                isApproved: false,
                                                remark: val.trim(),
                                                projectId: _project.projectId,
                                              );
                                      if (context.mounted && isSuccess) {
                                        final startDate =
                                            _payrollReportCubit
                                                .state
                                                .filterStartDate ??
                                            _selectedDateNotifier.value;
                                        final endDate =
                                            _payrollReportCubit
                                                .state
                                                .filterEndDate ??
                                            _selectedDateNotifier.value;

                                        _payrollReportCubit.getResignationList(
                                          context: context,
                                          pageNumber: 1,
                                          startDate: startDate,
                                          endDate: endDate,
                                          canApprove:
                                              _resignationTabController.index ==
                                              1,
                                        );
                                      }
                                    },
                                    customWidget: _selectAllWidget(),
                                  ),
                                ),
                                verticalSpacing(),
                              ],

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: state.selectedResignationIds
                                        .contains(
                                          resignation.employeeResignationId,
                                        ),
                                    onChanged: (_) {
                                      _payrollReportCubit.toggleSelection(
                                        id: resignation.employeeResignationId,
                                        listLength:
                                            state
                                                .approvalResignationList
                                                .length,
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 8),

                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: commonCardDecoration(),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                resignation.createdBy,
                                                style: AppTextStyle.ts16M(),
                                              ),
                                              CustomButton(
                                                onPressed: () async {
                                                  final approvalList =
                                                      await _payrollReportCubit
                                                          .getApprovalStatus(
                                                            requestId:
                                                                resignation
                                                                    .createdById
                                                                    .toString(),
                                                            id:
                                                                resignation
                                                                    .employeeResignationId,
                                                            moduleName:
                                                                _payrollReportCubit
                                                                    .getModuleName(),
                                                          );

                                                  final mappedList =
                                                      approvalList
                                                          .toApprovalLogHistoryList();

                                                  if (context.mounted) {
                                                    goRouter.pushNamed(
                                                      AppRoutes
                                                          .approvalLogHistory,
                                                      queryParameters: {
                                                        "subTitle": Uri.encodeComponent(
                                                          EncryptionManager.encryptData(
                                                            "${resignation.createdBy} > ${formatDateTimeAsDDMMMYYYY(resignation.resignationDate)}",
                                                          ),
                                                        ),
                                                        "title": Uri.encodeComponent(
                                                          EncryptionManager.encryptData(
                                                            "Resignation Approval History",
                                                          ),
                                                        ),
                                                        "approvalList":
                                                            Uri.encodeComponent(
                                                              EncryptionManager.encryptData(
                                                                jsonEncode(
                                                                  mappedList
                                                                      .map(
                                                                        (e) =>
                                                                            e.toJson(),
                                                                      )
                                                                      .toList(),
                                                                ),
                                                              ),
                                                            ),
                                                      },
                                                    );
                                                  }
                                                },
                                                leading: Icon(
                                                  Icons.watch_later_outlined,
                                                  size: 16,
                                                  color: AppColor.white,
                                                ),
                                                text: "History",
                                              ),
                                            ],
                                          ),

                                          verticalSpacing(height: 10),
                                          buildRowTitleValue(
                                            title: "Resignation Date",
                                            value: formatDateTimeAsDDMMMYYYY(
                                              resignation.resignationDate,
                                            ),
                                          ),
                                          buildRowTitleValue(
                                            title: "Expected Relieving Date",
                                            value: formatDateTimeAsDDMMMYYYY(
                                              resignation.expectedRelievingDate,
                                            ),
                                          ),
                                          buildRowTitleValue(
                                            title: "Reason Of Leaving",
                                            value: resignation.reasonOfLeaving,
                                          ),
                                          buildRowTitleValue(
                                            title: "Offer In Hand",
                                            value:
                                                resignation.isAnyOfferInHand
                                                    ? "Yes"
                                                    : "No",
                                          ),
                                          buildRowTitleValue(
                                            title: "Offer Amount",
                                            value:
                                                resignation.offerAmount
                                                    .toString(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _selectAllWidget() {
    return BlocBuilder<PayrollReportCubit, PayrollReportState>(
      builder: (context, state) {
        bool isAllSelected = false;
        bool showSelectAll = false;

        switch (state.currentTabIndex) {
          case 3: // Leave
            isAllSelected = state.isAllLeaveSelected;
            showSelectAll = state.leaveInnerTabIndex == 1;
            break;
          case 2: // CompOff
            isAllSelected = state.isAllCompOffSelected;
            showSelectAll = state.compOffInnerTabIndex == 1;
            break;
          case 4:
            isAllSelected = state.isAllOutdoorSelected;
            showSelectAll = state.outdoorInnerTabIndex == 1;
            break;
          case 5:
            isAllSelected = state.isAllResignationSelected;
            showSelectAll = state.resignationInnerTabIndex == 1;
            break;
        }

        return !showSelectAll
            ? const SizedBox.shrink()
            : InkWell(
              onTap: () {
                _payrollReportCubit.toggleSelectAll();
              },
              child: Row(
                children: [
                  SizedBox(
                    height: 18,
                    width: 18,
                    child: Checkbox(
                      value: isAllSelected,
                      onChanged: (_) {
                        _payrollReportCubit.toggleSelectAll();
                      },
                    ),
                  ),
                  horizontalSpacing(width: 5),
                  Text("Select All"),
                ],
              ),
            );
      },
    );
  }
}
