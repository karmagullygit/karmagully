import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flash_sale.dart';
import '../providers/flash_sale_provider.dart';

class FlashSaleBannerWidget extends StatefulWidget {
  final FlashSale flashSale;
  final bool isDarkMode;

  const FlashSaleBannerWidget({super.key, required this.flashSale, this.isDarkMode = true});

  @override
  State<FlashSaleBannerWidget> createState() => _FlashSaleBannerWidgetState();
}

class _FlashSaleBannerWidgetState extends State<FlashSaleBannerWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flashSale = widget.flashSale;
    return GestureDetector(
      onTap: () {
        final target = flashSale.actionUrl ?? '/customer-flash-sales';
        Navigator.pushNamed(context, target);
      },
      child: SizedBox(
        height: 140,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildImage(),
              _buildLiveBadge(),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 8),
                      const Icon(Icons.timer, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Consumer<FlashSaleProvider>(
                        builder: (context, provider, child) {
                          final remaining = flashSale.timeRemaining;
                          return Text(
                            _formatDuration(remaining),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Positioned(
      left: 10,
      top: 10,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final t = _animController.value;
          final glow = 6 + (6 * t);
          final scale = 0.95 + (0.1 * t);
          return Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.6 * (1 - (t * 0.5))),
                    blurRadius: glow,
                    spreadRadius: glow * 0.2,
                  ),
                ],
                border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.flash_on, color: Colors.white, size: 14),
                  SizedBox(width: 6),
                  Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage() {
    final url = widget.flashSale.imageUrl;
    debugPrint('🔥 FlashSaleBannerWidget loading imageUrl: "$url"');
    if (url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'))) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (c, child, progress) {
          if (progress == null) return child;
          return Container(color: Colors.black12, child: const Center(child: CircularProgressIndicator()));
        },
        errorBuilder: (c, e, s) {
          debugPrint('FlashSaleBannerWidget network image error: $e');
          return _placeholder();
        },
      );
    }

    if (url.isNotEmpty && url.startsWith('file://')) {
      try {
        final filePath = url.replaceFirst('file://', '');
        final file = File(filePath);
        final exists = file.existsSync();
        debugPrint('FlashSaleBannerWidget local file exists: $exists -> $filePath');
        if (exists) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) {
              debugPrint('FlashSaleBannerWidget file image error: $e');
              return _placeholder();
            },
          );
        }
      } catch (e) {
        debugPrint('FlashSaleBannerWidget file handling error: $e');
      }
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: widget.isDarkMode ? const Color(0xFF1E1E2E) : const Color(0xFFEFEFEF),
      child: const Center(child: Icon(Icons.photo, color: Colors.white54, size: 48)),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds <= 0) return 'Expired';
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    if (days > 0) return '${days}d ${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h ${minutes}m ${seconds}s';
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }
}

