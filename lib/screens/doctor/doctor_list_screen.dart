import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/doctor_provider.dart';
import '../../widgets/doctor_card.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  bool _isInit = true;
  String _searchQuery = '';
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      Provider.of<DoctorProvider>(context, listen: false).fetchDoctors();
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Doctors'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search doctors...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.cardColor,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<DoctorProvider>(
              builder: (ctx, doctorProvider, child) {
                if (doctorProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (doctorProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error loading doctors',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          doctorProvider.error!,
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Provider.of<DoctorProvider>(context, listen: false).fetchDoctors();
                          },
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }
                
                final doctors = doctorProvider.doctors;
                
                if (doctors.isEmpty) {
                  return const Center(
                    child: Text('No doctors found'),
                  );
                }
                
                // Filter doctors based on search query
                final filteredDoctors = _searchQuery.isEmpty
                    ? doctors
                    : doctors.where((doctor) {
                        return doctor.name.toLowerCase().contains(_searchQuery) ||
                               doctor.specialty.toLowerCase().contains(_searchQuery) ||
                               doctor.hospital.toLowerCase().contains(_searchQuery);
                      }).toList();
                
                if (filteredDoctors.isEmpty) {
                  return Center(
                    child: Text(
                      'No doctors match "$_searchQuery"',
                      style: theme.textTheme.bodyLarge,
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDoctors.length,
                  itemBuilder: (ctx, index) {
                    return DoctorCard(doctor: filteredDoctors[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 