import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class ChatBotProvider extends ChangeNotifier {
  ChatConversation? _currentConversation;
  List<ChatConversation> _conversations = [];
  bool _isTyping = false;
  String _currentUserId = 'user_1';
  bool _isAiInitialized = true;
  
  static const String _openRouterApiUrl = 'https://openrouter.ai/api/v1/chat/completions';
  // TODO: Move this to environment variables or secure configuration
  static const String _apiKey = '';
  static const String _selectedModel = 'mistralai/mistral-7b-instruct:free';

  ChatConversation? get currentConversation => _currentConversation;
  List<ChatConversation> get conversations => _conversations;
  bool get isTyping => _isTyping;
  String get currentUserId => _currentUserId;
  bool get isAiInitialized => _isAiInitialized;

  ChatBotProvider() {
    _initializeAI();
    loadConversations();
  }

  Future<void> _initializeAI() async {
    try {
      debugPrint('Simple AI Chatbot Ready!');
    } catch (e) {
      debugPrint('Failed to initialize AI: $e');
    }
    notifyListeners();
  }

  Future<String> _getAIResponse(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(_openRouterApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': _selectedModel,
          'messages': [
            {
              'role': 'user',
              'content': '[INST] You are KarmaBot, the smart AI assistant for KarmaShop e-commerce app! You can help with:\n\n🛍️ SHOPPING FEATURES:\n- Browse products (electronics, fashion, home goods)\n- Search for specific items\n- Show deals, sales, and discounts\n- Product recommendations\n- Price comparisons\n- Add items to cart or wishlist\n\n📦 ORDER MANAGEMENT:\n- Track orders and delivery status\n- Order history and details\n- Returns and refunds\n- Shipping information\n\n🎯 APP FEATURES:\n- Account management\n- Payment methods\n- Addresses and delivery\n- Notifications settings\n- Support and customer service\n- App navigation help\n\n💬 GENERAL AI:\n- Answer any question (science, math, general knowledge)\n- Have conversations\n- Provide explanations and help\n\nMatch the user\'s tone (casual/formal) and be helpful! If they ask about KarmaShop features, guide them through the app. For general questions, be a smart AI assistant.\n\nUser: $userMessage [/INST]'
            }
          ],
          'max_tokens': 300,
          'temperature': 0.7,
          'stream': false
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          String aiResponse = data['choices'][0]['message']['content'].toString().trim();
          aiResponse = aiResponse.replaceAll(RegExp(r'<[^>]*>'), '');
          aiResponse = aiResponse.replaceAll(RegExp(r'\s+'), ' ');
          aiResponse = aiResponse.trim();
          
          if (aiResponse.isNotEmpty) {
            return aiResponse;
          }
        }
      }
    } catch (e) {
      debugPrint('API Exception: $e');
    }
    
    return "I'm having trouble right now, but I'm here to help! Can you try asking again?";
  }

  Future<void> loadConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversationsJson = prefs.getString('chat_conversations');
      
      if (conversationsJson != null) {
        final List<dynamic> decoded = json.decode(conversationsJson);
        _conversations = decoded.map((item) => ChatConversation.fromJson(item)).toList();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading conversations: $e');
    }
  }

  Future<void> saveConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversationsJson = json.encode(_conversations.map((conv) => conv.toJson()).toList());
      await prefs.setString('chat_conversations', conversationsJson);
    } catch (e) {
      debugPrint('Error saving conversations: $e');
    }
  }

  void createNewConversation() {
    final newConversation = ChatConversation(
      id: 'conv_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUserId,
      title: 'New Chat',
      messages: [],
      createdAt: DateTime.now(),
      lastMessageAt: DateTime.now(),
    );

    _conversations.insert(0, newConversation);
    _currentConversation = newConversation;
    notifyListeners();
    saveConversations();
  }

  void startNewConversation() {
    createNewConversation();
  }

  void selectConversation(String conversationId) {
    _currentConversation = _conversations.firstWhere(
      (conv) => conv.id == conversationId,
      orElse: () => _conversations.first,
    );
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    if (_currentConversation == null) {
      createNewConversation();
    }

    final userMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      content: content.trim(),
      type: MessageType.user,
      timestamp: DateTime.now(),
    );

    _currentConversation!.messages.add(userMessage);
    _currentConversation!.lastMessageAt = DateTime.now();

    if (_currentConversation!.messages.length == 1) {
      _currentConversation!.title = content.length > 30 
          ? '${content.substring(0, 30)}...' 
          : content;
    }

    notifyListeners();

    _isTyping = true;
    notifyListeners();

    try {
      final response = await _getAIResponse(content);
      
      final botMessage = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch + 1}',
        content: response,
        type: MessageType.bot,
        timestamp: DateTime.now(),
        metadata: {
          'quickReplies': _generateQuickReplies(response, content),
        },
      );

      _currentConversation!.messages.add(botMessage);
      _currentConversation!.lastMessageAt = DateTime.now();

    } catch (e) {
      final errorMessage = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch + 1}',
        content: "Sorry, I'm having some trouble right now. Can you try asking again?",
        type: MessageType.bot,
        timestamp: DateTime.now(),
      );

      _currentConversation!.messages.add(errorMessage);
    } finally {
      _isTyping = false;
      notifyListeners();
      saveConversations();
    }
  }

  void deleteConversation(String conversationId) {
    _conversations.removeWhere((conv) => conv.id == conversationId);
    
    if (_currentConversation?.id == conversationId) {
      _currentConversation = _conversations.isNotEmpty ? _conversations.first : null;
    }
    
    notifyListeners();
    saveConversations();
  }

  void clearAllConversations() {
    _conversations.clear();
    _currentConversation = null;
    notifyListeners();
    saveConversations();
  }

  Future<void> sendQuickReply(String content) async {
    await sendMessage(content);
  }

  // Generate contextual quick replies for KarmaShop features
  List<String> _generateQuickReplies(String botResponse, String userMessage) {
    final response = botResponse.toLowerCase();
    final userMsg = userMessage.toLowerCase();
    
    // Recommendation related responses
    if (response.contains('recommend') || response.contains('suggest') || userMsg.contains('recommend') || userMsg.contains('suggest')) {
      return ['🤖 AI Recommendations', '🔥 Trending Now', '⭐ Popular Items', '💡 Smart Picks'];
    }
    
    // Shopping related responses
    if (response.contains('product') || response.contains('shop') || userMsg.contains('buy') || userMsg.contains('shop')) {
      return ['📱 Show Electronics', '👕 Browse Fashion', '🤖 AI Recommendations', '🔥 Today\'s Deals'];
    }
    
    // Order/tracking related
    if (response.contains('order') || response.contains('track') || userMsg.contains('order') || userMsg.contains('track')) {
      return ['📦 Track Order', '📋 Order History', '↩️ Returns Help', '🚚 Delivery Info'];
    }
    
    // Deals and discounts
    if (response.contains('deal') || response.contains('discount') || response.contains('sale')) {
      return ['🔥 Flash Sales', '🤖 AI Deals', '💎 Premium Deals', '📱 Tech Offers'];
    }
    
    // Account and app features
    if (response.contains('account') || response.contains('profile') || userMsg.contains('account')) {
      return ['👤 My Account', '💳 Payment Methods', '📍 Addresses', '🔔 Notifications'];
    }
    
    // Help and support
    if (response.contains('help') || response.contains('support') || userMsg.contains('help')) {
      return ['🤝 Customer Support', '❓ How to Order', '💰 Payment Help', '📞 Contact Us'];
    }
    
    // AI and smart features
    if (response.contains('ai') || response.contains('smart') || userMsg.contains('ai') || userMsg.contains('smart')) {
      return ['🤖 AI Recommendations', '🧠 Smart Shopping', '🔮 Predict Trends', '💡 AI Tips'];
    }
    
    // General conversation starters
    return ['🛍️ Browse Products', '🤖 AI Recommendations', '🔥 Show Deals', '📦 Track Orders'];
  }

  void setUserId(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }
}
