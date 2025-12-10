import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/features/calendar/data/models/calendar_event.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime selectedDate;
  late DateTime visibleMonth;
  late List<CalendarEvent> events;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    visibleMonth = DateTime(selectedDate.year, selectedDate.month);
    events = _dummyEvents();
  }

  List<CalendarEvent> _dummyEvents() {
    final now = DateTime.now();
    return [
      CalendarEvent(
        title: "Daily standup",
        date: DateTime(now.year, now.month, now.day),
        time: const TimeOfDay(hour: 10, minute: 0),
        type: CalendarEventType.meeting,
      ),
      CalendarEvent(
        title: "Prep release notes",
        date: DateTime(now.year, now.month, now.day + 1),
        time: const TimeOfDay(hour: 14, minute: 0),
        type: CalendarEventType.task,
      ),
      CalendarEvent(
        title: "Client sync",
        date: DateTime(now.year, now.month, now.day + 2),
        time: const TimeOfDay(hour: 9, minute: 0),
        type: CalendarEventType.meeting,
      ),
      CalendarEvent(
        title: "Client sync",
        date: DateTime(now.year, now.month, now.day + 2),
        time: const TimeOfDay(hour: 10, minute: 0),
        type: CalendarEventType.meeting,
      ),
      CalendarEvent(
        title: "Client sync",
        date: DateTime(now.year, now.month, now.day + 2),
        time: const TimeOfDay(hour: 10, minute: 30),
        type: CalendarEventType.meeting,
      ),
      CalendarEvent(
        title: "Client sync",
        date: DateTime(now.year, now.month, now.day + 2),
        time: const TimeOfDay(hour: 11, minute: 0),
        type: CalendarEventType.meeting,
      ),
      CalendarEvent(
        title: "Client sync",
        date: DateTime(now.year, now.month, now.day + 2),
        time: const TimeOfDay(hour: 11, minute: 30),
        type: CalendarEventType.meeting,
      ),
      CalendarEvent(
        title: "Conference room booking",
        date: DateTime(now.year, now.month, now.day + 2),
        time: const TimeOfDay(hour: 15, minute: 30),
        type: CalendarEventType.conferenceRoom,
      ),
      CalendarEvent(
        title: "Prep release notes",
        date: DateTime(now.year, now.month, now.day + 2),
        time: const TimeOfDay(hour: 13, minute: 0),
        type: CalendarEventType.task,
      ),
      CalendarEvent(
        title: "Sprint review",
        date: DateTime(now.year, now.month, now.day + 5),
        time: const TimeOfDay(hour: 16, minute: 0),
        type: CalendarEventType.meeting,
      ),
      CalendarEvent(
        title: "Design handoff",
        date: DateTime(now.year, now.month, now.day + 8),
        time: const TimeOfDay(hour: 12, minute: 30),
        type: CalendarEventType.task,
      ),
      CalendarEvent(
        title: "Townhall",
        date: DateTime(now.year, now.month, now.day + 10),
        time: const TimeOfDay(hour: 17, minute: 0),
        type: CalendarEventType.conferenceRoom,
      ),
    ];
  }

  String _monthTitle(DateTime month) {
    return DateFormat('MMMM yyyy').format(month);
  }

  List<CalendarEvent> _eventsForDate(DateTime date) {
    return events.where((e) {
      return e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day;
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
  }

  void _goToNextMonth() {
    setState(() {
      visibleMonth = DateTime(visibleMonth.year, visibleMonth.month + 1);
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
    final selectedEvents = _eventsForDate(date);
    final payload = {
      'date': date.toIso8601String(),
      'events': selectedEvents.map((e) => e.toJson()).toList(),
    };
    final encrypted = EncryptionManager.encryptData(jsonEncode(payload));
    context.pushNamed(
      AppRoutes.calendarDetail,
      queryParameters: {
        'data': Uri.encodeComponent(encrypted),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final daysInMonth = _daysInMonth(visibleMonth);
    final startWeekday = firstDayOfMonth.weekday % 7; // Sunday -> 0
    final totalGridItems = startWeekday + daysInMonth;
    final rows = math.max(
      6,
      ((totalGridItems + 6) / 7).floor(),
    );
    final paddedItemCount = rows * 7;

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: (){
            goRouter.pop();
          },
          child: Icon(Icons.arrow_back),
        ),
        title: Text("Calendar"),
      ),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColor.lightBlue.withValues(alpha: .4),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric( vertical: 12),
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
                  Text(
                    _monthTitle(visibleMonth),
                    style: AppTextStyle.ts16SB(),
                  ),
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
              Flexible(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 8.0;
                    final totalSpacingX = spacing * 6; // gaps between 7 cols
                    final cellWidth =
                        (constraints.maxWidth - totalSpacingX) / 5.0;
                    final totalRowsSpacing = spacing * (rows - 1);
                    final rawCellHeight =
                        (constraints.maxHeight - totalRowsSpacing) / rows;
                    final aspectRatio = cellWidth / (rawCellHeight * 0.7);

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: spacing,
                        crossAxisSpacing: spacing,
                        childAspectRatio: aspectRatio,
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
                          final day =
                              prevMonthDays - (startWeekday - index) + 1;
                          currentDate =
                              DateTime(prevMonth.year, prevMonth.month, day);
                          isOutOfMonth = true;
                        } else if (index >= totalGridItems) {
                          final day = index - totalGridItems + 1;
                          final nextMonth = DateTime(
                            visibleMonth.year,
                            visibleMonth.month + 1,
                            1,
                          );
                          currentDate =
                              DateTime(nextMonth.year, nextMonth.month, day);
                          isOutOfMonth = true;
                        } else {
                          final day = index - startWeekday + 1;
                          currentDate = DateTime(
                            visibleMonth.year,
                            visibleMonth.month,
                            day,
                          );
                        }
                        final isToday = _isSameDate(
                          currentDate,
                          DateTime.now(),
                        );
                        final isSelected = _isSameDate(
                          currentDate,
                          selectedDate,
                        );
                        final eventsForDay = _eventsForDate(currentDate);
                        final dots = <Color>[];
                        if (eventsForDay.any((e) => e.type == CalendarEventType.task)) {
                          dots.add(eventTypeColor(CalendarEventType.task));
                        }
                        if (eventsForDay.any((e) => e.type == CalendarEventType.meeting)) {
                          dots.add(eventTypeColor(CalendarEventType.meeting));
                        }
                        if (eventsForDay.any((e) => e.type == CalendarEventType.conferenceRoom)) {
                          dots.add(eventTypeColor(CalendarEventType.conferenceRoom));
                        }

                        return GestureDetector(
                          onTap: () => _onDateSelected(currentDate),
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
              ),
            ],
          ),
        ),
      ),
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
    final textColor = isOutOfMonth
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
          Text(
            '$day',
            style: AppTextStyle.ts12M(color: textColor),
          ),
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
