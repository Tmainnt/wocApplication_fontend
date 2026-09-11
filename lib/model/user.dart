class User {
  String _uid;
  String _token;
  String _email;
  String _name;
  String _gender;
  String _dob;
  String _phone;
  String _role;
  String _profileImage;
  String _backgroundImage;
  String _status;
  DateTime _createTimestamp;
  DateTime _updateTimestamp;

  // new field
  double _weight;
  double _height;
  int _age;
  int _total_step;
  double _total_calories;
  double _total_distance;
  int _total_time;
  int _total_lesson_complete;

  User({
    required String uid,
    required String token,
    required String email,
    required String name,
    required String gender,
    required String dob,
    required String phone,
    required String role,
    required String profileImage,
    required String backgroundImage,
    required String status,
    required DateTime cts,
    required DateTime uts,
    required double weight,
    required double height,
    required int age,
    required int total_step,
    required double total_calories,
    required double total_distance,
    required int total_time,
    required int total_lesson_complete,
  }) : _uid = uid,
       _token = token,
       _email = email,
       _name = name,
       _gender = gender,
       _dob = dob,
       _phone = phone,
       _role = role,
       _profileImage = profileImage,
       _backgroundImage = backgroundImage,
       _status = status,
       _createTimestamp = cts,
       _updateTimestamp = uts,
       _weight = weight,
       _height = height,
       _age = age,
       _total_step = total_step,
       _total_calories = total_calories,
       _total_distance = total_distance,
       _total_time = total_time,
       _total_lesson_complete = total_lesson_complete;

  factory User.fromJson(Map<String, dynamic> json, String tokenStr) {
    return User(
      uid: json['user_id'],
      token: tokenStr,
      email: json["user_email"],
      name: json["user_name"],
      dob: json["date_of_birth"],
      phone: json["phone_number"] ?? "",
      gender: json["user_gender"],
      role: json["user_role"],
      profileImage: json["user_profile_image"] ?? "",
      backgroundImage: json["user_background_image"] ?? "",
      status: json["user_status"],
      cts: DateTime.parse(json["create_timestamp"]),
      uts: DateTime.parse(json["update_timestamp"]),
      weight: json["user_weight"],
      height: json["user_height"],
      age: json["user_age"],
      total_step: json["total_step"],
      total_calories: json["total_calories"],
      total_distance: json["total_distance"],
      total_time: json["total_time"],
      total_lesson_complete: json["total_lesson_complete"],
    );
  }

  String get uid => _uid;
  String get token => _token;
  String get email => _email;
  String get name => _name;
  String get gender => _gender;
  String get dob => _dob;
  String get phone => _phone;
  String get role => _role;
  String get profileImage => _profileImage;
  String get backgroundImage => _backgroundImage;
  String get status => _status;
  DateTime get createTimestamp => _createTimestamp;
  DateTime get updateTimestamp => _updateTimestamp;
  double get height => _weight;
  double get weight => _height;
  int get age => _age;
  String get BMI => (_weight / (_height) * (_height)).toStringAsFixed(2);
  int get totalStep => _total_step;
  double get totalCalories => _total_calories;
  double get totalDistance => _total_distance;
  int get totalTime => _total_time;
  int get lessongComplete => _total_lesson_complete;
}