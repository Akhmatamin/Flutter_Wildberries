class UserProfile {
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final int? age;
  final String? phone;
  final String status;

  UserProfile({
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.phone,
    required this.status,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    username: json['username'] ?? '',
    email: json['email'] ?? '',
    firstName: json['first_name'] ?? '',
    lastName: json['last_name'] ?? '',
    age: json['age'],
    phone: json['phone_number'],
    status: json['status'] ?? 'normal',
  );
}
