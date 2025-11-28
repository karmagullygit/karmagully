import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/ads_tracking_service.dart';
import '../../constants/app_colors.dart';

class AdsTrackingSetupScreen extends StatefulWidget {
  const AdsTrackingSetupScreen({super.key});

  @override
  State<AdsTrackingSetupScreen> createState() => _AdsTrackingSetupScreenState();
}

class _AdsTrackingSetupScreenState extends State<AdsTrackingSetupScreen> {
  final _metaPixelController = TextEditingController();
  final _facebookAppController = TextEditingController();
  final _googleAnalyticsController = TextEditingController();
  final _firebaseProjectController = TextEditingController();
  final _googleAdsController = TextEditingController();
  
  Map<String, dynamic>? connectionStatus;
  Map<String, bool>? validationStatus;
  bool isLoading = false;
  int currentTab = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentIds();
    _updateStatus();
  }

  @override
  void dispose() {
    _metaPixelController.dispose();
    _facebookAppController.dispose();
    _googleAnalyticsController.dispose();
    _firebaseProjectController.dispose();
    _googleAdsController.dispose();
    super.dispose();
  }

  void _loadCurrentIds() {
    final currentIds = AdsTrackingService.trackingIds;
    _metaPixelController.text = currentIds['metaPixelId'] ?? '';
    _facebookAppController.text = currentIds['facebookAppId'] ?? '';
    _googleAnalyticsController.text = currentIds['googleAnalyticsId'] ?? '';
    _firebaseProjectController.text = currentIds['firebaseProjectId'] ?? '';
    _googleAdsController.text = currentIds['googleAdsId'] ?? '';
  }

  void _updateStatus() {
    setState(() {
      connectionStatus = AdsTrackingService.getConnectionStatus();
      validationStatus = AdsTrackingService.validateTrackingIds();
    });
  }

  Future<void> _saveIds() async {
    setState(() => isLoading = true);

    try {
      await AdsTrackingService.saveTrackingIds(
        metaPixelId: _metaPixelController.text.trim(),
        facebookAppId: _facebookAppController.text.trim(),
        googleAnalyticsId: _googleAnalyticsController.text.trim(),
        firebaseProjectId: _firebaseProjectController.text.trim(),
        googleAdsId: _googleAdsController.text.trim(),
      );

      _updateStatus();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Tracking IDs saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error saving: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Connect Tracking & Analytics'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (connectionStatus?['overall']['readyForCampaigns'] == true)
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/admin/campaign-analytics'),
              icon: const Icon(Icons.analytics),
              tooltip: 'View Analytics',
            ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            _buildStatusHeader(),
            const TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(icon: Icon(Icons.link), text: 'Connect IDs'),
                Tab(icon: Icon(Icons.code), text: 'Get Code'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildConnectTab(),
                  _buildCodeTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    if (connectionStatus == null) return const SizedBox.shrink();

    final overall = connectionStatus!['overall'];
    final isReady = overall['readyForCampaigns'] ?? false;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isReady ? Colors.green : Colors.orange,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isReady ? Icons.check_circle : Icons.warning,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isReady ? '🎉 Ready for Campaigns!' : '⚠️ Setup Required',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isReady 
                    ? 'Your tracking is configured and working'
                    : 'Enter your tracking IDs to start campaign optimization',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isReady)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'ACTIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConnectTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter Your Tracking IDs',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Just like Hostinger - enter your IDs and we\'ll handle the rest!',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          _buildPlatformSection(
            title: 'Meta (Facebook) Tracking',
            icon: Icons.facebook,
            color: Colors.blue,
            isConnected: connectionStatus?['meta']['connected'] ?? false,
            children: [
              _buildIdField(
                controller: _metaPixelController,
                label: 'Meta Pixel ID',
                hint: 'e.g., 123456789012345',
                helperText: 'Find in Meta Events Manager → Data Sources → Pixels',
                isValid: validationStatus?['metaPixel'] ?? true,
                errorText: 'Invalid format (should be 15-16 digits)',
              ),
              const SizedBox(height: 16),
              _buildIdField(
                controller: _facebookAppController,
                label: 'Facebook App ID',
                hint: 'e.g., 987654321098765',
                helperText: 'Find in Meta for Developers → Your Apps → App ID',
                isValid: validationStatus?['facebookApp'] ?? true,
                errorText: 'Invalid format (should be 15-16 digits)',
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildPlatformSection(
            title: 'Google Analytics & Firebase',
            icon: Icons.analytics,
            color: Colors.orange,
            isConnected: connectionStatus?['google']['connected'] ?? false,
            children: [
              _buildIdField(
                controller: _googleAnalyticsController,
                label: 'Google Analytics ID',
                hint: 'e.g., G-XXXXXXXXXX or UA-XXXXXX-X',
                helperText: 'Find in Google Analytics → Admin → Property Settings',
                isValid: validationStatus?['googleAnalytics'] ?? true,
                errorText: 'Invalid format (G-XXXXXXXXXX or UA-XXXXXX-X)',
              ),
              const SizedBox(height: 16),
              _buildIdField(
                controller: _firebaseProjectController,
                label: 'Firebase Project ID',
                hint: 'e.g., my-app-project',
                helperText: 'Find in Firebase Console → Project Settings → General',
                isValid: validationStatus?['firebaseProject'] ?? true,
                errorText: 'Invalid format (lowercase letters, numbers, hyphens only)',
              ),
              const SizedBox(height: 16),
              _buildIdField(
                controller: _googleAdsController,
                label: 'Google Ads Conversion ID (Optional)',
                hint: 'e.g., AW-1234567890',
                helperText: 'Find in Google Ads → Tools → Conversions',
                isValid: validationStatus?['googleAds'] ?? true,
                errorText: 'Invalid format (AW-XXXXXXXXXX)',
                isOptional: true,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _saveIds,
              icon: isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
              label: Text(isLoading ? 'Saving...' : 'Save & Connect'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
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

  Widget _buildCodeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Integration Code',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Copy and use these codes in your app for automatic tracking',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          if ((connectionStatus?['meta']['connected'] ?? false))
            _buildCodeSection(
              'Meta Pixel Code',
              AdsTrackingService.generateMetaTrackingCode(),
              Icons.facebook,
              Colors.blue,
            ),
          
          const SizedBox(height: 20),
          
          if ((connectionStatus?['google']['connected'] ?? false))
            _buildCodeSection(
              'Google Analytics Code',
              AdsTrackingService.generateGoogleTrackingCode(),
              Icons.analytics,
              Colors.orange,
            ),
          
          const SizedBox(height: 20),
          
          if ((connectionStatus?['overall']['readyForCampaigns'] ?? false))
            _buildCodeSection(
              'Flutter SDK Integration',
              AdsTrackingService.generateFlutterSDKCode(),
              Icons.flutter_dash,
              Colors.blue,
            ),
          
          if (!(connectionStatus?['overall']['readyForCampaigns'] ?? false))
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.info, color: Colors.orange, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Connect Your Tracking IDs First',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Switch to the "Connect IDs" tab and enter your tracking IDs to generate integration code.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlatformSection({
    required String title,
    required IconData icon,
    required Color color,
    required bool isConnected,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isConnected ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isConnected ? 'Connected' : 'Not Connected',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildIdField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String helperText,
    required bool isValid,
    required String errorText,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (isOptional)
              const Text(
                ' (Optional)',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            helperMaxLines: 2,
            helperStyle: const TextStyle(fontSize: 11, color: Colors.grey),
            errorText: !isValid && controller.text.isNotEmpty ? errorText : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: controller.text.isNotEmpty
              ? Icon(
                  isValid ? Icons.check_circle : Icons.error,
                  color: isValid ? Colors.green : Colors.red,
                )
              : null,
          ),
          onChanged: (_) => _updateStatus(),
        ),
      ],
    );
  }

  Widget _buildCodeSection(String title, String code, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied to clipboard!')),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy Code',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText(
                  code,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}