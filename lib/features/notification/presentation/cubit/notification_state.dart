part of 'notification_cubit.dart';

class NotificationState extends BaseState {
  final List<NotificationModel> notificationList;
  final int totalNumberOfRecord;
  final int currentPage;
  const NotificationState({
    required this.notificationList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    super.isLoading,
  });

  factory NotificationState.initial() => NotificationState(
    notificationList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    isLoading: true,
  );

  NotificationState copyWith({
    List<NotificationModel>? notificationList,
    bool? isLoading,
    int? totalNumberOfRecord,
    int? currentPage,
  }) {
    return NotificationState(
      notificationList: notificationList ?? this.notificationList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    notificationList,
    totalNumberOfRecord,
    currentPage,
  ];
}
