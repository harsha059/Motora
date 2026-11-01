import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../issues/data/issue_repository.dart';
import '../data/service_repository.dart';

class ServiceScreen extends ConsumerWidget {
  const ServiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openIssuesAsync = ref.watch(openIssuesProvider);
    final activeVisitAsync = ref.watch(activeServiceVisitProvider);
    final completedVisitsAsync = ref.watch(completedServiceVisitsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Service & Maintenance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_rounded, color: AppColors.accent),
            tooltip: 'Prepare for Service',
            onPressed: () => context.push('/service/prepare'),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.elevatedSurface,
          onRefresh: () async {
            ref.invalidate(openIssuesProvider);
            ref.invalidate(activeServiceVisitProvider);
            ref.invalidate(completedServiceVisitsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Active Service Visit in Progress (if any)
                activeVisitAsync.when(
                  data: (activeVisit) {
                    if (activeVisit == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        borderColor: AppColors.accent,
                        gradient: AppColors.heroCardGradient,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentDim,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.accent, width: 0.8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.build_circle_rounded, size: 14, color: AppColors.accent),
                                      SizedBox(width: 6),
                                      Text(
                                        'ACTIVE SERVICE VISIT',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.accent,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  DateFormat('dd MMM yyyy').format(activeVisit.visitDate),
                                  style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              activeVisit.serviceCentre,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Odometer: ${activeVisit.odometerReading} km • MG Comet EV',
                              style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => context.push('/service/visit/${activeVisit.id}'),
                                icon: const Icon(Icons.edit_note_rounded, size: 18),
                                label: const Text('Record Technician Observations & Complete'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),

                // Pre-Service Consultation Prep Card
                openIssuesAsync.when(
                  data: (openIssues) {
                    return GlassCard(
                      padding: const EdgeInsets.all(18),
                      borderColor: AppColors.cardBorderActive,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.accentDim,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.checklist_rtl_rounded, color: AppColors.accent, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Pre-Service Issue Checklist',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${openIssues.length} outstanding issues awaiting technician consultation',
                                      style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => context.push('/service/prepare'),
                              icon: const Icon(Icons.play_arrow_rounded, size: 20),
                              label: const Text('Prepare for Service Visit'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                // Service Visit History Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Service History Records',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: AppColors.primaryText,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.history_rounded, size: 20, color: AppColors.secondaryText),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                completedVisitsAsync.when(
                  data: (visits) {
                    if (visits.isEmpty) {
                      return GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: AppColors.elevatedSurface,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.description_outlined, color: AppColors.secondaryText, size: 28),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No Completed Service Visits',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primaryText),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'When you complete a service visit with technician sign-off, historical logs and PDF reports will be preserved here.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12.5, color: AppColors.secondaryText),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: visits.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final visit = visits[index];
                        return GlassCard(
                          padding: const EdgeInsets.all(16),
                          onTap: () => context.push('/service/visit/${visit.id}'),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.statusResolved.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle_rounded, size: 12, color: AppColors.statusResolved),
                                        SizedBox(width: 4),
                                        Text(
                                          'COMPLETED',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.statusResolved,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    DateFormat('dd MMM yyyy').format(visit.completedAt ?? visit.visitDate),
                                    style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                visit.serviceCentre,
                                style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Odometer: ${visit.odometerReading} km ${visit.technicianName != null ? '• Tech: ${visit.technicianName}' : ''}',
                                style: const TextStyle(fontSize: 12.5, color: AppColors.secondaryText),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (visit.totalCost != null)
                                    Text(
                                      'Cost: ₹${visit.totalCost!.toStringAsFixed(0)}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent),
                                    )
                                  else
                                    const SizedBox.shrink(),
                                  TextButton.icon(
                                    onPressed: () => context.push('/service/report/${visit.id}'),
                                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                                    label: const Text('PDF Report', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
                  error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.critical))),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
