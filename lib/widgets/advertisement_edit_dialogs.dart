import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/advertisement_provider.dart';
import '../../models/advertisement.dart';
import '../../models/carousel_banner.dart';
import '../../widgets/image_upload_widget.dart';
import '../../widgets/video_upload_widget.dart';

class EditBannerDialog extends StatefulWidget {
  final CarouselBanner banner;

  const EditBannerDialog({super.key, required this.banner});

  @override
  State<EditBannerDialog> createState() => _EditBannerDialogState();
}

class _EditBannerDialogState extends State<EditBannerDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _actionUrlController;
  late TextEditingController _orderController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  String _selectedImagePath = '';
  Color _backgroundColor = Colors.blue;
  Color _textColor = Colors.white;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimations();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.banner.title);
    _subtitleController = TextEditingController(text: widget.banner.subtitle);
    _actionUrlController = TextEditingController(text: widget.banner.actionUrl ?? '');
    _orderController = TextEditingController(text: widget.banner.order.toString());
    
    _selectedImagePath = widget.banner.imageUrl; // Initialize with existing image path/URL
    _backgroundColor = _parseColor(widget.banner.backgroundColor);
    _textColor = _parseColor(widget.banner.textColor);
    _isActive = widget.banner.isActive;
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _actionUrlController.dispose();
    _orderController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  String _colorToString(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.blue.shade50,
              ],
            ),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildForm(),
              ),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.edit,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Edit Banner',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Basic Information'),
            const SizedBox(height: 16),
            _buildAnimatedTextField(
              controller: _titleController,
              label: 'Banner Title',
              icon: Icons.title,
              validator: (value) => value?.isEmpty == true ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            _buildAnimatedTextField(
              controller: _subtitleController,
              label: 'Subtitle (Optional)',
              icon: Icons.text_fields,
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Media & Links'),
            const SizedBox(height: 16),
            
            // Replace URL input with image upload widget
            const Text(
              'Banner Image',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ImageUploadWidget(
              imagePaths: _selectedImagePath.isNotEmpty ? [_selectedImagePath] : [],
              onImagesChanged: (List<String> imagePaths) {
                setState(() {
                  _selectedImagePath = imagePaths.isNotEmpty ? imagePaths.first : '';
                });
              },
              maxImages: 1,
            ),
            const SizedBox(height: 16),
            _buildAnimatedTextField(
              controller: _actionUrlController,
              label: 'Action URL (Optional)',
              icon: Icons.link,
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Display Settings'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAnimatedTextField(
                    controller: _orderController,
                    label: 'Display Order',
                    icon: Icons.sort,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Order is required';
                      if (int.tryParse(value!) == null) return 'Must be a number';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Appearance'),
            const SizedBox(height: 16),
            _buildColorPickers(),
            const SizedBox(height: 20),
            _buildActiveSwitch(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue.shade700,
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: TextFormField(
              controller: controller,
              validator: validator,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon, color: Colors.blue.shade600),
                suffixIcon: suffixIcon,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorPickers() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Background Color', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showColorPicker(true),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Center(
                    child: Text(
                      _colorToString(_backgroundColor),
                      style: TextStyle(
                        color: _backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Text Color', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showColorPicker(false),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: _textColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Center(
                    child: Text(
                      _colorToString(_textColor),
                      style: TextStyle(
                        color: _textColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSwitch() {
    return Row(
      children: [
        Icon(Icons.power_settings_new, color: Colors.blue.shade600),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Active Banner',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        Switch(
          value: _isActive,
          onChanged: (value) {
            setState(() {
              _isActive = value;
            });
          },
          activeColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveBanner,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(bool isBackground) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isBackground ? 'Background Color' : 'Text Color'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Colors.blue, Colors.red, Colors.green, Colors.orange,
                Colors.purple, Colors.teal, Colors.pink, Colors.indigo,
                Colors.black, Colors.white, Colors.grey,
              ].map((color) => GestureDetector(
                onTap: () {
                  setState(() {
                    if (isBackground) {
                      _backgroundColor = color;
                    } else {
                      _textColor = color;
                    }
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _saveBanner() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate that an image is selected
    if (_selectedImagePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedBanner = CarouselBanner(
        id: widget.banner.id,
        title: _titleController.text.trim(),
        subtitle: _subtitleController.text.trim(),
        imageUrl: _selectedImagePath,
        actionUrl: _actionUrlController.text.trim(),
        backgroundColor: _colorToString(_backgroundColor),
        textColor: _colorToString(_textColor),
        order: int.parse(_orderController.text),
        isActive: _isActive,
        startDate: widget.banner.startDate,
        endDate: widget.banner.endDate,
        createdAt: widget.banner.createdAt,
        updatedAt: DateTime.now(),
      );

      Provider.of<AdvertisementProvider>(context, listen: false)
          .updateCarouselBanner(widget.banner.id, updatedBanner);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Banner updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating banner: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class EditAdvertisementDialog extends StatefulWidget {
  final Advertisement advertisement;

  const EditAdvertisementDialog({super.key, required this.advertisement});

  @override
  State<EditAdvertisementDialog> createState() => _EditAdvertisementDialogState();
}

class _EditAdvertisementDialogState extends State<EditAdvertisementDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _actionUrlController;
  late TextEditingController _priorityController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  String _selectedImagePath = '';
  String _selectedVideoPath = '';
  AdType _adType = AdType.video;
  AdPlacement _placement = AdPlacement.floatingVideo;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimations();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.advertisement.title);
    _descriptionController = TextEditingController(text: widget.advertisement.description);
    _actionUrlController = TextEditingController(text: widget.advertisement.actionUrl);
    _priorityController = TextEditingController(text: widget.advertisement.priority.toString());
    
    // Initialize with existing paths/URLs
    _selectedImagePath = widget.advertisement.imageUrl;
    _selectedVideoPath = widget.advertisement.videoUrl ?? '';
    
    _adType = widget.advertisement.type;
    _placement = widget.advertisement.placement;
    _isActive = widget.advertisement.isActive;
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _actionUrlController.dispose();
    _priorityController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.orange.shade50,
              ],
            ),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildForm(),
              ),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          colors: [Colors.orange.shade600, Colors.orange.shade400],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.video_library,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Edit Advertisement',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Basic Information'),
            const SizedBox(height: 16),
            _buildAnimatedTextField(
              controller: _titleController,
              label: 'Advertisement Title',
              icon: Icons.title,
              validator: (value) => value?.isEmpty == true ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            _buildAnimatedTextField(
              controller: _descriptionController,
              label: 'Description',
              icon: Icons.description,
              maxLines: 3,
              validator: (value) => value?.isEmpty == true ? 'Description is required' : null,
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Media Files'),
            const SizedBox(height: 16),
            
            // Image Upload Widget
            const Text(
              'Thumbnail Image',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ImageUploadWidget(
              imagePaths: _selectedImagePath.isNotEmpty ? [_selectedImagePath] : [],
              onImagesChanged: (List<String> imagePaths) {
                setState(() {
                  _selectedImagePath = imagePaths.isNotEmpty ? imagePaths.first : '';
                });
              },
              maxImages: 1,
            ),
            const SizedBox(height: 16),
            
            // Video Upload Widget  
            const Text(
              'Video File (for video ads)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            VideoUploadWidget(
              videoPath: _selectedVideoPath.isNotEmpty ? _selectedVideoPath : null,
              onVideoChanged: (String? videoPath) {
                setState(() {
                  _selectedVideoPath = videoPath ?? '';
                });
              },
              label: 'Select Video',
            ),
            const SizedBox(height: 16),
            _buildAnimatedTextField(
              controller: _actionUrlController,
              label: 'Action URL (Optional)',
              icon: Icons.link,
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Advertisement Settings'),
            const SizedBox(height: 16),
            _buildDropdowns(),
            const SizedBox(height: 16),
            _buildAnimatedTextField(
              controller: _priorityController,
              label: 'Priority (1-10)',
              icon: Icons.priority_high,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty == true) return 'Priority is required';
                final priority = int.tryParse(value!);
                if (priority == null || priority < 1 || priority > 10) {
                  return 'Priority must be between 1 and 10';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildActiveSwitch(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.orange.shade700,
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    int maxLines = 1,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: TextFormField(
              controller: controller,
              validator: validator,
              keyboardType: keyboardType,
              maxLines: maxLines,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon, color: Colors.orange.shade600),
                suffixIcon: suffixIcon,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.orange.shade600, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdowns() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ad Type', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              DropdownButtonFormField<AdType>(
                value: _adType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: AdType.values.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last.toUpperCase()),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _adType = value!;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Placement', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              DropdownButtonFormField<AdPlacement>(
                value: _placement,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: AdPlacement.values.map((placement) => DropdownMenuItem(
                  value: placement,
                  child: Text(placement.toString().split('.').last.toUpperCase()),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _placement = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSwitch() {
    return Row(
      children: [
        Icon(Icons.power_settings_new, color: Colors.orange.shade600),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Active Advertisement',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        Switch(
          value: _isActive,
          onChanged: (value) {
            setState(() {
              _isActive = value;
            });
          },
          activeColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveAdvertisement,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  void _saveAdvertisement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedAd = Advertisement(
        id: widget.advertisement.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _selectedImagePath,
        videoUrl: _selectedVideoPath.isNotEmpty ? _selectedVideoPath : null,
        actionUrl: _actionUrlController.text.trim(),
        type: _adType,
        placement: _placement,
        priority: int.parse(_priorityController.text),
        isActive: _isActive,
        createdAt: widget.advertisement.createdAt,
        updatedAt: DateTime.now(),
        startDate: widget.advertisement.startDate,
        endDate: widget.advertisement.endDate,
        metadata: widget.advertisement.metadata,
      );

      Provider.of<AdvertisementProvider>(context, listen: false)
          .updateAdvertisement(widget.advertisement.id, updatedAd);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Advertisement updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating advertisement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}