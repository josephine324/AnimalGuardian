import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/livestock_provider.dart';
import '../../../../core/models/livestock_model.dart';

class AddLivestockScreen extends ConsumerStatefulWidget {
  const AddLivestockScreen({super.key});

  @override
  ConsumerState<AddLivestockScreen> createState() => _AddLivestockScreenState();
}

class _AddLivestockScreenState extends ConsumerState<AddLivestockScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _tagNumberController = TextEditingController();
  final _weightController = TextEditingController();
  final _colorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _livestockTypeController = TextEditingController();
  final _breedController = TextEditingController();
  LivestockGender _selectedGender = LivestockGender.male;
  LivestockStatus _selectedStatus = LivestockStatus.healthy;
  DateTime? _selectedBirthDate;
  bool _isPregnant = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // No need to load types/breeds - using manual text input
  }


  @override
  void dispose() {
    _nameController.dispose();
    _tagNumberController.dispose();
    _weightController.dispose();
    _colorController.dispose();
    _descriptionController.dispose();
    _livestockTypeController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _submitLivestock() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_livestockTypeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a livestock type')),
      );
      return;
    }

    final livestockData = {
      'livestock_type_name': _livestockTypeController.text.trim(),
      if (_breedController.text.trim().isNotEmpty) 'breed_name': _breedController.text.trim(),
      if (_nameController.text.trim().isNotEmpty) 'name': _nameController.text.trim(),
      if (_tagNumberController.text.trim().isNotEmpty) 'tag_number': _tagNumberController.text.trim(),
      'gender': _selectedGender.apiValue,
      'status': _selectedStatus.apiValue,
      if (_selectedBirthDate != null) 'birth_date': DateFormat('yyyy-MM-dd').format(_selectedBirthDate!),
      if (_weightController.text.trim().isNotEmpty) 'weight_kg': double.tryParse(_weightController.text.trim()),
      if (_colorController.text.trim().isNotEmpty) 'color': _colorController.text.trim(),
      if (_descriptionController.text.trim().isNotEmpty) 'description': _descriptionController.text.trim(),
      'is_pregnant': _isPregnant,
    };

    setState(() {
      _isLoading = true;
    });

    try {
      final livestockNotifier = ref.read(livestockProvider.notifier);
      final newLivestock = await livestockNotifier.createLivestock(livestockData);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (newLivestock != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Livestock added successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          // Refresh livestock list after successful creation
          await livestockNotifier.loadLivestock(refresh: true);
          if (mounted) {
            context.pop();
          }
        } else {
          final error = ref.read(livestockProvider).error ?? 'Unknown error';
          // Extract meaningful error message
          String errorMessage = error.toString();
          if (errorMessage.contains('Exception:')) {
            errorMessage = errorMessage.split('Exception:').last.trim();
          }
          // Remove HTML tags if present
          errorMessage = errorMessage.replaceAll(RegExp(r'<[^>]*>'), '').trim();
          // Limit error message length
          if (errorMessage.length > 200) {
            errorMessage = '${errorMessage.substring(0, 200)}...';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add livestock: $errorMessage'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
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
        // Remove HTML tags if present
        errorMessage = errorMessage.replaceAll(RegExp(r'<[^>]*>'), '').trim();
        // Limit error message length
        if (errorMessage.length > 200) {
          errorMessage = '${errorMessage.substring(0, 200)}...';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using manual text input - no need to watch provider

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Add Livestock'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Livestock Type Input
              TextFormField(
                controller: _livestockTypeController,
                decoration: const InputDecoration(
                  labelText: 'Livestock Type *',
                  prefixIcon: Icon(Icons.pets),
                  hintText: 'e.g., Cattle, Goat, Sheep, Pig, Chicken, Rabbit',
                  border: OutlineInputBorder(),
                  helperText: 'Enter the type of livestock',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a livestock type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Breed Input
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: 'Breed (Optional)',
                  prefixIcon: Icon(Icons.category),
                  hintText: 'e.g., Holstein, Ankole, Boer (optional)',
                  border: OutlineInputBorder(),
                  helperText: 'Enter the breed if known',
                ),
              ),
              const SizedBox(height: 16),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name (Optional)',
                  hintText: 'e.g., Bella, Max',
                  prefixIcon: Icon(Icons.badge),
                ),
              ),
              const SizedBox(height: 16),

              // Tag Number
              TextFormField(
                controller: _tagNumberController,
                decoration: const InputDecoration(
                  labelText: 'Tag Number (Optional)',
                  hintText: 'Unique identification tag',
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
              ),
              const SizedBox(height: 16),

              // Gender
              DropdownButtonFormField<LivestockGender>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender *',
                  prefixIcon: Icon(Icons.wc),
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
                        _isPregnant = false; // Reset pregnancy for males
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Status
              DropdownButtonFormField<LivestockStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status *',
                  prefixIcon: Icon(Icons.health_and_safety),
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
              ),
              const SizedBox(height: 16),

              // Birth Date
              InkWell(
                onTap: _selectBirthDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Birth Date (Optional)',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedBirthDate != null
                        ? DateFormat('yyyy-MM-dd').format(_selectedBirthDate!)
                        : 'Select birth date',
                    style: TextStyle(
                      color: _selectedBirthDate != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Weight
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg) (Optional)',
                  hintText: 'e.g., 450.5',
                  prefixIcon: Icon(Icons.monitor_weight),
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
                  hintText: 'e.g., Brown, Black, White',
                  prefixIcon: Icon(Icons.palette),
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
                  hintText: 'Additional notes about the animal',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitLivestock,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add Livestock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

