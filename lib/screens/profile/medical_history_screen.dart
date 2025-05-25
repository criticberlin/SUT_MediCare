import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../utils/theme/app_theme.dart';
import '../../utils/theme/theme_provider.dart';
import '../../widgets/custom_button.dart';
import '../../providers/auth_provider.dart';
import 'package:firebase_database/firebase_database.dart';

class MedicalHistoryScreen extends StatefulWidget {
  const MedicalHistoryScreen({super.key});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> with SingleTickerProviderStateMixin {
  User? _user;
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _medicationsController = TextEditingController();
  final TextEditingController _conditionsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _selectedCategory = 0;
  
  // Medical history data
  List<String> _allergies = [];
  List<String> _medications = [];
  List<String> _conditions = [];
  bool _isFetchingData = true;
  
  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Allergies',
      'icon': Icons.dangerous_outlined,
      'color': Colors.redAccent,
    },
    {
      'title': 'Medications',
      'icon': Icons.medication_outlined,
      'color': Colors.blueAccent,
    },
    {
      'title': 'Conditions',
      'icon': Icons.healing_outlined,
      'color': Colors.orangeAccent,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isFetchingData = true;
    });
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _user = authProvider.user;
    
    if (_user != null) {
      try {
        final database = FirebaseDatabase.instance;
        final medicalRef = database.ref('medical_history/${_user!.id}');
        final snapshot = await medicalRef.get();
        
        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            _allergies = List<String>.from(data['allergies'] ?? []);
            _medications = List<String>.from(data['medications'] ?? []);
            _conditions = List<String>.from(data['conditions'] ?? []);
            _isFetchingData = false;
          });
        } else {
          // Create empty medical history record
          await database.ref('medical_history/${_user!.id}').set({
            'allergies': [],
            'medications': [],
            'conditions': [],
            'updatedAt': ServerValue.timestamp,
          });
          setState(() {
            _allergies = [];
            _medications = [];
            _conditions = [];
            _isFetchingData = false;
          });
        }
      } catch (e) {
        print('Error loading medical history: $e');
        setState(() {
          _isFetchingData = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load medical history: $e')),
        );
      }
    } else {
      setState(() {
        _isFetchingData = false;
      });
    }
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    _medicationsController.dispose();
    _conditionsController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _addAllergy(String allergy) {
    if (allergy.isEmpty || _user == null) return;
    
    setState(() {
      _allergies.add(allergy);
      _allergiesController.clear();
    });
    
    _updateFirebaseData('allergies', _allergies);
    
    _animationController.reset();
    _animationController.forward();
  }

  void _removeAllergy(int index) {
    if (_user == null) return;
    
    setState(() {
      _allergies.removeAt(index);
    });
    
    _updateFirebaseData('allergies', _allergies);
  }

  void _addMedication(String medication) {
    if (medication.isEmpty || _user == null) return;
    
    setState(() {
      _medications.add(medication);
      _medicationsController.clear();
    });
    
    _updateFirebaseData('medications', _medications);
    
    _animationController.reset();
    _animationController.forward();
  }

  void _removeMedication(int index) {
    if (_user == null) return;
    
    setState(() {
      _medications.removeAt(index);
    });
    
    _updateFirebaseData('medications', _medications);
  }

  void _addCondition(String condition) {
    if (condition.isEmpty || _user == null) return;
    
    setState(() {
      _conditions.add(condition);
      _conditionsController.clear();
    });
    
    _updateFirebaseData('conditions', _conditions);
    
    _animationController.reset();
    _animationController.forward();
  }

  void _removeCondition(int index) {
    if (_user == null) return;
    
    setState(() {
      _conditions.removeAt(index);
    });
    
    _updateFirebaseData('conditions', _conditions);
  }
  
  Future<void> _updateFirebaseData(String field, List<String> data) async {
    if (_user == null) return;
    
    try {
      final database = FirebaseDatabase.instance;
      await database.ref('medical_history/${_user!.id}/$field').set(data);
      await database.ref('medical_history/${_user!.id}/updatedAt').set(ServerValue.timestamp);
    } catch (e) {
      print('Error updating medical history: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update medical history: $e')),
      );
    }
  }

  void _saveMedicalHistory() {
    if (_user == null) return;
    
    setState(() {
      _isLoading = true;
    });

    // Update all medical history data
    FirebaseDatabase.instance.ref('medical_history/${_user!.id}').update({
      'allergies': _allergies,
      'medications': _medications,
      'conditions': _conditions,
      'updatedAt': ServerValue.timestamp,
    }).then((_) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Medical history updated successfully'),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(8),
        ),
      );
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update medical history: $error')),
      );
    });
  }

  void _changeCategory(int index) {
    setState(() {
      _selectedCategory = index;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    // Check if user is not logged in
    if (_user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Medical History'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: isDarkMode ? Colors.white70 : Colors.grey[700],
              ),
              const SizedBox(height: 16),
              Text(
                'Please sign in to view your medical history',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: isDarkMode ? Colors.white70 : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // Show loading indicator while fetching data
    if (_isFetchingData) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Medical History'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical History'),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, 
              color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
            ),
            onPressed: () {
              // Show help dialog with medical history tips
              showDialog(
                context: context, 
                builder: (context) => AlertDialog(
                  title: Text('About Medical History',
                    style: TextStyle(
                      color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    'Your medical history helps doctors provide better care. Keep this information updated for the best medical advice.',
                    style: TextStyle(
                      color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: Text('Got it'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildCategorySelector(isDarkMode),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildSelectedCategoryContent(isDarkMode),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
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
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(bool isDarkMode) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.2) 
                : Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == index;
          final category = _categories[index];
          
          return GestureDetector(
            onTap: () => _changeCategory(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? category['color'].withOpacity(isDarkMode ? 0.2 : 0.1)
                    : isDarkMode 
                        ? Colors.grey.shade800.withOpacity(0.3)
                        : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected 
                      ? category['color'] 
                      : isDarkMode 
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    category['icon'],
                    color: isSelected 
                        ? category['color']
                        : isDarkMode 
                            ? AppTheme.darkTextSecondaryColor
                            : AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category['title'],
                    style: TextStyle(
                      color: isSelected 
                          ? category['color']
                          : isDarkMode 
                              ? AppTheme.darkTextPrimaryColor
                              : AppTheme.textPrimaryColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedCategoryContent(bool isDarkMode) {
    switch (_selectedCategory) {
      case 0:
        return _buildAllergiesSection(isDarkMode);
      case 1:
        return _buildMedicationsSection(isDarkMode);
      case 2:
        return _buildConditionsSection(isDarkMode);
      default:
        return _buildAllergiesSection(isDarkMode);
    }
  }

  Widget _buildAllergiesSection(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Allergies', 
            Icons.dangerous_outlined, 
            Colors.redAccent,
            isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            _allergiesController,
            'Add an allergy',
            Icons.add_circle,
            Colors.redAccent,
            () => _addAllergy(_allergiesController.text),
            isDarkMode,
          ),
          const SizedBox(height: 24),
          _allergies.isEmpty
              ? _buildEmptyState(
                  Icons.dangerous_outlined, 
                  'No allergies recorded', 
                  Colors.redAccent,
                  isDarkMode,
                )
              : _buildItemsList(
                  _allergies, 
                  Icons.dangerous_outlined, 
                  Colors.redAccent,
                  _removeAllergy,
                  isDarkMode,
                ),
        ],
      ),
    );
  }

  Widget _buildMedicationsSection(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Current Medications', 
            Icons.medication_outlined, 
            Colors.blueAccent,
            isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            _medicationsController,
            'Add a medication',
            Icons.add_circle,
            Colors.blueAccent,
            () => _addMedication(_medicationsController.text),
            isDarkMode,
          ),
          const SizedBox(height: 24),
          _medications.isEmpty
              ? _buildEmptyState(
                  Icons.medication_outlined, 
                  'No medications recorded', 
                  Colors.blueAccent,
                  isDarkMode,
                )
              : _buildItemsList(
                  _medications, 
                  Icons.medication_outlined, 
                  Colors.blueAccent,
                  _removeMedication,
                  isDarkMode,
                ),
        ],
      ),
    );
  }

  Widget _buildConditionsSection(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Chronic Conditions', 
            Icons.healing_outlined, 
            Colors.orangeAccent,
            isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            _conditionsController,
            'Add a chronic condition',
            Icons.add_circle,
            Colors.orangeAccent,
            () => _addCondition(_conditionsController.text),
            isDarkMode,
          ),
          const SizedBox(height: 24),
          _conditions.isEmpty
              ? _buildEmptyState(
                  Icons.healing_outlined, 
                  'No chronic conditions recorded', 
                  Colors.orangeAccent,
                  isDarkMode,
                )
              : _buildItemsList(
                  _conditions, 
                  Icons.healing_outlined, 
                  Colors.orangeAccent,
                  _removeCondition,
                  isDarkMode,
                ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color, bool isDarkMode) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(isDarkMode ? 0.2 : 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String placeholder,
    IconData iconData,
    Color color,
    VoidCallback onAdd,
    bool isDarkMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.2) 
                : Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(
            color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              iconData,
              color: color,
            ),
            onPressed: onAdd,
          ),
        ),
        style: TextStyle(
          color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            onAdd();
          }
        },
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String message, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.2) 
                : Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(isDarkMode ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button above to add',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(
    List<String> items,
    IconData icon,
    Color color,
    Function(int) removeItem,
    bool isDarkMode,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildItemCard(
          items[index], 
          icon, 
          color, 
          () => removeItem(index),
          index,
          isDarkMode,
        );
      },
    );
  }

  Widget _buildItemCard(
    String item,
    IconData icon,
    Color color,
    VoidCallback onRemove,
    int index,
    bool isDarkMode,
  ) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.2) 
                : Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(isDarkMode ? 0.2 : 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          item,
          style: TextStyle(
            color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: isDarkMode ? Colors.redAccent.shade200 : Colors.redAccent,
            size: 20,
          ),
          onPressed: onRemove,
        ),
      ),
    );
  }
} 