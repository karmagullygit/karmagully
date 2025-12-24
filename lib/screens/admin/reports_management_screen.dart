import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/report_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/post_report.dart';
import 'admin_user_management_screen.dart';

class ReportsManagementScreen extends StatefulWidget {
  const ReportsManagementScreen({super.key});

  @override
  State<ReportsManagementScreen> createState() => _ReportsManagementScreenState();
}

class _ReportsManagementScreenState extends State<ReportsManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _filterReason;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load reports when screen opens to ensure we have latest data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().loadReports();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        title: const Text('Reports Management', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1C1F26),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6B73FF),
          labelColor: const Color(0xFF6B73FF),
          unselectedLabelColor: Colors.white60,
          tabs: [
            Consumer<ReportProvider>(
              builder: (context, reportProvider, child) {
                final count = reportProvider.unresolvedCount;
                return Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Pending'),
                      if (count > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            count.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const Tab(text: 'Resolved'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            color: const Color(0xFF1C1F26),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              setState(() {
                _filterReason = value == 'all' ? null : value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Reports', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuDivider(),
              ...ReportReason.values.map((reason) => PopupMenuItem(
                value: reason.value,
                child: Text(reason.displayName, style: const TextStyle(color: Colors.white)),
              )),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<ReportProvider>().loadReports();
            },
          ),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (context, reportProvider, child) {
          print('🔍 Reports Management Screen Update:');
          print('  - Total reports: ${reportProvider.reports.length}');
          print('  - Unresolved: ${reportProvider.unresolvedReports.length}');
          print('  - Resolved: ${reportProvider.resolvedReports.length}');
          print('  - Filter reason: $_filterReason');
          
          if (reportProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6B73FF)),
            );
          }

          final unresolvedFiltered = reportProvider.unresolvedReports
              .where((r) => _filterReason == null || r.reason == _filterReason)
              .toList();
          final resolvedFiltered = reportProvider.resolvedReports
              .where((r) => _filterReason == null || r.reason == _filterReason)
              .toList();
          
          print('  - After filter - Unresolved: ${unresolvedFiltered.length}, Resolved: ${resolvedFiltered.length}');

          return TabBarView(
            controller: _tabController,
            children: [
              _buildReportsList(unresolvedFiltered, false),
              _buildReportsList(resolvedFiltered, true),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReportsList(List<PostReport> reports, bool isResolved) {
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isResolved ? Icons.check_circle_outline : Icons.flag_outlined,
              size: 80,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            Text(
              isResolved ? 'No resolved reports' : 'No pending reports',
              style: const TextStyle(color: Colors.white60, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ReportProvider>().loadReports(),
      color: const Color(0xFF6B73FF),
      backgroundColor: const Color(0xFF1C1F26),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          return _buildReportCard(reports[index]);
        },
      ),
    );
  }

  Widget _buildReportCard(PostReport report) {

    return Card(
      color: const Color(0xFF1C1F26),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: report.isResolved 
              ? Colors.green.withOpacity(0.3) 
              : Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: report.isResolved 
                  ? Colors.green.withOpacity(0.1) 
                  : Colors.orange.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getReasonColor(report.reason).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getReasonIcon(report.reason),
                    color: _getReasonColor(report.reason),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ReportReason.values.firstWhere(
                          (r) => r.value == report.reason,
                          orElse: () => ReportReason.other,
                        ).displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        report.timeAgo,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (report.isResolved)
                  const Icon(Icons.check_circle, color: Colors.green, size: 24),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reporter and Post Owner Info
                Row(
                  children: [
                    Expanded(
                      child: _buildUserInfo(
                        'Reported By',
                        report.reportedByUsername,
                        report.reportedByKarmaId,
                        Icons.person_outline,
                        Colors.blue,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white12,
                    ),
                    Expanded(
                      child: _buildUserInfo(
                        'Post Owner',
                        report.postOwnerUsername,
                        report.postOwnerKarmaId,
                        Icons.flag,
                        Colors.red,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(color: Colors.white12),
                const SizedBox(height: 16),

                // Post Content Preview
                Text(
                  'Reported Content',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    report.postContent.isEmpty 
                        ? '[No text content]' 
                        : report.postContent,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                if (report.postMediaUrls.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: report.postMediaUrls.take(3).map((url) => 
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white12,
                        ),
                        child: const Icon(Icons.image, color: Colors.white24),
                      )
                    ).toList(),
                  ),
                ],

                // Description if provided
                if (report.description != null && report.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Additional Details',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.description!,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],

                // Admin Notes if resolved
                if (report.isResolved && report.adminNotes != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.admin_panel_settings, color: Colors.green, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Admin Notes',
                              style: TextStyle(
                                color: Colors.green.shade300,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          report.adminNotes!,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        if (report.resolvedAt != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Resolved ${DateFormat('MMM dd, yyyy HH:mm').format(report.resolvedAt!)}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToUserManagement(report.postOwnerKarmaId),
                        icon: const Icon(Icons.search, size: 18),
                        label: const Text('Find User'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6B73FF),
                          side: const BorderSide(color: Color(0xFF6B73FF)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (!report.isResolved)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showResolveDialog(report),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Resolve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmDelete(report),
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Delete'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(String label, String username, String karmaId, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _navigateToUserManagement(karmaId),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            username,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            karmaId,
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

  Color _getReasonColor(String reasonValue) {
    final reason = ReportReason.values.firstWhere(
      (r) => r.value == reasonValue,
      orElse: () => ReportReason.other,
    );
    
    switch (reason) {
      case ReportReason.spam:
        return Colors.orange;
      case ReportReason.harassment:
        return Colors.red;
      case ReportReason.hateSpeech:
        return Colors.deepOrange;
      case ReportReason.violence:
        return Colors.red.shade900;
      case ReportReason.nudity:
        return Colors.pink;
      case ReportReason.misinformation:
        return Colors.amber;
      case ReportReason.scam:
        return Colors.deepPurple;
      case ReportReason.other:
        return Colors.grey;
    }
  }

  IconData _getReasonIcon(String reasonValue) {
    final reason = ReportReason.values.firstWhere(
      (r) => r.value == reasonValue,
      orElse: () => ReportReason.other,
    );
    
    switch (reason) {
      case ReportReason.spam:
        return Icons.mail_outline;
      case ReportReason.harassment:
        return Icons.person_off_outlined;
      case ReportReason.hateSpeech:
        return Icons.report_outlined;
      case ReportReason.violence:
        return Icons.warning_outlined;
      case ReportReason.nudity:
        return Icons.visibility_off_outlined;
      case ReportReason.misinformation:
        return Icons.fact_check_outlined;
      case ReportReason.scam:
        return Icons.security_outlined;
      case ReportReason.other:
        return Icons.help_outline;
    }
  }

  void _navigateToUserManagement(String karmaId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminUserManagementScreen(searchKarmaId: karmaId),
      ),
    );
  }

  void _showResolveDialog(PostReport report) {
    final notesController = TextEditingController();
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in as admin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1F26),
        title: const Text('Resolve Report', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add notes about the resolution (optional):',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 4,
              maxLength: 300,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g., User banned for 7 days, post removed...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF6B73FF)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              notesController.dispose();
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.7))),
          ),
          ElevatedButton(
            onPressed: () async {
              final notes = notesController.text.trim().isEmpty 
                  ? null 
                  : notesController.text.trim();
              
              final success = await context.read<ReportProvider>().resolveReport(
                report.id,
                currentUser.id,
                notes,
              );

              notesController.dispose();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success 
                        ? 'Report marked as resolved' 
                        : 'Failed to resolve report'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Mark Resolved'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(PostReport report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1F26),
        title: const Text('Delete Report', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this report? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.7))),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await context.read<ReportProvider>().deleteReport(report.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success 
                        ? 'Report deleted' 
                        : 'Failed to delete report'),
                    backgroundColor: success ? const Color(0xFF6B73FF) : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
