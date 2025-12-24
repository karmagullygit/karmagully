import 'dart:async';
import 'dart:math';
import '../models/product.dart';
import '../models/social_post.dart';
import '../providers/social_feed_provider.dart';
import '../providers/product_provider.dart';

class ProductBotService {
  static const String botUserId = 'bot_karma_bot';
  static const String botUsername = 'KarmaBot';
  static const String botDisplayName = 'KarmaBot';
  static const String botAvatar = 'assets/images/karmabot_avatar.png';
  
  final SocialFeedProvider _socialFeedProvider;
  final ProductProvider _productProvider;
  Timer? _postTimer;
  
  ProductBotService(this._socialFeedProvider, this._productProvider);

  /// Start the bot to monitor for new products
  void startBot() {
    // Listen for new products and post them automatically
    print('🤖 KarmaBot: Started monitoring for new products');
  }

  /// Automatically post a product to the social feed after delay
  Future<void> autoPostProduct(Product product, {Duration delay = const Duration(seconds: 5)}) async {
    print('🤖 KarmaBot: Scheduling post for "${product.name}" in ${delay.inSeconds} seconds...');
    
    await Future.delayed(delay);
    
    // Generate AI caption
    final caption = _generateAICaption(product);
    
    // Generate hashtags
    final hashtags = _generateHashtags(product);
    
    // Create post content
    final content = '$caption\n\n$hashtags';
    
    // Determine post type
    final isVideo = product.imageUrl.contains('.mp4') || product.imageUrl.contains('.mov');
    final postType = isVideo ? PostType.video : PostType.image;
    
    // Create the post directly as bot user
    final post = SocialPost(
      id: 'bot_post_${DateTime.now().millisecondsSinceEpoch}',
      userId: botUserId,
      username: botUsername,
      userAvatar: botAvatar,
      userDisplayName: botDisplayName,
      content: content,
      type: postType,
      mediaUrls: [product.imageUrl],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isVerified: true,
    );
    
    // Add post directly to feed
    _socialFeedProvider.addBotPost(post);
    
    print('🤖 ProductBot: Successfully posted "${product.name}" to customer feed! 🎉');
  }

  /// Generate AI-powered caption for the product
  String _generateAICaption(Product product) {
    final templates = [
      // Exciting announcements
      '🎉 Just dropped! Check out our amazing ${product.name}! ${_getProductEmoji(product)}',
      '✨ New arrival alert! Introducing the ${product.name} - ${_getProductDescription(product)}',
      '🔥 HOT! The ${product.name} is now available! Don\'t miss out!',
      '💎 Premium quality meets affordability! Get your ${product.name} today!',
      
      // Value propositions
      '🌟 Transform your ${_getProductCategory(product)} experience with ${product.name}!',
      '💯 Quality you can trust! The ${product.name} is here to exceed your expectations!',
      '🎁 Perfect gift alert! The ${product.name} is exactly what you\'ve been looking for!',
      '⚡ Upgrade your lifestyle with the ${product.name}! Limited time offer!',
      
      // Emotional appeal
      '❤️ Fall in love with the ${product.name}! ${_getEmotionalHook(product)}',
      '🌈 Add some joy to your day with the ${product.name}!',
      '✨ Make every moment special with our ${product.name}!',
      '🎯 Your perfect match is here! Discover the ${product.name}!',
      
      // Urgency
      '⏰ Don\'t wait! The ${product.name} is flying off the shelves!',
      '🚀 Be the first to own the ${product.name}! Order now!',
      '💥 TRENDING NOW! Everyone\'s talking about the ${product.name}!',
      '🎊 Limited stock! Get your ${product.name} before it\'s gone!',
    ];
    
    // Add price if available
    String priceInfo = '';
    if (product.price > 0) {
      priceInfo = '\n\n💰 Special Price: \$${product.price.toStringAsFixed(2)}';
    }
    
    final random = Random();
    return templates[random.nextInt(templates.length)] + priceInfo;
  }

  /// Generate relevant hashtags based on product
  String _generateHashtags(Product product) {
    final hashtags = <String>[];
    
    // Core hashtags
    hashtags.add('#KarmaShop');
    hashtags.add('#NewArrival');
    
    // Product name hashtags
    final nameParts = product.name.split(' ');
    if (nameParts.isNotEmpty) {
      hashtags.add('#${nameParts.first.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}');
    }
    
    // Category-based hashtags
    if (product.category.isNotEmpty) {
      hashtags.add('#${product.category.replaceAll(' ', '')}');
    }
    
    // Price-based hashtags (add sale tags if featured)
    if (product.isFeatured) {
      hashtags.add('#Featured');
      hashtags.add('#BestSeller');
    }
    
    // Generic trending hashtags
    final trendingTags = ['#Shopping', '#OnlineShopping', '#BestDeals', '#MustHave', 
                          '#Trending', '#Quality', '#Style', '#Gift', '#Perfect'];
    final random = Random();
    for (int i = 0; i < 3; i++) {
      final tag = trendingTags[random.nextInt(trendingTags.length)];
      if (!hashtags.contains(tag)) {
        hashtags.add(tag);
      }
    }
    
    return hashtags.join(' ');
  }

  /// Get emoji based on product type
  String _getProductEmoji(Product product) {
    final name = product.name.toLowerCase();
    if (name.contains('phone') || name.contains('mobile')) return '📱';
    if (name.contains('watch')) return '⌚';
    if (name.contains('headphone') || name.contains('audio')) return '🎧';
    if (name.contains('camera')) return '📷';
    if (name.contains('laptop') || name.contains('computer')) return '💻';
    if (name.contains('shoe') || name.contains('sneaker')) return '👟';
    if (name.contains('bag')) return '👜';
    if (name.contains('dress') || name.contains('cloth')) return '👗';
    if (name.contains('food')) return '🍔';
    if (name.contains('book')) return '📚';
    if (name.contains('game')) return '🎮';
    if (name.contains('toy')) return '🧸';
    return '✨';
  }

  /// Get product category or type
  String _getProductCategory(Product product) {
    if (product.category.isNotEmpty) return product.category.toLowerCase();
    return 'collection';
  }

  /// Get description or feature highlight
  String _getProductDescription(Product product) {
    if (product.description.isNotEmpty && product.description.length > 10) {
      // Extract first sentence or up to 50 characters
      final desc = product.description.split('.').first;
      return desc.length > 50 ? '${desc.substring(0, 50)}...' : desc;
    }
    return 'a must-have addition to your collection';
  }

  /// Get emotional hook based on product
  String _getEmotionalHook(Product product) {
    final hooks = [
      'You deserve the best!',
      'Treat yourself today!',
      'Your satisfaction is guaranteed!',
      'Experience excellence!',
      'Quality that speaks for itself!',
      'Made with passion and care!',
      'Designed for you!',
      'Innovation meets style!',
    ];
    return hooks[Random().nextInt(hooks.length)];
  }

  /// Create a collage post with multiple products
  Future<void> createCollagePost(List<Product> products, {String? customCaption}) async {
    if (products.isEmpty) return;
    
    final mediaUrls = products.map((p) => p.imageUrl).take(4).toList();
    
    String caption;
    if (customCaption != null) {
      caption = customCaption;
    } else {
      caption = '🎉 NEW COLLECTION ALERT! 🎉\n\n'
                '✨ Check out our latest arrivals! ${products.length} amazing products just added!\n\n'
                '${products.map((p) => '• ${p.name}').take(3).join('\n')}'
                '${products.length > 3 ? '\n• And more...' : ''}\n\n'
                '💫 Swipe to see all! 👉';
    }
    
    final hashtags = '#KarmaShop #NewCollection #Shopping #MustHave #Trending';
    
    final post = SocialPost(
      id: 'bot_collage_${DateTime.now().millisecondsSinceEpoch}',
      userId: botUserId,
      username: botUsername,
      userAvatar: botAvatar,
      userDisplayName: botDisplayName,
      content: '$caption\n\n$hashtags',
      type: PostType.mixed,
      mediaUrls: mediaUrls,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isVerified: true,
    );
    
    _socialFeedProvider.addBotPost(post);
    print('🤖 ProductBot: Created collage post with ${products.length} products!');
  }

  /// Create promotional campaign posts
  Future<void> createPromotionalPost(String promotion, List<Product> products) async {
    if (products.isEmpty) return;
    
    final product = products.first;
    final caption = '🎊 SPECIAL PROMOTION! 🎊\n\n'
                    '$promotion\n\n'
                    '🌟 Featured: ${product.name}\n'
                    '💰 Only \$${product.price.toStringAsFixed(2)}\n\n'
                    'Tap to shop now! 🛍️';
    
    final post = SocialPost(
      id: 'bot_promo_${DateTime.now().millisecondsSinceEpoch}',
      userId: botUserId,
      username: botUsername,
      userAvatar: botAvatar,
      userDisplayName: botDisplayName,
      content: '$caption\n\n#Sale #Promotion #LimitedOffer #KarmaShop',
      type: PostType.image,
      mediaUrls: [product.imageUrl],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isVerified: true,
    );
    
    _socialFeedProvider.addBotPost(post);
    print('🤖 ProductBot: Created promotional post!');
  }

  /// Stop the bot
  void stopBot() {
    _postTimer?.cancel();
    print('🤖 ProductBot: Stopped');
  }

  void dispose() {
    stopBot();
  }
}
