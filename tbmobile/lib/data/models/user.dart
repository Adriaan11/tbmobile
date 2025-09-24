class User {
  final int? userId;
  final String? username;
  final String firstName;
  final String lastName;
  final String email;
  final String? mobileNumber;
  final String userType; // 'practitioner', 'patient', 'both'
  final String? accountNumber;
  final DateTime? createdDate;
  final DateTime? lastSync;

  User({
    this.userId,
    this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.mobileNumber,
    required this.userType,
    this.accountNumber,
    this.createdDate,
    this.lastSync,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'mobile_number': mobileNumber,
      'user_type': userType,
      'account_number': accountNumber,
      'created_date': createdDate?.toIso8601String(),
      'last_sync': lastSync?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['user_id'],
      username: map['username'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      email: map['email'],
      mobileNumber: map['mobile_number'],
      userType: map['user_type'],
      accountNumber: map['account_number'],
      createdDate: map['created_date'] != null 
          ? DateTime.parse(map['created_date']) 
          : null,
      lastSync: map['last_sync'] != null 
          ? DateTime.parse(map['last_sync']) 
          : null,
    );
  }

  String get fullName => '$firstName $lastName';

  bool get isPractitioner => userType == 'practitioner' || userType == 'both';
  bool get isPatient => userType == 'patient' || userType == 'both';

  User copyWith({
    int? userId,
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    String? mobileNumber,
    String? userType,
    String? accountNumber,
    DateTime? createdDate,
    DateTime? lastSync,
  }) {
    return User(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      userType: userType ?? this.userType,
      accountNumber: accountNumber ?? this.accountNumber,
      createdDate: createdDate ?? this.createdDate,
      lastSync: lastSync ?? this.lastSync,
    );
  }
}