class User {
  final String id;
  final String name;
  final String avatar;
  final int age;
  final String birthdate;
  final String city;

  User({
    required this.id,
    required this.name,
    required this.avatar,
    required this.age,
    required this.birthdate,
    required this.city,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
      age: json['age'],
      birthdate: json['birthdate'],
      city: json['city'],
    );
  }
}