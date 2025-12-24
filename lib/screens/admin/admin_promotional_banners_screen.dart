import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../../providers/promotional_banner_provider.dart';
import '../../models/promotional_banner.dart';

class AdminPromotionalBannersScreen extends StatefulWidget {
  const AdminPromotionalBannersScreen({super.key});

  @override
  State<AdminPromotionalBannersScreen> createState() => _AdminPromotionalBannersScreenState();
}

class _AdminPromotionalBannersScreenState extends State<AdminPromotionalBannersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PromotionalBannerProvider>().loadBanners();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promotional Banners'),
        backgroundColor: const Color(0xFF6B73FF),
      ),
      body: Consumer<PromotionalBannerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6B73FF)),
            );
          }

          if (provider.banners.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No promotional banners yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first banner to promote sales',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.banners.length,
            itemBuilder: (context, index) {
              final banner = provider.banners[index];
              return _buildBannerCard(banner, provider);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBannerDialog(context),
        backgroundColor: const Color(0xFF6B73FF),
        icon: const Icon(Icons.add),
        label: const Text('Create Banner'),
      ),
    );
  }

  Widget _buildBannerCard(PromotionalBanner banner, PromotionalBannerProvider provider) {
    final isExpired = DateTime.now().isAfter(banner.endDate);
    final isUpcoming = DateTime.now().isBefore(banner.startDate);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Preview
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: banner.backgroundColor != null 
                  ? Color(int.parse(banner.backgroundColor!.replaceFirst('#', '0xFF')))
                  : const Color(0xFF6B73FF),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Stack(
              children: [
                if (banner.imageUrl != null && banner.imageUrl!.isNotEmpty)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: _buildBannerImage(banner.imageUrl!),
                    ),
                  ),
                Positioned.fill(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                banner.title,
                                style: TextStyle(
                                  color: banner.textColor != null
                                      ? Color(int.parse(banner.textColor!.replaceFirst('#', '0xFF')))
                                      : Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (banner.subtitle.isNotEmpty)
                                Text(
                                  banner.subtitle,
                                  style: TextStyle(
                                    color: banner.textColor != null
                                        ? Color(int.parse(banner.textColor!.replaceFirst('#', '0xFF')))
                                        : Colors.white70,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: banner.buttonColor != null
                                ? Color(int.parse(banner.buttonColor!.replaceFirst('#', '0xFF')))
                                : Colors.amber,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                banner.buttonText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward, size: 14, color: Colors.black),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Banner Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                banner.isActive ? Icons.check_circle : Icons.cancel,
                                color: banner.isActive ? Colors.green : Colors.grey,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                banner.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: banner.isActive ? Colors.green : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isExpired) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Expired',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              if (isUpcoming) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Upcoming',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Priority: ${banner.priority}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(banner.isActive ? Icons.pause_circle : Icons.play_circle),
                          color: const Color(0xFF6B73FF),
                          onPressed: () async {
                            await provider.toggleBannerStatus(banner.id);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          color: Colors.orange,
                          onPressed: () => _showBannerDialog(context, banner: banner),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () => _confirmDelete(context, banner.id, provider),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.calendar_today, 
                  '${_formatDate(banner.startDate)} - ${_formatDate(banner.endDate)}'),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.location_on, 
                  'Pages: ${banner.targetPages.join(", ")}'),
                if (banner.targetCategories.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _buildInfoRow(Icons.category, 
                    'Categories: ${banner.targetCategories.join(", ")}'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildBannerImage(String imageUrl) {
    // Check if it's a base64 encoded image
    if (imageUrl.startsWith('data:image/')) {
      try {
        final base64String = imageUrl.split(',')[1];
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(),
        );
      } catch (e) {
        return Container();
      }
    } else {
      // It's a regular URL
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => Container(),
      );
    }
  }

  void _confirmDelete(BuildContext context, String bannerId, PromotionalBannerProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Banner'),
        content: const Text('Are you sure you want to delete this banner?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.deleteBanner(bannerId);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showBannerDialog(BuildContext context, {PromotionalBanner? banner}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _BannerFormScreen(banner: banner),
      ),
    );
  }
}

class _BannerFormScreen extends StatefulWidget {
  final PromotionalBanner? banner;

  const _BannerFormScreen({this.banner});

  @override
  State<_BannerFormScreen> createState() => _BannerFormScreenState();
}

class _BannerFormScreenState extends State<_BannerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _imageUrlController;
  late TextEditingController _buttonTextController;
  late TextEditingController _buttonLinkController;
  late TextEditingController _priorityController;
  
  String _backgroundColor = '#6B73FF';
  String _textColor = '#FFFFFF';
  String _buttonColor = '#FFC107';
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _selectedPages = ['all'];
  List<String> _selectedCategories = [];
  File? _backgroundImage;
  String _buttonLinkType = 'predefined'; // 'predefined' or 'custom'
  
  final List<Map<String, String>> _appRoutes = [
    {'name': 'Home', 'route': '/'},
    {'name': 'Flash Sales', 'route': '/customer-flash-sales'},
    {'name': 'Flash Sale Detail', 'route': '/flash-sale-detail'},
    {'name': 'Social Feed', 'route': '/social-feed'},
    {'name': 'Notifications', 'route': '/notifications'},
    {'name': 'Order History', 'route': '/order-history'},
    {'name': 'Addresses', 'route': '/addresses'},
    {'name': 'Customer Support', 'route': '/customer-support'},
    {'name': 'Custom Link', 'route': 'custom'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.banner?.title ?? '');
    _subtitleController = TextEditingController(text: widget.banner?.subtitle ?? '');
    _imageUrlController = TextEditingController(text: widget.banner?.imageUrl ?? '');
    _buttonTextController = TextEditingController(text: widget.banner?.buttonText ?? 'Shop Now');
    _buttonLinkController = TextEditingController(text: widget.banner?.buttonLink ?? '');
    _priorityController = TextEditingController(text: widget.banner?.priority.toString() ?? '0');
    
    if (widget.banner != null) {
      _backgroundColor = widget.banner!.backgroundColor ?? '#6B73FF';
      _textColor = widget.banner!.textColor ?? '#FFFFFF';
      _buttonColor = widget.banner!.buttonColor ?? '#FFC107';
      _startDate = widget.banner!.startDate;
      _endDate = widget.banner!.endDate;
      _selectedPages = List.from(widget.banner!.targetPages);
      _selectedCategories = List.from(widget.banner!.targetCategories);
      
      // Check if button link is predefined or custom
      final buttonLink = widget.banner!.buttonLink ?? '';
      if (buttonLink.isNotEmpty && !_appRoutes.any((r) => r['route'] == buttonLink)) {
        _buttonLinkType = 'custom';
      }
    } else {
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 7));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _imageUrlController.dispose();
    _buttonTextController.dispose();
    _buttonLinkController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.banner == null ? 'Create Banner' : 'Edit Banner'),
        backgroundColor: const Color(0xFF6B73FF),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
                hintText: '50-90% SALE IS LIVE!',
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subtitleController,
              decoration: const InputDecoration(
                labelText: 'Subtitle (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _buttonTextController,
              decoration: const InputDecoration(
                labelText: 'Button Text *',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            
            // Button Link Section
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _buttonLinkType == 'custom' ? 'custom' : (_buttonLinkController.text.isEmpty ? null : _buttonLinkController.text),
                    decoration: const InputDecoration(
                      labelText: 'Button Link (optional)',
                      border: OutlineInputBorder(),
                    ),
                    items: _appRoutes.map((route) {
                      return DropdownMenuItem(
                        value: route['route'],
                        child: Text(route['name']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        if (value == 'custom') {
                          _buttonLinkType = 'custom';
                          _buttonLinkController.text = '';
                        } else {
                          _buttonLinkType = 'predefined';
                          _buttonLinkController.text = value ?? '';
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            
            if (_buttonLinkType == 'custom') ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _buttonLinkController,
                decoration: const InputDecoration(
                  labelText: 'Custom Link',
                  border: OutlineInputBorder(),
                  hintText: '/category/sale or https://...',
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Background Design Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Banner Background *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Upload Custom Background Design
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      if (_backgroundImage != null)
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                              child: Image.file(
                                _backgroundImage!,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () => setState(() {
                                  _backgroundImage = null;
                                  _imageUrlController.clear();
                                }),
                              ),
                            ),
                          ],
                        )
                      else if (_imageUrlController.text.isNotEmpty)
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                              child: Image.network(
                                _imageUrlController.text,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) => Container(
                                  height: 120,
                                  color: Colors.grey.shade200,
                                  child: const Center(child: Icon(Icons.broken_image, size: 40)),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () => setState(() => _imageUrlController.clear()),
                              ),
                            ),
                          ],
                        )
                      else
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Color(int.parse(_backgroundColor.replaceFirst('#', '0xFF'))),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.wallpaper, size: 40, color: Colors.white.withOpacity(0.7)),
                                const SizedBox(height: 8),
                                Text(
                                  'No background image',
                                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickBackgroundImage,
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Upload Custom Background Design'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6B73FF),
                                minimumSize: const Size(double.infinity, 48),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Upload your own design (e.g., blue with stars, gradient, pattern)',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _imageUrlController,
                              decoration: const InputDecoration(
                                labelText: 'Or use image URL',
                                border: OutlineInputBorder(),
                                hintText: 'https://example.com/background.jpg',
                                isDense: true,
                              ),
                              onChanged: (_) => setState(() => _backgroundImage = null),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Fallback Background Color (if no image)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priorityController,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fallback Color', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                      Text('(if no image)', style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _pickColor('background'),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(int.parse(_backgroundColor.replaceFirst('#', '0xFF'))),
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Text Color', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _pickColor('text'),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(int.parse(_textColor.replaceFirst('#', '0xFF'))),
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Button Color', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _pickColor('button'),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(int.parse(_buttonColor.replaceFirst('#', '0xFF'))),
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Start Date'),
              subtitle: Text(_startDate == null ? 'Not set' : _formatDate(_startDate!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _startDate = date);
                }
              },
            ),
            ListTile(
              title: const Text('End Date'),
              subtitle: Text(_endDate == null ? 'Not set' : _formatDate(_endDate!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endDate ?? DateTime.now().add(const Duration(days: 7)),
                  firstDate: _startDate ?? DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _endDate = date);
                }
              },
            ),
            const SizedBox(height: 16),
            const Text('Show on Pages:', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: ['all', 'search', 'category', 'home'].map((page) {
                return FilterChip(
                  label: Text(page),
                  selected: _selectedPages.contains(page),
                  onSelected: (selected) {
                    setState(() {
                      if (page == 'all') {
                        _selectedPages = selected ? ['all'] : [];
                      } else {
                        _selectedPages.remove('all');
                        if (selected) {
                          _selectedPages.add(page);
                        } else {
                          _selectedPages.remove(page);
                        }
                        if (_selectedPages.isEmpty) {
                          _selectedPages.add('all');
                        }
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveBanner,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B73FF),
                padding: const EdgeInsets.all(16),
              ),
              child: Text(widget.banner == null ? 'Create Banner' : 'Update Banner'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _pickColor(String type) {
    final colorMap = {
      'background': {'title': 'Background', 'current': _backgroundColor},
      'text': {'title': 'Text', 'current': _textColor},
      'button': {'title': 'Button', 'current': _buttonColor},
    };
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose ${colorMap[type]!['title']} Color'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            '#6B73FF', '#FF6B6B', '#4ECDC4', '#FFC107', '#FFD93D', '#6C5CE7', '#A8E6CF', '#FF9800', '#E91E63', '#9C27B0'
          ].map((color) {
            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
              ),
              title: Text(color),
              onTap: () {
                setState(() {
                  if (type == 'background') {
                    _backgroundColor = color;
                  } else if (type == 'text') {
                    _textColor = color;
                  } else if (type == 'button') {
                    _buttonColor = color;
                  }
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _pickBackgroundImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _backgroundImage = File(pickedFile.path);
        _imageUrlController.clear(); // Clear URL if image is picked
      });
    }
  }

  Future<void> _saveBanner() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }

    final provider = context.read<PromotionalBannerProvider>();
    
    // Convert local image to base64 if selected
    String? imageData;
    if (_backgroundImage != null) {
      final bytes = await _backgroundImage!.readAsBytes();
      final base64String = base64Encode(bytes);
      imageData = 'data:image/jpeg;base64,$base64String';
    } else if (_imageUrlController.text.isNotEmpty) {
      imageData = _imageUrlController.text;
    }
    
    final banner = PromotionalBanner(
      id: widget.banner?.id ?? 'banner_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text,
      subtitle: _subtitleController.text,
      imageUrl: imageData,
      backgroundColor: _backgroundColor,
      textColor: _textColor,
      buttonColor: _buttonColor,
      buttonText: _buttonTextController.text,
      buttonLink: _buttonLinkController.text.isEmpty ? null : _buttonLinkController.text,
      isActive: widget.banner?.isActive ?? true,
      startDate: _startDate!,
      endDate: _endDate!,
      targetPages: _selectedPages,
      targetCategories: _selectedCategories,
      priority: int.tryParse(_priorityController.text) ?? 0,
    );

    final success = widget.banner == null 
        ? await provider.addBanner(banner)
        : await provider.updateBanner(banner);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Banner ${widget.banner == null ? "created" : "updated"} successfully')),
      );
    }
  }
}
