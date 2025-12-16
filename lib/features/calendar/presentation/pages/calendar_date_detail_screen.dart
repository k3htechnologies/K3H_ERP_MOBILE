import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/features/calendar/data/models/calendar_event.dart';
import 'package:k3h_erp_app/features/calendar/presentation/cubit/calendar_cubit.dart';
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

  List<CalendarEventModel> _sorted(List<CalendarEventModel> list) {
    final sorted = List<CalendarEventModel>.from(list);
    sorted.sort((a, b) {
      final aMinutes = a.time.hour * 60 + a.time.minute;
      final bMinutes = b.time.hour * 60 + b.time.minute;
      return aMinutes.compareTo(bMinutes);
    });
    return sorted;
  }

  Future<List<CalendarEventModel>> _fetchEventsForDate(DateTime date) async {
    // If it's the initial date, return the events from widget
    if (_isSameDate(date, widget.date)) {
      return widget.events;
    }

    // Fetch events for the specific date using separate API method
    // This uses dateDetailEvents which is separate from the main events list
    await _calendarCubit.getDateDetailEvents(
      context: context,
      date: date,
    );
    
    // Return events from dateDetailEvents (separate from main events list)
    return _calendarCubit.state.dateDetailEvents;
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM, yyyy').format(date);
  }

  String _formatTime(TimeOfDay time) {
    final dt = DateTime(0, 0, 0, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _changeDate(int days) async {
    final targetDate = _currentDate.add(Duration(days: days));
    setState(() {
      _isLoading = true;
      _currentDate = targetDate;
      _currentEvents = const [];
    });
    final fetched = await _fetchEventsForDate(targetDate);
    if (!mounted) return;
    setState(() {
      _currentEvents = _sorted(fetched);
      _isLoading = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentTime());
  }

  List<int> _timeSlots() {
    // FULL DAY: 12 AM to 11 PM (0-23)
    return List<int>.generate(24, (i) => i);
  }

  String _formatHour(int hour) {
    final dt = DateTime(0, 0, 0, hour);
    return DateFormat('hh a').format(dt);
  }

  void _ensureSlotKeys(int count) {
    if (_slotKeys.length != count) {
      _slotKeys = List<GlobalKey>.generate(count, (_) => GlobalKey());
    }
  }

  void _scrollToCurrentTime() {
    if (!_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentTime();
      });
      return;
    }

    final nowHour = DateTime.now().hour-2;
    if (nowHour < 0 || nowHour >= _slotKeys.length) return;

    final ctx = _slotKeys[nowHour].currentContext;
    if (ctx == null) return;

    // The list view’s render box
    final listBox = _scrollController.position.context.storageContext
        .findRenderObject() as RenderBox;

    // The item’s render box
    final itemBox = ctx.findRenderObject() as RenderBox;

    // Position of item relative to LIST, not the screen
    final itemOffset = itemBox.localToGlobal(Offset.zero, ancestor: listBox).dy;

    // Current scroll offset + item’s position in the list
    final targetOffset = _scrollController.offset + itemOffset - 20; // small padding

    final max = _scrollController.position.maxScrollExtent;
    final offset = targetOffset.clamp(0.0, max);

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slots = _timeSlots();
    _ensureSlotKeys(slots.length);
    final eventsByHour = <int, List<CalendarEventModel>>{};
    for (final e in _currentEvents) {
      eventsByHour.putIfAbsent(e.time.hour, () => []).add(e);
    }

    return Scaffold(
      appBar: CustomAppBarWithBackButton(screenTitle: "Details"),
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
                                const SizedBox(width: 8),
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
                                                          gradient:
                                                              LinearGradient(
                                                                colors: [
                                                                  eventTypeColor(
                                                                    event.type.toCalendarEventType(),
                                                                  ).withValues(
                                                                    alpha: 0.7,
                                                                  ),
                                                                  eventTypeColor(
                                                                    event.type.toCalendarEventType(),
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
                                                                  color:
                                                                      eventTypeColor(
                                                                        event
                                                                            .type.toCalendarEventType(),
                                                                      ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                ),
                                                              ),
                                                              const SizedBox(
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
                                                                    const SizedBox(
                                                                      height: 4,
                                                                    ),
                                                                    Text(
                                                                      _formatTime(
                                                                        TimeOfDay.fromDateTime(event.time)
                                                                      ),
                                                                      style: AppTextStyle.ts12SB(
                                                                        color:
                                                                            AppColor.darkGrey,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 4,
                                                                    ),
                                                                    Text(
                                                                      event
                                                                          .type
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
