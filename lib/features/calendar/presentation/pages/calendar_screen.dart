import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/calendar/data/models/calendar_event.dart'
    show
        CalendarEventModel,
        CalendarEventType,
        eventTypeColor,
        CalendarEventTypeMapper;
import 'package:k3h_erp_app/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime selectedDate;
  late DateTime visibleMonth;
  late DateTime visibleWeek; // Start of the visible week (Sunday)

  int _selectedTabIndex = 0;

  // CUBIT
  late CalendarCubit _calendarCubit;

  @override
  void initState() {
    super.initState();
    _calendarCubit = context.read<CalendarCubit>();
    selectedDate = DateTime.now();
    visibleMonth = DateTime(selectedDate.year, selectedDate.month);
    // Set visibleWeek to the start of the current week (Sunday)
    final now = DateTime.now();
    final daysFromSunday = now.weekday % 7;
    visibleWeek = DateTime(now.year, now.month, now.day - daysFromSunday);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMonthEvents();
    });
  }

  void _fetchMonthEvents() {
    final start = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final end = DateTime(visibleMonth.year, visibleMonth.month + 1, 0, 23, 59);
    context.read<CalendarCubit>().getEvents(
      context: context,
      fromDate: start,
      toDate: end,
    );
  }

  String _monthTitle(DateTime month) {
    return DateFormat('MMMM yyyy').format(month);
  }

  List<CalendarEventModel> _eventsForDate(
    List<CalendarEventModel> source,
    DateTime date,
  ) {
    return source.where((e) {
      final d = e.date;
      return d.year == date.year && d.month == date.month && d.day == date.day;
    }).toList();
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
    if (_selectedTabIndex == 1) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Calendar",
        authorization: AuthorizationModel(isAction: true),
        onAddCallback: () {},
      ),
      body: SafeArea(
        child: BlocBuilder<CalendarCubit, CalendarState>(
          builder: (context, calState) {
            if(calState.isLoading==true){
              return loader();
            }
            final sourceEvents = calState.events;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _eventTypeWidget(
                        color: AppColor.error,
                        eventType: "Task",
                      ),
                      const SizedBox(width: 10),
                      _eventTypeWidget(
                        color: AppColor.mediumBlue,
                        eventType: "Meeting",
                      ),
                      const SizedBox(width: 10),
                      _eventTypeWidget(
                        color: AppColor.warning,
                        eventType: "Conference Room",
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
                  CustomButton.add(
                    onPressed: () {
                      goRouter.pushNamed(AppRoutes.addDetailsCalendar);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

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

  Widget _buildMonthlyEventsList(List<CalendarEventModel> sourceEvents) {
    final selectedEvents = _eventsForDate(sourceEvents, selectedDate);

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
        final aMinutes = a.time.hour * 60 + a.time.minute;
        final bMinutes = b.time.hour * 60 + b.time.minute;
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
                  height: 80,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          typeEvents
                              .map(
                                (event) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _buildHorizontalEventCard(event),
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
      ],
    );
  }

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
                        onTap: () => _onDateSelected(currentDate, sourceEvents),
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

  Widget _buildWeeklyEventsList(
    List<DateTime> weekDates,
    List<CalendarEventModel> sourceEvents,
  ) {
    // Group events by date for the week
    final Map<DateTime, List<CalendarEventModel>> eventsByDate = {};
    for (final date in weekDates) {
      final dayEvents = _eventsForDate(sourceEvents, date);
      if (dayEvents.isNotEmpty) {
        // Sort events by time
        dayEvents.sort((a, b) {
          final aMinutes = a.time.hour * 60 + a.time.minute;
          final bMinutes = b.time.hour * 60 + b.time.minute;
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
                      height: 80,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              dayEvents
                                  .map(
                                    (event) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: _buildHorizontalEventCard(event),
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

  Widget _buildHorizontalEventCard(CalendarEventModel event) {
    final color = eventTypeColor(event.type.toCalendarEventType());
    final timeString = DateFormat(
      'h:mm a',
    ).format(DateTime(2000, 1, 1, event.time.hour, event.time.minute));

    return Container(
      width: 150,
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
            event.title,
            style: AppTextStyle.ts12M(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          verticalSpacing(height: 4),
          Text(timeString, style: AppTextStyle.ts12R(color: AppColor.grey)),
        ],
      ),
    );
  }

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
