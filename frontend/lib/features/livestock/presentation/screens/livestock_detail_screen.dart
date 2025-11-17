import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/livestock_provider.dart';
import '../../../../core/models/livestock_model.dart';

class LivestockDetailScreen extends ConsumerWidget {
  final int livestockId;

  const LivestockDetailScreen({
    super.key,
    required this.livestockId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livestockState = ref.watch(livestockProvider);
    final livestock = livestockState.livestock.firstWhere(
      (l) => l.id == livestockId,
      orElse: () => throw Exception('Livestock not found'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(livestock.displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              color: _getStatusColor(livestock.status).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.pets,
                      size: 48,
                      color: _getStatusColor(livestock.status),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            livestock.displayName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(livestock.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              livestock.status.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Basic Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildInfoRow('Type', livestock.livestockType?.name ?? 'Unknown'),
                    if (livestock.breed != null)
                      _buildInfoRow('Breed', livestock.breed!.name),
                    _buildInfoRow('Gender', livestock.gender.name),
                    if (livestock.tagNumber != null)
                      _buildInfoRow('Tag Number', livestock.tagNumber!),
                    if (livestock.birthDate != null)
                      _buildInfoRow(
                        'Birth Date',
                        DateFormat('yyyy-MM-dd').format(livestock.birthDate!),
                      ),
                    if (livestock.ageMonths != null)
                      _buildInfoRow(
                        'Age',
                        '${livestock.ageMonths! ~/ 12} years ${livestock.ageMonths! % 12} months',
                      ),
                    if (livestock.weightKg != null)
                      _buildInfoRow(
                        'Weight',
                        '${livestock.weightKg!.toStringAsFixed(1)} kg',
                      ),
                    if (livestock.color != null && livestock.color!.isNotEmpty)
                      _buildInfoRow('Color', livestock.color!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Health Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Health Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    if (livestock.lastHealthCheck != null)
                      _buildInfoRow(
                        'Last Health Check',
                        DateFormat('yyyy-MM-dd').format(livestock.lastHealthCheck!),
                      ),
                    if (livestock.lastVaccinationDate != null)
                      _buildInfoRow(
                        'Last Vaccination',
                        DateFormat('yyyy-MM-dd').format(livestock.lastVaccinationDate!),
                      ),
                    if (livestock.lastDewormingDate != null)
                      _buildInfoRow(
                        'Last Deworming',
                        DateFormat('yyyy-MM-dd').format(livestock.lastDewormingDate!),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Reproduction Information (for females)
            if (livestock.gender == LivestockGender.female) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reproduction Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      _buildInfoRow('Is Pregnant', livestock.isPregnant ? 'Yes' : 'No'),
                      if (livestock.pregnancyStartDate != null)
                        _buildInfoRow(
                          'Pregnancy Start',
                          DateFormat('yyyy-MM-dd').format(livestock.pregnancyStartDate!),
                        ),
                      if (livestock.expectedDeliveryDate != null)
                        _buildInfoRow(
                          'Expected Delivery',
                          DateFormat('yyyy-MM-dd').format(livestock.expectedDeliveryDate!),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Production Information
            if (livestock.dailyMilkProductionLiters != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Production Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      _buildInfoRow(
                        'Daily Milk Production',
                        '${livestock.dailyMilkProductionLiters!.toStringAsFixed(2)} liters',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Description
            if (livestock.description != null && livestock.description!.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      Text(livestock.description!),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to health records
                    },
                    icon: const Icon(Icons.medical_services),
                    label: const Text('Health Records'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to report case for this livestock
                    },
                    icon: const Icon(Icons.report_problem),
                    label: const Text('Report Case'),
                  ),
                ),
              ],
            ),
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
            width: 140,
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

  Color _getStatusColor(LivestockStatus status) {
    switch (status) {
      case LivestockStatus.healthy:
        return Colors.green;
      case LivestockStatus.sick:
        return Colors.red;
      case LivestockStatus.pregnant:
        return Colors.purple;
      case LivestockStatus.inHeat:
        return Colors.orange;
      case LivestockStatus.deceased:
        return Colors.grey;
      case LivestockStatus.sold:
        return Colors.blue;
    }
  }
}

