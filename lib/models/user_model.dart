import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id; // Firebase UID
  final String fullName;
  final String username;
  final String companyName;
  final String email;
  final String phoneNumber;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.companyName,
    required this.email,
    required this.phoneNumber,
    DateTime? createdAt,
    this.lastLogin,
  }) : createdAt = createdAt ?? DateTime.now();

  // Helper to copy User with modified fields
  UserModel copyWith({
    String? fullName,
    String? username,
    String? companyName,
    String? email,
    String? phoneNumber,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  // Convert User object to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'username': username,
      'companyName': companyName,
      'email': email,
      'phoneNumber': phoneNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
    };
  }

  // Create User object from Map (retrieved from Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return UserModel(
      id: map['id'],
      fullName: map['fullName'] ?? '',
      username: map['username'] ?? '',
      companyName: map['companyName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      createdAt: parseDate(map['createdAt']),
      lastLogin: map['lastLogin'] != null ? parseDate(map['lastLogin']) : null,
    );
  }
}
