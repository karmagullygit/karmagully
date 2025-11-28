import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/support_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/support_ticket.dart';
import '../../models/support_message.dart';
import '../../constants/app_colors.dart';

class AdminSupportScreen extends StatefulWidget {
  const AdminSupportScreen({super.key});

  @override
  State<AdminSupportScreen> createState() => _AdminSupportScreenState();
}

class _AdminSupportScreenState extends State<AdminSupportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SupportProvider>(context, listen: false).loadAllTickets();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        
        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(isDarkMode),
          appBar: AppBar(
            title: const Text('Customer Support'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Open'),
                Tab(text: 'In Progress'),
                Tab(text: 'Resolved'),
              ],
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
            ),
            actions: [
              Consumer<SupportProvider>(
                builder: (context, supportProvider, child) {
                  final unreadCount = supportProvider.unreadTicketsCount;
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          supportProvider.loadAllTickets();
                        },
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              _buildStatsBar(isDarkMode),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTicketsList('all', isDarkMode),
                    _buildTicketsList('open', isDarkMode),
                    _buildTicketsList('in_progress', isDarkMode),
                    _buildTicketsList('resolved', isDarkMode),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsBar(bool isDarkMode) {
    return Consumer<SupportProvider>(
      builder: (context, supportProvider, child) {
        final stats = supportProvider.ticketStats;
        
        return Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.getCardBackgroundColor(isDarkMode),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', stats['total'] ?? 0, Colors.blue, isDarkMode),
              _buildStatItem('Open', stats['open'] ?? 0, Colors.orange, isDarkMode),
              _buildStatItem('In Progress', stats['in_progress'] ?? 0, Colors.blue, isDarkMode),
              _buildStatItem('Unread', stats['unread'] ?? 0, Colors.red, isDarkMode),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, int count, Color color, bool isDarkMode) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.getTextColor(isDarkMode).withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketsList(String status, bool isDarkMode) {
    return Consumer<SupportProvider>(
      builder: (context, supportProvider, child) {
        if (supportProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<SupportTicket> tickets;
        if (status == 'all') {
          tickets = supportProvider.tickets;
        } else {
          tickets = supportProvider.getTicketsByStatus(status);
        }

        if (tickets.isEmpty) {
          return _buildEmptyState(status, isDarkMode);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            return _buildTicketCard(tickets[index], isDarkMode);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String status, bool isDarkMode) {
    String message;
    switch (status) {
      case 'open':
        message = 'No open tickets';
        break;
      case 'in_progress':
        message = 'No tickets in progress';
        break;
      case 'resolved':
        message = 'No resolved tickets';
        break;
      default:
        message = 'No tickets yet';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.support_agent,
            size: 80,
            color: AppColors.getTextColor(isDarkMode).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: AppColors.getTextColor(isDarkMode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(SupportTicket ticket, bool isDarkMode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.getCardBackgroundColor(isDarkMode),
      child: ListTile(
        leading: Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getStatusColor(ticket.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                _getStatusIcon(ticket.status),
                color: _getStatusColor(ticket.status),
              ),
            ),
            if (ticket.unreadMessages > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${ticket.unreadMessages}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          ticket.subject,
          style: TextStyle(
            color: AppColors.getTextColor(isDarkMode),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Customer: ${ticket.customerName}',
              style: TextStyle(
                color: AppColors.getTextColor(isDarkMode).withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(ticket.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ticket.statusDisplayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(ticket.priority),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ticket.priorityDisplayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Created: ${_formatDate(ticket.createdAt)}',
              style: TextStyle(
                color: AppColors.getTextColor(isDarkMode).withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            if (ticket.orderId != null)
              Text(
                'Order: ${ticket.orderId}',
                style: TextStyle(
                  color: AppColors.getTextColor(isDarkMode).withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'view':
                _openTicketChat(ticket);
                break;
              case 'status':
                _showStatusDialog(ticket);
                break;
              case 'priority':
                _showPriorityDialog(ticket);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('View Chat'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'status',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Change Status'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'priority',
              child: ListTile(
                leading: Icon(Icons.priority_high),
                title: Text('Change Priority'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: () => _openTicketChat(ticket),
      ),
    );
  }

  void _openTicketChat(SupportTicket ticket) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminSupportChatScreen(ticket: ticket),
      ),
    );
  }

  void _showStatusDialog(SupportTicket ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Open'),
              leading: Radio<String>(
                value: 'open',
                groupValue: ticket.status,
                onChanged: (value) {
                  Navigator.pop(context);
                  if (value != null) {
                    Provider.of<SupportProvider>(context, listen: false)
                        .updateTicketStatus(ticket.id, value);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('In Progress'),
              leading: Radio<String>(
                value: 'in_progress',
                groupValue: ticket.status,
                onChanged: (value) {
                  Navigator.pop(context);
                  if (value != null) {
                    Provider.of<SupportProvider>(context, listen: false)
                        .updateTicketStatus(ticket.id, value);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Resolved'),
              leading: Radio<String>(
                value: 'resolved',
                groupValue: ticket.status,
                onChanged: (value) {
                  Navigator.pop(context);
                  if (value != null) {
                    Provider.of<SupportProvider>(context, listen: false)
                        .updateTicketStatus(ticket.id, value);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Closed'),
              leading: Radio<String>(
                value: 'closed',
                groupValue: ticket.status,
                onChanged: (value) {
                  Navigator.pop(context);
                  if (value != null) {
                    Provider.of<SupportProvider>(context, listen: false)
                        .updateTicketStatus(ticket.id, value);
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showPriorityDialog(SupportTicket ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Priority'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Low'),
              leading: Radio<String>(
                value: 'low',
                groupValue: ticket.priority,
                onChanged: (value) {
                  Navigator.pop(context);
                  if (value != null) {
                    Provider.of<SupportProvider>(context, listen: false)
                        .updateTicketPriority(ticket.id, value);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Medium'),
              leading: Radio<String>(
                value: 'medium',
                groupValue: ticket.priority,
                onChanged: (value) {
                  Navigator.pop(context);
                  if (value != null) {
                    Provider.of<SupportProvider>(context, listen: false)
                        .updateTicketPriority(ticket.id, value);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('High'),
              leading: Radio<String>(
                value: 'high',
                groupValue: ticket.priority,
                onChanged: (value) {
                  Navigator.pop(context);
                  if (value != null) {
                    Provider.of<SupportProvider>(context, listen: false)
                        .updateTicketPriority(ticket.id, value);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Urgent'),
              leading: Radio<String>(
                value: 'urgent',
                groupValue: ticket.priority,
                onChanged: (value) {
                  Navigator.pop(context);
                  if (value != null) {
                    Provider.of<SupportProvider>(context, listen: false)
                        .updateTicketPriority(ticket.id, value);
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'open':
        return Icons.hourglass_empty;
      case 'in_progress':
        return Icons.work;
      case 'resolved':
        return Icons.check_circle;
      case 'closed':
        return Icons.lock;
      default:
        return Icons.help;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'urgent':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class AdminSupportChatScreen extends StatefulWidget {
  final SupportTicket ticket;

  const AdminSupportChatScreen({
    super.key,
    required this.ticket,
  });

  @override
  State<AdminSupportChatScreen> createState() => _AdminSupportChatScreenState();
}

class _AdminSupportChatScreenState extends State<AdminSupportChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SupportProvider>(context, listen: false)
          .loadMessages(widget.ticket.id);
      _markMessagesAsRead();
    });
  }

  void _markMessagesAsRead() {
    // Mark messages as read from admin perspective
    Provider.of<SupportProvider>(context, listen: false)
        .markMessagesAsRead(widget.ticket.id, 'admin');
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        
        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(isDarkMode),
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.ticket.subject,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Customer: ${widget.ticket.customerName}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'customer_details':
                      _showCustomerDetails();
                      break;
                    case 'order_details':
                      if (widget.ticket.orderId != null) {
                        _showOrderDetails();
                      }
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'customer_details',
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Customer Details'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  if (widget.ticket.orderId != null)
                    const PopupMenuItem(
                      value: 'order_details',
                      child: ListTile(
                        leading: Icon(Icons.shopping_bag),
                        title: Text('Order Details'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              _buildTicketInfo(isDarkMode),
              Expanded(
                child: Consumer<SupportProvider>(
                  builder: (context, supportProvider, child) {
                    if (supportProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final messages = supportProvider.messages;

                    if (messages.isEmpty) {
                      return Center(
                        child: Text(
                          'No messages yet',
                          style: TextStyle(
                            color: AppColors.getTextColor(isDarkMode),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageBubble(messages[index], isDarkMode);
                      },
                    );
                  },
                ),
              ),
              _buildMessageInput(isDarkMode),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTicketInfo(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.getCardBackgroundColor(isDarkMode),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.ticket.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.ticket.statusDisplayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(widget.ticket.priority),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.ticket.priorityDisplayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.ticket.orderId != null)
            Text(
              'Order: ${widget.ticket.orderId}',
              style: TextStyle(
                color: AppColors.getTextColor(isDarkMode).withOpacity(0.7),
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(SupportMessage message, bool isDarkMode) {
    final isAdmin = message.senderType == 'admin';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isAdmin ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isAdmin) ...[
            CircleAvatar(
              backgroundColor: AppColors.secondary,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isAdmin 
                    ? AppColors.primary 
                    : AppColors.getCardBackgroundColor(isDarkMode),
                borderRadius: BorderRadius.circular(16),
                border: !isAdmin
                    ? Border.all(color: AppColors.getBorderColor(isDarkMode))
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isAdmin 
                          ? Colors.white 
                          : AppColors.getTextColor(isDarkMode),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatMessageTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isAdmin 
                          ? Colors.white70 
                          : AppColors.getTextColor(isDarkMode).withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.support_agent, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(isDarkMode),
        border: Border(
          top: BorderSide(color: AppColors.getBorderColor(isDarkMode)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your response...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            mini: true,
            onPressed: _sendMessage,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final support = Provider.of<SupportProvider>(context, listen: false);

    await support.sendMessage(
      ticketId: widget.ticket.id,
      senderId: 'admin',
      senderName: 'Support Team',
      senderType: 'admin',
      message: _messageController.text.trim(),
    );

    _messageController.clear();
    _scrollToBottom();
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

  void _showCustomerDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Customer Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${widget.ticket.customerName}'),
            const SizedBox(height: 8),
            Text('Email: ${widget.ticket.customerEmail}'),
            const SizedBox(height: 8),
            Text('Customer ID: ${widget.ticket.customerId}'),
            const SizedBox(height: 8),
            Text('Created: ${_formatDate(widget.ticket.createdAt)}'),
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

  void _showOrderDetails() {
    // This would typically fetch order details from OrderService
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${widget.ticket.orderId}'),
            const SizedBox(height: 8),
            const Text('Status: Processing'),
            const SizedBox(height: 8),
            const Text('Total: \$99.99'),
            const SizedBox(height: 8),
            const Text('Items: 3'),
            const SizedBox(height: 8),
            const Text('Note: This is sample order data. Integrate with your OrderService for real data.'),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'urgent':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}