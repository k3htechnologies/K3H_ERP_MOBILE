import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // CUBIT
  late NotificationCubit _notificationCubit;

  // TEMP LIST TO READ NOTIFICATIONS
  List<int> notificationSelectedList = [];

  // SCROLL CONTROLLER
  late ScrollController _scrollController;
  Timer? _debounce;

  // PROJECT
  late ProjectModel project;

  @override
  void initState() {
    super.initState();
    // SCROLL CONTROLLER AND LISTENER
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    // CUBIT
    _notificationCubit = context.read<NotificationCubit>();
    project = getProject();
    _notificationCubit.getNotification(
      context: context,
      pageNumber: _notificationCubit.state.currentPage,
      pageSize: 10,
      projectId: project.projectId,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    if (notificationSelectedList.isNotEmpty) {
      _notificationCubit.readNotification(
        projectId: project.projectId,
        notificationIds: notificationSelectedList.join(","),
      );
    }
    super.dispose();
  }

  // PAGINATION
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_notificationCubit.state.isLoading! &&
        _notificationCubit.state.notificationList.length <
            _notificationCubit.state.totalNumberOfRecord) {
      // TO HANDLE MULTIPLE TIME API CALLS
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        _notificationCubit.getNotification(
          context: context,
          pageNumber: _notificationCubit.state.currentPage + 1,
          pageSize: 10,
          projectId: project.projectId,
        );
      });
    }
  }

  // SHOW DATE OR TIME LOGIC
  String formatNotificationTime(String createdDateString) {
    final createdDate = DateTime.parse(createdDateString);
    final now = DateTime.now();

    final isToday =
        createdDate.year == now.year &&
        createdDate.month == now.month &&
        createdDate.day == now.day;

    if (isToday) {
      final diff = now.difference(createdDate);
      if (diff.inHours >= 1) {
        return "${diff.inHours}hr ago";
      } else if (diff.inMinutes >= 1) {
        return "${diff.inMinutes}min ago";
      } else {
        return "Just now";
      }
    } else {
      return formatDateTimeAsDDMMMYYYY(createdDate);
    }
  }

  // MARK ALL NOTIFICATIONS AS READ
  void _markAllRead() async {
    await _notificationCubit.getNotification(
      context: context,
      pageNumber: 1,
      pageSize: _notificationCubit.state.totalNumberOfRecord,
      projectId: project.projectId,
    );

    // CLEAR PREVIOUS SELECTION
    notificationSelectedList.clear();

    final unreadIds =
        _notificationCubit.state.notificationList
            .where((e) => e.isRead != true)
            .map((e) => e.notificationId)
            .toList();

    notificationSelectedList.addAll(unreadIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60), // AppBar height
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColor.white,
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Back button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                    color: AppColor.black,
                  ),
                ),

                // Title
                Text("Notifications", style: AppTextStyle.ts20B()),

                const Spacer(),

                // Mark all as read
                BlocBuilder<NotificationCubit, NotificationState>(
                  builder: (context, state) {
                    if (state.notificationList.isEmpty) {
                      return const SizedBox();
                    }
                    return GestureDetector(
                      onTap: () => _markAllRead(),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            AppAssets.markAsReadIcon,
                            height: 18,
                            width: 18,
                          ),
                          horizontalSpacing(width: 6),
                          Text(
                            "mark all as read",
                            style: AppTextStyle.ts12R(color: AppColor.info),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          verticalSpacing(height: 20),
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state.notificationList.isEmpty) {
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppAssets.noDataImage,
                          height: 150,
                          width: 150,
                        ),
                        verticalSpacing(),
                        Text("No Data Available!", style: AppTextStyle.ts14B()),
                      ],
                    ),
                  ),
                );
              }
              return Expanded(
                child: ListView.separated(
                  controller: _scrollController,
                  itemCount: state.notificationList.length + 1,
                  separatorBuilder:
                      (context, index) =>
                          Divider(color: AppColor.grey.withValues(alpha: 0.3)),
                  itemBuilder: (context, index) {
                    if (index == state.notificationList.length) {
                      return state.notificationList.length <
                              state.totalNumberOfRecord
                          ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : const SizedBox.shrink();
                    }
                    final notification = state.notificationList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 15,
                      ),
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          return GestureDetector(
                            onTap: () {
                              if (!notification.isRead) {
                                notificationSelectedList.add(
                                  notification.notificationId,
                                );
                              }
                              setState(() {});
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      (notification.isRead != true &&
                                              !notificationSelectedList
                                                  .contains(
                                                    notification.notificationId,
                                                  ))
                                          ? Container(
                                            margin: EdgeInsets.only(top: 8),
                                            height: 6,
                                            width: 6,
                                            decoration: BoxDecoration(
                                              color: AppColor.slightDarkBlue,
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                          )
                                          : SizedBox(height: 6, width: 6),
                                      horizontalSpacing(),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              notification.title,
                                              style: AppTextStyle.ts16R(),
                                            ),
                                            Text(
                                              notification.description,
                                              style: AppTextStyle.ts12R(
                                                color: AppColor.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  formatNotificationTime(
                                    notification.createdDate.toString(),
                                  ),
                                  style: AppTextStyle.ts14R(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
