enum UserRole { student, teacher }

class User {
  final int? id;
  final String username;
  final String password;
  final String fullName;
  final String? email;
  final int? age;
  final UserRole role;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.fullName,
    this.email,
    this.age,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'fullName': fullName,
      'email': email,
      'age': age,
      'role': role == UserRole.student ? 'student' : 'teacher',
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      fullName: map['fullName'],
      email: map['email'],
      age: map['age'],
      role: map['role'] == 'student' ? UserRole.student : UserRole.teacher,
    );
  }

  // Phương thức copyWith để tạo bản sao có thay đổi
  User copyWith({
    int? id,
    String? username,
    String? password,
    String? fullName,
    String? email,
    int? age,
    UserRole? role,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      age: age ?? this.age,
      role: role ?? this.role,
    );
  }

  // Kiểm tra xem email có hợp lệ không
  bool get isValidEmail {
    if (email == null || email!.isEmpty) return true; // Email có thể để trống
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email!);
  }

  // Kiểm tra xem tuổi có hợp lệ không
  bool get isValidAge {
    if (age == null) return true; // Tuổi có thể để trống
    return age! > 0 && age! < 120;
  }

  // Lấy thông tin hiển thị của email
  String get displayEmail {
    if (email == null || email!.isEmpty) {
      return 'Chưa cập nhật';
    }
    return email!;
  }

  // Lấy thông tin hiển thị của tuổi
  String get displayAge {
    if (age == null) {
      return 'Chưa cập nhật';
    }
    return '$age tuổi';
  }

  // Lấy chữ cái đầu để hiển thị avatar
  String get initialLetter {
    if (fullName.isEmpty) return '?';
    return fullName[0].toUpperCase();
  }

  // Lấy role dạng text
  String get roleText {
    return role == UserRole.teacher ? 'Giáo viên' : 'Học sinh';
  }
}