part of 'attendance_cubit.dart';

class AttendanceState extends BaseState {
  final List<AttendanceModel> attendanceList;
  final int currentTabIndex;

  const AttendanceState({
    super.isLoading,
    required this.attendanceList,
    required this.currentTabIndex,
  });

  factory AttendanceState.initial() => AttendanceState(
    isLoading: true,
    attendanceList: [],
    currentTabIndex: 0,
  );

  AttendanceState copyWith({
    bool? isLoading,
    List<AttendanceModel>? attendanceList,
    int? currentTabIndex,
  }) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
      attendanceList: attendanceList ?? this.attendanceList,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    attendanceList,
    currentTabIndex,
  ];
}

