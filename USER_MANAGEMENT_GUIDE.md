# User Management System - Complete Guide

## 🎯 Overview
Comprehensive admin panel for managing users, posts, and community moderation using unique Karma IDs.

## ✨ Features Implemented

### 1. **Unique Karma ID System**
Every user gets a unique identifier in the format: `karma[number]`
- Example: `karma19812938`, `karma23847561`
- Displayed in user profile (tap to copy)
- Used for admin searches and management
- Cannot be changed or duplicated

### 2. **User Model Updates**
New fields added to User model:
```dart
final String karmaId;        // Unique identifier
final bool isBanned;         // Ban status
final String? banReason;     // Reason for ban
final DateTime? bannedAt;    // Ban timestamp
```

### 3. **Admin User Management Screen**
**Location:** Admin Dashboard → User Management

#### Features:
- **Three Tabs:**
  - All Users: Complete user list
  - Active: Non-banned users only
  - Banned: Banned users only

- **Search Functionality:**
  - Search by Karma ID
  - Search by name
  - Search by email
  - Real-time filtering

- **User Card Display:**
  - Profile avatar with role badge (Admin/Customer)
  - Name and email
  - Karma ID (tap to copy)
  - Post count
  - Days since joined
  - Ban status with reason (if banned)

#### Admin Actions:

1. **View Posts**
   - See all posts from specific user
   - Shows post type (text/image/video)
   - Displays likes and comments count
   - Quick delete button for each post

2. **Delete Posts**
   - Delete all posts from a user at once
   - Shows confirmation with Karma ID
   - Displays count of posts to be deleted
   - Permanent deletion

3. **Ban User**
   - Block user from community feed
   - Requires ban reason (mandatory)
   - Shows Karma ID in confirmation
   - User cannot create posts when banned

4. **Unban User**
   - Restore user access
   - Removes ban reason
   - User can post again

### 4. **User Profile Integration**
**Customer Profile Screen:**
- Karma ID displayed below email
- Fingerprint icon for visual identification
- Tap to copy functionality
- Snackbar confirmation on copy

### 5. **Ban Enforcement**
When a user is banned:
- ❌ Cannot create new posts
- ❌ Cannot access "What's on your mind?" feature
- ✅ Shows error message with ban reason
- ✅ Can still browse feed (view-only mode)

### 6. **User Management Provider**
**Features:**
- Stores all users with Karma IDs
- Tracks user posts (Karma ID → Post IDs mapping)
- Search functionality
- Ban/unban operations
- User statistics
- Persistent storage with SharedPreferences

**Key Methods:**
```dart
searchUsers(String query)              // Search by ID, name, email
getUserByKarmaId(String karmaId)       // Find user by Karma ID
banUser(String karmaId, String reason) // Ban with reason
unbanUser(String karmaId)              // Remove ban
getUserStats(String karmaId)           // Get user statistics
```

## 📝 Sample Users

The system includes 7 pre-loaded sample users:

| Name | Karma ID | Role | Email |
|------|----------|------|-------|
| Admin User | karma10000001 | Admin | admin@karma.com |
| Customer User | karma19812938 | Customer | user@karma.com |
| John Martinez | karma23847561 | Customer | john@example.com |
| Emma Wilson | karma45612398 | Customer | emma@example.com |
| David Chen | karma78934562 | Customer | david@example.com |
| Lisa Anderson | karma12398745 | Customer | lisa@example.com |
| Maria Garcia | karma56789321 | Customer | maria@example.com |

## 🔧 Usage Guide

### For Admins:

#### **Access User Management:**
1. Login as admin (admin@karma.com / admin123)
2. Go to Admin Dashboard
3. Click "User Management"

#### **Search for a User:**
1. Use the search bar at top
2. Type Karma ID or user name
3. Results filter in real-time

#### **Ban a User:**
1. Find the user in list
2. Click "Ban" button (red)
3. Enter ban reason (required)
4. Confirm ban
5. User immediately restricted

#### **Delete User Posts:**
1. Find the user
2. Click "View Posts" to see all posts
3. Click "Delete Posts" to remove all
4. Or delete individual posts from view dialog

#### **Unban a User:**
1. Go to "Banned" tab
2. Find the user
3. Click "Unban" button (green)
4. Confirm action

### For Users:

#### **Find Your Karma ID:**
1. Go to Profile screen
2. Look below your email
3. See fingerprint icon with ID
4. Tap to copy to clipboard

#### **If You're Banned:**
- Red notification appears when trying to post
- Shows ban reason
- Can still browse and view content
- Contact admin for appeal

## 🎨 UI/UX Features

### Color Coding:
- 🟦 Blue: View/Info actions
- 🟧 Orange: Delete warnings
- 🔴 Red: Ban/Critical actions
- 🟢 Green: Unban/Positive actions
- 🟣 Purple: Karma ID & Admin badges

### Visual Indicators:
- Admin badge (purple) on admin accounts
- Ban indicator (red block icon) on avatars
- Banned users have red border on cards
- Karma IDs shown with fingerprint icon

### Statistics Display:
- Post count with article icon
- Join date with calendar icon
- Status chips with colored borders
- Real-time updates on actions

## 🔒 Security Features

1. **Admin-Only Access:**
   - User management only for admin role
   - Regular users cannot access

2. **Confirmation Dialogs:**
   - All critical actions require confirmation
   - Display Karma ID for verification
   - Show impact (number of posts, etc.)

3. **Ban Reasons:**
   - Mandatory for accountability
   - Stored with timestamp
   - Displayed to user when attempting actions

4. **Persistent Storage:**
   - All data saved to SharedPreferences
   - Survives app restarts
   - Maintains ban status

## 📊 Data Flow

```
User Registration
    ↓
Generate Karma ID (karma + timestamp)
    ↓
Store in UserManagementProvider
    ↓
Display in Profile
    ↓
Admin can search by Karma ID
    ↓
Admin actions (ban/delete posts)
    ↓
Enforcement in Social Feed
```

## 🚀 Testing

### Test Scenario 1: Ban Flow
1. Login as admin
2. Go to User Management
3. Search for "karma19812938"
4. Ban user with reason "Spam posting"
5. Logout and login as user@karma.com
6. Try to create post → Should see ban message

### Test Scenario 2: Post Deletion
1. Login as admin
2. Find user with posts
3. Click "View Posts"
4. Verify posts shown
5. Click "Delete Posts"
6. Confirm deletion
7. Check social feed → Posts removed

### Test Scenario 3: Karma ID Copy
1. Login as any user
2. Go to Profile
3. Tap on Karma ID
4. See snackbar confirmation
5. Paste elsewhere to verify

## 📱 Navigation Paths

**Admin Dashboard:**
```
Admin Dashboard
  └─ User Management
       ├─ All Users Tab
       ├─ Active Tab
       ├─ Banned Tab
       └─ Search Bar
            └─ User Card
                 ├─ View Posts
                 ├─ Delete Posts
                 └─ Ban/Unban
```

**Customer Profile:**
```
Profile Screen
  └─ User Info Card
       ├─ Avatar
       ├─ Email
       ├─ Karma ID (tap to copy)
       ├─ Premium Badge
       └─ Verified Badge
```

## 🐛 Troubleshooting

**Issue: Karma ID not showing in profile**
- Check if User model has karmaId field
- Verify auth provider includes karmaId in user creation
- Ensure UI imports Clipboard from flutter/services.dart

**Issue: Ban not working**
- Verify UserManagementProvider is registered in main.dart
- Check if social_feed_screen imports UserManagementProvider
- Ensure auth currentUser has karmaId

**Issue: User management screen empty**
- Check if sample users are loaded
- Verify SharedPreferences permissions
- Call _loadUsers() in provider constructor

## 🔄 Future Enhancements

Potential additions:
- [ ] Temporary bans with expiry dates
- [ ] Ban appeal system
- [ ] User activity logs
- [ ] Bulk user actions
- [ ] Export user data
- [ ] Advanced filtering (by join date, post count, etc.)
- [ ] User roles beyond admin/customer
- [ ] Automated ban triggers (spam detection)

## 📚 Related Files

**Models:**
- `lib/models/user.dart` - User model with Karma ID

**Providers:**
- `lib/providers/user_management_provider.dart` - User management logic
- `lib/providers/auth_provider.dart` - Updated with Karma IDs

**Screens:**
- `lib/screens/admin/admin_user_management_screen.dart` - Main UI
- `lib/screens/customer/profile_screen.dart` - Karma ID display
- `lib/screens/social/social_feed_screen.dart` - Ban enforcement

**Configuration:**
- `lib/main.dart` - Provider registration and routing

## ✅ Checklist

Installation complete when:
- [x] User model has karmaId, isBanned, banReason, bannedAt
- [x] UserManagementProvider created and registered
- [x] Admin user management screen created
- [x] Route added to main.dart
- [x] Admin dashboard has "User Management" tile
- [x] Profile screen shows Karma ID
- [x] Social feed checks ban status
- [x] Sample users loaded with Karma IDs

---

**System Status:** ✅ Fully Operational
**Version:** 1.0.0
**Last Updated:** December 7, 2025
