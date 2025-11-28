class AdsTrackingService {
  // In-memory storage for tracking IDs (replace with SharedPreferences in production)
  static Map<String, String> _storage = {};

  // Simple tracking configuration
  static Map<String, String> get trackingIds => {
    'metaPixelId': _storage['metaPixelId'] ?? '',
    'facebookAppId': _storage['facebookAppId'] ?? '',
    'googleAnalyticsId': _storage['googleAnalyticsId'] ?? '',
    'firebaseProjectId': _storage['firebaseProjectId'] ?? '',
    'googleAdsId': _storage['googleAdsId'] ?? '',
  };

  // Save tracking IDs (like Hostinger style)
  static Future<void> saveTrackingIds({
    String? metaPixelId,
    String? facebookAppId,
    String? googleAnalyticsId,
    String? firebaseProjectId,
    String? googleAdsId,
  }) async {
    if (metaPixelId != null) _storage['metaPixelId'] = metaPixelId;
    if (facebookAppId != null) _storage['facebookAppId'] = facebookAppId;
    if (googleAnalyticsId != null) _storage['googleAnalyticsId'] = googleAnalyticsId;
    if (firebaseProjectId != null) _storage['firebaseProjectId'] = firebaseProjectId;
    if (googleAdsId != null) _storage['googleAdsId'] = googleAdsId;
    
    _storage['lastUpdated'] = DateTime.now().toIso8601String();
  }

  // Validate tracking IDs format
  static Map<String, bool> validateTrackingIds() {
    final ids = trackingIds;
    return {
      'metaPixel': _isValidMetaPixelId(ids['metaPixelId'] ?? ''),
      'facebookApp': _isValidFacebookAppId(ids['facebookAppId'] ?? ''),
      'googleAnalytics': _isValidGoogleAnalyticsId(ids['googleAnalyticsId'] ?? ''),
      'firebaseProject': _isValidFirebaseProjectId(ids['firebaseProjectId'] ?? ''),
      'googleAds': _isValidGoogleAdsId(ids['googleAdsId'] ?? ''),
    };
  }

  // Get connection status
  static Map<String, dynamic> getConnectionStatus() {
    final ids = trackingIds;
    final validation = validateTrackingIds();
    
    final metaConnected = ids['metaPixelId']!.isNotEmpty && ids['facebookAppId']!.isNotEmpty;
    final googleConnected = ids['googleAnalyticsId']!.isNotEmpty && ids['firebaseProjectId']!.isNotEmpty;
    
    return {
      'meta': {
        'connected': metaConnected && validation['metaPixel']! && validation['facebookApp']!,
        'pixelId': ids['metaPixelId'],
        'appId': ids['facebookAppId'],
        'status': metaConnected ? 'Connected' : 'Not Connected',
        'canTrack': metaConnected && validation['metaPixel']! && validation['facebookApp']!,
      },
      'google': {
        'connected': googleConnected && validation['googleAnalytics']! && validation['firebaseProject']!,
        'analyticsId': ids['googleAnalyticsId'],
        'projectId': ids['firebaseProjectId'],
        'adsId': ids['googleAdsId'],
        'status': googleConnected ? 'Connected' : 'Not Connected',
        'canTrack': googleConnected && validation['googleAnalytics']! && validation['firebaseProject']!,
      },
      'overall': {
        'fullyConnected': metaConnected && googleConnected && 
                         validation['metaPixel']! && validation['facebookApp']! && 
                         validation['googleAnalytics']! && validation['firebaseProject']!,
        'readyForCampaigns': (metaConnected && validation['metaPixel']! && validation['facebookApp']!) ||
                           (googleConnected && validation['googleAnalytics']! && validation['firebaseProject']!),
      }
    };
  }

  // Auto-generated tracking code for Meta
  static String generateMetaTrackingCode() {
    final ids = trackingIds;
    if (ids['metaPixelId']!.isEmpty) return '';
    
    return '''
<!-- Meta Pixel Code -->
<script>
!function(f,b,e,v,n,t,s)
{if(f.fbq)return;n=f.fbq=function(){n.callMethod?
n.callMethod.apply(n,arguments):n.queue.push(arguments)};
if(!f._fbq)f._fbq=n;n.push=n;n.loaded=!0;n.version='2.0';
n.queue=[];t=b.createElement(e);t.async=!0;
t.src=v;s=b.getElementsByTagName(e)[0];
s.parentNode.insertBefore(t,s)}(window, document,'script',
'https://connect.facebook.net/en_US/fbevents.js');
fbq('init', '${ids['metaPixelId']}');
fbq('track', 'PageView');
</script>
<noscript><img height="1" width="1" style="display:none"
src="https://www.facebook.com/tr?id=${ids['metaPixelId']}&ev=PageView&noscript=1"
/></noscript>
<!-- End Meta Pixel Code -->

<!-- Flutter App Integration -->
<script>
// Track app installs
fbq('track', 'MobileAppInstall', {
  app_name: 'KarmaShop',
  app_version: '1.0.0'
});

// Track purchases
function trackPurchase(value, currency = 'USD') {
  fbq('track', 'Purchase', {
    value: value,
    currency: currency
  });
}

// Track add to cart
function trackAddToCart(value, currency = 'USD') {
  fbq('track', 'AddToCart', {
    value: value,
    currency: currency
  });
}
</script>
''';
  }

  // Auto-generated tracking code for Google
  static String generateGoogleTrackingCode() {
    final ids = trackingIds;
    if (ids['googleAnalyticsId']!.isEmpty) return '';
    
    return '''
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=${ids['googleAnalyticsId']}"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', '${ids['googleAnalyticsId']}');
  
  // Enhanced ecommerce tracking
  gtag('config', '${ids['googleAdsId']?.isNotEmpty == true ? ids['googleAdsId'] : ids['googleAnalyticsId']}', {
    'custom_map': {'custom_parameter': 'app_install'}
  });
</script>

<!-- Firebase App Integration -->
<script>
// Track app installs
gtag('event', 'app_install', {
  'app_name': 'KarmaShop',
  'app_version': '1.0.0'
});

// Track purchases
function trackPurchase(transactionId, value, currency = 'USD', items = []) {
  gtag('event', 'purchase', {
    'transaction_id': transactionId,
    'value': value,
    'currency': currency,
    'items': items
  });
}

// Track add to cart
function trackAddToCart(itemId, itemName, category, value) {
  gtag('event', 'add_to_cart', {
    'currency': 'USD',
    'value': value,
    'items': [{
      'item_id': itemId,
      'item_name': itemName,
      'item_category': category,
      'quantity': 1,
      'price': value
    }]
  });
}
</script>
''';
  }

  // Flutter SDK integration code
  static String generateFlutterSDKCode() {
    return '''
// Add to pubspec.yaml
dependencies:
  facebook_app_events: ^0.19.2
  firebase_core: ^2.24.2
  firebase_analytics: ^10.7.4

// Add to main.dart
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class TrackingService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  // Initialize (call in main())
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    await FacebookAppEvents.setAutoLogAppEventsEnabled(true);
    await FacebookAppEvents.setAdvertiserTracking(enabled: true);
  }
  
  // Track purchase
  static Future<void> trackPurchase(double value, String currency) async {
    // Meta tracking
    await FacebookAppEvents.logPurchase(amount: value, currency: currency);
    
    // Google tracking
    await _analytics.logPurchase(
      currency: currency,
      value: value,
    );
  }
  
  // Track add to cart
  static Future<void> trackAddToCart(String itemId, double value) async {
    // Meta tracking
    await FacebookAppEvents.logEvent(
      name: 'add_to_cart',
      parameters: {'content_id': itemId, 'value': value},
    );
    
    // Google tracking
    await _analytics.logAddToCart(
      currency: 'USD',
      value: value,
      items: [AnalyticsEventItem(itemId: itemId, price: value)],
    );
  }
}

// Usage in your app:
// TrackingService.trackPurchase(29.99, 'USD');
// TrackingService.trackAddToCart('poster_123', 29.99);
''';
  }

  // Validation functions
  static bool _isValidMetaPixelId(String id) {
    return RegExp(r'^\d{15,16}$').hasMatch(id);
  }

  static bool _isValidFacebookAppId(String id) {
    return RegExp(r'^\d{15,16}$').hasMatch(id);
  }

  static bool _isValidGoogleAnalyticsId(String id) {
    return RegExp(r'^G-[A-Z0-9]{10}$').hasMatch(id) || RegExp(r'^UA-\d{4,10}-\d{1,4}$').hasMatch(id);
  }

  static bool _isValidFirebaseProjectId(String id) {
    return RegExp(r'^[a-z0-9-]{1,30}$').hasMatch(id);
  }

  static bool _isValidGoogleAdsId(String id) {
    return id.isEmpty || RegExp(r'^AW-\d{9,11}$').hasMatch(id);
  }

  // Sample tracking events (for demo)
  static List<Map<String, dynamic>> getSampleTrackingEvents() {
    final status = getConnectionStatus();
    
    if (!status['overall']['readyForCampaigns']) {
      return [];
    }
    
    return [
      {
        'platform': 'Meta',
        'event': 'app_install',
        'description': 'User installed app from Meta ad',
        'value': 0.0,
        'timestamp': DateTime.now().subtract(Duration(hours: 2)),
        'attribution': 'Campaign: Anime Posters - Lookalike',
      },
      {
        'platform': 'Meta',
        'event': 'purchase',
        'description': 'User purchased anime poster',
        'value': 29.99,
        'timestamp': DateTime.now().subtract(Duration(minutes: 45)),
        'attribution': 'Campaign: Retargeting - Cart Abandoners',
      },
      {
        'platform': 'Google',
        'event': 'first_open',
        'description': 'User opened app for first time',
        'value': 0.0,
        'timestamp': DateTime.now().subtract(Duration(hours: 1)),
        'attribution': 'Campaign: Universal App - Install',
      },
      {
        'platform': 'Google',
        'event': 'add_to_cart',
        'description': 'User added item to cart',
        'value': 19.99,
        'timestamp': DateTime.now().subtract(Duration(minutes: 15)),
        'attribution': 'Campaign: Shopping - Anime Collection',
      },
    ];
  }

  // Campaign performance (simulated based on connected platforms)
  static List<Map<String, dynamic>> getCampaignPerformance() {
    final status = getConnectionStatus();
    List<Map<String, dynamic>> campaigns = [];
    
    if (status['meta']['connected']) {
      campaigns.addAll([
        {
          'platform': 'Meta',
          'campaignName': 'KarmaShop - App Install Campaign',
          'status': 'Active',
          'budget': 100.0,
          'spent': 87.45,
          'installs': 156,
          'purchases': 34,
          'cpi': 0.56,
          'roas': 4.8,
          'pixelId': status['meta']['pixelId'],
        },
        {
          'platform': 'Meta',
          'campaignName': 'Anime Posters - Lookalike Audience',
          'status': 'Active',
          'budget': 75.0,
          'spent': 68.90,
          'installs': 89,
          'purchases': 23,
          'cpi': 0.77,
          'roas': 3.9,
          'pixelId': status['meta']['pixelId'],
        },
      ]);
    }
    
    if (status['google']['connected']) {
      campaigns.addAll([
        {
          'platform': 'Google',
          'campaignName': 'Universal App Campaign - Install',
          'status': 'Active',
          'budget': 150.0,
          'spent': 134.67,
          'installs': 203,
          'purchases': 41,
          'cpi': 0.66,
          'roas': 4.2,
          'projectId': status['google']['projectId'],
        },
      ]);
    }
    
    return campaigns;
  }
}