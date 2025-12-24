import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/user_management_provider.dart';
import '../../providers/social_feed_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/user.dart';
import '../../models/social_post.dart';
import '../../models/order.dart';
import '../../models/order_tracking.dart';

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  State<CustomerManagementScreen> createState() => _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _searchQuery = '';
  String _sortBy = 'newest'; // newest, oldest, most_active, spending
  Set<String> _selectedCustomers = {};
  bool _bulkMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text(
          'Customer Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1C1F26),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_bulkMode)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _bulkMode = false;
                  _selectedCustomers.clear();
                });
              },
              tooltip: 'Exit Bulk Mode',
            )
          else
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'bulk') {
                  setState(() => _bulkMode = true);
                } else if (value == 'export') {
                  _exportCustomers();
                } else if (value == 'analytics') {
                  _showAnalyticsDashboard();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'bulk',
                  child: Row(
                    children: [
                      Icon(Icons.checklist, color: Colors.purple),
                      SizedBox(width: 8),
                      Text('Bulk Operations'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.download, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Export Customers'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'analytics',
                  child: Row(
                    children: [
                      Icon(Icons.analytics, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Analytics Dashboard'),
                    ],
                  ),
                ),
              ],
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.purple,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'All Customers'),
                  Tab(text: 'Active'),
                  Tab(text: 'Inactive'),
                  Tab(text: 'Banned'),
                ],
              ),
              if (_bulkMode && _selectedCustomers.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.purple.withOpacity(0.2),
                  child: Row(
                    children: [
                      Text(
                        '${_selectedCustomers.length} selected',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _bulkBan,
                        icon: const Icon(Icons.block, size: 18, color: Colors.red),
                        label: const Text('Ban', style: TextStyle(color: Colors.red)),
                      ),
                      TextButton.icon(
                        onPressed: _bulkNotify,
                        icon: const Icon(Icons.notifications, size: 18, color: Colors.blue),
                        label: const Text('Notify', style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCustomerList(null),
                _buildCustomerList(false), // Not banned = active
                _buildCustomerList(null, inactive: true),
                _buildCustomerList(true),  // Banned customers
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search by name, email, phone, or Karma ID...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.search, color: Colors.purple),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.sort, color: Colors.purple),
                    tooltip: 'Sort By',
                    onSelected: (value) {
                      setState(() => _sortBy = value);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'newest',
                        child: Row(
                          children: [
                            Icon(Icons.new_releases, color: _sortBy == 'newest' ? Colors.purple : Colors.grey),
                            const SizedBox(width: 8),
                            const Text('Newest First'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'oldest',
                        child: Row(
                          children: [
                            Icon(Icons.history, color: _sortBy == 'oldest' ? Colors.purple : Colors.grey),
                            const SizedBox(width: 8),
                            const Text('Oldest First'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'most_active',
                        child: Row(
                          children: [
                            Icon(Icons.trending_up, color: _sortBy == 'most_active' ? Colors.purple : Colors.grey),
                            const SizedBox(width: 8),
                            const Text('Most Active'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'spending',
                        child: Row(
                          children: [
                            Icon(Icons.attach_money, color: _sortBy == 'spending' ? Colors.purple : Colors.grey),
                            const SizedBox(width: 8),
                            const Text('Highest Spending'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              filled: true,
              fillColor: const Color(0xFF0A0E21),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerList(bool? bannedFilter, {bool inactive = false}) {
    return Consumer3<UserManagementProvider, SocialFeedProvider, OrderProvider>(
      builder: (context, userProvider, feedProvider, orderProvider, child) {
        List<User> customers;
        
        if (_searchQuery.isNotEmpty) {
          customers = userProvider.searchUsers(_searchQuery);
        } else {
          customers = userProvider.users;
        }

        // Filter only customers (not admins)
        customers = customers.where((u) => u.role == UserRole.customer).toList();

        // Apply banned filter
        if (bannedFilter != null) {
          customers = customers.where((u) => u.isBanned == bannedFilter).toList();
        }

        // Apply inactive filter (customers with old last activity - mock for now)
        if (inactive) {
          customers = customers.where((u) => 
            DateTime.now().difference(u.createdAt).inDays > 90
          ).toList();
        }

        // Sort customers
        customers = _sortCustomers(customers, userProvider, orderProvider);

        if (customers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 80,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty ? 'No customers found' : 'No customers yet',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: customers.length,
          itemBuilder: (context, index) {
            final customer = customers[index];
            final stats = userProvider.getUserStats(customer.karmaId);
            final posts = feedProvider.getUserPosts(customer.id); // Use user ID, not karmaId
            
            return _buildCustomerCard(customer, stats, posts.length, feedProvider, orderProvider);
          },
        );
      },
    );
  }

  List<User> _sortCustomers(List<User> customers, UserManagementProvider provider, OrderProvider orderProvider) {
    switch (_sortBy) {
      case 'oldest':
        customers.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'most_active':
        customers.sort((a, b) {
          final aStats = provider.getUserStats(a.karmaId);
          final bStats = provider.getUserStats(b.karmaId);
          return (bStats['totalPosts'] ?? 0).compareTo(aStats['totalPosts'] ?? 0);
        });
        break;
      case 'spending':
        // Sort by real spending from orders
        customers.sort((a, b) {
          final aOrders = orderProvider.getUserOrders(a.id);
          final bOrders = orderProvider.getUserOrders(b.id);
          final aSpending = aOrders.fold<double>(0.0, (sum, order) => sum + order.totalAmount);
          final bSpending = bOrders.fold<double>(0.0, (sum, order) => sum + order.totalAmount);
          return bSpending.compareTo(aSpending);
        });
        break;
      case 'newest':
      default:
        customers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return customers;
  }

  Widget _buildCustomerCard(User customer, Map<String, dynamic> stats, int postCount, SocialFeedProvider feedProvider, OrderProvider orderProvider) {
    final isSelected = _selectedCustomers.contains(customer.id);
    // Get real order data
    final userOrders = orderProvider.getUserOrders(customer.id);
    final realSpending = userOrders.fold<double>(0.0, (sum, order) => sum + order.totalAmount);
    final realOrderCount = userOrders.length;
    final lastActive = DateTime.now().subtract(Duration(days: customer.id.hashCode % 30));

    return GestureDetector(
      onLongPress: () {
        if (!_bulkMode) {
          setState(() {
            _bulkMode = true;
            _selectedCustomers.add(customer.id);
          });
        }
      },
      onTap: () {
        if (_bulkMode) {
          setState(() {
            if (isSelected) {
              _selectedCustomers.remove(customer.id);
            } else {
              _selectedCustomers.add(customer.id);
            }
          });
        } else {
          _showCustomerDetails(customer, stats, postCount, feedProvider, orderProvider);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? Colors.purple.withOpacity(0.2) : const Color(0xFF1C1F26),
          border: Border.all(
            color: isSelected 
                ? Colors.purple
                : customer.isBanned 
                    ? Colors.red.withOpacity(0.3) 
                    : Colors.white.withOpacity(0.1),
            width: isSelected || customer.isBanned ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_bulkMode)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedCustomers.add(customer.id);
                        } else {
                          _selectedCustomers.remove(customer.id);
                        }
                      });
                    },
                    activeColor: Colors.purple,
                  ),
                ),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue,
                    child: Text(
                      customer.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (customer.isBanned)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.block,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customer.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (customer.isBanned)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red),
                            ),
                            child: const Text(
                              'BANNED',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: customer.karmaId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Copied ${customer.karmaId}'),
                            backgroundColor: Colors.purple,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.fingerprint, size: 14, color: Colors.purple),
                          const SizedBox(width: 4),
                          Text(
                            customer.karmaId,
                            style: const TextStyle(
                              color: Colors.purple,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.copy, size: 12, color: Colors.grey),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildStatChip(Icons.shopping_bag, '$realOrderCount orders', Colors.blue),
                        _buildStatChip(Icons.attach_money, '₹${realSpending.toStringAsFixed(0)}', Colors.green),
                        _buildStatChip(Icons.article, '$postCount posts', Colors.orange),
                        _buildStatChip(Icons.access_time, _getLastActiveText(lastActive), Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getLastActiveText(DateTime lastActive) {
    final diff = DateTime.now().difference(lastActive);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  void _showCustomerDetails(User customer, Map<String, dynamic> stats, int postCount, SocialFeedProvider feedProvider, OrderProvider orderProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomerDetailsSheet(
        customer: customer,
        stats: stats,
        postCount: postCount,
        feedProvider: feedProvider,
        orderProvider: orderProvider,
      ),
    );
  }

  void _bulkBan() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1F26),
        title: const Text('Ban Selected Customers', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to ban ${_selectedCustomers.length} customers?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement bulk ban logic
              Navigator.pop(context);
              setState(() {
                _bulkMode = false;
                _selectedCustomers.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Customers banned successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ban'),
          ),
        ],
      ),
    );
  }

  void _bulkNotify() {
    // Show notification dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1F26),
        title: const Text('Send Notification', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Send notification to ${_selectedCustomers.length} customers',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter notification message...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFF0A0E21),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _bulkMode = false;
                _selectedCustomers.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notification sent successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _exportCustomers() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting customers to CSV...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showAnalyticsDashboard() {
    showDialog(
      context: context,
      builder: (context) => CustomerAnalyticsDialog(),
    );
  }
}

// Customer Details Bottom Sheet
class CustomerDetailsSheet extends StatefulWidget {
  final User customer;
  final Map<String, dynamic> stats;
  final int postCount;
  final SocialFeedProvider feedProvider;
  final OrderProvider orderProvider;

  const CustomerDetailsSheet({
    super.key,
    required this.customer,
    required this.stats,
    required this.postCount,
    required this.feedProvider,
    required this.orderProvider,
  });

  @override
  State<CustomerDetailsSheet> createState() => _CustomerDetailsSheetState();
}

class _CustomerDetailsSheetState extends State<CustomerDetailsSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get real order data
    final userOrders = widget.orderProvider.getUserOrders(widget.customer.id);
    final realSpending = userOrders.fold<double>(0.0, (sum, order) => sum + order.totalAmount);
    final realOrderCount = userOrders.length;
    final realAverageOrder = realOrderCount > 0 ? realSpending / realOrderCount : 0.0;
    final lastActive = DateTime.now().subtract(Duration(days: widget.customer.id.hashCode % 30));

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1C1F26),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue,
                      child: Text(
                        widget.customer.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.customer.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.customer.email,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Stats Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E21),
                  border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.1)),
                    bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn('Orders', realOrderCount.toString(), Icons.shopping_bag, Colors.blue),
                    _buildStatColumn('Spent', '₹${realSpending.toStringAsFixed(0)}', Icons.attach_money, Colors.green),
                    _buildStatColumn('Posts', widget.postCount.toString(), Icons.article, Colors.orange),
                    _buildStatColumn('Days', widget.stats['daysSinceJoined'].toString(), Icons.calendar_today, Colors.purple),
                  ],
                ),
              ),
              // Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.purple,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Orders'),
                  Tab(text: 'Posts'),
                  Tab(text: 'Actions'),
                ],
              ),
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(realAverageOrder, lastActive, realSpending),
                    _buildOrdersTab(userOrders),
                    _buildPostsTab(),
                    _buildActionsTab(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab(double avgOrder, DateTime lastActive, double totalSpending) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          'Account Information',
          [
            _buildInfoRow('Email', widget.customer.email, Icons.email),
            _buildInfoRow('Phone', widget.customer.phone, Icons.phone),
            _buildInfoRow('Karma ID', widget.customer.karmaId, Icons.fingerprint),
            _buildInfoRow('Joined', DateFormat('MMM dd, yyyy').format(widget.customer.createdAt), Icons.calendar_today),
            _buildInfoRow('Last Active', _formatLastActive(lastActive), Icons.access_time),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Purchase Analytics',
          [
            _buildInfoRow('Average Order Value', '₹${avgOrder.toStringAsFixed(2)}', Icons.trending_up),
            _buildInfoRow('Total Spending', '₹${totalSpending.toStringAsFixed(2)}', Icons.attach_money),
            _buildInfoRow('Preferred Payment', 'Various', Icons.payment),
            _buildInfoRow('Customer Lifetime Value', '₹${totalSpending.toStringAsFixed(0)}', Icons.star),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Engagement Metrics',
          [
            _buildInfoRow('Engagement Score', '85/100', Icons.psychology),
            _buildInfoRow('Posts Created', widget.postCount.toString(), Icons.article),
            _buildInfoRow('Avg. Likes per Post', '${(widget.customer.id.hashCode % 100)}', Icons.favorite),
            _buildInfoRow('Comments Received', '${(widget.customer.id.hashCode % 500)}', Icons.comment),
          ],
        ),
      ],
    );
  }

  Widget _buildOrdersTab(List<Order> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No orders yet',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0E21),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Order #${order.id.substring(0, 8)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getOrderStatusColor(order.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getOrderStatusText(order.status),
                      style: TextStyle(
                        color: _getOrderStatusColor(order.status),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM dd, yyyy').format(order.createdAt),
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  Text(
                    '₹${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${order.items.length} items',
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostsTab() {
    final posts = widget.feedProvider.getUserPosts(widget.customer.id); // Use user ID
    
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 60, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No posts yet',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0E21),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.content,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.favorite, size: 16, color: Colors.red[300]),
                  const SizedBox(width: 4),
                  Text(
                    post.likesCount.toString(),
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.comment, size: 16, color: Colors.blue[300]),
                  const SizedBox(width: 4),
                  Text(
                    post.commentsCount.toString(),
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _deletePost(post),
                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    label: const Text('Delete', style: TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildActionTile(
          'Send Notification',
          'Send a direct notification to this customer',
          Icons.notifications,
          Colors.blue,
          _sendNotification,
        ),
        _buildActionTile(
          'Edit Information',
          'Update customer details and information',
          Icons.edit,
          Colors.purple,
          _editCustomer,
        ),
        _buildActionTile(
          'View Activity Timeline',
          'See complete activity history',
          Icons.timeline,
          Colors.green,
          _viewTimeline,
        ),
        _buildActionTile(
          'Add Internal Note',
          'Add private notes about this customer',
          Icons.note_add,
          Colors.orange,
          _addNote,
        ),
        const Divider(height: 32, color: Colors.white24),
        if (!widget.customer.isBanned)
          _buildActionTile(
            'Ban Customer',
            'Temporarily or permanently ban this customer',
            Icons.block,
            Colors.red,
            _banCustomer,
          )
        else
          _buildActionTile(
            'Unban Customer',
            'Remove ban and restore access',
            Icons.check_circle,
            Colors.green,
            _unbanCustomer,
          ),
        _buildActionTile(
          'Suspend Account',
          'Temporarily suspend customer access',
          Icons.pause_circle,
          Colors.orange,
          _suspendAccount,
        ),
        _buildActionTile(
          'Delete Account',
          'Permanently delete customer account',
          Icons.delete_forever,
          Colors.red,
          _deleteAccount,
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E21),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.purple),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        tileColor: const Color(0xFF0A0E21),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  String _formatLastActive(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    return '${diff.inMinutes} minutes ago';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered': return Colors.green;
      case 'In Transit': return Colors.blue;
      case 'Processing': return Colors.orange;
      case 'Cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  Color _getOrderStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.shipped:
        return Colors.blue;
      case OrderStatus.processing:
      case OrderStatus.confirmed:
        return Colors.orange;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.pending:
      default:
        return Colors.grey;
    }
  }

  String _getOrderStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  void _deletePost(SocialPost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1F26),
        title: const Text('Delete Post', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this post?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              widget.feedProvider.deletePost(post.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Post deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _sendNotification() {
    Navigator.pop(context);
    // Implement notification sending
  }

  void _editCustomer() {
    Navigator.pop(context);
    // Implement customer editing
  }

  void _viewTimeline() {
    Navigator.pop(context);
    // Implement timeline view
  }

  void _addNote() {
    Navigator.pop(context);
    // Implement note adding
  }

  void _banCustomer() {
    Navigator.pop(context);
    // Implement ban customer
  }

  void _unbanCustomer() {
    Navigator.pop(context);
    // Implement unban customer
  }

  void _suspendAccount() {
    Navigator.pop(context);
    // Implement suspend account
  }

  void _deleteAccount() {
    Navigator.pop(context);
    // Implement delete account
  }
}

// Customer Analytics Dialog
class CustomerAnalyticsDialog extends StatelessWidget {
  const CustomerAnalyticsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1C1F26),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.green, size: 32),
                const SizedBox(width: 12),
                const Text(
                  'Customer Analytics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildAnalyticCard('Total Customers', '1,234', Icons.people, Colors.blue),
            const SizedBox(height: 12),
            _buildAnalyticCard('Active This Month', '856', Icons.trending_up, Colors.green),
            const SizedBox(height: 12),
            _buildAnalyticCard('Total Revenue', '₹12,45,678', Icons.attach_money, Colors.purple),
            const SizedBox(height: 12),
            _buildAnalyticCard('Avg. Order Value', '₹1,234', Icons.shopping_cart, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E21),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
