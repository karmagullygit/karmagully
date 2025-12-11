import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/post_report.dart';

class ReportProvider with ChangeNotifier {
  List<PostReport> _reports = [];
  bool _isLoading = false;

  List<PostReport> get reports => _reports;
  List<PostReport> get unresolvedReports => 
      _reports.where((r) => !r.isResolved).toList();
  List<PostReport> get resolvedReports => 
      _reports.where((r) => r.isResolved).toList();
  bool get isLoading => _isLoading;

  int get unresolvedCount => unresolvedReports.length;

  ReportProvider() {
    loadReports();
  }

  Future<void> loadReports() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final reportsJson = prefs.getString('post_reports');
      
      print('📥 Loading reports from storage...');
      print('  - Raw JSON length: ${reportsJson?.length ?? 0}');
      
      if (reportsJson != null && reportsJson.isNotEmpty) {
        final List<dynamic> reportsList = jsonDecode(reportsJson);
        print('  - Decoded ${reportsList.length} reports');
        
        _reports = reportsList
            .map((json) {
              try {
                return PostReport.fromJson(Map<String, dynamic>.from(json));
              } catch (e) {
                print('❌ Error parsing report: $e');
                return null;
              }
            })
            .whereType<PostReport>()
            .toList();

        // Sort by date, newest first
        _reports.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
        
        print('✅ Successfully loaded ${_reports.length} reports');
        print('  - Unresolved: ${unresolvedReports.length}');
        print('  - Resolved: ${resolvedReports.length}');
      } else {
        _reports = [];
        print('  - No reports found in storage');
      }
    } catch (e) {
      print('❌ Error loading reports: $e');
      _reports = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> reportPost({
    required String postId,
    required String reportedBy,
    required String reportedByUsername,
    required String reportedByKarmaId,
    required String postOwnerId,
    required String postOwnerUsername,
    required String postOwnerKarmaId,
    required String reason,
    String? description,
    required String postContent,
    List<String> postMediaUrls = const [],
  }) async {
    try {
      debugPrint('');
      debugPrint('========================================');
      debugPrint('📝 CREATING NEW REPORT');
      debugPrint('========================================');
      debugPrint('Post ID: $postId');
      debugPrint('Reported By: $reportedByUsername (ID: $reportedBy, Karma: $reportedByKarmaId)');
      debugPrint('Post Owner: $postOwnerUsername (ID: $postOwnerId, Karma: $postOwnerKarmaId)');
      debugPrint('Reason: $reason');
      debugPrint('Description: ${description ?? "None"}');
      debugPrint('Content: ${postContent.substring(0, postContent.length > 50 ? 50 : postContent.length)}...');
      debugPrint('Media URLs: ${postMediaUrls.length} files');
      debugPrint('========================================');
      
      final reportId = 'report_${DateTime.now().millisecondsSinceEpoch}';
      final report = PostReport(
        id: reportId,
        postId: postId,
        reportedBy: reportedBy,
        reportedByUsername: reportedByUsername,
        reportedByKarmaId: reportedByKarmaId,
        postOwnerId: postOwnerId,
        postOwnerUsername: postOwnerUsername,
        postOwnerKarmaId: postOwnerKarmaId,
        reason: reason,
        description: description,
        reportedAt: DateTime.now(),
        postContent: postContent,
        postMediaUrls: postMediaUrls,
      );

      debugPrint('📊 Current reports count: ${_reports.length}');
      _reports.insert(0, report);
      debugPrint('📊 After insert: ${_reports.length}');
      debugPrint('📊 Unresolved: ${unresolvedReports.length}');
      debugPrint('📊 Resolved: ${resolvedReports.length}');
      
      debugPrint('💾 Saving to SharedPreferences...');
      final saved = await _saveReports();
      if (!saved) {
        debugPrint('❌ Failed to save reports!');
        _reports.removeAt(0); // Rollback
        return false;
      }
      
      debugPrint('🔔 Notifying listeners...');
      notifyListeners();
      
      debugPrint('✅ REPORT CREATED SUCCESSFULLY: $reportId');
      debugPrint('========================================');
      debugPrint('');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR CREATING REPORT: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<bool> resolveReport(String reportId, String adminId, String? notes) async {
    try {
      final index = _reports.indexWhere((r) => r.id == reportId);
      if (index == -1) return false;

      _reports[index] = _reports[index].copyWith(
        isResolved: true,
        resolvedBy: adminId,
        resolvedAt: DateTime.now(),
        adminNotes: notes,
      );

      await _saveReports();
      notifyListeners();
      return true;
    } catch (e) {
      print('Error resolving report: $e');
      return false;
    }
  }

  Future<bool> deleteReport(String reportId) async {
    try {
      _reports.removeWhere((r) => r.id == reportId);
      await _saveReports();
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting report: $e');
      return false;
    }
  }

  Future<bool> _saveReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reportsList = _reports.map((report) => report.toJson()).toList();
      final reportsJson = jsonEncode(reportsList);
      
      debugPrint('💾 Saving ${_reports.length} reports...');
      debugPrint('   JSON length: ${reportsJson.length} characters');
      
      final success = await prefs.setString('post_reports', reportsJson);
      
      if (success) {
        debugPrint('✅ Reports saved successfully');
        
        // Verify save
        final verification = prefs.getString('post_reports');
        if (verification != null) {
          debugPrint('✅ Verification successful - data persisted');
        } else {
          debugPrint('⚠️ Warning: Verification failed - data may not be persisted');
        }
      } else {
        debugPrint('❌ Failed to save reports to SharedPreferences');
      }
      
      return success;
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving reports: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  // Get reports for a specific post
  List<PostReport> getReportsForPost(String postId) {
    return _reports.where((r) => r.postId == postId).toList();
  }

  // Get reports by a specific user
  List<PostReport> getReportsByUser(String userId) {
    return _reports.where((r) => r.postOwnerId == userId).toList();
  }

  // Check if a post has been reported by a user
  bool hasUserReportedPost(String postId, String userId) {
    return _reports.any(
      (r) => r.postId == postId && r.reportedBy == userId
    );
  }
}
