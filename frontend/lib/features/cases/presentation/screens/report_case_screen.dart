import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/cases_provider.dart';
import '../../../livestock/providers/livestock_provider.dart';
import '../../../../core/models/case_model.dart';

class ReportCaseScreen extends ConsumerStatefulWidget {
  final CaseReport? editCase;

  const ReportCaseScreen({super.key, this.editCase});

  @override
  ConsumerState<ReportCaseScreen> createState() => _ReportCaseScreenState();
}

class _ReportCaseScreenState extends ConsumerState<ReportCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symptomsController = TextEditingController();
  final _durationController = TextEditingController();
  final _locationNotesController = TextEditingController();
  final _numberOfAnimalsController = TextEditingController(text: '1');

  int? _selectedLivestockId;
  CaseUrgency _selectedUrgency = CaseUrgency.medium;
  final List<XFile> _selectedImages = [];
  bool _isEditing = false;
  int? _caseId;

  @override
  void initState() {
    super.initState();
    if (widget.editCase != null) {
      _isEditing = true;
      _caseId = widget.editCase!.id;
      _symptomsController.text = widget.editCase!.symptomsObserved;
      _durationController.text = widget.editCase!.durationOfSymptoms ?? '';
      _locationNotesController.text = widget.editCase!.locationNotes ?? '';
      _numberOfAnimalsController.text =
          widget.editCase!.numberOfAffectedAnimals.toString();
      _selectedLivestockId = widget.editCase!.livestockId;
      _selectedUrgency = widget.editCase!.urgency;
    }
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _durationController.dispose();
    _locationNotesController.dispose();
    _numberOfAnimalsController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: $e')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _selectedImages.add(photo);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitCase() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show loading indicator
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    try {
      // Convert images to base64 data URLs
      final List<String> photoUrls = [];
      for (var imageFile in _selectedImages) {
        try {
          final bytes = await imageFile.readAsBytes();
          final base64String = base64Encode(bytes);
          // Determine MIME type from file extension
          final extension = imageFile.path.split('.').last.toLowerCase();
          String mimeType = 'image/jpeg'; // default
          if (extension == 'png') {
            mimeType = 'image/png';
          } else if (extension == 'gif') {
            mimeType = 'image/gif';
          } else if (extension == 'webp') {
            mimeType = 'image/webp';
          }
          final dataUrl = 'data:$mimeType;base64,$base64String';
          photoUrls.add(dataUrl);
        } catch (e) {
          // Skip images that fail to convert
          print('Error converting image to base64: $e');
        }
      }

      final caseData = {
        if (_selectedLivestockId != null) 'livestock': _selectedLivestockId,
        'urgency': _selectedUrgency.apiValue,
        'symptoms_observed': _symptomsController.text.trim(),
        if (_durationController.text.trim().isNotEmpty)
          'duration_of_symptoms': _durationController.text.trim(),
        'number_of_affected_animals':
            int.tryParse(_numberOfAnimalsController.text) ?? 1,
        if (_locationNotesController.text.trim().isNotEmpty)
          'location_notes': _locationNotesController.text.trim(),
        if (photoUrls.isNotEmpty) 'photos': photoUrls,
      };

      final casesNotifier = ref.read(casesProvider.notifier);

      if (_isEditing && _caseId != null) {
        // Update existing case
        final success = await casesNotifier.updateCase(_caseId!, caseData);

        // Close loading indicator
        if (mounted) {
          Navigator.of(context).pop();
        }

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Case updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop(true); // Return true to indicate success
          } else {
            final errorMessage = casesNotifier.state.error ??
                'Failed to update case. Please try again.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      } else {
        // Create new case
        final newCase = await casesNotifier.createCase(caseData);

        // Close loading indicator
        if (mounted) {
          Navigator.of(context).pop();
        }

        if (mounted) {
          if (newCase != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Case reported successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else {
            // Show the actual error message from the provider
            final errorMessage = casesNotifier.state.error ??
                'Failed to report case. Please try again.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      }
    } catch (e) {
      // Close loading indicator if still open
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading images: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final livestockState = ref.watch(livestockProvider);
    final casesState = ref.watch(casesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(_isEditing ? 'Edit Case' : 'Report Case'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Livestock Selection (Optional)
              DropdownButtonFormField<int>(
                initialValue: _selectedLivestockId,
                decoration: const InputDecoration(
                  labelText: 'Select Livestock (Optional)',
                  prefixIcon: Icon(Icons.pets),
                  hintText: 'Select a specific animal (optional)',
                ),
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('No specific livestock (general case)'),
                  ),
                  ...livestockState.livestock.map((livestock) {
                    return DropdownMenuItem<int>(
                      value: livestock.id,
                      child: Text(
                        '${livestock.displayName} (${livestock.livestockType?.name ?? "Unknown"})',
                      ),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedLivestockId = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Urgency Selection
              DropdownButtonFormField<CaseUrgency>(
                initialValue: _selectedUrgency,
                decoration: const InputDecoration(
                  labelText: 'Urgency Level *',
                  prefixIcon: Icon(Icons.priority_high),
                ),
                items: CaseUrgency.values.map((urgency) {
                  return DropdownMenuItem<CaseUrgency>(
                    value: urgency,
                    child: Text(urgency.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedUrgency = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Symptoms
              TextFormField(
                controller: _symptomsController,
                decoration: const InputDecoration(
                  labelText: 'Symptoms Observed *',
                  hintText: 'Describe the symptoms you observed',
                  prefixIcon: Icon(Icons.medical_services),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe the symptoms';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Duration
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration of Symptoms',
                  hintText: 'e.g., 2 days, 1 week',
                  prefixIcon: Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 16),

              // Number of Affected Animals
              TextFormField(
                controller: _numberOfAnimalsController,
                decoration: const InputDecoration(
                  labelText: 'Number of Affected Animals *',
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the number of affected animals';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num < 1) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location Notes
              TextFormField(
                controller: _locationNotesController,
                decoration: const InputDecoration(
                  labelText: 'Location Notes',
                  hintText: 'Additional location information',
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Photos Section
              const Text(
                'Photos (Optional)',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Choose from Gallery'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Display Selected Images
              if (_selectedImages.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder<Uint8List?>(
                        future: _selectedImages[index].readAsBytes(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (snapshot.hasError || !snapshot.hasData) {
                            return Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: const Center(
                                child: Icon(Icons.error, color: Colors.red),
                              ),
                            );
                          }

                          return Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.red,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    iconSize: 16,
                                    icon: const Icon(Icons.close,
                                        color: Colors.white),
                                    onPressed: () => _removeImage(index),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: casesState.isLoading ? null : _submitCase,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: casesState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Case Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
