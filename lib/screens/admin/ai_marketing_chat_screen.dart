import 'package:flutter/material.dart';
import '../../services/ai_marketing_assistant.dart';

class AIMarketingChatScreen extends StatefulWidget {
  const AIMarketingChatScreen({super.key});

  @override
  State<AIMarketingChatScreen> createState() => _AIMarketingChatScreenState();
}

class _AIMarketingChatScreenState extends State<AIMarketingChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AIMarketingAssistant _aiAssistant = AIMarketingAssistant();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAI();
    _addWelcomeMessage();
  }

  Future<void> _initializeAI() async {
    await _aiAssistant.initialize();
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage(
        text: "👋 Welcome to your AI Marketing Assistant!\n\nI'm here to help you grow Karma Shop with:\n\n🎯 Marketing strategies\n📊 Market research\n💡 Business insights\n🔍 Competitor analysis\n\nWhat would you like to know about marketing your anime merchandise business?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI Marketing Assistant'),
        backgroundColor: const Color(0xFF1A1D29),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0F1419),
      body: Column(
        children: [
          // Quick Actions
          _buildQuickActions(),
          
          // Chat Messages
          Expanded(
            child: _buildChatArea(),
          ),
          
          // Message Input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickActionButton(
                  '📊 Market Research',
                  'Research anime poster trends',
                  () => _sendMessage('Research current market trends and demand for anime posters. What should I know about pricing and competition?'),
                ),
                const SizedBox(width: 12),
                _buildQuickActionButton(
                  '🎯 Marketing Ideas',
                  'Get marketing strategies',
                  () => _sendMessage('Give me 5 specific marketing strategies for my anime merchandise store. Focus on social media and customer acquisition.'),
                ),
                const SizedBox(width: 12),
                _buildQuickActionButton(
                  '💰 Pricing Help',
                  'Analyze pricing strategy',
                  () => _sendMessage('Help me create a competitive pricing strategy for anime merchandise. What price ranges work best?'),
                ),
                const SizedBox(width: 12),
                _buildQuickActionButton(
                  '📱 Social Media',
                  'Social media advice',
                  () => _sendMessage('How can I effectively use Instagram, TikTok, and other social media platforms to market anime products to young adults?'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2328),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3B4043)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2328),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _messages.length && _isLoading) {
            return _buildTypingIndicator();
          }
          return _buildMessageBubble(_messages[index]);
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF4A9EFF),
              child: const Text('🤖', style: TextStyle(fontSize: 14)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser ? const Color(0xFF4A9EFF) : const Color(0xFF2D3339),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF4A9EFF),
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF4A9EFF),
            child: const Text('🤖', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2D3339),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600 + (index * 200)),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E2328),
        border: Border(
          top: BorderSide(color: Color(0xFF3B4043)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ask about marketing strategies, trends, pricing...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFF0F1419),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF3B4043)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF3B4043)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4A9EFF)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: null,
              onSubmitted: (_) => _handleSendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _handleSendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4A9EFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty && !_isLoading) {
      _sendMessage(message);
      _messageController.clear();
    }
  }

  Future<void> _sendMessage(String message) async {
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      String response;
      
      // Check if this is a market research request
      if (message.toLowerCase().contains('research') || 
          message.toLowerCase().contains('market') ||
          message.toLowerCase().contains('trends')) {
        
        final marketData = await _aiAssistant.researchMarketTrends('anime posters');
        response = _formatMarketResearchResponse(marketData);
      } else {
        // Regular chat response
        response = await _aiAssistant.quickChat(message);
      }

      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: "Sorry, I couldn't process your request right now. Please check your internet connection and try again.\n\nError: ${e.toString()}",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  String _formatMarketResearchResponse(Map<String, dynamic> data) {
    if (data['status'] == 'success' && data['analysis'] != null) {
      final analysis = data['analysis'];
      return """
🔍 **Market Research Results**

📊 **Market Overview:**
• Demand Score: ${analysis['demand_score']}/10
• Market Size: ${analysis['market_size']}
• Growth Trend: ${analysis['growth_trend']}
• Competition: ${analysis['competition_level']}

💡 **Key Opportunities:**
${(analysis['opportunities'] as List).map((o) => '• $o').join('\n')}

🎯 **Trending Keywords:**
${(analysis['trending_keywords'] as List).join(', ')}

💰 **Price Range:**
• Average: \$${analysis['price_range']['average']}
• Range: \$${analysis['price_range']['min']} - \$${analysis['price_range']['max']}

📱 **Best Marketing Channels:**
${(analysis['marketing_channels'] as List).map((c) => '• $c').join('\n')}

📋 **Recommendations:**
${(analysis['recommendations'] as List).map((r) => '• $r').join('\n')}
""";
    } else if (data['status'] == 'search_only') {
      return """
🔍 **Market Research (Basic)**

Found some market data but AI analysis isn't available. Here's what I found:

📊 **Trending Topics:**
${(data['raw_data']['trends'] as List).take(3).map((t) => '• $t').join('\n')}

🛍️ **Popular Products:**
${(data['raw_data']['popular_products'] as List).take(3).map((p) => '• $p').join('\n')}

💡 **Quick Recommendations:**
• Focus on trending anime series
• Optimize for mobile shopping
• Use social media marketing
• Consider seasonal campaigns
""";
    } else {
      return """
🔍 **Market Research**

I found some general insights about the anime merchandise market:

📊 **Current Trends:**
• Growing global anime popularity
• Increased online shopping preference  
• Mobile-first commerce behavior
• Social media influence on purchases

💡 **Opportunities:**
• Partner with anime influencers
• Create seasonal collections
• Focus on exclusive/limited items
• Build community engagement

📱 **Marketing Channels:**
• Instagram & TikTok
• YouTube unboxing videos
• Anime forums & communities
• Email newsletters

${data['message'] ?? 'Configure search API for detailed real-time market data!'}
""";
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2328),
        title: const Text('AI Settings', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'AI Status: ${_aiAssistant.isConfigured ? "✅ Connected" : "❌ Not configured"}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Search Status: ${_aiAssistant.isSearchConfigured ? "✅ Connected" : "❌ Not configured"}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your API keys are securely stored and ready to use!',
              style: TextStyle(color: Colors.green),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}