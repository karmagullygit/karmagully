import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/social_feed_provider.dart';
import '../../models/social_post.dart';
import '../../models/post_comment.dart';

class PostDetailScreen extends StatefulWidget {
  final SocialPost post;

  const PostDetailScreen({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _commentFocusNode = FocusNode();
  String? _replyingTo;
  bool _isCommenting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SocialFeedProvider>().incrementViewCount(widget.post.id);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1877F2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  widget.post.userAvatar,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.post.userDisplayName ?? widget.post.username}\'s post',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _sharePost,
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
          ),
          PopupMenuButton<String>(
            onSelected: _handlePostAction,
            itemBuilder: (context) => [
              if (widget.post.isOwnedBy(
                  context.read<SocialFeedProvider>().currentUserId)) ...[
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit post'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete post', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ] else ...[
                const PopupMenuItem(
                  value: 'save',
                  child: Row(
                    children: [
                      Icon(Icons.bookmark_border),
                      SizedBox(width: 8),
                      Text('Save post'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'report',
                  child: Row(
                    children: [
                      Icon(Icons.report_outlined),
                      SizedBox(width: 8),
                      Text('Report post'),
                    ],
                  ),
                ),
              ],
              const PopupMenuItem(
                value: 'copy_link',
                child: Row(
                  children: [
                    Icon(Icons.link),
                    SizedBox(width: 8),
                    Text('Copy link'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<SocialFeedProvider>(
        builder: (context, feedProvider, child) {
          final comments = feedProvider.getPostComments(widget.post.id);
          
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post content
                      _buildPostContent(),
                      
                      // Engagement summary
                      _buildEngagementSummary(),
                      
                      // Action buttons
                      _buildActionButtons(feedProvider),
                      
                      const Divider(height: 1),
                      
                      // Comments section
                      _buildCommentsSection(comments, feedProvider),
                    ],
                  ),
                ),
              ),
              
              // Comment input
              _buildCommentInput(feedProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPostContent() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF1877F2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    widget.post.userAvatar,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.post.userDisplayName ?? widget.post.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (widget.post.isPromoted) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1877F2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Sponsored',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          widget.post.formattedDate,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _getPrivacyIcon(widget.post.privacy),
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        if (widget.post.isEdited) ...[
                          const SizedBox(width: 4),
                          Text(
                            '• edited',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Post content
          if (widget.post.content.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              widget.post.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],

          // Post media
          if (widget.post.hasMedia) ...[
            const SizedBox(height: 16),
            _buildPostMedia(),
          ],

          // Post tags
          if (widget.post.hasTags) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: widget.post.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1877F2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '#$tag',
                  style: const TextStyle(
                    color: Color(0xFF1877F2),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
          ],

          // Post location
          if (widget.post.hasLocation) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  widget.post.location!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPostMedia() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.post.type == PostType.video
                  ? Icons.play_circle_filled
                  : Icons.image,
              size: 80,
              color: Colors.grey[500],
            ),
            const SizedBox(height: 12),
            Text(
              widget.post.type == PostType.video ? 'Video Content' : 'Image Content',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${widget.post.mediaUrls.length} ${widget.post.mediaUrls.length == 1 ? 'item' : 'items'}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementSummary() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (widget.post.likesCount > 0) ...[
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF1877F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.thumb_up,
                size: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.post.likesCount}',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (widget.post.dislikesCount > 0) ...[
            const SizedBox(width: 16),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.thumb_down,
                size: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.post.dislikesCount}',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const Spacer(),
          Row(
            children: [
              if (widget.post.commentsCount > 0) ...[
                Text(
                  '${widget.post.commentsCount} comments',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 15,
                  ),
                ),
                if (widget.post.sharesCount > 0) ...[
                  const SizedBox(width: 8),
                  Text(
                    '•',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
              if (widget.post.sharesCount > 0)
                Text(
                  '${widget.post.sharesCount} shares',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 15,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(SocialFeedProvider provider) {
    final isLiked = widget.post.isLikedBy(provider.currentUserId);
    final isDisliked = widget.post.isDislikedBy(provider.currentUserId);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.thumb_up,
              label: 'Like',
              isActive: isLiked,
              onTap: () => provider.toggleLike(widget.post.id),
            ),
          ),
          Expanded(
            child: _buildActionButton(
              icon: Icons.thumb_down,
              label: 'Dislike',
              isActive: isDisliked,
              onTap: () => provider.toggleDislike(widget.post.id),
            ),
          ),
          Expanded(
            child: _buildActionButton(
              icon: Icons.comment_outlined,
              label: 'Comment',
              onTap: () {
                _commentFocusNode.requestFocus();
              },
            ),
          ),
          Expanded(
            child: _buildActionButton(
              icon: Icons.share_outlined,
              label: 'Share',
              onTap: _sharePost,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? const Color(0xFF1877F2) : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF1877F2) : Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection(List<CommentThread> comments, SocialFeedProvider provider) {
    if (comments.isEmpty) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.comment_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No comments yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Be the first to comment!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Comments (${widget.post.commentsCount})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...comments.map((commentThread) => _buildCommentThread(commentThread, provider)),
        ],
      ),
    );
  }

  Widget _buildCommentThread(CommentThread commentThread, SocialFeedProvider provider) {
    return Column(
      children: [
        _buildCommentItem(commentThread.comment, provider, isMainComment: true),
        ...commentThread.replies.map(
          (reply) => _buildCommentItem(reply, provider, isReply: true),
        ),
      ],
    );
  }

  Widget _buildCommentItem(PostComment comment, SocialFeedProvider provider, {bool isMainComment = false, bool isReply = false}) {
    final isLiked = comment.isLikedBy(provider.currentUserId);
    
    return Container(
      margin: EdgeInsets.only(
        left: isReply ? 48 : 16,
        right: 16,
        bottom: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isReply ? 32 : 40,
            height: isReply ? 32 : 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1877F2),
              borderRadius: BorderRadius.circular(isReply ? 16 : 20),
            ),
            child: Center(
              child: Text(
                comment.userAvatar,
                style: TextStyle(fontSize: isReply ? 16 : 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.userDisplayName ?? comment.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comment.content,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      comment.timeAgo,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => provider.toggleCommentLike(widget.post.id, comment.id),
                      child: Row(
                        children: [
                          Icon(
                            Icons.thumb_up,
                            size: 14,
                            color: isLiked ? const Color(0xFF1877F2) : Colors.grey[600],
                          ),
                          if (comment.likesCount > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '${comment.likesCount}',
                              style: TextStyle(
                                color: isLiked ? const Color(0xFF1877F2) : Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!isReply) ...[
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _replyToComment(comment),
                        child: Text(
                          'Reply',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    if (comment.isOwnedBy(provider.currentUserId)) ...[
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _showCommentOptions(comment),
                        child: Icon(
                          Icons.more_horiz,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(SocialFeedProvider provider) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyingTo != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.reply,
                    size: 16,
                    color: Colors.blue[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Replying to $_replyingTo',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _replyingTo = null),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF1877F2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text(
                    '👤',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocusNode,
                    decoration: InputDecoration(
                      hintText: _replyingTo != null ? 'Write a reply...' : 'Write a comment...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (value) => setState(() {}),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _commentController.text.trim().isEmpty || _isCommenting
                    ? null
                    : () => _postComment(provider),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _commentController.text.trim().isEmpty
                        ? Colors.grey[300]
                        : const Color(0xFF1877F2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: _isCommenting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(
                          Icons.send,
                          color: _commentController.text.trim().isEmpty
                              ? Colors.grey[600]
                              : Colors.white,
                          size: 18,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getPrivacyIcon(PostPrivacy privacy) {
    switch (privacy) {
      case PostPrivacy.public:
        return Icons.public;
      case PostPrivacy.friends:
        return Icons.people;
      case PostPrivacy.private:
        return Icons.lock;
    }
  }

  void _handlePostAction(String action) {
    switch (action) {
      case 'edit':
        _showSnackbar('Edit feature coming soon!');
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
      case 'save':
        _showSnackbar('Post saved!');
        break;
      case 'report':
        _showSnackbar('Post reported. Thank you for helping keep our community safe.');
        break;
      case 'copy_link':
        _showSnackbar('Link copied to clipboard!');
        break;
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SocialFeedProvider>().deletePost(widget.post.id);
              Navigator.pop(context);
              _showSnackbar('Post deleted successfully');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _sharePost() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Share Post',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(Icons.message, 'Message'),
                _buildShareOption(Icons.copy, 'Copy Link'),
                _buildShareOption(Icons.share, 'Share'),
                _buildShareOption(Icons.more_horiz, 'More'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _showSnackbar('$label functionality coming soon!');
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1877F2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1877F2),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _replyToComment(PostComment comment) {
    setState(() {
      _replyingTo = comment.userDisplayName ?? comment.username;
    });
    _commentFocusNode.requestFocus();
  }

  void _showCommentOptions(PostComment comment) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit comment'),
              onTap: () {
                Navigator.pop(context);
                _showSnackbar('Edit comment feature coming soon!');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete comment', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showSnackbar('Delete comment feature coming soon!');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _postComment(SocialFeedProvider provider) async {
    if (_commentController.text.trim().isEmpty || _isCommenting) return;

    setState(() => _isCommenting = true);

    try {
      String? parentCommentId;
      if (_replyingTo != null) {
        // Find the parent comment ID based on the username we're replying to
        final comments = provider.getPostComments(widget.post.id);
        for (final thread in comments) {
          if ((thread.comment.userDisplayName ?? thread.comment.username) == _replyingTo) {
            parentCommentId = thread.comment.id;
            break;
          }
        }
      }

      await provider.addComment(
        widget.post.id,
        _commentController.text.trim(),
        parentCommentId: parentCommentId,
      );

      _commentController.clear();
      setState(() => _replyingTo = null);
      _commentFocusNode.unfocus();

      // Scroll to bottom to show new comment
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      _showSnackbar('Failed to post comment: $e');
    } finally {
      setState(() => _isCommenting = false);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}