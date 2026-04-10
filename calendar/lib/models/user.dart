class User {
  String? id;
  String? fullName;
  String? email;
  String? password;
  String? token;

  User({this.id, this.fullName, this.email, this.password, this.token});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['fullName'];
    email = json['email'];
    password = json['password'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['fullName'] = fullName;
    data['email'] = email;
    data['password'] = password;
    data['token'] = token;
    return data;
  }
}