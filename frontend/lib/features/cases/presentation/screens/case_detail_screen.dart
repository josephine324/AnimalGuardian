import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/cases_provider.dart';
import '../../../../core/models/case_model.dart';

class CaseDetailScreen extends ConsumerWidget {
  final int caseId;

  const CaseDetailScreen({
    super.key,
    required this.caseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final casesState = ref.watch(casesProvider);
    final caseReport = casesState.cases.firstWhere(
      (c) => c.id == caseId,
      orElse: () => throw Exception('Case not found'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Case ${caseReport.caseId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(casesProvider.notifier).loadCases(refresh: true);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Urgency Cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: _getStatusColor(caseReport.status).withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Status',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(caseReport.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              caseReport.status.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    color: _getPriorityColor(caseReport.urgency).withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Urgency',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(caseReport.urgency),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              caseReport.urgency.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Case Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Case Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildInfoRow('Case ID', caseReport.caseId),
                    _buildInfoRow(
                      'Livestock',
                      caseReport.livestockName ?? 'Livestock #${caseReport.livestockId}',
                    ),
                    _buildInfoRow(
                      'Reported At',
                      DateFormat('yyyy-MM-dd HH:mm').format(caseReport.reportedAt),
                    ),
                    _buildInfoRow(
                      'Last Updated',
                      DateFormat('yyyy-MM-dd HH:mm').format(caseReport.updatedAt),
                    ),
                    _buildInfoRow(
                      'Affected Animals',
                      caseReport.numberOfAffectedAnimals.toString(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Symptoms
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Symptoms Observed',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    Text(
                      caseReport.symptomsObserved,
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (caseReport.durationOfSymptoms != null &&
                        caseReport.durationOfSymptoms!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        'Duration',
                        caseReport.durationOfSymptoms!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Location Notes
            if (caseReport.locationNotes != null &&
                caseReport.locationNotes!.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Location Notes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      Text(caseReport.locationNotes!),
                    ],
                  ),
                ),
              ),

            // Photos
            if (caseReport.photos.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Photos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: caseReport.photos.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 200,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  caseReport.photos[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(Icons.broken_image),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(CaseStatus status) {
    switch (status) {
      case CaseStatus.pending:
        return Colors.blue;
      case CaseStatus.underReview:
        return Colors.orange;
      case CaseStatus.diagnosed:
        return Colors.purple;
      case CaseStatus.treated:
        return Colors.teal;
      case CaseStatus.resolved:
        return Colors.green;
      case CaseStatus.escalated:
        return Colors.red;
    }
  }

  Color _getPriorityColor(CaseUrgency urgency) {
    switch (urgency) {
      case CaseUrgency.low:
        return Colors.green;
      case CaseUrgency.medium:
        return Colors.orange;
      case CaseUrgency.high:
        return Colors.red;
      case CaseUrgency.urgent:
        return Colors.purple;
    }
  }
}

