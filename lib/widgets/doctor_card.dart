import 'package:flutter/material.dart';
import '../utils/theme/app_theme.dart';

class DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String imageUrl;
  final double rating;
  final int experience;
  final VoidCallback onTap;
  final bool isFeatured;

  const DoctorCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.imageUrl,
    required this.rating,
    required this.experience,
    required this.onTap,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isFeatured ? 220 : double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 2),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Hero(
                    tag: 'doctor-$name',
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: AppTheme.lightBlueBackground,
                      backgroundImage: NetworkImage(imageUrl),
                      onBackgroundImageError: (_, __) {},
                      child: imageUrl.isEmpty
                          ? Icon(
                              Icons.person,
                              size: 36,
                              color: AppTheme.primaryColor,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr. $name',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          specialty,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppTheme.ratingColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toString(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Row(
                              children: [
                                const Icon(
                                  Icons.work_outline,
                                  color: AppTheme.textSecondaryColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$experience yrs',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isFeatured) ...[
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.withOpacity(0.1),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Book Appointment',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 