import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../routes.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final bool showDetails;

  const DoctorCard({
    super.key,
    required this.doctor,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
        margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.doctorDetail,
            arguments: doctor,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // Doctor Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: doctor.imageUrl.startsWith('http')
                  ? Image.network(
                      doctor.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          child: Icon(
                              Icons.person,
                            size: 40,
                            color: theme.colorScheme.primary,
                          ),
                        );
                      },
                            )
                  : Image.asset(
                      doctor.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: theme.colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  ),
              const SizedBox(width: 12),
              // Doctor Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            doctor.name,
                            style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        ),
                        if (doctor.isOnline)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                          ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Online',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialty,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
                    ),
                    if (showDetails) ...[
                      const SizedBox(height: 4),
                      Text(
                        doctor.hospital,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                ),
                      const SizedBox(height: 8),
                      Row(
                  children: [
                    Icon(
                            Icons.star,
                            color: Colors.amber,
                      size: 16,
                    ),
                          const SizedBox(width: 4),
                    Text(
                            doctor.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.medical_services_outlined,
                            color: theme.colorScheme.primary,
                            size: 16,
                      ),
                          const SizedBox(width: 4),
                          Text('${doctor.experience} years'),
                        ],
                    ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 