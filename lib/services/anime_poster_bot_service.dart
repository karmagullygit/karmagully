import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/anime_poster_bot_config.dart';
import '../providers/product_provider.dart';

class AnimePosterBotService {
  final ProductProvider _productProvider;
  Timer? _uploadTimer;
  AnimePosterBotConfig _config = AnimePosterBotConfig();
  
  static const String _geminiApiKey = 'AIzaSyCK5bwqpT7IFxYS-XZJjyAe-W5qUc5DXXM';
  
  final List<String> _animeThemes = [
    'Naruto', 'One Piece', 'Attack on Titan', 'Demon Slayer', 'My Hero Academia',
    'Death Note', 'Tokyo Ghoul', 'Sword Art Online', 'Dragon Ball', 'Bleach',
    'Hunter x Hunter', 'Fullmetal Alchemist', 'Jujutsu Kaisen', 'Chainsaw Man',
    'Spy x Family', 'Cyberpunk Edgerunners', 'Akira', 'Cowboy Bebop', 'Evangelion',
  ];

  final List<String> _posterStyles = [
    'Epic Battle Scene', 'Character Portrait', 'Iconic Moment', 'Group Shot',
    'Villain Showcase', 'Hero Power-up', 'Emotional Scene', 'Action Pose',
  ];

  AnimePosterBotService(this._productProvider);

  void updateConfig(AnimePosterBotConfig config) {
    _config = config;
    if (config.isEnabled) {
      startBot();
    } else {
      stopBot();
    }
  }

  AnimePosterBotConfig get config => _config;

  void startBot() {
    if (_uploadTimer != null && _uploadTimer!.isActive) {
      _uploadTimer!.cancel();
    }

    print('🤖 Anime Poster Bot: Starting... Upload interval: ${_config.uploadIntervalSeconds}s');
    
    _uploadTimer = Timer.periodic(
      Duration(seconds: _config.uploadIntervalSeconds),
      (timer) => _uploadAnimeProduct(),
    );
  }

  void stopBot() {
    _uploadTimer?.cancel();
    _uploadTimer = null;
    print('🤖 Anime Poster Bot: Stopped');
  }

  Future<void> _uploadAnimeProduct() async {
    try {
      print('🎨 Anime Poster Bot: Generating new product...');

      // Fetch or generate anime image
      String imageUrl;
      final random = Random();
      final theme = _animeThemes[random.nextInt(_animeThemes.length)];
      final style = _posterStyles[random.nextInt(_posterStyles.length)];
      
      if (_config.useGeminiGeneration) {
        print('🤖 Using Gemini AI to generate image...');
        imageUrl = await _generateAnimeImageWithGemini(theme, style);
      } else {
        print('🌐 Fetching image from web...');
        imageUrl = await _fetchAnimeImage();
      }

      // Composite image with frame removed as per request
      // imageUrl = await _compositeImage(imageUrl);
      
      final title = '$theme - $style Metal Poster';
      final description = _generateDescription(theme, style);
      
      // Create product with two variants (Small and Large)
      final product = Product(
        id: 'anime_${DateTime.now().millisecondsSinceEpoch}',
        name: title,
        description: description,
        price: _config.smallPosterPrice,
        category: _config.category,
        imageUrl: imageUrl,
        stock: 100,
        isFeatured: random.nextBool(),
        createdAt: DateTime.now(),
      );

      // Add product to database
      await _productProvider.addProduct(product);
      
      _config = _config.copyWith(
        totalProductsUploaded: _config.totalProductsUploaded + 1,
        lastUploadTime: DateTime.now(),
      );

      print('✅ Anime Poster Bot: Product uploaded successfully! Total: ${_config.totalProductsUploaded}');
      print('   Title: $title');
      print('   Price: Small ₹${_config.smallPosterPrice}, Large ₹${_config.largePosterPrice}');
    } catch (e) {
      print('❌ Anime Poster Bot Error: $e');
    }
  }

  Future<String> _fetchAnimeImage() async {
    try {
      // Try multiple high-quality anime image sources
      final random = Random();
      
      // Try Jikan API first for real anime posters
      final response = await http.get(
        Uri.parse('https://api.jikan.moe/v4/random/anime'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final imageUrl = data['data']?['images']?['jpg']?['large_image_url'] ??
                        data['data']?['images']?['jpg']?['image_url'];
        
        if (imageUrl != null && imageUrl.isNotEmpty) {
          return imageUrl;
        }
      }
    } catch (e) {
      print('⚠️ Failed to fetch from Jikan API: $e');
    }

    // Try alternative anime APIs
    try {
      final themes = ['naruto', 'onepiece', 'bleach', 'dragonball', 'demonslayer', 'attackontitan', 'myheroacademia'];
      final random = Random();
      final theme = themes[random.nextInt(themes.length)];
      
      // Use Unsplash for high-quality anime art
      return 'https://source.unsplash.com/600x900/?anime,$theme,poster,art';
    } catch (e) {
      print('⚠️ Fallback to default: $e');
    }

    // Final fallback
    final animeId = Random().nextInt(50000) + 1;
    return 'https://picsum.photos/seed/anime$animeId/600/900';
  }

  String _generateDescription(String theme, String style) {
    final descriptions = [
      'Premium framed metal poster featuring $theme in a stunning $style design. High-quality print on metal with elegant white frame. Perfect for anime fans and collectors!',
      'Museum-quality framed metal wall art showcasing $theme. This $style poster comes with a sleek white gallery frame that adds epic anime vibes to any room.',
      'Exclusive framed $theme metal poster with incredible $style artwork. Premium metal print in elegant white frame - durable, sleek, and ready to display!',
      'Limited edition framed metal poster of $theme featuring an amazing $style. Museum-grade quality with professional white frame - a must-have for any anime enthusiast!',
      'Transform your space with this breathtaking framed $theme metal poster. The $style design captures every detail perfectly in a premium white gallery frame.',
    ];
    
    final features = [
      '\n\n✨ Features:\n'
      '• Premium metal construction with white gallery frame\n'
      '• High-resolution anime artwork print\n'
      '• Vibrant, fade-resistant colors\n'
      '• Professional framing - ready to display\n'
      '• Scratch and UV resistant coating\n'
      '• Perfect for bedrooms, offices, or gaming rooms\n'
      '• Officially inspired artwork\n'
      '\n📦 Ships within 2-3 business days\n'
      '🎨 Available in Small (12x18") and Large (18x24") framed sizes\n'
      '🖼️ Comes with elegant white frame as shown'
    ];

    final random = Random();
    return descriptions[random.nextInt(descriptions.length)] + features[0];
  }

  Future<String> _generateAnimeImageWithGemini(String theme, String style) async {
    try {
      // 1. Generate a creative prompt using Gemini (Text)
      // We use gemini-1.5-flash which has a generous free tier
      final textGenUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_geminiApiKey';
      
      String imagePrompt = 'anime poster of $theme, $style style, masterpiece, 8k, vibrant colors';
      
      try {
        final promptResponse = await http.post(
          Uri.parse(textGenUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'contents': [{
              'parts': [{'text': 'Write a short, descriptive image generation prompt for an anime poster featuring "$theme" in "$style" style. Focus on visual details. Output ONLY the prompt.'}]
            }]
          }),
        ).timeout(const Duration(seconds: 10));

        if (promptResponse.statusCode == 200) {
          final data = json.decode(promptResponse.body);
          final generatedText = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
          if (generatedText != null && generatedText.isNotEmpty) {
            imagePrompt = generatedText.trim();
            print('📝 Gemini Generated Prompt: $imagePrompt');
          }
        }
      } catch (e) {
        print('⚠️ Gemini Text Gen failed, using default prompt: $e');
      }

      // 2. Generate Image using Pollinations.ai (Free, No Key)
      print('🎨 Generating image via Pollinations.ai...');
      final encodedPrompt = Uri.encodeComponent(imagePrompt);
      // Add seed to ensure uniqueness
      final seed = Random().nextInt(1000000);
      final imageUrl = 'https://image.pollinations.ai/prompt/$encodedPrompt?width=768&height=1024&seed=$seed&model=flux';
      
      print('🔗 Image URL: $imageUrl');
      
      // Download the image to a temporary file
      final imageResponse = await http.get(Uri.parse(imageUrl)).timeout(const Duration(seconds: 60));
      
      if (imageResponse.statusCode == 200) {
         final directory = await getTemporaryDirectory();
         final fileName = 'pollinations_anime_${DateTime.now().millisecondsSinceEpoch}.jpg';
         final file = File('${directory.path}/$fileName');
         await file.writeAsBytes(imageResponse.bodyBytes);
         
         print('✅ Pollinations image saved to: ${file.path}');
         return file.path;
      } else {
        print('❌ Pollinations Error: ${imageResponse.statusCode}');
      }
      
    } catch (e) {
      print('❌ Generation Error: $e');
    }
    
    throw Exception('Failed to generate image');
  }

  void dispose() {
    stopBot();
  }
}
