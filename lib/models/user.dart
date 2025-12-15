class User {
  final String id;
  final String name;
  final String? profilePicture;
  final String email;
  final String phone;
  final String address;
  final UserRole role;
  final DateTime createdAt;
  final bool isActive;
  final String karmaId; // Unique identifier like karma19812938
  final bool isBanned;
  final String? banReason;
  final DateTime? bannedAt;
  final bool isSuperAdmin; // Can promote other users to admin

  User({
    required this.id,
    required this.name,
    this.profilePicture,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
    required this.createdAt,
    this.isActive = true,
    required this.karmaId,
    this.isBanned = false,
    this.banReason,
    this.bannedAt,
    this.isSuperAdmin = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      profilePicture: json['profilePicture'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.customer,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
      karmaId: json['karmaId'] ?? 'karma${json['id']}',
      isBanned: json['isBanned'] ?? false,
      banReason: json['banReason'],
      bannedAt: json['bannedAt'] != null ? DateTime.parse(json['bannedAt']) : null,
      isSuperAdmin: json['isSuperAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profilePicture': profilePicture,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'karmaId': karmaId,
      'isBanned': isBanned,
      'banReason': banReason,
      'bannedAt': bannedAt?.toIso8601String(),
      'isSuperAdmin': isSuperAdmin,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? profilePicture,
    String? email,
    String? phone,
    String? address,
    UserRole? role,
    DateTime? createdAt,
    bool? isActive,
    String? karmaId,
    bool? isBanned,
    String? banReason,
    DateTime? bannedAt,
    bool? isSuperAdmin,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      karmaId: karmaId ?? this.karmaId,
      isBanned: isBanned ?? this.isBanned,
      banReason: banReason ?? this.banReason,
      bannedAt: bannedAt ?? this.bannedAt,
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
    );
  }
}

enum UserRole {
  admin,
  customer,
}