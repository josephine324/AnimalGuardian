import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/livestock_provider.dart';
import '../../../../core/models/livestock_model.dart';

class EditLivestockScreen extends ConsumerStatefulWidget {
  final int livestockId;

  const EditLivestockScreen({
    super.key,
    required this.livestockId,
  });

  @override
  ConsumerState<EditLivestockScreen> createState() =>
      _EditLivestockScreenState();
}

class _EditLivestockScreenState extends ConsumerState<EditLivestockScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _tagNumberController = TextEditingController();
  final _weightController = TextEditingController();
  final _colorController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _selectedLivestockTypeId;
  int? _selectedBreedId;
  LivestockGender? _selectedGender;
  LivestockStatus? _selectedStatus;
  DateTime? _selectedBirthDate;
  bool _isPregnant = false;
  bool _isLoading = false;
  bool _isLoadingData = true;
  Livestock? _livestock;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLivestockData();
      _loadLivestockTypes();
    });
  }

  Future<void> _loadLivestockData() async {
    try {
      final livestock = await ref
          .read(livestockProvider.notifier)
          .getLivestockById(widget.livestockId);
      if (mounted && livestock != null) {
        setState(() {
          _livestock = livestock;
          _selectedLivestockTypeId = livestock.livestockType?.id;
          _selectedBreedId = livestock.breed?.id;
          _selectedGender = livestock.gender;
          _selectedStatus = livestock.status;
          _selectedBirthDate = livestock.birthDate;
          _isPregnant = livestock.isPregnant;

          _nameController.text = livestock.name ?? '';
          _tagNumberController.text = livestock.tagNumber ?? '';
          _weightController.text = livestock.weightKg?.toString() ?? '';
          _colorController.text = livestock.color ?? '';
          _descriptionController.text = livestock.description ?? '';

          _isLoadingData = false;
        });

        // Load breeds for the selected type
        if (_selectedLivestockTypeId != null) {
          await ref
              .read(livestockProvider.notifier)
              .loadBreeds(livestockTypeId: _selectedLivestockTypeId!);
        }
      } else if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load livestock: Livestock not found'),
            backgroundColor: Colors.red,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load livestock: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        context.pop();
      }
    }
  }

  Future<void> _loadLivestockTypes() async {
    try {
      await ref.read(livestockProvider.notifier).loadLivestockTypes();
    } catch (e) {
      // Ignore errors, types might already be loaded
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tagNumberController.dispose();
    _weightController.dispose();
    _colorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ??
          DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _updateLivestock() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLivestockTypeId == null ||
        _selectedGender == null ||
        _selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final livestockData = {
      'livestock_type_id': _selectedLivestockTypeId,
      if (_selectedBreedId != null) 'breed_id': _selectedBreedId,
      if (_nameController.text.trim().isNotEmpty)
        'name': _nameController.text.trim(),
      if (_tagNumberController.text.trim().isNotEmpty)
        'tag_number': _tagNumberController.text.trim(),
      'gender': _selectedGender!.apiValue,
      'status': _selectedStatus!.apiValue,
      if (_selectedBirthDate != null)
        'birth_date': DateFormat('yyyy-MM-dd').format(_selectedBirthDate!),
      if (_weightController.text.trim().isNotEmpty)
        'weight_kg': double.tryParse(_weightController.text.trim()),
      if (_colorController.text.trim().isNotEmpty)
        'color': _colorController.text.trim(),
      if (_descriptionController.text.trim().isNotEmpty)
        'description': _descriptionController.text.trim(),
      'is_pregnant': _isPregnant,
    };

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(livestockProvider.notifier)
          .updateLivestock(widget.livestockId, livestockData);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Livestock updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        await ref.read(livestockProvider.notifier).loadLivestock(refresh: true);
        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        String errorMessage = e.toString();
        if (errorMessage.contains('Exception:')) {
          errorMessage = errorMessage.split('Exception:').last.trim();
        }
        errorMessage = errorMessage.replaceAll(RegExp(r'<[^>]*>'), '').trim();
        if (errorMessage.length > 200) {
          errorMessage = '${errorMessage.substring(0, 200)}...';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update livestock: $errorMessage'),
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

    if (_isLoadingData) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Livestock'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_livestock == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Livestock'),
        ),
        body: const Center(child: Text('Livestock not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Edit Livestock'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Livestock Type Selection
              DropdownButtonFormField<int>(
                initialValue: _selectedLivestockTypeId,
                decoration: const InputDecoration(
                  labelText: 'Livestock Type *',
                  prefixIcon: Icon(Icons.pets),
                  border: OutlineInputBorder(),
                ),
                items: livestockState.livestockTypes.map((type) {
                  return DropdownMenuItem<int>(
                    value: type.id,
                    child: Text(type.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedLivestockTypeId = value;
                      _selectedBreedId = null;
                    });
                    ref
                        .read(livestockProvider.notifier)
                        .loadBreeds(livestockTypeId: value);
                  }
                },
                validator: (value) =>
                    value == null ? 'Please select a livestock type' : null,
              ),
              const SizedBox(height: 16),

              // Breed Selection
              DropdownButtonFormField<int>(
                initialValue: _selectedBreedId,
                decoration: const InputDecoration(
                  labelText: 'Breed (Optional)',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<int>(
                      value: null, child: Text('No breed (optional)')),
                  ...livestockState.breeds
                      .where((breed) =>
                          breed.livestockTypeId == _selectedLivestockTypeId)
                      .map((breed) => DropdownMenuItem<int>(
                            value: breed.id,
                            child: Text(breed.name),
                          )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedBreedId = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name (Optional)',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Tag Number
              TextFormField(
                controller: _tagNumberController,
                decoration: const InputDecoration(
                  labelText: 'Tag Number (Optional)',
                  prefixIcon: Icon(Icons.confirmation_number),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Gender
              DropdownButtonFormField<LivestockGender>(
                initialValue: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender *',
                  prefixIcon: Icon(Icons.wc),
                  border: OutlineInputBorder(),
                ),
                items: LivestockGender.values.map((gender) {
                  return DropdownMenuItem<LivestockGender>(
                    value: gender,
                    child: Text(gender.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedGender = value;
                      if (value == LivestockGender.male) {
                        _isPregnant = false;
                      }
                    });
                  }
                },
                validator: (value) =>
                    value == null ? 'Please select gender' : null,
              ),
              const SizedBox(height: 16),

              // Status
              DropdownButtonFormField<LivestockStatus>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status *',
                  prefixIcon: Icon(Icons.health_and_safety),
                  border: OutlineInputBorder(),
                ),
                items: LivestockStatus.values.map((status) {
                  return DropdownMenuItem<LivestockStatus>(
                    value: status,
                    child: Text(status.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  }
                },
                validator: (value) =>
                    value == null ? 'Please select status' : null,
              ),
              const SizedBox(height: 16),

              // Birth Date
              InkWell(
                onTap: _selectBirthDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Birth Date (Optional)',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedBirthDate != null
                        ? DateFormat('yyyy-MM-dd').format(_selectedBirthDate!)
                        : 'Select birth date',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Weight
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg) (Optional)',
                  prefixIcon: Icon(Icons.monitor_weight),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final weight = double.tryParse(value);
                    if (weight == null || weight < 0) {
                      return 'Please enter a valid weight';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Color
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Color (Optional)',
                  prefixIcon: Icon(Icons.palette),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Is Pregnant (only for females)
              if (_selectedGender == LivestockGender.female)
                CheckboxListTile(
                  title: const Text('Is Pregnant'),
                  value: _isPregnant,
                  onChanged: (value) {
                    setState(() {
                      _isPregnant = value ?? false;
                    });
                  },
                ),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Update Button
              ElevatedButton(
                onPressed: _isLoading ? null : _updateLivestock,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Update Livestock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
