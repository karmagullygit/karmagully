import '../models/social_post.dart';
import '../providers/social_feed_provider.dart';

/// KarmaGully Official Bot - Manually controlled by admin
/// Used for announcements, reels, shorts, stories, and official content
class OfficialBotService {
  static const String botUserId = 'bot_karma_gully';
  static const String botUsername = 'KarmaGully_Official';
  static const String botDisplayName = 'KarmaGully Official';
  static const String botAvatar = 'assets/images/karma_logo.png';
  
  final SocialFeedProvider _socialFeedProvider;
  
  OfficialBotService(this._socialFeedProvider);

  /// Post an announcement
  Future<bool> postAnnouncement({
    required String content,
    List<String> mediaUrls = const [],
  }) async {
    try {
      print('📢 KarmaGully Official: Posting announcement...');
      
      final now = DateTime.now();
      final post = SocialPost(
        id: 'official_post_${now.millisecondsSinceEpoch}',
        userId: botUserId,
        username: botUsername,
        userAvatar: botAvatar,
        userDisplayName: botDisplayName,
        content: '📢 ANNOUNCEMENT\n\n$content',
        mediaUrls: mediaUrls,
        type: mediaUrls.isEmpty ? PostType.text : PostType.image,
        createdAt: now,
        updatedAt: now,
      );
      
      _socialFeedProvider.addBotPost(post);
      print('✅ KarmaGully Official: Announcement posted successfully');
      return true;
    } catch (e) {
      print('❌ Error posting announcement: $e');
      return false;
    }
  }

  /// Post a reel/short video
  Future<bool> postReel({
    required String content,
    required String videoUrl,
    String? thumbnailUrl,
  }) async {
    try {
      print('🎬 KarmaGully Official: Posting reel...');
      
      final now = DateTime.now();
      final post = SocialPost(
        id: 'official_reel_${now.millisecondsSinceEpoch}',
        userId: botUserId,
        username: botUsername,
        userAvatar: botAvatar,
        userDisplayName: botDisplayName,
        content: '🎬 NEW REEL\n\n$content',
        mediaUrls: [videoUrl],
        type: PostType.video,
        createdAt: now,
        updatedAt: now,
      );
      
      _socialFeedProvider.addBotPost(post);
      print('✅ KarmaGully Official: Reel posted successfully');
      return true;
    } catch (e) {
      print('❌ Error posting reel: $e');
      return false;
    }
  }

  /// Post a story (temporary content)
  Future<bool> postStory({
    required String content,
    List<String> mediaUrls = const [],
  }) async {
    try {
      print('📖 KarmaGully Official: Posting story...');
      
      final now = DateTime.now();
      PostType type = PostType.text;
      if (mediaUrls.isNotEmpty) {
        type = (mediaUrls.first.contains('.mp4') || mediaUrls.first.contains('.mov')) 
            ? PostType.video 
            : PostType.image;
      }
      
      final post = SocialPost(
        id: 'official_story_${now.millisecondsSinceEpoch}',
        userId: botUserId,
        username: botUsername,
        userAvatar: botAvatar,
        userDisplayName: botDisplayName,
        content: '📖 $content',
        mediaUrls: mediaUrls,
        type: type,
        createdAt: now,
        updatedAt: now,
      );
      
      _socialFeedProvider.addBotPost(post);
      print('✅ KarmaGully Official: Story posted successfully');
      return true;
    } catch (e) {
      print('❌ Error posting story: $e');
      return false;
    }
  }

  /// Post custom content (images, videos, text)
  Future<bool> postCustomContent({
    required String content,
    List<String> mediaUrls = const [],
    PostType? postType,
  }) async {
    try {
      print('✨ KarmaGully Official: Posting custom content...');
      
      // Determine post type if not provided
      PostType type = postType ?? PostType.text;
      if (postType == null && mediaUrls.isNotEmpty) {
        if (mediaUrls.first.contains('.mp4') || mediaUrls.first.contains('.mov')) {
          type = PostType.video;
        } else {
          type = PostType.image;
        }
      }
      
      final now = DateTime.now();
      final post = SocialPost(
        id: 'official_custom_${now.millisecondsSinceEpoch}',
        userId: botUserId,
        username: botUsername,
        userAvatar: botAvatar,
        userDisplayName: botDisplayName,
        content: content,
        mediaUrls: mediaUrls,
        type: type,
        createdAt: now,
        updatedAt: now,
      );
      
      _socialFeedProvider.addBotPost(post);
      print('✅ KarmaGully Official: Custom content posted successfully');
      return true;
    } catch (e) {
      print('❌ Error posting custom content: $e');
      return false;
    }
  }

  /// Post a promotional campaign
  Future<bool> postPromotion({
    required String title,
    required String description,
    List<String> mediaUrls = const [],
    String? promoCode,
    String? link,
  }) async {
    try {
      print('🎉 KarmaGully Official: Posting promotion...');
      
      String content = '🎉 $title\n\n$description';
      
      if (promoCode != null) {
        content += '\n\n🎫 Use code: $promoCode';
      }
      
      if (link != null) {
        content += '\n\n🔗 $link';
      }
      
      final now = DateTime.now();
      final post = SocialPost(
        id: 'official_promo_${now.millisecondsSinceEpoch}',
        userId: botUserId,
        username: botUsername,
        userAvatar: botAvatar,
        userDisplayName: botDisplayName,
        content: content,
        mediaUrls: mediaUrls,
        type: mediaUrls.isEmpty ? PostType.text : PostType.image,
        createdAt: now,
        updatedAt: now,
      );
      
      _socialFeedProvider.addBotPost(post);
      print('✅ KarmaGully Official: Promotion posted successfully');
      return true;
    } catch (e) {
      print('❌ Error posting promotion: $e');
      return false;
    }
  }
}
