import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    // Try to get from storage first
    String? userType = await _storage.read(key: AppConstants.userTypeKey);
    String? userId = await _storage.read(key: AppConstants.userIdKey);

    // If not in storage, try to get from API
    if (userType == null || userId == null) {
      try {
        final userData = await _apiService.getCurrentUser();
        userType = userData['user_type']?.toString();
        userId = userData['id']?.toString();

        // Store for future use
        if (userType != null) {
          await _storage.write(key: AppConstants.userTypeKey, value: userType);
        }
        if (userId != null) {
          await _storage.write(key: AppConstants.userIdKey, value: userId);
        }
      } catch (e) {
        print('Error loading user info from API: $e');
      }
    }

    // Debug: Print values to console
    print('DEBUG: Loaded userType: $userType, userId: $userId');
    if (mounted) {
      setState(() {
        _userType = userType;
        _userId = userId;
        print('DEBUG: Set state - userType: $_userType, userId: $_userId');
      });
    }
  }

  Future<void> _navigateToEditCase(
      BuildContext context, CaseReport caseReport) async {
    // Navigate to edit screen using go_router
    final result = await context.push<bool>(
      '/cases/edit',
      extra: caseReport,
    );

    if (result == true) {
      // Case was updated, refresh
      ref.read(casesProvider.notifier).loadCases(refresh: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Case updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteCase(
      BuildContext context, CaseReport caseReport) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Case'),
        content: Text(
            'Are you sure you want to delete case ${caseReport.caseId}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isUpdating = true;
      });

      try {
        final success =
            await ref.read(casesProvider.notifier).deleteCase(caseReport.id);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Case deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(); // Go back to cases list
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Failed to delete case: ${ref.read(casesProvider).error ?? "Unknown error"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting case: ${e.toString()}'),
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

    // Try to find the case in the list
    CaseReport? caseReport;
    try {
      caseReport = casesState.cases.firstWhere(
        (c) => c.id == widget.caseId,
      );
    } catch (e) {
      // Case not in list - show loading and fetch it
      return FutureBuilder<CaseReport?>(
        future: ref.read(casesProvider.notifier).getCaseById(widget.caseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(title: const Text('Loading Case...')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Case Not Found')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Case not found'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          }
          // Case found, build the detail view
          return _CaseDetailContent(
            caseReport: snapshot.data!,
            userType: _userType,
            userId: _userId,
            onLoadUserInfo: _loadUserInfo,
            onNavigateToEdit: _navigateToEditCase,
            onConfirmDelete: _confirmDeleteCase,
            onUpdateStatus: _updateCaseStatus,
            isUpdating: _isUpdating,
          );
        },
      );
    }

    // Case found in list, build the detail view
    return _CaseDetailContent(
      caseReport: caseReport,
      userType: _userType,
      userId: _userId,
      onLoadUserInfo: _loadUserInfo,
      onNavigateToEdit: _navigateToEditCase,
      onConfirmDelete: _confirmDeleteCase,
      onUpdateStatus: _updateCaseStatus,
      isUpdating: _isUpdating,
    );
  }

  Widget _buildCaseDetail(CaseReport caseReport) {
    // This method is deprecated - use _CaseDetailContent widget instead
    return _CaseDetailContent(
      caseReport: caseReport,
      userType: _userType,
      userId: _userId,
      onLoadUserInfo: _loadUserInfo,
      onNavigateToEdit: _navigateToEditCase,
      onConfirmDelete: _confirmDeleteCase,
      onUpdateStatus: _updateCaseStatus,
      isUpdating: _isUpdating,
    );
  }
}

// Separate widget to avoid rebuild issues and fix overflow
class _CaseDetailContent extends ConsumerWidget {
  final CaseReport caseReport;
  final String? userType;
  final String? userId;
  final VoidCallback onLoadUserInfo;
  final Function(BuildContext, CaseReport) onNavigateToEdit;
  final Function(BuildContext, CaseReport) onConfirmDelete;
  final Function(CaseStatus) onUpdateStatus;
  final bool isUpdating;

  const _CaseDetailContent({
    required this.caseReport,
    required this.userType,
    required this.userId,
    required this.onLoadUserInfo,
    required this.onNavigateToEdit,
    required this.onConfirmDelete,
    required this.onUpdateStatus,
    required this.isUpdating,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canUpdateStatus = userType == 'local_vet' || userType == 'sector_vet';
    final isFarmer = userType == 'farmer';
    // Check if user is the reporter (owner) of the case - compare as strings to avoid type issues
    final userIdStr = userId?.toString().trim();
    final reporterIdStr = caseReport.reporterId.toString().trim();
    final isCaseOwner =
        userIdStr != null && userIdStr.isNotEmpty && userIdStr == reporterIdStr;

    // Check status - use string comparison to be safe
    final statusStr = caseReport.status.toString().toLowerCase();
    final isEditableStatus = statusStr.contains('pending') ||
        statusStr.contains('rejected') ||
        statusStr.contains('underreview') ||
        caseReport.status == CaseStatus.pending ||
        caseReport.status == CaseStatus.rejected ||
        caseReport.status == CaseStatus.underReview;
    final isDeletableStatus = statusStr.contains('pending') ||
        statusStr.contains('rejected') ||
        caseReport.status == CaseStatus.pending ||
        caseReport.status == CaseStatus.rejected;

    final canEdit = isFarmer && isCaseOwner && isEditableStatus;
    final canDelete = isFarmer && isCaseOwner && isDeletableStatus;

    // Debug output
    print('DEBUG Case Detail:');
    print('  userType: $userType');
    print('  userId: $userId (string: $userIdStr)');
    print(
        '  caseReport.reporterId: ${caseReport.reporterId} (string: $reporterIdStr)');
    print('  isFarmer: $isFarmer');
    print(
        '  isCaseOwner: $isCaseOwner (userIdStr == reporterIdStr: ${userIdStr == reporterIdStr})');
    print('  caseStatus: ${caseReport.status} (string: $statusStr)');
    print('  isEditableStatus: $isEditableStatus');
    print('  isDeletableStatus: $isDeletableStatus');
    print('  canEdit: $canEdit');
    print('  canDelete: $canDelete');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Case ${caseReport.caseId}'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(casesProvider.notifier).loadCases(refresh: true);
              onLoadUserInfo(); // Reload user info on refresh
            },
            tooltip: 'Refresh',
          ),
          // Show edit/delete buttons if conditions are met
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => onNavigateToEdit(context, caseReport),
              tooltip: 'Edit Case',
            ),
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => onConfirmDelete(context, caseReport),
              tooltip: 'Delete Case',
            ),
          // Debug menu - consolidate debug options into one popup menu
          if (isFarmer)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: 'More Options',
              onSelected: (value) {
                if (value == 'debug_info') {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Debug Information'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('User Type: ${userType ?? "NULL"}'),
                            Text('User ID: ${userId ?? "NULL"}'),
                            Text('Case Reporter ID: ${caseReport.reporterId}'),
                            Text('Is Farmer: $isFarmer'),
                            Text('Is Case Owner: $isCaseOwner'),
                            Text('Case Status: ${caseReport.status}'),
                            Text('Can Edit: $canEdit'),
                            Text('Can Delete: $canDelete'),
                            if (userType == null || userId == null)
                              const Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: Text(
                                  '⚠️ SOLUTION: Log out and log back in!',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            onLoadUserInfo();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Reload User Info'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                } else if (value == 'force_edit' && isFarmer) {
                  // Force edit for testing
                  onNavigateToEdit(context, caseReport);
                }
              },
              itemBuilder: (context) => [
                if (!canEdit && !canDelete && isFarmer)
                  const PopupMenuItem(
                    value: 'debug_info',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 20),
                        SizedBox(width: 8),
                        Text('Why no buttons?'),
                      ],
                    ),
                  ),
                if (isFarmer && !canEdit)
                  const PopupMenuItem(
                    value: 'force_edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit (Force)'),
                      ],
                    ),
                  ),
                if (isFarmer)
                  const PopupMenuItem(
                    value: 'debug_info',
                    child: Row(
                      children: [
                        Icon(Icons.bug_report, size: 20),
                        SizedBox(width: 8),
                        Text('Debug Info'),
                      ],
                    ),
                  ),
              ],
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
                    color:
                        _getPriorityColor(caseReport.urgency).withOpacity(0.1),
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
                      if (isUpdating)
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
                      caseReport.livestockName ??
                          'Livestock #${caseReport.livestockId}',
                    ),
                    _buildInfoRow(
                      'Reported At',
                      DateFormat('yyyy-MM-dd HH:mm')
                          .format(caseReport.reportedAt),
                    ),
                    _buildInfoRow(
                      'Last Updated',
                      DateFormat('yyyy-MM-dd HH:mm')
                          .format(caseReport.updatedAt),
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
                    if (caseReport.reporterPhone != null &&
                        caseReport.reporterPhone!.isNotEmpty)
                      _buildInfoRow('Phone', caseReport.reporterPhone!),
                    if (caseReport.reporterEmail != null &&
                        caseReport.reporterEmail!.isNotEmpty)
                      _buildInfoRow('Email', caseReport.reporterEmail!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Assigned Veterinarian Information (if assigned)
            if (caseReport.assignedVeterinarianName != null &&
                caseReport.assignedVeterinarianName!.isNotEmpty)
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
                      _buildInfoRow(
                          'Name', caseReport.assignedVeterinarianName!),
                      if (caseReport.assignedVeterinarianPhone != null &&
                          caseReport.assignedVeterinarianPhone!.isNotEmpty)
                        _buildInfoRow(
                            'Phone', caseReport.assignedVeterinarianPhone!),
                      if (caseReport.assignedVeterinarianEmail != null &&
                          caseReport.assignedVeterinarianEmail!.isNotEmpty)
                        _buildInfoRow(
                            'Email', caseReport.assignedVeterinarianEmail!),
                    ],
                  ),
                ),
              ),
            if (caseReport.assignedVeterinarianName != null &&
                caseReport.assignedVeterinarianName!.isNotEmpty)
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
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
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
      onPressed:
          isUpdating || isCurrentStatus ? null : () => onUpdateStatus(status),
      style: ElevatedButton.styleFrom(
        backgroundColor: isCurrentStatus ? Colors.grey : color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label),
    );
  }
}
