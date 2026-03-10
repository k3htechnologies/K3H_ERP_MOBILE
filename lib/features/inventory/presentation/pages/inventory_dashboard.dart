import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class InventoryDashboard extends StatefulWidget {
  const InventoryDashboard({super.key});

  @override
  State<InventoryDashboard> createState() => _InventoryDashboardState();
}

class _InventoryDashboardState extends State<InventoryDashboard> {
  late ProjectModel _selectedProject;
  @override
  void initState() {
    super.initState();
    _selectedProject = getProject();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightGreyBackground,
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Inventory",
        isMenuButton: true,
        authorization: AuthorizationModel(),
        onProjectChangeCallback: (value) {
          _selectedProject = value;
        },
        showNotification: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SELECTED PROJECT TEXT PROJECT CUSTOM TEXT FIELD (ONLY DISPLAY)
                    CustomTextField(
                      readOnly: true,
                      textController: TextEditingController(
                        text: _selectedProject.projectName,
                      ),
                      hint: 'Select Project',
                    ),
                    // GENERATE REPORT AND ADD BUTTON
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 5.0,
                            horizontal: 12.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0),
                            color: AppColor.lightBlue,
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                AppAssets.generateReportIcon,
                                width: 16,
                                height: 16,
                              ),
                              horizontalSpacing(),
                              Text(
                                "Generate Report",
                                style: AppTextStyle.ts14M(
                                  color: AppColor.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        horizontalSpacing(width: 20.0),
                        Expanded(
                          child: CustomButton(
                            leading: Icon(
                              Icons.add,
                              size: 18,
                              color: AppColor.white,
                            ),
                            text: "Add",
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    // TOTOAL BUILDING COUNT WIDGET
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 16.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: AppColor.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipOval(
                                child: NetworkImageWidget(
                                  imageUrl:
                                      'https://toppng.com/uploads/preview/immagini-divertenti-115510630433jfc6mpnb0.png',
                                  width: 42,
                                  height: 42,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              horizontalSpacing(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Total Buildings",
                                      style: AppTextStyle.ts14M(
                                        color: AppColor.black.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "10",
                                      style: AppTextStyle.ts20SB(
                                        color: AppColor.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    verticalSpacing(),
                    // BASEMENT AND PODIUM COUNT WIDGET
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 16.0,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: AppColor.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ClipOval(
                                      child: NetworkImageWidget(
                                        imageUrl:
                                            'https://toppng.com/uploads/preview/immagini-divertenti-115510630433jfc6mpnb0.png',
                                        width: 42,
                                        height: 42,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    horizontalSpacing(width: 16.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Basement",
                                            style: AppTextStyle.ts14M(
                                              color: AppColor.black.withValues(
                                                alpha: 0.5,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "02",
                                            style: AppTextStyle.ts20SB(
                                              color: AppColor.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        horizontalSpacing(),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 16.0,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: AppColor.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ClipOval(
                                      child: NetworkImageWidget(
                                        imageUrl:
                                            'https://toppng.com/uploads/preview/immagini-divertenti-115510630433jfc6mpnb0.png',
                                        width: 42,
                                        height: 42,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    horizontalSpacing(width: 16.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Podium",
                                            style: AppTextStyle.ts14M(
                                              color: AppColor.black.withValues(
                                                alpha: 0.5,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "04",
                                            style: AppTextStyle.ts20SB(
                                              color: AppColor.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    // WINGS AND FLOORS COUNT WIDGET
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 16.0,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: AppColor.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ClipOval(
                                      child: NetworkImageWidget(
                                        imageUrl:
                                            'https://toppng.com/uploads/preview/immagini-divertenti-115510630433jfc6mpnb0.png',
                                        width: 42,
                                        height: 42,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    horizontalSpacing(width: 16.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Wings",
                                            style: AppTextStyle.ts14M(
                                              color: AppColor.black.withValues(
                                                alpha: 0.5,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "40",
                                            style: AppTextStyle.ts20SB(
                                              color: AppColor.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        horizontalSpacing(),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 16.0,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: AppColor.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ClipOval(
                                      child: NetworkImageWidget(
                                        imageUrl:
                                            'https://toppng.com/uploads/preview/immagini-divertenti-115510630433jfc6mpnb0.png',
                                        width: 42,
                                        height: 42,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    horizontalSpacing(width: 16.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Floors",
                                            style: AppTextStyle.ts14M(
                                              color: AppColor.black.withValues(
                                                alpha: 0.5,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "120",
                                            style: AppTextStyle.ts20SB(
                                              color: AppColor.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    // UNIT STATUS DISTRIBUTION WIDGET
                    _buildUnitStatusDistributionWidget(context),
                    verticalSpacing(),
                    // PARKING DISTRIBUTION WIDGET
                    _buildParkingDistributionWidget(context),
                    verticalSpacing(),
                    // BUILDING OVERVIEW WIDGET
                    _buildBuildingOverviewWidget(context),
                    verticalSpacing(),
                    // ATLERT WIDGET
                    _buildAlertsWidget(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitStatusDistributionWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "Unit Status Distribution",
                  style: AppTextStyle.ts14M(
                    color: AppColor.black.withValues(alpha: 0.50),
                  ),
                ),
              ),
            ],
          ),
          verticalSpacing(height: 20),
          UnitStatusDistributionRadialChart(
            blocked: 100,
            allotted: 200,
            sold: 300,
            hold: 400,
            available: 500,
          ),
        ],
      ),
    );
  }

  Widget _buildParkingDistributionWidget(BuildContext context) {
    return Container(
      height: 300.0,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "Parking Distribution",
                  style: AppTextStyle.ts14M(
                    color: AppColor.black.withValues(alpha: 0.50),
                  ),
                ),
              ),
            ],
          ),
          verticalSpacing(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 6.0,
                      height: 6.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.0),
                        color: AppColor.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    horizontalSpacing(width: 6.0),
                    Text(
                      "Total Parking",
                      style: AppTextStyle.ts12R(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ],
                ),
              ),
              horizontalSpacing(width: 50.0),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 6.0,
                      height: 6.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.0),
                        color: AppColor.primary,
                      ),
                    ),
                    horizontalSpacing(width: 6.0),
                    Text(
                      "Available Parking",
                      style: AppTextStyle.ts12R(
                        color: AppColor.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpacing(height: 20.0),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, int index) {
                return _buildParkingRow(
                  title: "Basement 1",
                  used: 100,
                  total: 300,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingRow({
    required String title,
    required int used,
    required int total,
  }) {
    final double progress = total == 0 ? 0 : used / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyle.ts16M(
                  color: AppColor.black.withValues(alpha: 0.7),
                ),
              ),
              Text(
                "$used/$total",
                style: AppTextStyle.ts16M(
                  color: AppColor.black.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),

          verticalSpacing(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(4.0),
              backgroundColor: AppColor.primary.withValues(alpha: 0.25),
              valueColor: AlwaysStoppedAnimation(AppColor.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingOverviewWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "Building Overview",
                  style: AppTextStyle.ts14M(
                    color: AppColor.black.withValues(alpha: 0.50),
                  ),
                ),
              ),
            ],
          ),
          verticalSpacing(),
          ListView.builder(
            itemCount: 3,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, int index) {
              return Container(
                margin: EdgeInsets.only(bottom: 16.0),
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(width: 0.3, color: AppColor.primary),
                  color: AppColor.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Ratan Nagar 1", style: AppTextStyle.ts14SB()),
                    verticalSpacing(height: 20.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildOverviewItem("02", "Basement"),
                            _buildOverviewItem("02", "Podiums"),
                            _buildOverviewItem("05", "Wings"),
                          ],
                        ),
                        verticalSpacing(height: 20),
                        Row(
                          children: [
                            _buildOverviewItem("20", "Floor"),
                            _buildOverviewItem("400", "Units"),
                            _buildOverviewItem("800", "Parkings"),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyle.ts12M(
              color: AppColor.black.withValues(alpha: 0.50),
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyle.ts14M()),
        ],
      ),
    );
  }

  Widget _buildAlertsWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "Alerts",
                  style: AppTextStyle.ts14M(
                    color: AppColor.black.withValues(alpha: 0.50),
                  ),
                ),
              ),
            ],
          ),
          verticalSpacing(),
          ListView.builder(
            itemCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, int index) {
              return Container(
                margin: EdgeInsets.only(bottom: 6.0),
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                  color: AppColor.red.withValues(alpha: 0.1),
                  border: Border(
                    left: BorderSide(width: 4, color: AppColor.red),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Basement 2", style: AppTextStyle.ts16M()),
                    Text(
                      "87% Occupancy Reached In Building A",
                      style: AppTextStyle.ts14R(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class UnitStatusDistributionRadialChart extends StatelessWidget {
  final int blocked;
  final int allotted;
  final int sold;
  final int hold;
  final int available;

  const UnitStatusDistributionRadialChart({
    super.key,
    required this.blocked,
    required this.allotted,
    required this.sold,
    required this.hold,
    required this.available,
  });

  int get total => blocked + allotted + sold + hold + available;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: SizedBox(
            height: 120,
            width: 120,
            child: CustomPaint(
              painter: UnitRadialPainter(
                blocked: blocked,
                allotted: allotted,
                sold: sold,
                hold: hold,
                available: available,
              ),
            ),
          ),
        ),
        verticalSpacing(),
        Center(
          child: Text("Total Units : $total", style: AppTextStyle.ts16SB()),
        ),
        verticalSpacing(),

        _legendRow(AppColor.grey, "Blocked Units", blocked),
        const SizedBox(height: 14),
        _legendRow(AppColor.purple, "Allotted Units", allotted),
        const SizedBox(height: 14),
        _legendRow(AppColor.red, "Sold Units", sold),
        const SizedBox(height: 14),
        _legendRow(AppColor.yellow, "Hold Units", hold),
        const SizedBox(height: 14),
        _legendRow(AppColor.green, "Available Units", available),
      ],
    );
  }

  Widget _legendRow(Color color, String title, int value) {
    return Row(
      children: [
        Container(
          height: 6,
          width: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        horizontalSpacing(),

        Expanded(child: Text(title, style: AppTextStyle.ts14M(color: color))),

        Text(value.toString(), style: AppTextStyle.ts16B(color: color)),
      ],
    );
  }
}

class UnitRadialPainter extends CustomPainter {
  final int blocked;
  final int allotted;
  final int sold;
  final int hold;
  final int available;

  UnitRadialPainter({
    required this.blocked,
    required this.allotted,
    required this.sold,
    required this.hold,
    required this.available,
  });

  final double stroke = 20;
  final double gap = 25;

  @override
  void paint(Canvas canvas, Size size) {
    final total = blocked + allotted + sold + hold + available;
    if (total == 0) return;

    final center = size.center(Offset.zero);
    final radius = size.width / 2.4;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round;

    final usableDegrees = 360 - (gap * 5);
    double startAngle = -90;

    void drawSegment(int value, Color color) {
      if (value == 0) return;
      final sweep = (value / total) * usableDegrees;
      paint.color = color;
      canvas.drawArc(
        rect,
        _degToRad(startAngle),
        _degToRad(sweep),
        false,
        paint,
      );
      startAngle += sweep + gap;
    }

    drawSegment(sold, AppColor.red);
    drawSegment(allotted, AppColor.purple);
    drawSegment(blocked, AppColor.grey);
    drawSegment(hold, AppColor.yellow);
    drawSegment(available, AppColor.green);
  }

  double _degToRad(double deg) => deg * pi / 180;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
