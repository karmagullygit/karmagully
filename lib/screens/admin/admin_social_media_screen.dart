import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/social_media_provider.dart';
import '../../models/social_media_link.dart';

class AdminSocialMediaScreen extends StatefulWidget {
  const AdminSocialMediaScreen({super.key});

  @override
  State<AdminSocialMediaScreen> createState() => _AdminSocialMediaScreenState();
}

class _AdminSocialMediaScreenState extends State<AdminSocialMediaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SocialMediaProvider>(context, listen: false).loadSocialMediaLinks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text(
          'Social Media Links',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1C1F26),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.purple),
            onPressed: () => _showAddEditDialog(context, null),
            tooltip: 'Add Social Media',
          ),
        ],
      ),
      body: Consumer<SocialMediaProvider>(
        builder: (context, provider, child) {
          final links = provider.allLinks;

          if (links.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.share, size: 80, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text(
                    'No social media links added',
                    style: TextStyle(color: Colors.grey[400], fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditDialog(context, null),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Social Media Link'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: links.length,
            onReorder: (oldIndex, newIndex) {
              provider.reorderLinks(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final link = links[index];
              return _buildSocialMediaCard(context, link, provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildSocialMediaCard(BuildContext context, SocialMediaLink link, SocialMediaProvider provider) {
    return Container(
      key: ValueKey(link.id),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1C1F26),
        border: Border.all(
          color: link.isActive ? Colors.purple.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getIconColor(link.iconName).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: FaIcon(
              _getIconData(link.iconName),
              color: _getIconColor(link.iconName),
              size: 26,
            ),
          ),
        ),
        title: Text(
          link.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              link.url,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: link.isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    link.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: link.isActive ? Colors.green : Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Order: ${link.order}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: const Color(0xFF1C1F26),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showAddEditDialog(context, link);
                break;
              case 'toggle':
                provider.toggleLinkStatus(link.id);
                break;
              case 'test':
                _launchURL(link.url);
                break;
              case 'delete':
                _showDeleteDialog(context, link, provider);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text('Edit', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    link.isActive ? Icons.visibility_off : Icons.visibility,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    link.isActive ? 'Deactivate' : 'Activate',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'test',
              child: Row(
                children: [
                  Icon(Icons.open_in_new, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text('Test Link', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, SocialMediaLink? link) {
    final isEdit = link != null;
    final nameController = TextEditingController(text: link?.name ?? '');
    final urlController = TextEditingController(text: link?.url ?? '');
    String selectedIcon = link?.iconName ?? 'facebook';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1C1F26),
          title: Text(
            isEdit ? 'Edit Social Media Link' : 'Add Social Media Link',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Platform Name',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    hintText: 'e.g., Facebook, Instagram',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: const Color(0xFF0A0E21),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: urlController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'URL',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    hintText: 'https://...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: const Color(0xFF0A0E21),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select Icon',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    'facebook',
                    'instagram',
                    'twitter',
                    'youtube',
                    'linkedin',
                    'whatsapp',
                    'telegram',
                    'tiktok',
                    'pinterest',
                    'snapchat',
                  ].map((iconName) {
                    final isSelected = selectedIcon == iconName;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIcon = iconName;
                        });
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _getIconColor(iconName).withOpacity(0.3)
                              : const Color(0xFF0A0E21),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? _getIconColor(iconName)
                                : Colors.grey.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: FaIcon(
                            _getIconData(iconName),
                            color: _getIconColor(iconName),
                            size: 28,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty || urlController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final provider = Provider.of<SocialMediaProvider>(context, listen: false);
                final newLink = SocialMediaLink(
                  id: link?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  url: urlController.text,
                  iconName: selectedIcon,
                  order: link?.order ?? provider.allLinks.length,
                  isActive: link?.isActive ?? true,
                );

                if (isEdit) {
                  provider.updateSocialMediaLink(newLink);
                } else {
                  provider.addSocialMediaLink(newLink);
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEdit ? 'Link updated successfully' : 'Link added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, SocialMediaLink link, SocialMediaProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1F26),
        title: const Text('Delete Social Media Link', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete ${link.name}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteSocialMediaLink(link.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Link deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'facebook':
        return FontAwesomeIcons.facebook;
      case 'instagram':
        return FontAwesomeIcons.instagram;
      case 'twitter':
        return FontAwesomeIcons.xTwitter;
      case 'youtube':
        return FontAwesomeIcons.youtube;
      case 'linkedin':
        return FontAwesomeIcons.linkedin;
      case 'whatsapp':
        return FontAwesomeIcons.whatsapp;
      case 'telegram':
        return FontAwesomeIcons.telegram;
      case 'tiktok':
        return FontAwesomeIcons.tiktok;
      case 'pinterest':
        return FontAwesomeIcons.pinterest;
      case 'snapchat':
        return FontAwesomeIcons.snapchat;
      default:
        return FontAwesomeIcons.share;
    }
  }

  Color _getIconColor(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'twitter':
        return const Color(0xFF000000);
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'linkedin':
        return const Color(0xFF0A66C2);
      case 'whatsapp':
        return const Color(0xFF25D366);
      case 'telegram':
        return const Color(0xFF0088CC);
      case 'tiktok':
        return const Color(0xFF010101);
      case 'pinterest':
        return const Color(0xFFBD081C);
      case 'snapchat':
        return const Color(0xFFFFFC00);
      default:
        return Colors.grey;
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch URL'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
