class UserModel {
  String? uid;
  late String? name;
  String? email;
  late String? profileImage;
  int? state;

  UserModel({
    this.uid,
    required this.name,
    this.email,
    required this.profileImage,
    this.state,
  });

  Map toMap(UserModel user) {
    var data = Map<String, dynamic>();
    data['uid'] = user.uid;
    data['name'] = user.name;
    data['email'] = user.email;
    data['profile_image'] = user.profileImage;
    data['state'] = user.state;
    return data;
  }

  UserModel.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['uid'];
    this.name = mapData['name'];
    this.email = mapData['email'];
    this.profileImage = mapData['profile_image'];
    this.state = mapData['state'];
  }
}
