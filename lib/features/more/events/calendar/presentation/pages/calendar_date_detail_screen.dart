import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/more/events/calendar/data/models/calendar_event.dart';
import 'package:k3h_erp_app/features/more/events/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CalendarDateDetailScreen extends StatefulWidget {
  final DateTime date;
  final List<CalendarEventModel> events;

  const CalendarDateDetailScreen({
    super.key,
    required this.date,
    required this.events,
  });

  @override
  State<CalendarDateDetailScreen> createState() =>
      _CalendarDateDetailScreenState();
}

class _CalendarDateDetailScreenState extends State<CalendarDateDetailScreen> {
  late DateTime _currentDate;
  late List<CalendarEventModel> _currentEvents;
  bool _isLoading = false;
  List<GlobalKey> _slotKeys = [];
  final ScrollController _scrollController = ScrollController();

  // CUBIT
  late CalendarCubit _calendarCubit;

  @override
  void initState() {
    super.initState();
    _calendarCubit = context.read<CalendarCubit>();
    _currentDate = widget.date;
    _currentEvents = _sorted(widget.events);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentTime();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // SORT EVENTS
  List<CalendarEventModel> _sorted(List<CalendarEventModel> list) {
    final sorted = List<CalendarEventModel>.from(list);
    sorted.sort((a, b) {
      final aTime = a.getStartTimeAsDateTime();
      final bTime = b.getStartTimeAsDateTime();
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      final aMinutes = aTime.hour * 60 + aTime.minute;
      final bMinutes = bTime.hour * 60 + bTime.minute;
      return aMinutes.compareTo(bMinutes);
    });
    return sorted;
  }

  // FETCH EVENTS FOR DATE
  Future<List<CalendarEventModel>> _fetchEventsForDate(DateTime date) async {
    // If it's the initial date, return the events from widget
    if (_isSameDate(date, widget.date)) {
      return widget.events;
    }

    await _calendarCubit.getDateDetailEvents(context: context, date: date);

    final events = _calendarCubit.state.dateDetailEvents;
    return events;
  }

  // FORMAT DATE
  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM, yyyy').format(date);
  }

  // FORMAT TIME
  String _formatTime(TimeOfDay time) {
    final dt = DateTime(0, 0, 0, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  // CHECK IF DATES ARE SAME
  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // CHANGE DATE
  Future<void> _changeDate(int days) async {
    final targetDate = _currentDate.add(Duration(days: days));

    setState(() {
      _isLoading = true;
      _currentDate = targetDate;
      _currentEvents = const [];
    });

    await Future.delayed(const Duration(milliseconds: 50));

    try {
      final fetched = await _fetchEventsForDate(targetDate);
      if (!mounted) return;

      final filteredEvents =
          fetched.where((event) {
            final eventDate = event.getEventDate();
            if (eventDate == null) return false;
            return eventDate.year == targetDate.year &&
                eventDate.month == targetDate.month &&
                eventDate.day == targetDate.day;
          }).toList();

      setState(() {
        _currentEvents = _sorted(filteredEvents);
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToCurrentTime(),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _currentEvents = const [];
        _isLoading = false;
      });
    }
  }

  // TIME SLOTS
  List<int> _timeSlots() {
    // FULL DAY: 12 AM to 11 PM (0-23)
    return List<int>.generate(24, (i) => i);
  }

  // FORMAT HOUR
  String _formatHour(int hour) {
    final dt = DateTime(0, 0, 0, hour);
    return DateFormat('hh a').format(dt);
  }

  // ENSURE SLOT KEYS
  void _ensureSlotKeys(int count) {
    if (_slotKeys.length != count) {
      _slotKeys = List<GlobalKey>.generate(count, (_) => GlobalKey());
    }
  }

  // SCROLL TO CURRENT TIME
  void _scrollToCurrentTime() {
    if (!_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentTime();
      });
      return;
    }

    final nowHour = DateTime.now().hour - 2;
    if (nowHour < 0 || nowHour >= _slotKeys.length) return;

    final ctx = _slotKeys[nowHour].currentContext;
    if (ctx == null) return;

    final listBox =
        _scrollController.position.context.storageContext.findRenderObject()
            as RenderBox;

    final itemBox = ctx.findRenderObject() as RenderBox;

    final itemOffset = itemBox.localToGlobal(Offset.zero, ancestor: listBox).dy;

    final targetOffset = _scrollController.offset + itemOffset - 20;

    final max = _scrollController.position.maxScrollExtent;
    final offset = targetOffset.clamp(0.0, max);

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final slots = _timeSlots();
    _ensureSlotKeys(slots.length);
    final eventsByHour = <int, List<CalendarEventModel>>{};
    final eventsWithoutTime = <CalendarEventModel>[];

    for (final e in _currentEvents) {
      final time = e.getStartTimeAsDateTime();
      if (time != null) {
        eventsByHour.putIfAbsent(time.hour, () => []).add(e);
      } else {
        // Events without time (like tasks) - add to a special list or first hour
        eventsWithoutTime.add(e);
      }
    }

    // Add events without time to hour 0 (midnight) or first available slot
    if (eventsWithoutTime.isNotEmpty) {
      eventsByHour.putIfAbsent(0, () => []).addAll(eventsWithoutTime);
    }

    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Details",
        authorization: AuthorizationModel(isAction: true),
      ),
      body: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: AppColor.grey,
                ),
                onPressed: () => _changeDate(-1),
              ),
              Text(
                _formatDate(_currentDate),
                style: AppTextStyle.ts16SB(color: AppColor.mediumBlue),
              ),
              IconButton(
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: AppColor.grey,
                ),
                onPressed: () => _changeDate(1),
              ),
            ],
          ),
          verticalSpacing(),
          Expanded(
            child: ColoredBox(
              color: AppColor.lightBlue.withValues(alpha: .4),
              child:
                  _isLoading
                      ? loader()
                      : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        itemCount: slots.length,
                        itemBuilder: (_, index) {
                          final hour = slots[index];
                          final hourEvents = eventsByHour[hour] ?? [];
                          return Container(
                            key: _slotKeys[index],
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    _formatHour(hour),
                                    style: AppTextStyle.ts12SB(
                                      color: AppColor.grey,
                                    ),
                                  ),
                                ),
                                horizontalSpacing(width: 8),
                                Expanded(
                                  child:
                                      hourEvents.isEmpty
                                          ? Container(
                                            height: 1,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.grey.shade300,
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                          )
                                          : Column(
                                            children:
                                                hourEvents
                                                    .map(
                                                      (event) => Container(
                                                        margin:
                                                            const EdgeInsets.only(
                                                              bottom: 8,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            colors: [
                                                              eventTypeColor(
                                                                event.type
                                                                    .toCalendarEventType(),
                                                              ).withValues(
                                                                alpha: 0.7,
                                                              ),
                                                              eventTypeColor(
                                                                event.type
                                                                    .toCalendarEventType(),
                                                              ).withValues(
                                                                alpha: 0.4,
                                                              ),
                                                            ],
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        padding:
                                                            const EdgeInsets.all(
                                                              12,
                                                            ),
                                                        child: IntrinsicHeight(
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                width: 6,
                                                                decoration: BoxDecoration(
                                                                  color: eventTypeColor(
                                                                    event.type
                                                                        .toCalendarEventType(),
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                ),
                                                              ),
                                                              horizontalSpacing(
                                                                width: 8,
                                                              ),
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      event
                                                                          .title,
                                                                      style:
                                                                          AppTextStyle.ts16SB(),
                                                                    ),
                                                                    verticalSpacing(
                                                                      height: 4,
                                                                    ),
                                                                    Text(
                                                                      _formatTime(
                                                                        event.getStartTimeAsDateTime() !=
                                                                                null
                                                                            ? TimeOfDay.fromDateTime(
                                                                              event.getStartTimeAsDateTime()!,
                                                                            )
                                                                            : TimeOfDay.now(),
                                                                      ),
                                                                      style: AppTextStyle.ts12SB(
                                                                        color:
                                                                            AppColor.darkGrey,
                                                                      ),
                                                                    ),
                                                                    verticalSpacing(
                                                                      height: 4,
                                                                    ),
                                                                    Text(
                                                                      event.type
                                                                          .toUpperCase(),
                                                                      style: AppTextStyle.ts12SB(
                                                                        color:
                                                                            AppColor.darkGrey,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                          ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
