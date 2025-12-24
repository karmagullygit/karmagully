import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../providers/advertisement_provider.dart';
import '../../models/advertisement.dart';
import '../../models/carousel_banner.dart';
import '../../services/simple_banner_service.dart';


class AdsManagementScreen extends StatefulWidget {
  const AdsManagementScreen({super.key});

  @override
  State<AdsManagementScreen> createState() => _AdsManagementScreenState();
}

class _AdsManagementScreenState extends State<AdsManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdvertisementProvider>(context, listen: false).loadSampleData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('� Carousel Management'),
        backgroundColor: const Color(0xFF1A1D29),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateAdDialog(context),
            tooltip: 'Create New Ad',
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0F1419),
      body: Consumer<AdvertisementProvider>(
        builder: (context, adProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Stats
                _buildStatsCard(adProvider),
                const SizedBox(height: 20),
                
                // Carousel Ads Section
                _buildCarouselSection(adProvider),
                const SizedBox(height: 20),
                
                // General Ads Section
                _buildGeneralAdsSection(adProvider),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateAdDialog(context),
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add),
        label: const Text('Create Ad'),
      ),
    );
  }

  Widget _buildStatsCard(AdvertisementProvider adProvider) {
    final totalAds = adProvider.advertisements.length + adProvider.carouselBanners.length;
    
    return Card(
      color: const Color(0xFF1A1D29),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Total Ads', totalAds.toString(), Icons.ads_click, Colors.orange),
            _buildStatItem('Carousel', adProvider.carouselBanners.length.toString(), Icons.view_carousel, Colors.blue),
            _buildStatItem('General', adProvider.advertisements.length.toString(), Icons.campaign, Colors.green),
            _buildStatItem('Active', _getActiveCount(adProvider).toString(), Icons.check_circle, Colors.purple),
          ],
        ),
      ),
    );
  }

  int _getActiveCount(AdvertisementProvider adProvider) {
    return adProvider.carouselBanners.where((b) => b.isCurrentlyActive).length +
           adProvider.advertisements.where((a) => a.isCurrentlyActive).length;
  }

  Widget _buildStatItem(String label, String count, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCarouselSection(AdvertisementProvider adProvider) {
    return Card(
      color: const Color(0xFF1A1D29),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.view_carousel, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Carousel Banners',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Main homepage carousel advertisements',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () => _showCreateCarouselDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (adProvider.carouselBanners.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                child: const Center(
                  child: Text(
                    'No carousel banners yet. Click + to create your first banner.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: adProvider.carouselBanners.length,
                itemBuilder: (context, index) {
                  final banner = adProvider.carouselBanners[index];
                  return _buildCarouselCard(banner, adProvider);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralAdsSection(AdvertisementProvider adProvider) {
    return Card(
      color: const Color(0xFF1A1D29),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.campaign, color: Colors.green, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'General Advertisements',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Banners, videos, and promotional content',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () => _showCreateAdDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (adProvider.advertisements.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                child: const Center(
                  child: Text(
                    'No general ads yet. Click + to create your first ad.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: adProvider.advertisements.length,
                itemBuilder: (context, index) {
                  final ad = adProvider.advertisements[index];
                  return _buildAdCard(ad, adProvider);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselCard(CarouselBanner banner, AdvertisementProvider adProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 60,
            height: 60,
            color: Colors.grey[800],
            child: banner.imageUrl.isNotEmpty 
                ? (banner.imageUrl.startsWith('file://') 
                    ? Image.file(
                        File(banner.imageUrl.replaceFirst('file://', '')), 
                        fit: BoxFit.cover, 
                        errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.white54)
                      )
                    : Image.network(
                        banner.imageUrl, 
                        fit: BoxFit.cover, 
                        errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.white54)
                      ))
                : const Icon(Icons.image, color: Colors.white54),
          ),
        ),
        title: Text(
          banner.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(banner.subtitle, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: banner.isCurrentlyActive ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    banner.isCurrentlyActive ? 'Active' : 'Inactive',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Order: ${banner.order}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: const Color(0xFF1A1D29),
          onSelected: (value) {
            switch (value) {
              case 'delete':
                _showDeleteCarouselConfirmation(context, banner, adProvider);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
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

  Widget _buildAdCard(Advertisement ad, AdvertisementProvider adProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 60,
            height: 60,
            color: Colors.grey[800],
            child: ad.imageUrl.isNotEmpty 
                ? (ad.imageUrl.startsWith('file://') 
                    ? Image.file(
                        File(ad.imageUrl.replaceFirst('file://', '')), 
                        fit: BoxFit.cover, 
                        errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.white54)
                      )
                    : Image.network(
                        ad.imageUrl, 
                        fit: BoxFit.cover, 
                        errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.white54)
                      ))
                : const Icon(Icons.image, color: Colors.white54),
          ),
        ),
        title: Text(
          ad.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ad.description, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: ad.isCurrentlyActive ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    ad.isCurrentlyActive ? 'Active' : 'Inactive',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Type: ${ad.type.name}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Text(
                  'Place: ${ad.placement.name}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: const Color(0xFF1A1D29),
          onSelected: (value) {
            switch (value) {
              case 'delete':
                _showDeleteAdConfirmation(context, ad, adProvider);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
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

  void _showCreateCarouselDialog(BuildContext context) {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final imageUrlController = TextEditingController();
    final actionUrlController = TextEditingController();
    int order = 1;
    File? selectedImageFile;

    // Dark theme input decoration
    InputDecoration darkInputDecoration(String label, {String? hint}) {
      return InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.blue),
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: const Color(0xFF252836),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3A3D4A), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E2130),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Create Carousel Banner', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: darkInputDecoration('Banner Title', hint: 'Enter banner title'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: subtitleController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 2,
                    decoration: darkInputDecoration('Subtitle', hint: 'Enter subtitle'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: imageUrlController,
                          style: const TextStyle(color: Colors.white),
                          decoration: darkInputDecoration('Image URL', hint: 'URL or upload'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: () async {
                            FilePickerResult? result = await FilePicker.platform.pickFiles(
                              type: FileType.image,
                              allowMultiple: false,
                            );
                            if (result != null) {
                              setState(() {
                                selectedImageFile = File(result.files.single.path!);
                                imageUrlController.text = result.files.single.name;
                              });
                            }
                          },
                          icon: const Icon(Icons.upload, color: Colors.white),
                          tooltip: 'Upload Image',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: actionUrlController,
                    style: const TextStyle(color: Colors.white),
                    decoration: darkInputDecoration('Action URL (optional)', hint: 'https://...'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Display Order', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF252836),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF3A3D4A)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: order,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF252836),
                        style: const TextStyle(color: Colors.white),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        items: List.generate(10, (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('Order ${index + 1}'),
                        )),
                        onChanged: (value) => setState(() => order = value!),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final imageUrl = selectedImageFile != null 
                      ? 'file://${selectedImageFile!.path}' 
                      : imageUrlController.text;
                  _createCarouselBanner(
                    titleController.text,
                    subtitleController.text,
                    imageUrl,
                    actionUrlController.text,
                    order,
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Create Banner'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateAdDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final imageUrlController = TextEditingController();
    final videoUrlController = TextEditingController();
    final actionUrlController = TextEditingController();
    AdType selectedType = AdType.banner;
    AdPlacement selectedPlacement = AdPlacement.banner;
    String mediaType = 'image';
    File? selectedVideoFile;
    File? selectedImageFile;

    // Dark theme input decoration
    InputDecoration darkInputDecoration(String label, {String? hint}) {
      return InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.blue),
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: const Color(0xFF252836),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3A3D4A), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E2130),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Create Advertisement',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ad Type Dropdown
                  const Text('Ad Type', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF252836),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF3A3D4A)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<AdType>(
                        value: selectedType,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF252836),
                        style: const TextStyle(color: Colors.white),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        items: AdType.values.map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.name.toUpperCase()),
                        )).toList(),
                        onChanged: (value) => setState(() => selectedType = value!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Placement Dropdown
                  const Text('Placement', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF252836),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF3A3D4A)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<AdPlacement>(
                        value: selectedPlacement,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF252836),
                        style: const TextStyle(color: Colors.white),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        items: AdPlacement.values.map((placement) => DropdownMenuItem(
                          value: placement,
                          child: Text(placement.name.toUpperCase()),
                        )).toList(),
                        onChanged: (value) => setState(() => selectedPlacement = value!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ad Title
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: darkInputDecoration('Ad Title', hint: 'Enter ad title'),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextField(
                    controller: descriptionController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: darkInputDecoration('Description', hint: 'Enter description'),
                  ),
                  const SizedBox(height: 16),

                  // Media Type Selection
                  const Text('Media Type', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => mediaType = 'image'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: mediaType == 'image' ? Colors.blue.withOpacity(0.2) : const Color(0xFF252836),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: mediaType == 'image' ? Colors.blue : const Color(0xFF3A3D4A),
                                width: mediaType == 'image' ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image, color: mediaType == 'image' ? Colors.blue : Colors.grey, size: 20),
                                const SizedBox(width: 8),
                                Text('Image', style: TextStyle(color: mediaType == 'image' ? Colors.blue : Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => mediaType = 'video'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: mediaType == 'video' ? Colors.blue.withOpacity(0.2) : const Color(0xFF252836),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: mediaType == 'video' ? Colors.blue : const Color(0xFF3A3D4A),
                                width: mediaType == 'video' ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.videocam, color: mediaType == 'video' ? Colors.blue : Colors.grey, size: 20),
                                const SizedBox(width: 8),
                                Text('Video', style: TextStyle(color: mediaType == 'video' ? Colors.blue : Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Media URL/Upload
                  if (mediaType == 'image') ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: imageUrlController,
                            style: const TextStyle(color: Colors.white),
                            decoration: darkInputDecoration('Image URL', hint: 'URL or tap upload'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: () async {
                              FilePickerResult? result = await FilePicker.platform.pickFiles(
                                type: FileType.image,
                                allowMultiple: false,
                              );
                              if (result != null) {
                                setState(() {
                                  selectedImageFile = File(result.files.single.path!);
                                  imageUrlController.text = result.files.single.name;
                                });
                              }
                            },
                            icon: const Icon(Icons.upload, color: Colors.white),
                            tooltip: 'Upload Image',
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: videoUrlController,
                            style: const TextStyle(color: Colors.white),
                            decoration: darkInputDecoration('Video URL', hint: 'URL or tap upload'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: () async {
                              FilePickerResult? result = await FilePicker.platform.pickFiles(
                                type: FileType.video,
                                allowMultiple: false,
                              );
                              if (result != null) {
                                setState(() {
                                  selectedVideoFile = File(result.files.single.path!);
                                  videoUrlController.text = result.files.single.name;
                                });
                              }
                            },
                            icon: const Icon(Icons.upload, color: Colors.white),
                            tooltip: 'Upload Video',
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Action URL
                  TextField(
                    controller: actionUrlController,
                    style: const TextStyle(color: Colors.white),
                    decoration: darkInputDecoration('Action URL (optional)', hint: 'https://...'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final mediaUrl = mediaType == 'image'
                      ? (selectedImageFile != null ? 'file://${selectedImageFile!.path}' : imageUrlController.text)
                      : null;
                  SimpleBannerService.instance.showBanner(
                    context: context,
                    title: titleController.text,
                    message: descriptionController.text.isEmpty ? 'Test banner ad' : descriptionController.text,
                    imageUrl: mediaUrl,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Test banner clicked: ${actionUrlController.text.isEmpty ? "No action URL" : actionUrlController.text}')),
                      );
                    },
                  );
                }
              },
              child: const Text('Test Banner', style: TextStyle(color: Colors.orange)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final mediaUrl = mediaType == 'video'
                      ? (selectedVideoFile != null ? 'file://${selectedVideoFile!.path}' : videoUrlController.text)
                      : (selectedImageFile != null ? 'file://${selectedImageFile!.path}' : imageUrlController.text);

                  _createAdvertisement(
                    titleController.text,
                    descriptionController.text,
                    selectedType,
                    selectedPlacement,
                    mediaUrl,
                    actionUrlController.text,
                  );

                  if (mediaType == 'image' && mediaUrl.isNotEmpty) {
                    Future.delayed(const Duration(seconds: 1), () {
                      SimpleBannerService.instance.showBanner(
                        context: context,
                        title: titleController.text,
                        message: descriptionController.text.isEmpty ? 'New advertisement!' : descriptionController.text,
                        imageUrl: mediaUrl,
                        onTap: () {
                          if (actionUrlController.text.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Opening: ${actionUrlController.text}')),
                            );
                          }
                        },
                      );
                    });
                  }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        mediaType == 'image'
                            ? 'Advertisement created! A banner will appear shortly.'
                            : 'Advertisement created successfully!',
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Create Ad'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteCarouselConfirmation(BuildContext context, CarouselBanner banner, AdvertisementProvider adProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D29),
        title: const Text('Delete Carousel Banner', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${banner.title}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteCarouselBanner(banner, adProvider);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAdConfirmation(BuildContext context, Advertisement ad, AdvertisementProvider adProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D29),
        title: const Text('Delete Advertisement', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${ad.title}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteAdvertisement(ad, adProvider);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _createCarouselBanner(String title, String subtitle, String imageUrl, String actionUrl, int order) {
    final adProvider = Provider.of<AdvertisementProvider>(context, listen: false);
    
    adProvider.addCarouselBanner(
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      actionUrl: actionUrl.isNotEmpty ? actionUrl : null,
      order: order,
      startDate: DateTime.now(),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Carousel banner "$title" created successfully!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _createAdvertisement(String title, String description, AdType type, AdPlacement placement, String imageUrl, String actionUrl) {
    final adProvider = Provider.of<AdvertisementProvider>(context, listen: false);
    
    adProvider.addAdvertisement(
      title: title,
      description: description,
      type: type,
      placement: placement,
      imageUrl: imageUrl,
      actionUrl: actionUrl.isNotEmpty ? actionUrl : null,
      startDate: DateTime.now(),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Advertisement "$title" created successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }



  void _deleteCarouselBanner(CarouselBanner banner, AdvertisementProvider adProvider) {
    adProvider.deleteCarouselBanner(banner.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🗑️ "${banner.title}" deleted successfully!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _deleteAdvertisement(Advertisement ad, AdvertisementProvider adProvider) {
    adProvider.deleteAdvertisement(ad.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🗑️ "${ad.title}" deleted successfully!'),
        backgroundColor: Colors.red,
      ),
    );
  }
}