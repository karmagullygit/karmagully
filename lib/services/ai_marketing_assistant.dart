import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AIMarketingAssistant {
  static const String _geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';
  static const String _searchBaseUrl = 'https://www.googleapis.com/customsearch/v1';
  
  String? _geminiApiKey;
  String? _searchApiKey;
  String? _searchEngineId;
  
  // Initialize with your API keys
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Use your actual API keys
    _geminiApiKey = 'AIzaSyALbGKZ-iAH9V0o6RPB14pQK42JHiC5blY';
    _searchApiKey = 'AIzaSyDg-mODqCp2RcHF1IdlrPt6R99gIIQgO5I';
    _searchEngineId = 'a7a0778067e624cd6';
    
    // Save them to preferences
    await prefs.setString('gemini_api_key', _geminiApiKey!);
    await prefs.setString('search_api_key', _searchApiKey!);
    await prefs.setString('search_engine_id', _searchEngineId!);
  }
  
  // Save API keys
  Future<void> saveApiKeys({
    String? geminiKey,
    String? searchKey,
    String? searchEngineId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (geminiKey != null) {
      await prefs.setString('gemini_api_key', geminiKey);
      _geminiApiKey = geminiKey;
    }
    if (searchKey != null) {
      await prefs.setString('search_api_key', searchKey);
      _searchApiKey = searchKey;
    }
    if (searchEngineId != null) {
      await prefs.setString('search_engine_id', searchEngineId);
      _searchEngineId = searchEngineId;
    }
  }
  
  // Check if AI is configured
  bool get isConfigured {
    return _geminiApiKey != null && _geminiApiKey!.isNotEmpty;
  }
  
  bool get isSearchConfigured {
    return _searchApiKey != null && _searchApiKey!.isNotEmpty && 
           _searchEngineId != null && _searchEngineId!.isNotEmpty;
  }
  
  // Get marketing advice using AI
  Future<String> getMarketingAdvice({
    required String query,
    Map<String, dynamic>? appData,
  }) async {
    await initialize();
    
    if (!isConfigured) {
      return "Please configure your Gemini API key in settings to get personalized marketing advice.";
    }
    
    final context = _buildBusinessContext(appData);
    final prompt = _buildMarketingPrompt(query, context);
    
    try {
      return await _callGemini(prompt);
    } catch (e) {
      return "Error getting AI advice: ${e.toString()}\n\nPlease check your API key and internet connection.";
    }
  }
  
  // Quick chat response for simple questions
  Future<String> quickChat(String message) async {
    await initialize();
    
    if (!isConfigured) {
      return "🤖 AI not configured. Please add your Gemini API key in settings.\n\nMeanwhile, here are some quick marketing tips:\n• Focus on social media engagement\n• Use high-quality product images\n• Implement customer reviews\n• Create seasonal campaigns";
    }
    
    final prompt = """
  You are an expert marketing consultant specializing in anime merchandise and e-commerce.

  User question: "$message"

  Provide a helpful, detailed response (4-6 sentences) with specific, actionable advice for an anime merchandise business called KarmaGully. Include:
  - Practical steps they can implement immediately
  - Specific platforms, tools, or strategies
  - Expected outcomes or metrics to track
  - Any relevant trends in anime/pop culture marketing

  Be enthusiastic and use relevant emojis. Make it personal and specific to anime merchandise business.
  """;
    
    try {
      final response = await _callGemini(prompt);
      return response;
    } catch (e) {
      print('Error in quickChat: $e');
      return "🤖 I'm having trouble connecting to AI services right now. Here's a quick tip based on your question:\n\n• Focus on visual storytelling with your anime products\n• Engage with anime communities on social platforms\n• Use seasonal anime releases to drive campaigns\n• Build email lists with exclusive product previews\n\nTry asking again in a moment! 📱✨";
    }
  }
  
  // Research market trends for specific products
  Future<Map<String, dynamic>> researchMarketTrends(String productCategory) async {
    await initialize();
    
    if (!isSearchConfigured) {
      return {
        'status': 'search_not_configured',
        'message': 'Search API not configured',
        'insights': _getDefaultMarketInsights(productCategory),
        'suggestions': [
          'Configure Google Custom Search API to get real market data',
          'Enable image search for visual trend analysis',
          'Use safe search for professional results'
        ]
      };
    }
    
    try {
      // Search for multiple aspects of the market
      final futures = await Future.wait([
        _searchWeb('$productCategory market trends 2024 2025 demand growth'),
        _searchWeb('$productCategory best selling popular products anime'),
        _searchWeb('$productCategory pricing strategy market analysis competition'),
        _searchWeb('$productCategory social media marketing instagram tiktok'),
      ]);
      
      final trendData = futures[0];
      final popularProducts = futures[1];
      final pricingData = futures[2];
      final socialData = futures[3];
      
      // Analyze with AI if available
      if (isConfigured) {
        final analysis = await _analyzeMarketData(productCategory, {
          'trends': trendData,
          'popular_products': popularProducts,
          'pricing': pricingData,
          'social_media': socialData,
        });
        return {
          'status': 'success',
          'analysis': analysis,
          'raw_data': {
            'trends': trendData,
            'popular_products': popularProducts,
            'pricing': pricingData,
            'social_media': socialData,
          }
        };
      }
      
      return {
        'status': 'search_only',
        'raw_data': {
          'trends': trendData,
          'popular_products': popularProducts,
          'pricing': pricingData,
          'social_media': socialData,
        },
        'message': 'Raw search data available - enable AI for detailed analysis'
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': 'Failed to research market: ${e.toString()}',
        'insights': _getDefaultMarketInsights(productCategory),
        'suggestions': [
          'Check your API keys and internet connection',
          'Verify Custom Search Engine is properly configured',
          'Try again in a few minutes'
        ],
      };
    }
  }
  
  // Generate marketing strategies
  Future<List<Map<String, dynamic>>> generateMarketingStrategies({
    required String productType,
    Map<String, dynamic>? businessData,
  }) async {
    await initialize();
    
    if (!isConfigured) {
      return _getDefaultStrategies();
    }
    
    try {
      final prompt = """
As a marketing expert specializing in anime merchandise and e-commerce, generate 8 specific marketing strategies for a business selling $productType.

Business context: ${businessData?.toString() ?? 'Anime merchandise e-commerce app'}

For each strategy, provide:
1. Strategy name (short, catchy)
2. Description (2-3 sentences)
3. Implementation difficulty (1-5 scale)
4. Expected impact (1-5 scale)
5. Cost level (low/medium/high)
6. Timeline (immediate/short-term/long-term)

Format as JSON array:
[
  {
    "name": "Strategy Name",
    "description": "Detailed description with actionable steps",
    "difficulty": 3,
    "impact": 4,
    "cost": "low",
    "timeline": "short-term",
    "icon": "📱"
  }
]

Focus on modern, digital marketing tactics that work in 2024-2025. Include social media, influencer marketing, SEO, email marketing, and customer retention strategies.
""";
      
      final response = await _callGemini(prompt);
      return _parseStrategiesResponse(response);
    } catch (e) {
      return _getDefaultStrategies();
    }
  }
  
  // Analyze business performance
  Future<Map<String, dynamic>> analyzeBusinessPerformance(Map<String, dynamic> businessData) async {
    await initialize();
    
    if (!isConfigured) {
      return _getDefaultBusinessAnalysis();
    }
    
    try {
      final prompt = """
Analyze this e-commerce business data and provide insights:
${json.encode(businessData)}

Provide detailed analysis in this JSON format:
{
  "overall_score": [0-100 performance score],
  "strengths": ["strength 1", "strength 2", "strength 3"],
  "weaknesses": ["weakness 1", "weakness 2"],
  "opportunities": ["opportunity 1", "opportunity 2", "opportunity 3"],
  "threats": ["threat 1", "threat 2"],
  "recommendations": [
    {"action": "Specific action", "priority": "high/medium/low", "impact": "Expected impact"}
  ],
  "key_metrics": {
    "customer_acquisition": "assessment",
    "retention": "assessment", 
    "monetization": "assessment"
  },
  "next_steps": ["immediate action 1", "immediate action 2"]
}

Focus on practical business advice for mobile app growth, customer acquisition, and revenue optimization in the anime merchandise market.
""";
      
      final response = await _callGemini(prompt);
      try {
        return json.decode(response);
      } catch (parseError) {
        return _getDefaultBusinessAnalysis();
      }
    } catch (e) {
      return _getDefaultBusinessAnalysis();
    }
  }
  
  // Get competitor analysis
  Future<Map<String, dynamic>> getCompetitorAnalysis(String category) async {
    await initialize();
    
    if (!isSearchConfigured) {
      return {
        'status': 'not_configured',
        'message': 'Search API needed for competitor analysis'
      };
    }
    
    try {
      final competitors = await _searchWeb('$category online store shop anime merchandise competitors');
      
      if (isConfigured) {
        final analysis = await _analyzeCompetitors(category, competitors);
        return {
          'status': 'success',
          'analysis': analysis,
          'raw_data': competitors
        };
      }
      
      return {
        'status': 'search_only',
        'competitors': competitors
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString()
      };
    }
  }
  
  // Private helper methods
  String _buildBusinessContext(Map<String, dynamic>? appData) {
    return """
Business Context:
- Business Name: KarmaGully
- Industry: E-commerce / Anime Merchandise 
- Platform: Mobile App (Flutter)
- Target Market: Anime fans, collectors, young adults (16-35)
- Product Focus: Anime posters, figures, merchandise, collectibles
- Geographic: Global online sales
- Stage: Growing business looking to scale
${appData != null ? '- Current Data: ${json.encode(appData)}' : ''}
""";
  }
  
  String _buildMarketingPrompt(String query, String context) {
    return """
You are an expert marketing consultant specializing in:
- E-commerce and mobile app marketing
- Anime/pop culture merchandise 
- Digital marketing strategies
- Customer acquisition and retention
- Social media marketing

Business question: "$query"

$context

Provide practical, actionable advice considering:
1. Current anime/pop culture market trends
2. Mobile-first marketing strategies  
3. Gen Z and Millennial customer behavior
4. Budget-conscious solutions for growing businesses
5. Data-driven marketing approaches
6. Social media and influencer marketing
7. Customer lifecycle optimization

Give specific, implementable steps with expected outcomes. Keep response concise but comprehensive.
""";
  }
  
  Future<String> _callGemini(String prompt) async {
    if (_geminiApiKey == null || _geminiApiKey!.isEmpty) {
      throw Exception('Gemini API key not configured');
    }
    
    final url = '$_geminiBaseUrl?key=$_geminiApiKey';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'contents': [{
            'parts': [{'text': prompt}]
          }],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          }
        }),
      );
      
      print('Gemini API Response Status: ${response.statusCode}');
      print('Gemini API Response: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final content = data['candidates'][0]['content'];
          if (content != null && content['parts'] != null && content['parts'].isNotEmpty) {
            return content['parts'][0]['text'] ?? 'No response generated';
          }
        }
        throw Exception('Invalid response format from Gemini API');
      } else {
        throw Exception('Gemini API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error calling Gemini API: $e');
      rethrow;
    }
  }
  
  Future<List<String>> _searchWeb(String query) async {
    final response = await http.get(
      Uri.parse('$_searchBaseUrl?key=$_searchApiKey&cx=$_searchEngineId&q=${Uri.encodeComponent(query)}&num=8'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List? ?? [];
      return items.map((item) => '${item['title']}: ${item['snippet']}').cast<String>().toList();
    } else {
      throw Exception('Search API error: ${response.statusCode} - ${response.body}');
    }
  }
  
  Future<Map<String, dynamic>> _analyzeMarketData(String category, Map<String, dynamic> data) async {
    final prompt = """
Analyze this market research data for $category products:
${json.encode(data)}

Provide analysis in JSON format:
{
  "demand_score": [1-10],
  "market_size": "small/medium/large/huge",
  "growth_trend": "declining/stable/growing/booming", 
  "competition_level": "low/medium/high/very high",
  "opportunities": ["opportunity 1", "opportunity 2", "opportunity 3"],
  "threats": ["threat 1", "threat 2"],
  "price_range": {"min": 0, "max": 0, "average": 0},
  "trending_keywords": ["keyword1", "keyword2", "keyword3"],
  "target_demographics": ["demo1", "demo2"],
  "marketing_channels": ["channel1", "channel2", "channel3"],
  "seasonality": "description of seasonal patterns",
  "recommendations": ["rec1", "rec2", "rec3"]
}
""";
    
    try {
      final response = await _callGemini(prompt);
      return json.decode(response);
    } catch (e) {
      return {
        'demand_score': 7,
        'market_size': 'medium',
        'growth_trend': 'growing',
        'competition_level': 'medium',
        'opportunities': ['Digital marketing expansion', 'Social media growth', 'Influencer partnerships'],
        'threats': ['Market saturation', 'Economic factors'],
        'price_range': {'min': 10, 'max': 100, 'average': 35},
        'trending_keywords': ['anime', 'merchandise', 'collectibles'],
        'target_demographics': ['Young adults', 'Anime fans'],
        'marketing_channels': ['Instagram', 'TikTok', 'YouTube'],
        'seasonality': 'Higher demand during anime convention seasons',
        'recommendations': ['Focus on unique products', 'Build community', 'Leverage social proof']
      };
    }
  }
  
  Future<Map<String, dynamic>> _analyzeCompetitors(String category, List<String> competitorData) async {
    final prompt = """
Analyze these competitor search results for $category:
${competitorData.join('\n')}

Provide competitor analysis in JSON:
{
  "top_competitors": ["comp1", "comp2", "comp3"],
  "competitive_advantages": ["advantage1", "advantage2"],
  "gaps_in_market": ["gap1", "gap2"], 
  "pricing_insights": "pricing analysis",
  "differentiation_opportunities": ["opp1", "opp2"],
  "market_positioning": "analysis of positioning"
}
""";
    
    try {
      final response = await _callGemini(prompt);
      return json.decode(response);
    } catch (e) {
      return {
        'top_competitors': ['Major anime stores', 'General merchandise platforms'],
        'competitive_advantages': ['Curated selection', 'Mobile-first experience'],
        'gaps_in_market': ['Personalized recommendations', 'Community features'],
        'pricing_insights': 'Competitive pricing needed',
        'differentiation_opportunities': ['AI-powered curation', 'Exclusive partnerships'],
        'market_positioning': 'Position as premium, curated anime marketplace'
      };
    }
  }
  
  List<Map<String, dynamic>> _parseStrategiesResponse(String response) {
    try {
      final List<dynamic> strategies = json.decode(response);
      return strategies.cast<Map<String, dynamic>>();
    } catch (e) {
      return _getDefaultStrategies();
    }
  }
  
  Map<String, dynamic> _getDefaultMarketInsights(String category) {
    return {
      'demand_score': 7,
      'trends': ['Growing anime popularity globally', 'Increased online shopping', 'Mobile-first commerce'],
      'opportunities': ['Social media marketing', 'Influencer partnerships', 'Seasonal campaigns'],
      'competition_level': 'medium',
      'recommendations': ['Focus on unique value proposition', 'Build strong brand identity', 'Optimize for mobile']
    };
  }
  
  List<Map<String, dynamic>> _getDefaultStrategies() {
    return [
      {
        "name": "Social Media Marketing",
        "description": "Build strong presence on Instagram, TikTok, and Twitter with anime-focused content. Share product photos, behind-the-scenes content, and engage with anime communities.",
        "difficulty": 2,
        "impact": 4,
        "cost": "low",
        "timeline": "immediate",
        "icon": "📱"
      },
      {
        "name": "Influencer Partnerships",
        "description": "Collaborate with anime YouTubers, Instagram influencers, and TikTok creators. Send free products for honest reviews and unboxing videos.",
        "difficulty": 3,
        "impact": 5,
        "cost": "medium",
        "timeline": "short-term",
        "icon": "🤝"
      },
      {
        "name": "Email Marketing",
        "description": "Build email list with anime fans. Send weekly newsletters with new arrivals, exclusive deals, and anime news. Segment by favorite series/genres.",
        "difficulty": 2,
        "impact": 4,
        "cost": "low", 
        "timeline": "immediate",
        "icon": "📧"
      },
      {
        "name": "SEO Optimization",
        "description": "Optimize product pages for anime-related keywords. Create blog content about anime series, character guides, and merchandise reviews.",
        "difficulty": 3,
        "impact": 4,
        "cost": "low",
        "timeline": "long-term",
        "icon": "🔍"
      },
      {
        "name": "Loyalty Program",
        "description": "Create points-based rewards for repeat customers. Offer exclusive products, early access to new releases, and birthday discounts.",
        "difficulty": 4,
        "impact": 4,
        "cost": "medium",
        "timeline": "short-term",
        "icon": "💝"
      },
      {
        "name": "User-Generated Content",
        "description": "Encourage customers to share photos with their purchases. Create branded hashtags and feature customer photos on your social media.",
        "difficulty": 2,
        "impact": 3,
        "cost": "low",
        "timeline": "immediate",
        "icon": "📸"
      },
      {
        "name": "Seasonal Campaigns",
        "description": "Align marketing with anime conventions, seasonal anime releases, and holidays. Create themed collections and limited-time offers.",
        "difficulty": 3,
        "impact": 4,
        "cost": "medium",
        "timeline": "short-term",
        "icon": "🎉"
      },
      {
        "name": "Push Notifications",
        "description": "Send strategic push notifications for new arrivals, price drops, and personalized recommendations. Avoid over-messaging to prevent uninstalls.",
        "difficulty": 2,
        "impact": 3,
        "cost": "low",
        "timeline": "immediate",
        "icon": "🔔"
      }
    ];
  }
  
  Map<String, dynamic> _getDefaultBusinessAnalysis() {
    return {
      'overall_score': 75,
      'strengths': ['Mobile-first approach', 'Niche market focus', 'Growing anime popularity'],
      'weaknesses': ['Limited brand awareness', 'Competition from larger platforms'],
      'opportunities': ['Social media growth', 'Influencer marketing', 'International expansion'],
      'threats': ['Economic downturn', 'Supply chain issues', 'Platform dependency'],
      'recommendations': [
        {'action': 'Improve social media presence', 'priority': 'high', 'impact': 'Increased brand awareness'},
        {'action': 'Implement loyalty program', 'priority': 'medium', 'impact': 'Higher customer retention'},
        {'action': 'Partner with anime influencers', 'priority': 'high', 'impact': 'Reach new audiences'}
      ],
      'key_metrics': {
        'customer_acquisition': 'Good potential with proper marketing',
        'retention': 'Can be improved with loyalty programs',
        'monetization': 'Strong niche market with good margins'
      },
      'next_steps': ['Focus on social media marketing', 'Build email list', 'Optimize mobile experience']
    };
  }
}