import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String username;
  final String email;
  final String phoneNumber;
  final bool isOnline;
  final Timestamp createdAt;
  final Timestamp lastSeen;
  final String? fcmToken;
  final List<String> blockedUsers;


  UserModel({
    required this.uid,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.isOnline = false,
    Timestamp? createdAt,
    Timestamp? lastSeen,
    this.fcmToken,
    this.blockedUsers = const [],

  }) : lastSeen =lastSeen ?? Timestamp.now(),
       createdAt = createdAt ?? Timestamp.now();

  UserModel copyWith({
    String? uid,
    String? username,
    String? fullName,               // we use copyWith to create a new instance of UserModel with updated values
    String? email,                  // because at above there is final which can't allow to change the value
    String? phoneNumber,
    bool? isOnline,
    Timestamp? lastSeen,
    Timestamp? createdAt,
    String? fcmToken,
    List<String>? blockedUsers,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
      blockedUsers: blockedUsers ?? this.blockedUsers,
    );
  }



  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'isOnline': isOnline,
      'createdAt': createdAt,
      'lastSeen': lastSeen,
      'fcmToken': fcmToken,
      'blockedUsers': blockedUsers,
    };
  }


  factory UserModel.fromFirestore(DocumentSnapshot doc){
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      fullName: data["fullName"],
      username: data["username"],
      email: data["email"],
      phoneNumber: data["phoneNumber"],
      fcmToken: data["fcmToken"],
      // isOnline: data["isOnline"] ?? false,
      lastSeen: data["lastSeen"],
      createdAt: data["createdAt"],
      blockedUsers: List<String>.from(data["blockedUsers"] ?? []),

    );
  }

}



