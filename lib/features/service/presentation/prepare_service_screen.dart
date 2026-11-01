import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/vehicle_components.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/priority_badge.dart';
import '../../issues/data/issue_repository.dart';
import '../../issues/domain/issue_model.dart';
import '../data/service_repository.dart';

class PrepareServiceScreen extends ConsumerStatefulWidget {
  const PrepareServiceScreen({super.key});

  @override
  ConsumerState<PrepareServiceScreen> createState() => _PrepareServiceScreenState();
}

class _PrepareServiceScreenState extends ConsumerState<PrepareServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceCentreController = TextEditingController(text: 'MG Flagship EV Service Centre');
  final _odometerController = TextEditingController(text: '4850');
  final _additionalRequestsController = TextEditingController();

  DateTime _appointmentDate = DateTime.now();
  final Set<String> _selectedIssueIds = {};
  bool _isCreating = false;

  @override
  void dispose() {
    _serviceCentreController.dispose();
    _odometerController.dispose();
    _additionalRequestsController.dispose();
    super.dispose();
  }

  void _selectAll(List<IssueModel> issues) {
    setState(() {
      _selectedIssueIds.addAll(issues.map((i) => i.id));
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedIssueIds.clear();
    });
  }

  Future<void> _startServiceVisit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedIssueIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.critical,
          content: Text('Please select at least one vehicle issue for the service visit.'),
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final odometer = int.tryParse(_odometerController.text.trim()) ?? 0;
      final visitId = await ref.read(serviceRepositoryProvider).createServiceVisit(
            serviceCentre: _serviceCentreController.text.trim(),
            visitDate: _appointmentDate,
            odometerReading: odometer,
            selectedIssueIds: _selectedIssueIds.toList(),
            additionalRequests: _additionalRequestsController.text.trim().isNotEmpty
                ? _additionalRequestsController.text.trim()
                : null,
          );

      if (mounted) {
        context.pushReplacement('/service/visit/$visitId');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCreating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: AppColors.critical, content: Text('Error creating visit: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final issuesAsync = ref.watch(openIssuesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Prepare for Service'),
      ),
      body: SafeArea(
        child: issuesAsync.when(
          data: (openIssues) {
            final critical = openIssues.where((i) => i.priority == IssuePriority.critical).toList();
            final high = openIssues.where((i) => i.priority == IssuePriority.high).toList();
            final medium = openIssues.where((i) => i.priority == IssuePriority.medium).toList();
            final low = openIssues.where((i) => i.priority == IssuePriority.low).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Visit Meta Inputs
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.garage_rounded, color: AppColors.accent, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Service Appointment Details',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Service Centre
                          const Text('Service Centre Name', style: TextStyle(fontSize: 12, color: AppColors.secondaryText, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _serviceCentreController,
                            style: const TextStyle(color: AppColors.primaryText, fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'e.g. MG Authorized Service Hub',
                              prefixIcon: Icon(Icons.business_rounded, color: AppColors.secondaryText, size: 18),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Please enter service centre' : null,
                          ),
                          const SizedBox(height: 14),

                          // Odometer & Date
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Odometer (km)', style: TextStyle(fontSize: 12, color: AppColors.secondaryText, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _odometerController,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(color: AppColors.primaryText, fontSize: 14),
                                      decoration: const InputDecoration(
                                        hintText: 'e.g. 4850',
                                        prefixIcon: Icon(Icons.speed_rounded, color: AppColors.secondaryText, size: 18),
                                      ),
                                      validator: (v) => v == null || int.tryParse(v.trim()) == null ? 'Enter km' : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Visit Date', style: TextStyle(fontSize: 12, color: AppColors.secondaryText, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 6),
                                    InkWell(
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: _appointmentDate,
                                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                          lastDate: DateTime.now().add(const Duration(days: 90)),
                                        );
                                        if (picked != null) {
                                          setState(() => _appointmentDate = picked);
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                                        decoration: BoxDecoration(
                                          color: AppColors.elevatedSurface,
                                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                          border: Border.all(color: AppColors.cardBorder),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.accent),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                DateFormat('dd MMM yyyy').format(_appointmentDate),
                                                style: const TextStyle(color: AppColors.primaryText, fontSize: 13),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Additional Inspection Requests
                          const Text('Additional Requests / General Checks', style: TextStyle(fontSize: 12, color: AppColors.secondaryText, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _additionalRequestsController,
                            maxLines: 2,
                            style: const TextStyle(color: AppColors.primaryText, fontSize: 13),
                            decoration: const InputDecoration(
                              hintText: 'e.g. Perform HV battery balance check, test 12V auxiliary battery, wheel alignment...',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Issues Selection Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Issues (${_selectedIssueIds.length}/${openIssues.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => _selectAll(openIssues),
                              child: const Text('Select All', style: TextStyle(fontSize: 12)),
                            ),
                            TextButton(
                              onPressed: _deselectAll,
                              child: const Text('Deselect', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (openIssues.isEmpty)
                      GlassCard(
                        padding: const EdgeInsets.all(24),
                        child: const Center(
                          child: Text(
                            'No open vehicle issues registered. You can still schedule an inspection by adding requests above.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.secondaryText),
                          ),
                        ),
                      )
                    else ...[
                      if (critical.isNotEmpty) ...[
                        _buildPriorityGroupHeader('CRITICAL ISSUES', AppColors.critical, critical.length),
                        ...critical.map(_buildIssueCheckboxTile),
                      ],
                      if (high.isNotEmpty) ...[
                        _buildPriorityGroupHeader('HIGH PRIORITY ISSUES', AppColors.high, high.length),
                        ...high.map(_buildIssueCheckboxTile),
                      ],
                      if (medium.isNotEmpty) ...[
                        _buildPriorityGroupHeader('MEDIUM PRIORITY ISSUES', AppColors.medium, medium.length),
                        ...medium.map(_buildIssueCheckboxTile),
                      ],
                      if (low.isNotEmpty) ...[
                        _buildPriorityGroupHeader('LOW PRIORITY ISSUES', AppColors.low, low.length),
                        ...low.map(_buildIssueCheckboxTile),
                      ],
                    ],

                    const SizedBox(height: 24),

                    // Start Visit CTA Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isCreating ? null : _startServiceVisit,
                        icon: _isCreating
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background))
                            : const Icon(Icons.play_arrow_rounded, size: 22),
                        label: Text(
                          _isCreating ? 'Creating Service Visit...' : 'Begin Service Visit (${_selectedIssueIds.length} Issues)',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
          error: (e, _) => Center(child: Text('Error loading issues: $e', style: const TextStyle(color: AppColors.critical))),
        ),
      ),
    );
  }

  Widget _buildPriorityGroupHeader(String title, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 14,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '($count)',
            style: const TextStyle(fontSize: 11, color: AppColors.tertiaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueCheckboxTile(IssueModel issue) {
    final isSelected = _selectedIssueIds.contains(issue.id);
    final comp = VehicleComponentsCatalog.getById(issue.componentId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        borderColor: isSelected ? AppColors.accent : AppColors.cardBorder,
        backgroundColor: isSelected ? AppColors.accentDim.withValues(alpha: 0.12) : AppColors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedIssueIds.remove(issue.id);
            } else {
              _selectedIssueIds.add(issue.id);
            }
          });
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: isSelected,
              activeColor: AppColors.accent,
              checkColor: AppColors.background,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _selectedIssueIds.add(issue.id);
                  } else {
                    _selectedIssueIds.remove(issue.id);
                  }
                });
              },
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PriorityBadge(priority: issue.priority, compact: true),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          comp.name,
                          style: const TextStyle(fontSize: 11.5, color: AppColors.secondaryText, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    issue.title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryText),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    issue.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
