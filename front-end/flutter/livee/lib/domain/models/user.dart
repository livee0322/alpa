class User {
  final String? id;
  final String? name;
  final String? email;
  final String? role;
  final String? token;

  User({
    this.id,
    this.name,
    this.email,
    this.role,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String? ?? json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      token: json['token'] as String?,
    );
  }
}