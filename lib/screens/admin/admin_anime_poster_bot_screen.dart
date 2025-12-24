import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/anime_poster_bot_provider.dart';

class AdminAnimePosterBotScreen extends StatefulWidget {
  const AdminAnimePosterBotScreen({super.key});

  @override
  State<AdminAnimePosterBotScreen> createState() => _AdminAnimePosterBotScreenState();
}

class _AdminAnimePosterBotScreenState extends State<AdminAnimePosterBotScreen> {
  final _intervalController = TextEditingController();
  final _smallPriceController = TextEditingController();
  final _largePriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AnimePosterBotProvider>();
      _intervalController.text = provider.config.uploadIntervalSeconds.toString();
      _smallPriceController.text = provider.config.smallPosterPrice.toString();
      _largePriceController.text = provider.config.largePosterPrice.toString();
      
      // Start periodic stats update
      _startStatsUpdate();
    });
  }

  void _startStatsUpdate() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        context.read<AnimePosterBotProvider>().updateStats();
        _startStatsUpdate();
      }
    });
  }

  @override
  void dispose() {
    _intervalController.dispose();
    _smallPriceController.dispose();
    _largePriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎨 Anime Poster Bot'),
        backgroundColor: const Color(0xFF6B73FF),
      ),
      body: Consumer<AnimePosterBotProvider>(
        builder: (context, provider, child) {
          final config = provider.config;
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Status Card
              Card(
                color: config.isEnabled ? Colors.green.shade50 : Colors.grey.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            config.isEnabled ? Icons.check_circle : Icons.pause_circle,
                            color: config.isEnabled ? Colors.green : Colors.grey,
                            size: 40,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  config.isEnabled ? 'Bot is Active' : 'Bot is Inactive',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: config.isEnabled ? Colors.green.shade700 : Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  config.isEnabled 
                                      ? 'Uploading products every ${config.uploadIntervalSeconds}s'
                                      : 'Enable to start uploading products',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: config.isEnabled,
                            activeColor: Colors.green,
                            onChanged: (value) => provider.toggleBot(value),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Statistics Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📊 Statistics',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow('Total Products Uploaded', '${config.totalProductsUploaded}', Icons.upload_file),
                      const Divider(),
                      _buildStatRow(
                        'Last Upload',
                        config.lastUploadTime != null
                            ? _formatDateTime(config.lastUploadTime!)
                            : 'Never',
                        Icons.access_time,
                      ),
                      const Divider(),
                      _buildStatRow('Upload Interval', '${config.uploadIntervalSeconds}s', Icons.timer),
                      const Divider(),
                      _buildStatRow('Category', config.category, Icons.category),
                      const Divider(),
                      _buildStatRow(
                        'Image Source',
                        config.useGeminiGeneration ? '🤖 Gemini AI' : '🌐 Web Fetch',
                        Icons.image,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Configuration Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '⚙️ Configuration',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      // Upload Interval
                      TextField(
                        controller: _intervalController,
                        decoration: const InputDecoration(
                          labelText: 'Upload Interval (seconds)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.timer),
                          helperText: 'Time between each product upload',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          final interval = int.tryParse(_intervalController.text);
                          if (interval != null && interval > 0) {
                            provider.updateInterval(interval);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('✅ Interval updated to ${interval}s')),
                            );
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Update Interval'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B73FF),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Image Generation Mode
                      const Text(
                        '🖼️ Image Generation',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        color: config.useGeminiGeneration ? Colors.purple.shade50 : Colors.blue.shade50,
                        child: SwitchListTile(
                          title: Text(
                            config.useGeminiGeneration 
                                ? '🤖 Gemini AI Generation' 
                                : '🌐 Web Image Fetch',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            config.useGeminiGeneration
                                ? 'Using AI to generate unique anime posters'
                                : 'Fetching existing anime images from web',
                          ),
                          value: config.useGeminiGeneration,
                          activeColor: Colors.purple,
                          onChanged: (value) => provider.toggleGenerationMode(value),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Pricing
                      const Text(
                        '💰 Pricing',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _smallPriceController,
                              decoration: const InputDecoration(
                                labelText: 'Small Poster (₹)',
                                border: OutlineInputBorder(),
                                prefixText: '₹ ',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _largePriceController,
                              decoration: const InputDecoration(
                                labelText: 'Large Poster (₹)',
                                border: OutlineInputBorder(),
                                prefixText: '₹ ',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          final smallPrice = double.tryParse(_smallPriceController.text);
                          final largePrice = double.tryParse(_largePriceController.text);
                          if (smallPrice != null && largePrice != null) {
                            provider.updatePrices(smallPrice, largePrice);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('✅ Prices updated successfully')),
                            );
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Update Prices'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Info Card
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'How it works',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '• Bot automatically fetches cool anime images from web\n'
                        '• OR uses Gemini AI to generate unique anime posters\n'
                        '• Creates products with auto-generated titles & descriptions\n'
                        '• Uploads products at your specified interval\n'
                        '• Two variants: Small (12x18") and Large (18x24")\n'
                        '• Features popular anime themes like Naruto, One Piece, etc.\n'
                        '• Toggle between AI generation and web fetch modes\n'
                        '• Enable/disable anytime from this panel',
                        style: TextStyle(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6B73FF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B73FF),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    }
  }
}
