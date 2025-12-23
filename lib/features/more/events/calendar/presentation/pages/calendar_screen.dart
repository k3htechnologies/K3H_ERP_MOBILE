// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/more/events/calendar/data/models/calendar_event.dart'
    show
        CalendarEventModel,
        CalendarEventType,
        eventTypeColor,
        CalendarEventTypeMapper;
import 'package:k3h_erp_app/features/more/events/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

enum SortType { all, task, meeting, conference }

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime selectedDate;
  late DateTime visibleMonth;
  late DateTime visibleWeek;

  int _selectedTabIndex = 0;

  SortType? selectedSortType;
  OverlayEntry? _overlayEntry;

  // CUBIT
  late CalendarCubit _calendarCubit;
  bool _isInitialLoad = true;
  DateTime? _lastRefreshTime;

  @override
  void initState() {
    super.initState();
    _calendarCubit = context.read<CalendarCubit>();
    selectedDate = DateTime.now();
    visibleMonth = DateTime(selectedDate.year, selectedDate.month);
    final now = DateTime.now();
    final daysFromSunday = now.weekday % 7;
    visibleWeek = DateTime(now.year, now.month, now.day - daysFromSunday);
    _lastRefreshTime = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMonthEvents();
      _isInitialLoad = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh events when screen becomes active (after navigation back)
    // Only refresh if enough time has passed since last refresh to avoid unnecessary calls
    final now = DateTime.now();
    if (!_isInitialLoad && 
        mounted && 
        (_lastRefreshTime == null || now.difference(_lastRefreshTime!).inSeconds > 1)) {
      _lastRefreshTime = now;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _fetchMonthEvents();
        }
      });
    }
  }

  void _fetchMonthEvents() {
    final start = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final end = DateTime(visibleMonth.year, visibleMonth.month + 1, 0, 23, 59);
    _calendarCubit.getEvents(context: context, fromDate: start, toDate: end);
  }

  String _monthTitle(DateTime month) {
    return DateFormat('MMMM yyyy').format(month);
  }

  List<CalendarEventModel> _eventsForDate(
    List<CalendarEventModel> source,
    DateTime date,
  ) {
    return source.where((e) {
      final d = e.getEventDate();
      if (d == null) return false;
      return d.year == date.year && d.month == date.month && d.day == date.day;
    }).toList();
  }

  CalendarEventType? _mapSortTypeToEventType(SortType? sortType) {
    if (sortType == null || sortType == SortType.all) return null;
    switch (sortType) {
      case SortType.task:
        return CalendarEventType.task;
      case SortType.meeting:
        return CalendarEventType.meeting;
      case SortType.conference:
        return CalendarEventType.conferenceRoom;
      case SortType.all:
        return null;
    }
  }

  int _daysInMonth(DateTime month) {
    final beginningNextMonth =
        (month.month == 12)
            ? DateTime(month.year + 1, 1, 1)
            : DateTime(month.year, month.month + 1, 1);
    return beginningNextMonth.subtract(const Duration(days: 1)).day;
  }

  void _goToPreviousMonth() {
    setState(() {
      visibleMonth = DateTime(visibleMonth.year, visibleMonth.month - 1);
    });
    _fetchMonthEvents();
  }

  void _goToNextMonth() {
    setState(() {
      visibleMonth = DateTime(visibleMonth.year, visibleMonth.month + 1);
    });
    _fetchMonthEvents();
  }

  void _goToPreviousWeek() {
    setState(() {
      visibleWeek = visibleWeek.subtract(const Duration(days: 7));
    });
  }

  void _goToNextWeek() {
    setState(() {
      visibleWeek = visibleWeek.add(const Duration(days: 7));
    });
  }

  List<DateTime> _getWeekDates(DateTime weekStart) {
    return List.generate(7, (index) {
      return weekStart.add(Duration(days: index));
    });
  }

  String _weekTitle(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    if (weekStart.month == weekEnd.month) {
      return '${DateFormat('MMM').format(weekStart)} ${weekStart.day} - ${weekEnd.day}, ${weekStart.year}';
    } else {
      return '${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d').format(weekEnd)}, ${weekStart.year}';
    }
  }

  void _onDateSelected(DateTime date, List<CalendarEventModel> source) {
    setState(() {
      selectedDate = date;
    });
    final selectedEvents = _eventsForDate(source, date);
    final payload = {
      'date': date.toIso8601String(),
      'events': selectedEvents.map((e) => e.toJson()).toList(),
    };
    final encrypted = EncryptionManager.encryptData(jsonEncode(payload));
    context.pushNamed(
      AppRoutes.calendarDetail,
      queryParameters: {'data': Uri.encodeComponent(encrypted)},
    );
  }

  // FILTER OVERLAY
  void showSortOverlay(BuildContext context) {
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder:
          (context) => GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              _overlayEntry?.remove();
              _overlayEntry = null;
            },
            child: Stack(
              children: [
                Positioned(
                  top: 160,
                  right: 16,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 220,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.black.withValues(alpha: .05),
                            blurRadius: 0,
                            spreadRadius: 2,
                            offset: Offset(0, 2),
                          ),
                          BoxShadow(
                            color: AppColor.black.withValues(alpha: .0),
                            blurRadius: 0,
                            spreadRadius: 0,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: StatefulBuilder(
                        builder: (context, innerSetState) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // HEADER
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Sort By", style: AppTextStyle.ts16SB()),
                                  InkWell(
                                    onTap: () {
                                      _overlayEntry?.remove();
                                      _overlayEntry = null;
                                    },
                                    child: const Icon(Icons.close, size: 18),
                                  ),
                                ],
                              ),

                              Divider(color: AppColor.grey, thickness: .5),

                              // RADIO OPTIONS
                              _buildRadio(
                                title: "All",
                                value: SortType.all,
                                groupValue: selectedSortType,
                                onChanged: (value) {
                                  innerSetState(() {
                                    selectedSortType = value;
                                  });
                                  // Rebuild main calendar screen to reflect updated label
                                  setState(() {});

                                  _overlayEntry?.remove();
                                  _overlayEntry = null;
                                },
                              ),
                              _buildRadio(
                                title: "Task",
                                value: SortType.task,
                                groupValue: selectedSortType,
                                onChanged: (value) {
                                  innerSetState(() {
                                    selectedSortType = value;
                                  });
                                  setState(() {});

                                  _overlayEntry?.remove();
                                  _overlayEntry = null;
                                },
                              ),
                              _buildRadio(
                                title: "Meeting",
                                value: SortType.meeting,
                                groupValue: selectedSortType,
                                onChanged: (value) {
                                  innerSetState(() {
                                    selectedSortType = value;
                                  });
                                  setState(() {});

                                  _overlayEntry?.remove();
                                  _overlayEntry = null;
                                },
                              ),
                              _buildRadio(
                                title: "Conference Room",
                                value: SortType.conference,
                                groupValue: selectedSortType,
                                onChanged: (value) {
                                  innerSetState(() {
                                    selectedSortType = value;
                                  });
                                  setState(() {});

                                  _overlayEntry?.remove();
                                  _overlayEntry = null;
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );

    overlay.insert(_overlayEntry!);
  }

  // GET SORT LABEL
  String getSortLabel(SortType? type) {
    switch (type) {
      case SortType.task:
        return "Task";
      case SortType.meeting:
        return "Meeting";
      case SortType.conference:
        return "Conference Room";
      case SortType.all:
        return "All";
      default:
        return "All";
    }
  }

  // RADIO BUTTON
  Widget _buildRadio({
    required String title,
    required SortType value,
    required SortType? groupValue,
    required ValueChanged<SortType?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Row(
        children: [
          Radio<SortType>(
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
          ),
          Text(title),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Calendar",
        authorization: AuthorizationModel(isAction: true),
        onAddCallback: () {
          goRouter.pushNamed(AppRoutes.addDetailsCalendar);
        },
        showNotification: true,
      ),
      body: SafeArea(
        child: BlocListener<CalendarCubit, CalendarState>(
          listenWhen: (previous, current) {
            // Listen when events list increases (new event added) and not loading
            // This helps refresh the list when events are added from other screens
            return (current.isLoading == false) && 
                   previous.isLoading == false &&
                   previous.eventsList.length < current.eventsList.length &&
                   !_isInitialLoad;
          },
          listener: (context, state) {
            // When a new event is detected, refresh the current month's events
            // This ensures the calendar shows the latest data
            if (mounted) {
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  _fetchMonthEvents();
                }
              });
            }
          },
          child: BlocBuilder<CalendarCubit, CalendarState>(
            builder: (context, calState) {
            if (calState.isLoading == true) {
              return loader();
            }
            final sourceEvents = calState.eventsList;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  selectedSortType == SortType.all || selectedSortType == null
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _eventTypeWidget(
                                color: AppColor.mediumBlue,
                                eventType: "Task",
                              ),
                              const SizedBox(width: 10),
                              _eventTypeWidget(
                                color: AppColor.error,
                                eventType: "Meeting",
                              ),
                              const SizedBox(width: 10),
                              _eventTypeWidget(
                                color: AppColor.warning,
                                eventType: "Conference Room",
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              showSortOverlay(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.lightBlue.withValues(alpha: .3),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: AppColor.primary,
                                  width: .5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    getSortLabel(selectedSortType),
                                    style: AppTextStyle.ts14R(),
                                  ),
                                  horizontalSpacing(),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColor.lightBlue,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    padding: EdgeInsets.all(6),
                                    child: SvgPicture.asset(
                                      AppAssets.filterIcon,
                                      height: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _eventTypeWidget(
                                color: AppColor.green,
                                eventType: "Low",
                              ),
                              const SizedBox(width: 10),
                              _eventTypeWidget(
                                color: AppColor.mediumBlue,
                                eventType: "Medium",
                              ),
                              const SizedBox(width: 10),
                              _eventTypeWidget(
                                color: AppColor.error,
                                eventType: "High",
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              showSortOverlay(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.lightBlue.withValues(alpha: .3),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: AppColor.primary,
                                  width: .5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    getSortLabel(selectedSortType),
                                    style: AppTextStyle.ts14R(),
                                  ),
                                  horizontalSpacing(),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColor.lightBlue,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    padding: EdgeInsets.all(6),
                                    child: SvgPicture.asset(
                                      AppAssets.filterIcon,
                                      height: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  verticalSpacing(),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (_selectedTabIndex == 0) return;
                            setState(() => _selectedTabIndex = 0);
                          },
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color:
                                      _selectedTabIndex == 0
                                          ? AppColor.mediumBlue.withValues(
                                            alpha: .5,
                                          )
                                          : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Text(
                              "Weekly",
                              textAlign: TextAlign.center,
                              style: AppTextStyle.ts14R(
                                color:
                                    _selectedTabIndex == 0
                                        ? AppColor.primary
                                        : AppColor.grey,
                              ).copyWith(
                                fontWeight:
                                    _selectedTabIndex == 0
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (_selectedTabIndex == 1) return;
                            setState(() => _selectedTabIndex = 1);
                          },
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color:
                                      _selectedTabIndex == 1
                                          ? AppColor.mediumBlue.withValues(
                                            alpha: .5,
                                          )
                                          : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Text(
                              "Monthly",
                              textAlign: TextAlign.center,
                              style: AppTextStyle.ts14R(
                                color:
                                    _selectedTabIndex == 1
                                        ? AppColor.primary
                                        : AppColor.grey,
                              ).copyWith(
                                fontWeight:
                                    _selectedTabIndex == 1
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(height: .5, color: AppColor.primary),
                  verticalSpacing(),
                  _selectedTabIndex == 0
                      ? _weeklyWidget(sourceEvents)
                      : _monthlyWidget(sourceEvents),
                  if (_selectedTabIndex == 1) ...[
                    verticalSpacing(height: 16),
                    _buildMonthlyEventsList(sourceEvents),
                  ],
                  verticalSpacing(height: 20),
                ],
              ),
            );
          },
          ),
        ),
      ),
    );
  }

  // MONTHLY WIDGET
  Widget _monthlyWidget(List<CalendarEventModel> sourceEvents) {
    final firstDayOfMonth = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final daysInMonth = _daysInMonth(visibleMonth);
    final startWeekday = firstDayOfMonth.weekday % 7; // Sunday -> 0
    final totalGridItems = startWeekday + daysInMonth;
    final rows = math.max(6, ((totalGridItems + 6) / 7).floor());
    final paddedItemCount = rows * 7;

    return Container(
      decoration: BoxDecoration(
        color: AppColor.lightBlue.withValues(alpha: .4),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // MONTH AND YEAR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 22),
                onPressed: _goToPreviousMonth,
              ),
              Text(_monthTitle(visibleMonth), style: AppTextStyle.ts16SB()),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 22),
                onPressed: _goToNextMonth,
              ),
            ],
          ),
          verticalSpacing(),
          // DAYS
          _buildWeekdayHeader(),
          // DATES
          verticalSpacing(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 8.0;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  childAspectRatio: 1,
                ),
                itemCount: paddedItemCount,
                itemBuilder: (context, index) {
                  DateTime currentDate;
                  bool isOutOfMonth = false;

                  if (index < startWeekday) {
                    final prevMonth = DateTime(
                      visibleMonth.year,
                      visibleMonth.month - 1,
                      1,
                    );
                    final prevMonthDays = _daysInMonth(prevMonth);
                    final day = prevMonthDays - (startWeekday - index) + 1;
                    currentDate = DateTime(
                      prevMonth.year,
                      prevMonth.month,
                      day.toInt(),
                    );
                    isOutOfMonth = true;
                  } else if (index >= totalGridItems) {
                    final day = index - totalGridItems + 1;
                    final nextMonth = DateTime(
                      visibleMonth.year,
                      visibleMonth.month + 1,
                      1,
                    );
                    currentDate = DateTime(
                      nextMonth.year,
                      nextMonth.month,
                      day.toInt(),
                    );
                    isOutOfMonth = true;
                  } else {
                    final day = index - startWeekday + 1;
                    currentDate = DateTime(
                      visibleMonth.year,
                      visibleMonth.month,
                      day.toInt(),
                    );
                  }
                  final isToday = _isSameDate(currentDate, DateTime.now());
                  final isSelected = _isSameDate(currentDate, selectedDate);
                  final eventsForDay = _eventsForDate(
                    sourceEvents,
                    currentDate,
                  );
                  final dots = <Color>[];
                  if (eventsForDay.any(
                    (e) =>
                        e.type.toCalendarEventType() == CalendarEventType.task,
                  )) {
                    dots.add(eventTypeColor(CalendarEventType.task));
                  }
                  if (eventsForDay.any(
                    (e) =>
                        e.type.toCalendarEventType() ==
                        CalendarEventType.meeting,
                  )) {
                    dots.add(eventTypeColor(CalendarEventType.meeting));
                  }
                  if (eventsForDay.any(
                    (e) =>
                        e.type.toCalendarEventType() ==
                        CalendarEventType.conferenceRoom,
                  )) {
                    dots.add(eventTypeColor(CalendarEventType.conferenceRoom));
                  }
                  return GestureDetector(
                    onTap: () => _onDateSelected(currentDate, sourceEvents),
                    child: _DayCell(
                      day: currentDate.day,
                      isToday: isToday,
                      isSelected: isSelected,
                      isOutOfMonth: isOutOfMonth,
                      dots: dots,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // MONTHLY EVENT LIST
  Widget _buildMonthlyEventsList(List<CalendarEventModel> sourceEvents) {
    // Events for the currently selected date
    final allSelectedEvents = _eventsForDate(sourceEvents, selectedDate);

    // Apply type filter if any specific filter is selected
    final filterType = _mapSortTypeToEventType(selectedSortType);
    final selectedEvents =
        filterType == null
            ? allSelectedEvents
            : allSelectedEvents
                .where((e) => e.type.toCalendarEventType() == filterType)
                .toList();

    if (selectedEvents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No events for ${DateFormat('d MMMM yyyy').format(selectedDate)}',
            style: AppTextStyle.ts14R(color: AppColor.grey),
          ),
        ),
      );
    }

    // Group events by type
    final Map<CalendarEventType, List<CalendarEventModel>> eventsByType = {};
    for (final event in selectedEvents) {
      final type = event.type.toCalendarEventType();
      eventsByType.putIfAbsent(type, () => []);
      eventsByType[type]!.add(event);
    }

    // Sort events within each type by time
    eventsByType.forEach((type, events) {
      events.sort((a, b) {
        final aTime = a.getStartTimeAsDateTime();
        final bTime = b.getStartTimeAsDateTime();
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        final aMinutes = aTime.hour * 60 + aTime.minute;
        final bMinutes = bTime.hour * 60 + bTime.minute;
        return aMinutes.compareTo(bMinutes);
      });
    });

    // Define order: Task, Meeting, Conference Room
    final eventTypeOrder = [
      CalendarEventType.task,
      CalendarEventType.meeting,
      CalendarEventType.conferenceRoom,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Header
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: Text(
            DateFormat('d MMMM yyyy, EEEE').format(selectedDate),
            style: AppTextStyle.ts14M(),
          ),
        ),
        // Events grouped by type (vertically)
        ...eventTypeOrder.map((type) {
          final typeEvents = eventsByType[type] ?? [];
          if (typeEvents.isEmpty) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event type label
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: eventTypeColor(type),
                        ),
                      ),
                      horizontalSpacing(width: 5),
                      Text(
                        _getEventTypeName(type),
                        style: AppTextStyle.ts14M(),
                      ),
                    ],
                  ),
                ),
                // Events for this type (horizontal scroll)
                SizedBox(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          typeEvents
                              .map(
                                (event) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _buildEventCardForCurrentFilter(event),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // HELPER FUNCTIONS FOR EVENT TYPE
  String _getEventTypeName(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.task:
        return 'Task';
      case CalendarEventType.meeting:
        return 'Meeting';
      case CalendarEventType.conferenceRoom:
        return 'Conference Room';
    }
  }

  // WEEKLY WIDGET
  Widget _weeklyWidget(List<CalendarEventModel> sourceEvents) {
    final weekDates = _getWeekDates(visibleWeek);

    return Column(
      children: [
        // Weekly Calendar Grid
        Container(
          decoration: BoxDecoration(
            color: AppColor.lightBlue.withValues(alpha: .4),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // WEEK NAVIGATION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 22),
                    onPressed: _goToPreviousWeek,
                  ),
                  Text(_weekTitle(visibleWeek), style: AppTextStyle.ts16SB()),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 22),
                    onPressed: _goToNextWeek,
                  ),
                ],
              ),
              verticalSpacing(),
              // DAYS HEADER
              _buildWeekdayHeader(),
              verticalSpacing(height: 6),
              // WEEK DATES GRID
              LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 8.0;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
                          childAspectRatio: 1,
                        ),
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      final currentDate = weekDates[index];
                      final isToday = _isSameDate(currentDate, DateTime.now());
                      final isSelected = _isSameDate(currentDate, selectedDate);
                      final eventsForDay = _eventsForDate(
                        sourceEvents,
                        currentDate,
                      );
                      final dots = <Color>[];
                      if (eventsForDay.any(
                        (e) =>
                            e.type.toCalendarEventType() ==
                            CalendarEventType.task,
                      )) {
                        dots.add(eventTypeColor(CalendarEventType.task));
                      }
                      if (eventsForDay.any(
                        (e) =>
                            e.type.toCalendarEventType() ==
                            CalendarEventType.meeting,
                      )) {
                        dots.add(eventTypeColor(CalendarEventType.meeting));
                      }
                      if (eventsForDay.any(
                        (e) =>
                            e.type.toCalendarEventType() ==
                            CalendarEventType.conferenceRoom,
                      )) {
                        dots.add(
                          eventTypeColor(CalendarEventType.conferenceRoom),
                        );
                      }

                      return GestureDetector(
                        onTap: () {
                          _onDateSelected(currentDate, sourceEvents);
                        },
                        child: _DayCell(
                          day: currentDate.day,
                          isToday: isToday,
                          isSelected: isSelected,
                          isOutOfMonth: false,
                          dots: dots,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        verticalSpacing(height: 16),
        // HORIZONTAL EVENTS LIST PER DATE
        _buildWeeklyEventsList(weekDates, sourceEvents),
      ],
    );
  }

  // WEEKLY EVENT LIST
  Widget _buildWeeklyEventsList(
    List<DateTime> weekDates,
    List<CalendarEventModel> sourceEvents,
  ) {
    final Map<DateTime, List<CalendarEventModel>> eventsByDate = {};
    for (final date in weekDates) {
      final allDayEvents = _eventsForDate(sourceEvents, date);

      // Apply type filter when specific filter selected
      final filterType = _mapSortTypeToEventType(selectedSortType);
      final dayEvents =
          filterType == null
              ? allDayEvents
              : allDayEvents
                  .where((e) => e.type.toCalendarEventType() == filterType)
                  .toList();

      if (dayEvents.isNotEmpty) {
        // Sort events by time
        dayEvents.sort((a, b) {
          final aTime = a.getStartTimeAsDateTime();
          final bTime = b.getStartTimeAsDateTime();
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          final aMinutes = aTime.hour * 60 + aTime.minute;
          final bMinutes = bTime.hour * 60 + bTime.minute;
          return aMinutes.compareTo(bMinutes);
        });
        eventsByDate[date] = dayEvents;
      }
    }

    // Find the maximum number of events in any day to determine height
    int maxEvents = 0;
    for (final date in weekDates) {
      final dayEvents = eventsByDate[date] ?? [];
      if (dayEvents.length > maxEvents) {
        maxEvents = dayEvents.length;
      }
    }

    if (maxEvents == 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No events for this week',
            style: AppTextStyle.ts14R(color: AppColor.grey),
          ),
        ),
      );
    }

    // Build vertical list of days, each with a horizontal list of events
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          weekDates.map((date) {
            final dayEvents = eventsByDate[date] ?? [];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date / day label (vertical list)
                  GestureDetector(
                    onTap: () => setState(() => selectedDate = date),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.transparent,
                          ),
                          child: Text(
                            DateFormat('EEE, d MMM').format(date),
                            style: AppTextStyle.ts12M(color: AppColor.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  verticalSpacing(height: 6),
                  // Events for this day (horizontal)
                  if (dayEvents.isEmpty)
                    Text(
                      'No events',
                      style: AppTextStyle.ts12R(color: AppColor.grey),
                    )
                  else
                    SizedBox(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              dayEvents
                                  .map(
                                    (event) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: _buildEventCardForCurrentFilter(
                                        event,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildEventCardForCurrentFilter(CalendarEventModel event) {
    switch (selectedSortType) {
      case null:
        return _buildHorizontalEventCard(event);
      case SortType.task:
        return _buildTaskCard(event);
      case SortType.meeting:
        return _buildMeetingCard(event);
      case SortType.conference:
        return _buildConferenceCard(event);
      case SortType.all:
        return _buildHorizontalEventCard(event);
    }
  }

  // HORIZONTAL CARD FOR EVENT.
  Widget _buildHorizontalEventCard(CalendarEventModel event) {
    final color = eventTypeColor(event.type.toCalendarEventType());
    final time = event.getStartTimeAsDateTime();
    final timeString = time != null
        ? DateFormat('h:mm a').format(time)
        : event.startTime ?? '';

    return Container(
      width: 200,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            event.type == "Conference Room Booking" ? (event.room ?? '') : (event.title),
            style: AppTextStyle.ts12M(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          verticalSpacing(height: 4),
          event.type == "Conference Room Booking"
              ? Text(
                event.title,
                style: AppTextStyle.ts12R(color: AppColor.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
              : Row(
                children: [
                  Text(
                    "Created By: ",
                    style: AppTextStyle.ts12R(color: AppColor.grey),
                  ),
                  Flexible(
                    child: Text(
                      event.createdBy ?? '',
                      style: AppTextStyle.ts12R(color: AppColor.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
          verticalSpacing(height: 4),
          Text(timeString, style: AppTextStyle.ts12R(color: AppColor.grey)),
        ],
      ),
    );
  }

  // FILTER CARD FOR TASK.
  Widget _buildTaskCard(CalendarEventModel event) {
    final deadline = event.deadlineDate != null
        ? formatDateTimeAsDDMMMYYYY(event.deadlineDate!)
        : '';

    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColor.primary, width: 0.3),
        color: AppColor.lightGreyBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Task Id- ${event.eventId}',
                style: AppTextStyle.ts14SB(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              horizontalSpacing(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.green,
                ),
              ),
              Spacer(),
              CustomIconButton(
                onPressed: () {
                  goRouter.pushNamed(AppRoutes.taskTransferHistory);
                },
                icon: Icon(Icons.history),
              ),
              horizontalSpacing(width: 4),
              CustomIconButton(
                onPressed: () {},
                icon: Icon(Icons.compare_arrows_outlined),
              ),
            ],
          ),
          verticalSpacing(height: 6),
          Text(
            'Project  :-  ${event.title}',
            style: AppTextStyle.ts12R(color: AppColor.black),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          verticalSpacing(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Deadline :-  $deadline',
                  style: AppTextStyle.ts12R(color: AppColor.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              horizontalSpacing(width: 4),
              Text(
                'Status :- ',
                style: AppTextStyle.ts12R(color: AppColor.grey),
              ),
              Text('Open', style: AppTextStyle.ts12R(color: AppColor.green)),
            ],
          ),
        ],
      ),
    );
  }

  // FILTER CARD FOR MEETING.
  Widget _buildMeetingCard(CalendarEventModel event) {
    final time = event.getStartTimeAsDateTime();
    final timeString = time != null
        ? DateFormat('h:mm a').format(time)
        : event.startTime ?? '';

    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColor.primary.withValues(alpha: .4),
          width: 0.8,
        ),
        color: AppColor.lightGreyBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Meeting', style: AppTextStyle.ts14M()),
          verticalSpacing(height: 4),
          Text(
            event.title,
            style: AppTextStyle.ts12R(color: AppColor.black),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          verticalSpacing(height: 4),
          Text(timeString, style: AppTextStyle.ts12R(color: AppColor.grey)),
        ],
      ),
    );
  }

  // FILTER CARD FOR CONFERENCE
  Widget _buildConferenceCard(CalendarEventModel event) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppColor.primary, width: 0.3),
        color: AppColor.lightGreyBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(event.room ?? '', style: AppTextStyle.ts14SB()),
          verticalSpacing(height: 4),
          Row(
            children: [
              Text("Title: ", style: AppTextStyle.ts12R(color: AppColor.grey)),
              Text(
                event.title,
                style: AppTextStyle.ts12R(color: AppColor.black),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Divider(color: AppColor.grey, thickness: .2),
          Row(
            children: [
              Text(
                "Date & Time: ",
                style: AppTextStyle.ts12R(color: AppColor.grey),
              ),
              Text(
                event.getEventDate() != null
                    ? formatDateTimeAsDDMMMYYYY(event.getEventDate()!)
                    : '',
                style: AppTextStyle.ts12R(color: AppColor.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Divider(color: AppColor.grey, thickness: .2),
          Row(
            children: [
              Text(
                "Created By: ",
                style: AppTextStyle.ts12R(color: AppColor.grey),
              ),
              Text(
                event.createdBy ?? '',
                style: AppTextStyle.ts12R(color: AppColor.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // EVENT TYPE CARD FOR INDICATION OF EVENT TYPE AND PRIORITY
  Widget _eventTypeWidget({required Color color, required String eventType}) {
    return Row(
      children: [
        Container(
          height: 8,
          width: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: color,
          ),
        ),
        horizontalSpacing(width: 5),
        Text(eventType, style: AppTextStyle.ts12M()),
      ],
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // WEEKLY HEADER
  Widget _buildWeekdayHeader() {
    const labels = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
          labels
              .map(
                (label) => Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: AppTextStyle.ts12SB(color: AppColor.grey),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isSelected;
  final bool isOutOfMonth;
  final List<Color> dots;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.isOutOfMonth,
    required this.dots,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected ? AppColor.mediumBlue : Colors.transparent;
    final textColor =
        isOutOfMonth
            ? AppColor.grey
            : isSelected
            ? Colors.white
            : Colors.black87;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border:
            isToday && !isSelected
                ? Border.all(color: AppColor.primary, width: 0.5)
                : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('$day', style: AppTextStyle.ts12M(color: textColor)),
          if (dots.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    dots
                        .take(3)
                        .map(
                          (color) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
