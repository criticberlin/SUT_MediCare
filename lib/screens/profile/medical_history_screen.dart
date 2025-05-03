import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../utils/theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class MedicalHistoryScreen extends StatefulWidget {
  const MedicalHistoryScreen({super.key});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  late User _user;
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _medicationsController = TextEditingController();
  final TextEditingController _conditionsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = User.getCurrentUser();
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    _medicationsController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

  void _addAllergy(String allergy) {
    if (allergy.isEmpty) return;
    
    setState(() {
      List<String> allergies = List<String>.from(_user.allergies ?? []);
      allergies.add(allergy);
      _user = _user.copyWith(allergies: allergies);
      _allergiesController.clear();
    });
  }

  void _removeAllergy(int index) {
    setState(() {
      List<String> allergies = List<String>.from(_user.allergies ?? []);
      allergies.removeAt(index);
      _user = _user.copyWith(allergies: allergies);
    });
  }

  void _addMedication(String medication) {
    if (medication.isEmpty) return;
    
    setState(() {
      List<String> medications = List<String>.from(_user.medications ?? []);
      medications.add(medication);
      _user = _user.copyWith(medications: medications);
      _medicationsController.clear();
    });
  }

  void _removeMedication(int index) {
    setState(() {
      List<String> medications = List<String>.from(_user.medications ?? []);
      medications.removeAt(index);
      _user = _user.copyWith(medications: medications);
    });
  }

  void _addCondition(String condition) {
    if (condition.isEmpty) return;
    
    setState(() {
      List<String> conditions = List<String>.from(_user.chronicConditions ?? []);
      conditions.add(condition);
      _user = _user.copyWith(chronicConditions: conditions);
      _conditionsController.clear();
    });
  }

  void _removeCondition(int index) {
    setState(() {
      List<String> conditions = List<String>.from(_user.chronicConditions ?? []);
      conditions.removeAt(index);
      _user = _user.copyWith(chronicConditions: conditions);
    });
  }

  void _saveMedicalHistory() {
    setState(() {
      _isLoading = true;
    });

    // In a real app, this would save the updated user data to a database or API
    // For now, we'll just simulate a delay
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medical history updated successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical History'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection(
              title: 'Allergies',
              icon: Icons.dangerous,
              items: _user.allergies ?? [],
              controller: _allergiesController,
              addItem: _addAllergy,
              removeItem: _removeAllergy,
              placeholder: 'Add an allergy',
              emptyMessage: 'No allergies recorded',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Current Medications',
              icon: Icons.medication,
              items: _user.medications ?? [],
              controller: _medicationsController,
              addItem: _addMedication,
              removeItem: _removeMedication,
              placeholder: 'Add a medication',
              emptyMessage: 'No medications recorded',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Chronic Conditions',
              icon: Icons.healing,
              items: _user.chronicConditions ?? [],
              controller: _conditionsController,
              addItem: _addCondition,
              removeItem: _removeCondition,
              placeholder: 'Add a chronic condition',
              emptyMessage: 'No chronic conditions recorded',
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Save Medical History',
              onTap: _saveMedicalHistory,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Upload Medical Records',
              onTap: () {
                // Navigate to upload medical records screen
              },
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<String> items,
    required TextEditingController controller,
    required Function(String) addItem,
    required Function(int) removeItem,
    required String placeholder,
    required String emptyMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                hint: placeholder,
                controller: controller,
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.add_circle,
                    color: AppTheme.primaryColor,
                  ),
                  onPressed: () => addItem(controller.text),
                ),
                onChanged: (value) {
                  // Enable submission with enter key
                  if (value.contains('\n')) {
                    addItem(value.replaceAll('\n', ''));
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        items.isEmpty
            ? _buildEmptyState(icon, emptyMessage)
            : _buildItemList(items, icon, removeItem),
      ],
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.textSecondaryColor,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemList(List<String> items, IconData icon, Function(int) removeItem) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            title: Text(items[index]),
            trailing: IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppTheme.errorColor,
                size: 20,
              ),
              onPressed: () => removeItem(index),
            ),
          );
        },
      ),
    );
  }
} 