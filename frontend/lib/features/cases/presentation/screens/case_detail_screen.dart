import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/cases_provider.dart';
import '../../../../core/models/case_model.dart';
import '../../../../core/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';

class CaseDetailScreen extends ConsumerStatefulWidget {
  final int caseId;

  const CaseDetailScreen({
    super.key,
    required this.caseId,
  });

  @override
  ConsumerState<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends ConsumerState<CaseDetailScreen> {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isUpdating = false;
  String? _userType;

  @override
  void initState() {
    super.initState();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    final userType = await _storage.read(key: AppConstants.userTypeKey);
    if (mounted) {
      setState(() {
        _userType = userType;
      });
    }
  }

  Future<void> _updateCaseStatus(CaseStatus newStatus) async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      await _apiService.updateCase(widget.caseId, {
        'status': newStatus.apiValue,
      });

      // Refresh cases
      ref.read(casesProvider.notifier).loadCases(refresh: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Case status updated to ${newStatus.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final casesState = ref.watch(casesProvider);
    final caseReport = casesState.cases.firstWhere(
      (c) => c.id == widget.caseId,
      orElse: () => throw Exception('Case not found'),
    );
    
    final canUpdateStatus = _userType == 'local_vet' || _userType == 'sector_vet';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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

            // Update Status Section (for vets only)
            if (canUpdateStatus) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Update Case Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (caseReport.status != CaseStatus.underReview)
                            _buildStatusButton(
                              context,
                              'Start Review',
                              CaseStatus.underReview,
                              Colors.blue,
                              caseReport.status,
                            ),
                          if (caseReport.status != CaseStatus.diagnosed)
                            _buildStatusButton(
                              context,
                              'Mark Diagnosed',
                              CaseStatus.diagnosed,
                              Colors.purple,
                              caseReport.status,
                            ),
                          if (caseReport.status != CaseStatus.treated)
                            _buildStatusButton(
                              context,
                              'Mark Treated',
                              CaseStatus.treated,
                              Colors.teal,
                              caseReport.status,
                            ),
                          if (caseReport.status != CaseStatus.resolved)
                            _buildStatusButton(
                              context,
                              'Mark Resolved',
                              CaseStatus.resolved,
                              Colors.green,
                              caseReport.status,
                            ),
                          if (caseReport.status != CaseStatus.escalated)
                            _buildStatusButton(
                              context,
                              'Escalate',
                              CaseStatus.escalated,
                              Colors.red,
                              caseReport.status,
                            ),
                        ],
                      ),
                      if (_isUpdating)
                        const Padding(
                          padding: EdgeInsets.only(top: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

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

            // Reporter Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reporter Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildInfoRow('Name', caseReport.reporterName ?? 'Unknown'),
                    if (caseReport.reporterPhone != null && caseReport.reporterPhone!.isNotEmpty)
                      _buildInfoRow('Phone', caseReport.reporterPhone!),
                    if (caseReport.reporterEmail != null && caseReport.reporterEmail!.isNotEmpty)
                      _buildInfoRow('Email', caseReport.reporterEmail!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Assigned Veterinarian Information (if assigned)
            if (caseReport.assignedVeterinarianName != null && caseReport.assignedVeterinarianName!.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assigned Veterinarian',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      _buildInfoRow('Name', caseReport.assignedVeterinarianName!),
                      if (caseReport.assignedVeterinarianPhone != null && caseReport.assignedVeterinarianPhone!.isNotEmpty)
                        _buildInfoRow('Phone', caseReport.assignedVeterinarianPhone!),
                      if (caseReport.assignedVeterinarianEmail != null && caseReport.assignedVeterinarianEmail!.isNotEmpty)
                        _buildInfoRow('Email', caseReport.assignedVeterinarianEmail!),
                    ],
                  ),
                ),
              ),
            if (caseReport.assignedVeterinarianName != null && caseReport.assignedVeterinarianName!.isNotEmpty)
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
      case CaseStatus.investigation:
        return Colors.indigo;
      case CaseStatus.diagnosed:
        return Colors.purple;
      case CaseStatus.treated:
        return Colors.teal;
      case CaseStatus.resolved:
        return Colors.green;
      case CaseStatus.rejected:
        return Colors.red;
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

  Widget _buildStatusButton(
    BuildContext context,
    String label,
    CaseStatus status,
    Color color,
    CaseStatus currentStatus,
  ) {
    final isCurrentStatus = status == currentStatus;
    return ElevatedButton(
      onPressed: _isUpdating || isCurrentStatus
          ? null
          : () => _updateCaseStatus(status),
      style: ElevatedButton.styleFrom(
        backgroundColor: isCurrentStatus ? Colors.grey : color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label),
    );
  }
}

