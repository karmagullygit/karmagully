import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../constants/app_colors.dart';
import '../../providers/flash_sale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/flash_sale.dart';

class FlashSaleFormScreen extends StatefulWidget {
  final FlashSale? flashSale;

  const FlashSaleFormScreen({super.key, this.flashSale});

  @override
  State<FlashSaleFormScreen> createState() => _FlashSaleFormScreenState();
}

class _FlashSaleFormScreenState extends State<FlashSaleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  File? _pickedImage;
  DateTime? _startTime;
  DateTime? _endTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.flashSale != null) {
      _populateFields(widget.flashSale!);
    }
  }

  void _populateFields(FlashSale sale) {
    _titleController.text = sale.title;
    _descriptionController.text = sale.description;
    if (sale.imageUrl.isNotEmpty) _imageUrlController.text = sale.imageUrl;
    _startTime = sale.startTime;
    _endTime = sale.endTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(isDark),
          appBar: AppBar(
            title: Text(widget.flashSale == null ? 'Create Flash Sale' : 'Edit Flash Sale'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: [
              TextButton(
                onPressed: _isLoading ? null : _saveFlashSale,
                child: Text(widget.flashSale == null ? 'Create' : 'Save', style: const TextStyle(color: Colors.white)),
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicSection(isDark),
                  const SizedBox(height: 12),
                  _buildImageSection(isDark),
                  const SizedBox(height: 12),
                  _buildTimeSection(isDark),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveFlashSale,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                      child: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save Flash Sale'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBasicSection(bool isDark) {
    return Card(
      color: AppColors.getCardBackgroundColor(isDark),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Basic Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title *', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description *', border: OutlineInputBorder()),
              maxLines: 3,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a description' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(bool isDark) {
    return Card(
      color: AppColors.getCardBackgroundColor(isDark),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Banner Image', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 160,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImagePreview(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Pick Image'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _showUrlInputDialog(isDark),
                  icon: const Icon(Icons.link),
                  label: const Text('Use URL'),
                ),
                const SizedBox(width: 8),
                if (_pickedImage != null || _imageUrlController.text.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _pickedImage = null;
                        _imageUrlController.clear();
                      });
                    },
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_pickedImage != null) {
      return Image.file(_pickedImage!, fit: BoxFit.cover, errorBuilder: (c, e, s) => _placeholder());
    }
    final url = _imageUrlController.text.trim();
    if (url.isNotEmpty) {
      if (url.startsWith('file://')) {
        final path = url.replaceFirst('file://', '');
        final f = File(path);
        if (f.existsSync()) return Image.file(f, fit: BoxFit.cover, errorBuilder: (c, e, s) => _placeholder());
      }
      return Image.network(url, fit: BoxFit.cover, loadingBuilder: (c, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator());
      }, errorBuilder: (c, e, s) => _placeholder());
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey)),
    );
  }

  Widget _buildTimeSection(bool isDark) {
    return Card(
      color: AppColors.getCardBackgroundColor(isDark),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sale Duration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Start Time'),
              subtitle: Text(_startTime?.toString() ?? 'Select start time'),
              onTap: () => _selectDateTime(true),
            ),
            ListTile(
              leading: const Icon(Icons.stop),
              title: const Text('End Time'),
              subtitle: Text(_endTime?.toString() ?? 'Select end time'),
              onTap: () => _selectDateTime(false),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);
      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;
        if (path != null) {
          setState(() {
            _pickedImage = File(path);
            _imageUrlController.clear();
          });
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image pick error: $e')));
    }
  }

  void _showUrlInputDialog(bool isDark) {
    final c = TextEditingController(text: _imageUrlController.text.startsWith('http') ? _imageUrlController.text : '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Image URL'),
        content: TextField(controller: c, decoration: const InputDecoration(hintText: 'https://...')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final url = c.text.trim();
              if (url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'))) {
                setState(() {
                  _imageUrlController.text = url;
                  _pickedImage = null;
                });
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid URL')));
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateTime(bool isStart) async {
    final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
    if (date == null) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart) _startTime = dt; else _endTime = dt;
    });
  }

  Future<void> _saveFlashSale() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select start and end times'), backgroundColor: Colors.red));
      return;
    }
    if (_endTime!.isBefore(_startTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End must be after start'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final flashSale = FlashSale(
        id: widget.flashSale?.id ?? 'flash_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _pickedImage != null ? 'file://${_pickedImage!.path}' : _imageUrlController.text.trim(),
        startTime: _startTime!,
        endTime: _endTime!,
        discountPercentage: 0,
        maxDiscountAmount: null,
        productIds: const [],
        categoryIds: const [],
        createdAt: widget.flashSale?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        maxItems: null,
        soldItems: 0,
        bannerColor: null,
        type: 'percentage',
        actionUrl: null,
      );

      final provider = Provider.of<FlashSaleProvider>(context, listen: false);
      final success = widget.flashSale == null ? await provider.createFlashSale(flashSale) : await provider.updateFlashSale(flashSale);
      if (!mounted) return;
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Flash sale saved'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save flash sale'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}