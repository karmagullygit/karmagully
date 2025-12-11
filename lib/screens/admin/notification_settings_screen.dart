import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_settings_provider.dart';
import '../../services/whatsapp_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final _adminPhoneController = TextEditingController();
  final _supportPhoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NotificationSettingsProvider>();
      _adminPhoneController.text = provider.adminWhatsAppNumber;
      _supportPhoneController.text = provider.supportWhatsAppNumber;
    });
  }

  @override
  void dispose() {
    _adminPhoneController.dispose();
    _supportPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text(
          'Notification Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1C1F26),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<NotificationSettingsProvider>(
        builder: (context, settings, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('WhatsApp Notifications', Icons.chat_bubble, Colors.green),
                  const SizedBox(height: 16),
                  
                  _buildInfoCard(
                    'Order notifications will be sent via WhatsApp to keep you updated in real-time.',
                    Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSwitchTile(
                    'Enable WhatsApp Notifications',
                    'Receive order notifications on WhatsApp',
                    settings.enableWhatsAppNotifications,
                    (value) => settings.toggleWhatsAppNotifications(value),
                    Icons.notifications_active,
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildSwitchTile(
                    'Send Customer Confirmations',
                    'Automatically send order confirmations to customers',
                    settings.sendCustomerConfirmation,
                    (value) => settings.toggleCustomerConfirmation(value),
                    Icons.mark_email_read,
                    Colors.blue,
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('WhatsApp Numbers', Icons.phone, Colors.purple),
                  const SizedBox(height: 16),
                  
                  _buildPhoneNumberField(
                    controller: _adminPhoneController,
                    label: 'Admin WhatsApp Number',
                    hint: 'e.g., 919876543210',
                    helperText: 'Include country code without + or spaces',
                    icon: Icons.admin_panel_settings,
                    onSave: () async {
                      if (_formKey.currentState!.validate()) {
                        await settings.updateAdminWhatsAppNumber(_adminPhoneController.text);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Admin WhatsApp number updated'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  _buildPhoneNumberField(
                    controller: _supportPhoneController,
                    label: 'Support WhatsApp Number',
                    hint: 'e.g., 919876543210',
                    helperText: 'Customer support WhatsApp number',
                    icon: Icons.support_agent,
                    onSave: () async {
                      if (_formKey.currentState!.validate()) {
                        await settings.updateSupportWhatsAppNumber(_supportPhoneController.text);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Support WhatsApp number updated'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('Email Notifications', Icons.email, Colors.orange),
                  const SizedBox(height: 16),
                  
                  _buildSwitchTile(
                    'Enable Email Notifications',
                    'Receive order notifications via email',
                    settings.enableEmailNotifications,
                    (value) => settings.toggleEmailNotifications(value),
                    Icons.mail_outline,
                    Colors.orange,
                  ),
                  const SizedBox(height: 24),
                  
                  _buildTestSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Text(
            subtitle,
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ),
        activeColor: color,
      ),
    );
  }

  Widget _buildPhoneNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String helperText,
    required IconData icon,
    required VoidCallback onSave,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[600]),
              helperText: helperText,
              helperStyle: TextStyle(color: Colors.grey[500], fontSize: 11),
              prefixIcon: const Icon(Icons.phone, color: Colors.purple),
              filled: true,
              fillColor: const Color(0xFF0A0E21),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a phone number';
              }
              if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value)) {
                return 'Enter valid number (10-15 digits, country code included)';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.save),
              label: const Text('Save Number'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bug_report, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Test Notifications',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Open WhatsApp to verify your notification setup',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final success = await WhatsAppService.openSupportChat();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Opening WhatsApp...'
                            : 'Could not open WhatsApp. Make sure it\'s installed.',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.chat_bubble),
              label: const Text('Test WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
