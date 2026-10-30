// ignore_for_file: use_build_context_synchronously

part of '../dashboard_screen.dart';

extension _WorkOverview on _DashboardScreenState {
  Widget _buildWordayOverviewWidget(
    DashboardState state,
    BuildContext context,
  ) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state.isLoading == true && !isProcessingNotifier.value) {
          return Center(child: loader());
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: commonCardDecoration(),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Workday Overview",
                        style: AppTextStyle.ts14M(
                          color: AppColor.black.withValues(alpha: 0.50),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          color: AppColor.primary.withValues(alpha: 0.13),
                        ),
                        child: Center(
                          child: Text(
                            dateFormatterDDMMYYYYDAY(
                              DateTime.now(),
                              isDayNotRequired: true,
                            ),
                            style: AppTextStyle.ts12M(color: AppColor.primary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  thickness: 0.3,
                  color: AppColor.black.withValues(alpha: 0.50),
                ),
                Container(
                  margin: EdgeInsets.only(top: 32),
                  alignment: Alignment.center,
                  child: ValueListenableBuilder<Duration>(
                    valueListenable: workedDuration,
                    builder: (context, duration, _) {
                      return RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: formatDuration(duration),
                              style: AppTextStyle.ts24SB().copyWith(
                                fontFamily: "semibold",
                                fontSize: 34,
                                color: AppColor.black,
                              ),
                            ),
                            TextSpan(
                              text: "/\n9:00:00",
                              style: AppTextStyle.ts12M().copyWith(
                                color: AppColor.black.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ValueListenableBuilder2<bool, bool>(
                  first: isPunchedInNotifier,
                  second: isSwipeDisabledNotifier,
                  builder: (context, isPunchedIn, isSwipeDisabled, _) {
                    final isCurrentlyPunchedIn =
                        isPunchedInNotifier.value &&
                        !isDayCompletedNotifier.value;
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final sliderWidth = constraints.maxWidth;
                        final thumbWidth = 52.0;

                        maxWidth = sliderWidth - thumbWidth;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final targetPosition =
                              isCurrentlyPunchedIn ? maxWidth : 0.0;

                          if (dragPositionNotifier.value != targetPosition) {
                            dragPositionNotifier.value = targetPosition;
                          }
                        });
                        return StatefulBuilder(
                          builder: (context, setInnerState) {
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 24.0,
                              ),
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color:
                                    isSwipeDisabled
                                        ? AppColor.lightGrey
                                        : AppColor.primary.withValues(
                                          alpha: 0.12,
                                        ),
                              ),
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  Center(
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: Text(
                                        isCurrentlyPunchedIn
                                            ? "Swipe to Punch Out"
                                            : "Swipe to Punch In",
                                        key: ValueKey(isCurrentlyPunchedIn),
                                        style: AppTextStyle.ts12B(
                                          color:
                                              isSwipeDisabled
                                                  ? AppColor.grey
                                                  : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                  ValueListenableBuilder<double>(
                                    valueListenable: dragPositionNotifier,
                                    builder: (context, dragPosition, _) {
                                      return AnimatedPositioned(
                                        duration: const Duration(
                                          milliseconds: 120,
                                        ),
                                        curve: Curves.easeOut,
                                        left: dragPosition,
                                        top: 2,
                                        bottom: 2,
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onHorizontalDragUpdate:
                                              isSwipeDisabled
                                                  ? null
                                                  : (details) {
                                                    if (isProcessingNotifier
                                                        .value) {
                                                      return;
                                                    }

                                                    final updated =
                                                        dragPositionNotifier
                                                            .value +
                                                        details.delta.dx;

                                                    dragPositionNotifier
                                                        .value = updated.clamp(
                                                      0.0,
                                                      maxWidth,
                                                    );
                                                  },
                                          onHorizontalDragEnd:
                                              isSwipeDisabled
                                                  ? null
                                                  : (details) => _onSwipeEnd(
                                                    context,
                                                    details,
                                                    isCurrentlyPunchedIn,
                                                  ),
                                          child: Container(
                                            width: thumbWidth,
                                            decoration: BoxDecoration(
                                              color:
                                                  isSwipeDisabled
                                                      ? AppColor.grey50
                                                      : AppColor.primary,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              boxShadow: [
                                                BoxShadow(
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                  color: AppColor.black
                                                      .withValues(alpha: 0.15),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              isCurrentlyPunchedIn
                                                  ? Icons.arrow_back_ios_new
                                                  : Icons
                                                      .arrow_forward_ios_sharp,
                                              color: AppColor.white,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                _buildDashboardPunchInPunchOutWidget(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onSwipeEnd(
    BuildContext context,
    DragEndDetails details,
    bool isCurrentlyPunchedIn,
  ) async {
    if (isProcessingNotifier.value) return;

    final velocity = details.primaryVelocity ?? 0;
    final current = dragPositionNotifier.value;

    final shouldComplete = current > maxWidth * 0.55 || velocity > 700;

    // PUNCH IN
    if (!isCurrentlyPunchedIn &&
        shouldComplete &&
        !isDayCompletedNotifier.value &&
        currentAttendanceId == null) {
      final hasPermission = await _ensureLocationPermission(context);

      if (!hasPermission) {
        dragPositionNotifier.value = 0;
        return;
      }

      // overlay shows immediately, before GPS / address / API work
      isProcessingNotifier.value = true;

      try {
        dragPositionNotifier.value = maxWidth;

        await Future.delayed(const Duration(milliseconds: 150));

        final success = await punchIn(context);

        if (success) {
          isPunchedInNotifier.value = true;
          _startTimerFrom(DateTime.now());
          dragPositionNotifier.value = maxWidth;
          HapticFeedback.mediumImpact();
        } else {
          isPunchedInNotifier.value = false;
          dragPositionNotifier.value = 0;
        }

        HapticFeedback.mediumImpact();
      } finally {
        if (mounted) isProcessingNotifier.value = false;
      }
    }
    // PUNCH OUT
    else if (isCurrentlyPunchedIn) {
      final shouldPunchOut = current < maxWidth * 0.45 || velocity < -700;

      if (shouldPunchOut) {
        if (!canPunchOut()) {
          showErrorMessage(
            context,
            "Punch Out Not Allowed",
            "Minimum working duration is 1 hour.",
          );

          dragPositionNotifier.value = maxWidth;
          return;
        }

        isProcessingNotifier.value = true;

        try {
          dragPositionNotifier.value = 0;

          await Future.delayed(const Duration(milliseconds: 150));

          if (context.mounted) {
            await punchOut(context);
          }
          isSwipeDisabledNotifier.value = true;
          isDayCompletedNotifier.value = true;
          isPunchedInNotifier.value = false;
          await initialise();
          HapticFeedback.mediumImpact();
        } finally {
          if (mounted) isProcessingNotifier.value = false;
        }
      } else {
        dragPositionNotifier.value = maxWidth;
      }
    }
    // RESET
    else {
      dragPositionNotifier.value = isCurrentlyPunchedIn ? maxWidth : 0;
    }
  }

  Widget _buildDashboardPunchInPunchOutWidget(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final bool hasLocation =
            state.data != null &&
            state.data!.startLatitude != 0 &&
            state.data!.startLongitude != 0 &&
            state.data!.endLatitude != 0 &&
            state.data!.endLongitude != 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Punch In : ',
                    style: AppTextStyle.ts14M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                  TextSpan(
                    text:
                        (state.data != null && state.data?.punchIn != null)
                            ? DateFormat('hh:mm a').format(state.data!.punchIn!)
                            : "--",
                    style: AppTextStyle.ts14M(color: AppColor.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '',
                    style: AppTextStyle.ts14M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                  TextSpan(
                    text:
                        (state.data != null &&
                                state.data!.punchInAddress.isNotEmpty)
                            ? state.data!.punchInAddress
                            : "--",
                    style: AppTextStyle.ts14M(color: AppColor.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Punch Out : ',
                    style: AppTextStyle.ts14M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                  TextSpan(
                    text:
                        (state.data != null && state.data?.punchOut != null)
                            ? DateFormat(
                              'hh:mm a',
                            ).format(state.data!.punchOut!)
                            : "--",
                    style: AppTextStyle.ts14M(color: AppColor.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '',
                    style: AppTextStyle.ts14M(
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                  ),
                  TextSpan(
                    text:
                        (state.data != null &&
                                state.data!.punchOutAddress.isNotEmpty)
                            ? state.data!.punchOutAddress
                            : "--",
                    style: AppTextStyle.ts14M(color: AppColor.black),
                  ),
                ],
              ),
            ),
            if (hasLocation) ...[
              verticalSpacing(height: 5),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => MapScreen(
                            startLatitude: state.data!.startLatitude,
                            startLongitude: state.data!.startLongitude,
                            endLatitude: state.data!.endLatitude,
                            endLongitude: state.data!.endLongitude,
                            polyline: state.data!.polyline,
                            distance: state.data!.distance.toDouble(),
                            attendanceDataModel: state.data!,
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
            ],
          ],
        );
      },
    );
  }
}
