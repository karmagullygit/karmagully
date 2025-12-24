import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/social_feed_provider.dart';
import '../../services/official_bot_service.dart';

class AdminOfficialBotScreen extends StatefulWidget {
  const AdminOfficialBotScreen({super.key});

  @override
  State<AdminOfficialBotScreen> createState() => _AdminOfficialBotScreenState();
}

class _AdminOfficialBotScreenState extends State<AdminOfficialBotScreen> {
  final _contentController = TextEditingController();
  final _titleController = TextEditingController();
  final _promoCodeController = TextEditingController();
  final _linkController = TextEditingController();
  
  List<File> _selectedImages = [];
  File? _selectedVideo;
  String _postType = 'custom';
  
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    _promoCodeController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      setState(() {
        _selectedImages = images.map((xFile) => File(xFile.path)).toList();
        _selectedVideo = null; // Clear video if images selected
      });
    } catch (e) {
      _showSnackBar('Error picking images: $e', isError: true);
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          _selectedVideo = File(video.path);
          _selectedImages = []; // Clear images if video selected
        });
      }
    } catch (e) {
      _showSnackBar('Error picking video: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _postContent() async {
    if (_contentController.text.trim().isEmpty && _titleController.text.trim().isEmpty) {
      _showSnackBar('Please enter some content', isError: true);
      return;
    }

    final socialProvider = Provider.of<SocialFeedProvider>(context, listen: false);
    final botService = OfficialBotService(socialProvider);

    // Prepare media URLs (for demo, using file paths - in production use cloud storage)
    List<String> mediaUrls = [];
    if (_selectedImages.isNotEmpty) {
      mediaUrls = _selectedImages.map((file) => file.path).toList();
    } else if (_selectedVideo != null) {
      mediaUrls = [_selectedVideo!.path];
    }

    bool success = false;

    setState(() => _isPosting = true);

    switch (_postType) {
      case 'announcement':
        success = await botService.postAnnouncement(
          content: _contentController.text.trim(),
          mediaUrls: mediaUrls,
        );
        break;
      case 'reel':
        if (_selectedVideo == null) {
          _showSnackBar('Please select a video for reels', isError: true);
          setState(() => _isPosting = false);
          return;
        }
        success = await botService.postReel(
          content: _contentController.text.trim(),
          videoUrl: _selectedVideo!.path,
        );
        break;
      case 'story':
        success = await botService.postStory(
          content: _contentController.text.trim(),
          mediaUrls: mediaUrls,
        );
        break;
      case 'promotion':
        if (_titleController.text.trim().isEmpty) {
          _showSnackBar('Please enter promotion title', isError: true);
          setState(() => _isPosting = false);
          return;
        }
        success = await botService.postPromotion(
          title: _titleController.text.trim(),
          description: _contentController.text.trim(),
          mediaUrls: mediaUrls,
          promoCode: _promoCodeController.text.trim().isEmpty ? null : _promoCodeController.text.trim(),
          link: _linkController.text.trim().isEmpty ? null : _linkController.text.trim(),
        );
        break;
      case 'custom':
      default:
        success = await botService.postCustomContent(
          content: _contentController.text.trim(),
          mediaUrls: mediaUrls,
        );
        break;
    }

    setState(() => _isPosting = false);

    if (success) {
      _showSnackBar('✅ Posted successfully as KarmaGully Official!');
      _clearForm();
    } else {
      _showSnackBar('❌ Failed to post. Please try again.', isError: true);
    }
  }

  void _clearForm() {
    _contentController.clear();
    _titleController.clear();
    _promoCodeController.clear();
    _linkController.clear();
    setState(() {
      _selectedImages = [];
      _selectedVideo = null;
    });
  }

  bool _isPosting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 KarmaGully Official Bot'),
        backgroundColor: const Color(0xFF6B73FF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bot Info Card
            Card(
              color: Colors.purple.shade50,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 48)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'KarmaGully Official',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Post announcements, reels, stories, and promotions',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Post Type Selection
            const Text(
              'Post Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildTypeChip('custom', 'Custom', Icons.edit),
                _buildTypeChip('announcement', 'Announcement', Icons.campaign),
                _buildTypeChip('reel', 'Reel/Short', Icons.video_library),
                _buildTypeChip('story', 'Story', Icons.auto_stories),
                _buildTypeChip('promotion', 'Promotion', Icons.local_offer),
              ],
            ),
            const SizedBox(height: 24),

            // Promotion Title (only for promotion type)
            if (_postType == 'promotion') ...[
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Promotion Title *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                maxLength: 100,
              ),
              const SizedBox(height: 16),
            ],

            // Content Input
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: _postType == 'promotion' ? 'Description *' : 'Content *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              maxLength: 1000,
            ),
            const SizedBox(height: 16),

            // Promo Code (only for promotion type)
            if (_postType == 'promotion') ...[
              TextField(
                controller: _promoCodeController,
                decoration: InputDecoration(
                  labelText: 'Promo Code (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.confirmation_number),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _linkController,
                decoration: InputDecoration(
                  labelText: 'Link (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Media Selection
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _postType == 'reel' ? null : _pickImages,
                    icon: const Icon(Icons.image),
                    label: Text(_postType == 'reel' ? 'Images disabled for reels' : 'Select Images'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickVideo,
                    icon: const Icon(Icons.videocam),
                    label: const Text('Select Video'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Selected Media Preview
            if (_selectedImages.isNotEmpty) ...[
              const Text(
                'Selected Images:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _selectedImages[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImages.removeAt(index);
                                });
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_selectedVideo != null) ...[
              const Text(
                'Selected Video:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.video_library, size: 48),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _selectedVideo!.path.split('/').last,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedVideo = null;
                        });
                      },
                      icon: const Icon(Icons.close, color: Colors.red),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Post Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPosting ? null : _postContent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B73FF),
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isPosting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Post as KarmaGully Official',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Clear Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _clearForm,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Clear Form'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String value, String label, IconData icon) {
    final isSelected = _postType == value;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        setState(() {
          _postType = value;
        });
      },
      selectedColor: const Color(0xFF6B73FF),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
    );
  }
}
