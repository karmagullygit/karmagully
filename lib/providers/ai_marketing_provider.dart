import 'package:flutter/material.dart';

/// Local AI-like provider that generates marketing & sales plans for a niche product.
/// This is intentionally implemented locally (no external API) so it works offline and
/// avoids credentials. It returns structured suggestions tailored for "anime metal posters".
class AIMarketingProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _plan;

  bool get loading => _loading;
  String? get error => _error;
  Map<String, dynamic>? get plan => _plan;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    _error = e;
    notifyListeners();
  }

  void _setPlan(Map<String, dynamic>? p) {
    _plan = p;
    notifyListeners();
  }

  /// Generate a marketing plan based on inputs. This simulates an AI by using
  /// simple heuristics and templates tuned for anime metal posters.
  Future<void> generatePlan({
    required String businessName,
    required String audience,
    required String budgetRange,
    required String primaryGoal,
    List<String>? channels,
  }) async {
    _setError(null);
    _setLoading(true);
    _setPlan(null);

    try {
      // Simulate processing time
      await Future.delayed(const Duration(milliseconds: 600));

      final selectedChannels = channels == null || channels.isEmpty
          ? ['Instagram', 'TikTok', 'Etsy/Shopify', 'Email']
          : channels;

      // Simple heuristics to create prioritized channels and tactics
      final channelTactics = <String, List<String>>{};

      for (final ch in selectedChannels) {
        switch (ch.toLowerCase()) {
          case 'instagram':
            channelTactics[ch] = [
              'High-quality lifestyle photos showing posters in rooms',
              'Use reels showing unboxing and close-ups of metal finish',
              'Partner with anime interior decorators / micro-influencers',
              'Use targeted story ads for anime fans and collectors',
            ];
            break;
          case 'tiktok':
            channelTactics[ch] = [
              'Short clips of poster reflection, metallic shimmer',
              'Before/after room makeovers with the poster as focal point',
              'Create hashtag challenges (e.g. #MetalPosterGlow)',
              'Work with anime cosplayers and set backgrounds',
            ];
            break;
          case 'etsy/shopify':
          case 'etsy':
          case 'shopify':
            channelTactics[ch] = [
              'Optimize listings with keywords: "anime metal poster", "anime wall art"',
              'Offer bundle discounts (2+ posters), free tracked shipping thresholds',
              'Use high-res product photos + 360° views',
              'Promote limited edition runs to create scarcity',
            ];
            break;
          case 'email':
            channelTactics[ch] = [
              'Collect emails with a small discount on first purchase',
              'Send segmented campaigns for collectors vs casual buyers',
              'Announce limited drops and restocks with clear CTAs',
            ];
            break;
          case 'facebook':
            channelTactics[ch] = [
              'Run carousel ads targeting anime interest groups',
              'Retarget visitors who viewed product pages',
            ];
            break;
          case 'twitter':
          case 'x':
            channelTactics[ch] = [
              'Share product teasers, engage in anime community conversations',
            ];
            break;
          case 'influencer':
            channelTactics[ch] = [
              'Identify micro influencers (10k-50k) in anime niche',
              'Offer free sample + affiliate commission',
            ];
            break;
          default:
            channelTactics[ch] = [
              'General content marketing and product showcase tailored to platform',
            ];
        }
      }

      // Generate sample ad copy variants
      final adCopies = <String>[];
      adCopies.add(
          'Transform your space with limited-edition anime metal posters — metallic finish, museum-quality printing. Shop now!');
      adCopies.add(
          'Collectors alert: premium anime metal posters in limited drops. Free shipping over \$50. Grab yours before they\'re gone!');
      adCopies.add(
          'Give your wall a glow-up — durable metal posters with stunning color and shine. Perfect for gifts.');

      // Pricing/promotion suggestions based on budget
      final pricing = <String>[];
      if (budgetRange.contains(r'\$') || budgetRange.contains('low')) {
        pricing.add('Start with low CPM channels (TikTok organic + Instagram Reels + community posts)');
        pricing.add('Use small paid test campaigns (\$5-20/day) to find top-performing creatives');
      } else if (budgetRange.contains('medium') || budgetRange.contains('100')) {
        pricing.add('Allocate budget across Instagram ads, TikTok ads, and boosted Etsy listings');
        pricing.add('Run A/B tests on creatives and landing pages for 2 weeks');
      } else {
        pricing.add('Invest in influencer partnerships and multi-platform paid campaigns');
        pricing.add('Consider limited-edition drops with pre-orders to gauge demand');
      }

      // Timeline and KPIs
      final timeline = [
        'Week 1: Build creative assets, set up store funnels and tracking, run small audience tests',
        'Weeks 2-3: Scale winners, optimize creatives, onboard micro-influencers',
        'Week 4+: Launch limited drop + email campaign, analyze conversion & ROAS',
      ];

      final kpis = [
        'Click-through rate (CTR) for ads',
        'Cost per acquisition (CPA)',
        'Return on ad spend (ROAS)',
        'Email list growth rate',
      ];

      final suggestedPlan = {
        'businessName': businessName,
        'audience': audience,
        'budgetRange': budgetRange,
        'primaryGoal': primaryGoal,
        'channels': channelTactics,
        'adCopies': adCopies,
        'pricingAndPromotions': pricing,
        'timeline': timeline,
        'kpis': kpis,
        'notes': [
          'Focus on high-quality visuals showing metallic reflections.',
          'Offer limited runs to create urgency and collector interest.',
        ],
      };

      _setPlan(suggestedPlan);
    } catch (e) {
      _setError('Failed to generate plan: $e');
    } finally {
      _setLoading(false);
    }
  }
}
