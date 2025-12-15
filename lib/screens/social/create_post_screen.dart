import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/social_feed_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/social_post.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  
  PostType _selectedType = PostType.text;
  PostPrivacy _selectedPrivacy = PostPrivacy.public;
  final List<String> _mediaUrls = [];
  bool _isPosting = false;

  @override
  void dispose() {
    _contentController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Create Post',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _createPost,
            child: _isPosting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Post',
                    style: TextStyle(
                      color: _contentController.text.trim().isEmpty
                          ? Colors.grey
                          : const Color(0xFF1877F2),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info section
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final currentUser = authProvider.currentUser;
                final profilePic = currentUser?.profilePicture;
                final userName = currentUser?.name ?? 'Your Name';
                
                return Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1877F2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: profilePic != null && profilePic.isNotEmpty
                            ? Builder(builder: (context) {
                                try {
                                  if (profilePic.startsWith('http')) {
                                    return Image.network(
                                      profilePic,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) {
                                        return const Center(
                                          child: Text(
                                            '👤',
                                            style: TextStyle(fontSize: 24),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                  return Image.file(
                                    File(profilePic),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) {
                                      return const Center(
                                        child: Text(
                                          '👤',
                                          style: TextStyle(fontSize: 24),
                                        ),
                                      );
                                    },
                                  );
                                } catch (e) {
                                  return const Center(
                                    child: Text(
                                      '👤',
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  );
                                }
                              })
                            : const Center(
                                child: Text(
                                  '👤',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildPrivacySelector(),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // Content input
            TextField(
              controller: _contentController,
              maxLines: null,
              minLines: 3,
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                hintStyle: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 18),
              onChanged: (value) => setState(() {}),
            ),

            const SizedBox(height: 20),

            // Post type selector
            _buildPostTypeSelector(),

            const SizedBox(height: 20),

            // Media section (if applicable)
            if (_selectedType != PostType.text) ...[
              _buildMediaSection(),
              const SizedBox(height: 20),
            ],

            // Location input
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Add location',
                prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Tags input
            TextField(
              controller: _tagsController,
              decoration: InputDecoration(
                hintText: 'Add tags (separate with commas)',
                prefixIcon: const Icon(Icons.tag, color: Colors.blue),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Additional options
            _buildAdditionalOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySelector() {
    return GestureDetector(
      onTap: _showPrivacySelector,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getPrivacyIcon(_selectedPrivacy),
              size: 14,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              _getPrivacyText(_selectedPrivacy),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Post Type',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTypeButton(PostType.text, '📝', 'Text'),
              const SizedBox(width: 12),
              _buildTypeButton(PostType.image, '📸', 'Photo'),
              const SizedBox(width: 12),
              _buildTypeButton(PostType.video, '🎥', 'Video'),
              const SizedBox(width: 12),
              _buildTypeButton(PostType.mixed, '🎭', 'Mixed'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(PostType type, String emoji, String label) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1877F2) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF1877F2) : Colors.grey[300]!,
            ),
          ),
          child: Column(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _selectedType == PostType.image || _selectedType == PostType.mixed
                    ? Icons.photo_camera
                    : Icons.videocam,
                color: const Color(0xFF1877F2),
              ),
              const SizedBox(width: 8),
              Text(
                _selectedType == PostType.image
                    ? 'Add Photos'
                    : _selectedType == PostType.video
                        ? 'Add Video'
                        : 'Add Media',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_mediaUrls.isEmpty)
            GestureDetector(
              onTap: _addMedia,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 40,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to add ${_selectedType == PostType.image ? 'photos' : _selectedType == PostType.video ? 'video' : 'media'}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._mediaUrls.map((url) => _buildMediaPreview(url)),
                GestureDetector(
                  onTap: _addMedia,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: Colors.grey),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview(String url) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              _selectedType == PostType.video || _selectedType == PostType.mixed
                  ? Icons.play_circle_filled
                  : Icons.image,
              size: 30,
              color: Colors.grey[600],
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeMedia(url),
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additional Options',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _buildOptionTile(
            icon: Icons.mood,
            title: 'Feeling/Activity',
            subtitle: 'Share how you\'re feeling or what you\'re doing',
            onTap: () {},
          ),
          _buildOptionTile(
            icon: Icons.people,
            title: 'Tag People',
            subtitle: 'Tag friends in your post',
            onTap: () {},
          ),
          _buildOptionTile(
            icon: Icons.schedule,
            title: 'Schedule Post',
            subtitle: 'Choose when to publish this post',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF1877F2).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF1877F2),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  IconData _getPrivacyIcon(PostPrivacy privacy) {
    switch (privacy) {
      case PostPrivacy.public:
        return Icons.public;
      case PostPrivacy.friends:
        return Icons.people;
      case PostPrivacy.private:
        return Icons.lock;
    }
  }

  String _getPrivacyText(PostPrivacy privacy) {
    switch (privacy) {
      case PostPrivacy.public:
        return 'Public';
      case PostPrivacy.friends:
        return 'Friends';
      case PostPrivacy.private:
        return 'Only me';
    }
  }

  void _showPrivacySelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Who can see this post?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...PostPrivacy.values.map(
              (privacy) => ListTile(
                leading: Icon(_getPrivacyIcon(privacy)),
                title: Text(_getPrivacyText(privacy)),
                subtitle: Text(_getPrivacyDescription(privacy)),
                trailing: _selectedPrivacy == privacy
                    ? const Icon(Icons.check, color: Color(0xFF1877F2))
                    : null,
                onTap: () {
                  setState(() => _selectedPrivacy = privacy);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getPrivacyDescription(PostPrivacy privacy) {
    switch (privacy) {
      case PostPrivacy.public:
        return 'Anyone on or off KarmaShop';
      case PostPrivacy.friends:
        return 'Your friends on KarmaShop';
      case PostPrivacy.private:
        return 'Only you';
    }
  }

  Future<void> _addMedia() async {
    if (_selectedType == PostType.image) {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _mediaUrls.add(pickedFile.path);
        });
        _showSnackbar('Image added!');
      }
    } else if (_selectedType == PostType.video) {
      final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _mediaUrls.add(pickedFile.path);
        });
        _showSnackbar('Video added!');
      }
    } else {
      final result = await FilePicker.platform.pickFiles(type: FileType.media, allowMultiple: true);
      if (result != null) {
        setState(() {
          _mediaUrls.addAll(result.paths.whereType<String>());
        });
        _showSnackbar('Media added!');
      }
    }
  }

  void _removeMedia(String url) {
    setState(() {
      _mediaUrls.remove(url);
    });
  }

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty) {
      _showSnackbar('Please write something before posting');
      return;
    }

    setState(() => _isPosting = true);

    try {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      await context.read<SocialFeedProvider>().createPost(
            content: _contentController.text.trim(),
            type: _selectedType,
            mediaUrls: _mediaUrls,
            tags: tags,
            location: _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
            privacy: _selectedPrivacy,
          );

      if (mounted) {
        Navigator.pop(context);
        _showSnackbar('Post created successfully! 🎉');
      }
    } catch (e) {
      _showSnackbar('Failed to create post: $e');
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}