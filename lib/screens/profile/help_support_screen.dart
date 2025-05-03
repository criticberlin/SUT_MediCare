import 'package:flutter/material.dart';
import '../../utils/theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _messageController = TextEditingController();
  int _selectedFaqIndex = -1;
  bool _isLoading = false;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I book an appointment?',
      'answer': 'You can book an appointment by going to the doctor\'s profile page and selecting your preferred date and time from the available slots. After confirming the details, you can proceed to payment to complete your booking.'
    },
    {
      'question': 'How do I cancel or reschedule an appointment?',
      'answer': 'To cancel or reschedule an appointment, go to the "Appointments" section in the app, select the appointment you want to modify, and choose either "Cancel" or "Reschedule". If you reschedule, you\'ll be able to select a new time slot. Please note that cancellations made less than 24 hours before the appointment may be subject to a cancellation fee.'
    },
    {
      'question': 'How do video consultations work?',
      'answer': 'Video consultations take place directly in the app. At the scheduled time, go to the "Appointments" section, find your appointment, and click "Join Call". Make sure you have a stable internet connection and your device\'s camera and microphone permissions are enabled for the app.'
    },
    {
      'question': 'How do I update my payment information?',
      'answer': 'You can update your payment information in the "Profile" section under "Payment Methods". Here you can add new payment methods, remove existing ones, or set a default payment method for your appointments.'
    },
    {
      'question': 'How do I update my medical history?',
      'answer': 'Your medical history can be updated in the "Profile" section under "Medical History". You can add allergies, medications, chronic conditions, and upload medical records. This information will be available to doctors during your consultations.'
    },
    {
      'question': 'Is my personal and medical information secure?',
      'answer': 'Yes, we take data security very seriously. All your personal and medical information is encrypted and stored securely in compliance with healthcare privacy laws. We never share your information with third parties without your explicit consent.'
    },
  ];

  final List<Map<String, dynamic>> _supportOptions = [
    {
      'title': 'Live Chat',
      'subtitle': 'Chat with our support team',
      'icon': Icons.chat_bubble_outline,
      'color': Colors.blue,
    },
    {
      'title': 'Call Us',
      'subtitle': '+1 (800) 123-4567',
      'icon': Icons.phone,
      'color': Colors.green,
    },
    {
      'title': 'Email Support',
      'subtitle': 'support@medicare.com',
      'icon': Icons.email_outlined,
      'color': Colors.orange,
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitSupportRequest() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // In a real app, this would send the support request to a backend
    // For demo purposes, just simulate a delay and show success message
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
        _messageController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your message has been sent. We\'ll get back to you soon.'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSupportCard(),
          const SizedBox(height: 24),
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          ..._buildFaqList(),
          const SizedBox(height: 24),
          const Text(
            'Contact Us',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactForm(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSupportCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.support_agent,
                color: Colors.white,
                size: 36,
              ),
              SizedBox(width: 16),
              Text(
                '24/7 Support',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Need help? Our support team is available 24/7 to assist you with any issues or questions you might have.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _supportOptions.map((option) {
              return _buildSupportOptionButton(
                title: option['title'],
                subtitle: option['subtitle'],
                icon: option['icon'],
                color: option['color'],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOptionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFaqList() {
    return List.generate(_faqs.length, (index) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        child: ExpansionTile(
          title: Text(
            _faqs[index]['question'] ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Icon(
            _selectedFaqIndex == index
                ? Icons.remove_circle_outline
                : Icons.add_circle_outline,
            color: AppTheme.primaryColor,
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              _selectedFaqIndex = expanded ? index : -1;
            });
          },
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                _faqs[index]['answer'] ?? '',
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Send us a message',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            hint: 'How can we help you?',
            controller: _messageController,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Send Message',
            onTap: _submitSupportRequest,
            isLoading: _isLoading,
            prefixIcon: const Icon(
              Icons.send,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
} 