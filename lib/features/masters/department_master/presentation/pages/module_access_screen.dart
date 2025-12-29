import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/module.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/model/designation.model.dart';
import 'package:k3h_erp_app/features/masters/designation_master/presentation/cubit/designation_master_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ModuleAccessScreen extends StatefulWidget {
  final DesignationMasterModel designation;
  const ModuleAccessScreen({super.key, required this.designation});

  @override
  State<ModuleAccessScreen> createState() => _ModuleAccessScreenState();
}

class _ModuleAccessScreenState extends State<ModuleAccessScreen> {
  // INITIALIZING LIST
  final List<ModuleModel> modulePermissionsList = [];

  List<Map<String, dynamic>> savedPermissionsList = [];

  late DesignationMasterCubit _designationMasterCubit;

  @override
  void initState() {
    super.initState();
    _designationMasterCubit = context.read<DesignationMasterCubit>();
    // Only fetch if we don't already have data for this specific designation,
    // to preserve unsaved changes when navigating back
    final currentState = _designationMasterCubit.state;
    final currentDesignationId = widget.designation.designationMasterId;

    // Only fetch if:
    // 1. We don't have any data, OR
    // 2. The state type doesn't match, OR
    // 3. We have data but it's for a different designation
    if (currentState.modulesPermissionsList.isEmpty ||
        currentState.stateType != StateType.employeeMasterModuleAccessState ||
        currentState.currentDesignationId != currentDesignationId) {
      _designationMasterCubit.getModulesPermissions(
        context,
        currentDesignationId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: 'Designation',
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: BlocBuilder<DesignationMasterCubit, DesignationMasterState>(
          // Remove buildWhen to always rebuild on any state change
          builder: (context, state) {
            // Show loader if loading
            if (state.isLoading == true) {
              return Center(child: loader());
            }

            // If stateType doesn't match, show loader (waiting for correct state)
            if (state.stateType != StateType.employeeMasterModuleAccessState) {
              return Center(child: loader());
            }

            // Check for empty list only when in correct state and not loading
            if (state.modulesPermissionsList.isEmpty) {
              return Center(child: noDataWidget());
            }

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Designation Name Header
                  Text(
                    widget.designation.designationName,
                    style: AppTextStyle.ts16SB(),
                  ),
                  verticalSpacing(),
                  // Select All Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Select All', style: AppTextStyle.ts14M()),
                      BlocBuilder<
                        DesignationMasterCubit,
                        DesignationMasterState
                      >(
                        builder: (context, state) {
                          return CustomCheckBox(
                            key: ValueKey('selectAll_${state.isAllSelected}'),
                            isSelected: state.isAllSelected,
                            onChanged: (value) {
                              _designationMasterCubit.updateRow(
                                null,
                                null,
                                null,
                                value,
                                null,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  verticalSpacing(),
                  // Search Bar
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColor.grey10,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColor.grey30, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, size: 20, color: AppColor.grey),
                        horizontalSpacing(),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search',
                              border: InputBorder.none,
                              hintStyle: AppTextStyle.ts14R(
                                color: AppColor.grey,
                              ),
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: AppTextStyle.ts14R(),
                            onChanged: (value) {
                              // TODO: Implement search functionality if needed
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  verticalSpacing(),
                  // Modules List
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (
                            int i = 0;
                            i < state.modulesPermissionsList.length;
                            i++
                          )
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: ModuleAccessTile(
                                module: state.modulesPermissionsList[i],
                                index: i,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: CustomButton(
            text: 'Update',
            onPressed: () async {
              await _designationMasterCubit.updateModulesPermissions(
                designationMasterId: widget.designation.designationMasterId,
                context: context,
              );
            },
          ),
        ),
      ),
    );
  }
}

class ModuleAccessTile extends StatefulWidget {
  final ModuleModel module;
  final int index;
  const ModuleAccessTile({
    super.key,
    required this.module,
    required this.index,
  });

  @override
  State<ModuleAccessTile> createState() => _ModuleAccessTileState();
}

class _ModuleAccessTileState extends State<ModuleAccessTile> {
  bool isExpanded = false;
  late DesignationMasterCubit _designationMasterCubit;

  @override
  void initState() {
    super.initState();
    _designationMasterCubit = context.read<DesignationMasterCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColor.grey30, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: ColoredBox(
              color: Color(0xFFFCFCFC),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.module.moduleName,
                              style: AppTextStyle.ts16M(),
                            ),
                          ),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              size: 24,
                              color: AppColor.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    BlocBuilder<DesignationMasterCubit, DesignationMasterState>(
                      // Remove buildWhen to always rebuild on any state change
                      builder: (context, state) {
                        if (state.modulesPermissionsList.length <=
                            widget.index) {
                          return SizedBox.shrink();
                        }
                        final module =
                            state.modulesPermissionsList[widget.index];
                        return CustomCheckBox(
                          key: ValueKey(
                            '${module.moduleName}_${module.isSelected}',
                          ),
                          isSelected: module.isSelected,
                          onChanged: (value) {
                            _designationMasterCubit.updateRow(
                              widget.index,
                              null,
                              null,
                              value,
                              null,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isExpanded)
            BlocBuilder<DesignationMasterCubit, DesignationMasterState>(
              // Remove buildWhen to always rebuild on any state change
              builder: (context, state) {
                // Safety check
                if (state.modulesPermissionsList.length <= widget.index) {
                  return SizedBox.shrink();
                }

                final module = state.modulesPermissionsList[widget.index];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(height: 0.5, color: AppColor.grey30),
                    // Column Headers Row
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      color: AppColor.grey10,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: SizedBox(), // Space for sub-module name
                          ),
                          Expanded(
                            child: Text(
                              'Action',
                              style: AppTextStyle.ts14M(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Export',
                              style: AppTextStyle.ts14M(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'View',
                              style: AppTextStyle.ts14M(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (int i = 0; i < module.subModuleData.length; i++)
                      SubModuleTile(
                        moduleIndex: widget.index,
                        subModuleIndex: i,
                        subModule: module.subModuleData[i],
                        isSubModuleSelected: module.subModuleData[i].isSelected,
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class SubModuleTile extends StatefulWidget {
  final int moduleIndex;
  final int subModuleIndex;
  final SubModuleModel subModule;
  final bool isSubModuleSelected;
  const SubModuleTile({
    super.key,
    required this.moduleIndex,
    required this.subModuleIndex,
    required this.subModule,
    required this.isSubModuleSelected,
  });

  @override
  State<SubModuleTile> createState() => _SubModuleTileState();
}

class _SubModuleTileState extends State<SubModuleTile> {
  bool isExpanded = false;
  late DesignationMasterCubit _designationMasterCubit;

  @override
  void initState() {
    super.initState();
    _designationMasterCubit = context.read<DesignationMasterCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DesignationMasterCubit, DesignationMasterState>(
      // Remove buildWhen to always rebuild when state changes
      builder: (context, state) {
        // Safety check
        if (state.modulesPermissionsList.length <= widget.moduleIndex ||
            state
                    .modulesPermissionsList[widget.moduleIndex]
                    .subModuleData
                    .length <=
                widget.subModuleIndex) {
          return SizedBox.shrink();
        }

        final subModule =
            state
                .modulesPermissionsList[widget.moduleIndex]
                .subModuleData[widget.subModuleIndex];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Row(
                children: [
                  // Sub-module name only (no checkbox for submodule) - with InkWell only on this part
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap:
                          subModule.subSubModuleData.isEmpty
                              ? null
                              : () {
                                setState(() {
                                  isExpanded = !isExpanded;
                                });
                              },
                      child: Row(
                        children: [
                          // Expand arrow if has sub-sub-modules
                          if (subModule.subSubModuleData.isNotEmpty)
                            AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                size: 20,
                                color: AppColor.primary,
                              ),
                            ),
                          if (subModule.subSubModuleData.isNotEmpty)
                            horizontalSpacing(width: 8),
                          Expanded(
                            child: Text(
                              subModule.subModuleName,
                              style: AppTextStyle.ts14R(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Action/Export/View checkboxes aligned in columns - NOT inside InkWell
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomCheckBox(
                          key: ValueKey(
                            '${widget.moduleIndex}_${widget.subModuleIndex}_action_${subModule.isAction}',
                          ),
                          isSelected: subModule.isAction,
                          onChanged: (value) {
                            _designationMasterCubit.updateRow(
                              widget.moduleIndex,
                              widget.subModuleIndex,
                              null,
                              value,
                              'action',
                            );
                          },
                        ),
                        CustomCheckBox(
                          key: ValueKey(
                            '${widget.moduleIndex}_${widget.subModuleIndex}_export_${subModule.isExport}',
                          ),
                          isSelected: subModule.isExport,
                          onChanged: (value) {
                            _designationMasterCubit.updateRow(
                              widget.moduleIndex,
                              widget.subModuleIndex,
                              null,
                              value,
                              'export',
                            );
                          },
                        ),
                        CustomCheckBox(
                          key: ValueKey(
                            '${widget.moduleIndex}_${widget.subModuleIndex}_view_${subModule.isView}',
                          ),
                          isSelected: subModule.isView,
                          onChanged: (value) {
                            _designationMasterCubit.updateRow(
                              widget.moduleIndex,
                              widget.subModuleIndex,
                              null,
                              value,
                              'view',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Expanded sub-sub-modules
            if (isExpanded && subModule.subSubModuleData.isNotEmpty)
              ...subModule.subSubModuleData.asMap().entries.map((entry) {
                final i = entry.key;
                return BlocBuilder<
                  DesignationMasterCubit,
                  DesignationMasterState
                >(
                  // Remove buildWhen to always rebuild on any state change
                  builder: (context, state) {
                    // Safety check
                    if (state.modulesPermissionsList.length <=
                            widget.moduleIndex ||
                        state
                                .modulesPermissionsList[widget.moduleIndex]
                                .subModuleData
                                .length <=
                            widget.subModuleIndex) {
                      return SizedBox.shrink();
                    }

                    final currentSubModule =
                        state
                            .modulesPermissionsList[widget.moduleIndex]
                            .subModuleData[widget.subModuleIndex];

                    if (currentSubModule.subSubModuleData.length <= i) {
                      return SizedBox.shrink();
                    }

                    final currentSubSubModule =
                        currentSubModule.subSubModuleData[i];
                    return Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: EdgeInsets.only(left: 40),
                              child: Text(
                                currentSubSubModule.subSubModuleName,
                                style: AppTextStyle.ts14R(),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CustomCheckBox(
                                  key: ValueKey(
                                    '${widget.moduleIndex}_${widget.subModuleIndex}_${i}_action_${currentSubSubModule.isAction}',
                                  ),
                                  isSelected: currentSubSubModule.isAction,
                                  onChanged: (value) {
                                    _designationMasterCubit.updateRow(
                                      widget.moduleIndex,
                                      widget.subModuleIndex,
                                      i,
                                      value,
                                      'action',
                                    );
                                  },
                                ),
                                CustomCheckBox(
                                  key: ValueKey(
                                    '${widget.moduleIndex}_${widget.subModuleIndex}_${i}_export_${currentSubSubModule.isExport}',
                                  ),
                                  isSelected: currentSubSubModule.isExport,
                                  onChanged: (value) {
                                    _designationMasterCubit.updateRow(
                                      widget.moduleIndex,
                                      widget.subModuleIndex,
                                      i,
                                      value,
                                      'export',
                                    );
                                  },
                                ),
                                CustomCheckBox(
                                  key: ValueKey(
                                    '${widget.moduleIndex}_${widget.subModuleIndex}_${i}_view_${currentSubSubModule.isView}',
                                  ),
                                  isSelected: currentSubSubModule.isView,
                                  onChanged: (value) {
                                    _designationMasterCubit.updateRow(
                                      widget.moduleIndex,
                                      widget.subModuleIndex,
                                      i,
                                      value,
                                      'view',
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
          ],
        );
      },
    );
  }
}

class LinePainter extends CustomPainter {
  final bool isLast;
  LinePainter({this.isLast = false});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = AppColor.grey30
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke
          ..isAntiAlias = true;
    double halfSize = size.height / 2;
    // First draw the vertical line
    final Path verticalLine =
        Path()
          ..moveTo(3, 0)
          ..lineTo(3, isLast ? halfSize : size.height);
    canvas.drawPath(verticalLine, paint);

    // Then draw the rest
    final Path horizontalPath =
        Path()
          ..moveTo(3, halfSize)
          ..lineTo(14, halfSize);

    canvas.drawPath(horizontalPath, paint);

    final Path arrowPath =
        Path()
          ..moveTo(14, halfSize)
          ..lineTo(17, halfSize - 3)
          ..lineTo(20, halfSize)
          ..lineTo(17, halfSize + 3)
          ..close();

    final Paint paint2 =
        Paint()
          ..color = AppColor.grey30
          ..strokeWidth = 1
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;

    canvas.drawPath(arrowPath, paint2);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) => false;
}

class CustomCheckBox extends StatefulWidget {
  final bool isSelected;
  final String? title;
  final Function(bool)? onChanged;
  const CustomCheckBox({
    super.key,
    required this.isSelected,
    this.title,
    this.onChanged,
  });

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  @override
  void didUpdateWidget(CustomCheckBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update state when widget's isSelected changes
    if (oldWidget.isSelected != widget.isSelected) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 6.0,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (widget.onChanged != null) {
              widget.onChanged!(!widget.isSelected);
            }
          },
          child: Container(
            width: 22,
            height: 22,
            margin: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: widget.isSelected ? AppColor.green : AppColor.white,
              border:
                  widget.isSelected
                      ? null
                      : Border.all(color: AppColor.grey, width: 1.0),
              borderRadius: BorderRadius.circular(2),
            ),
            child:
                widget.isSelected
                    ? Icon(Icons.check, size: 18, color: AppColor.white)
                    : null,
          ),
        ),

        if (widget.title != null)
          Flexible(child: Text(widget.title!, style: AppTextStyle.ts14M())),
      ],
    );
  }
}
