// lib/models/now_free_model.dart
class NowFreeModel {
  final String id;
  final String groupName;
  final String groupDescription;
  final String groupType;
  final String location;
  final String time;
  final String contactNo;
  final String? imageUrl;

  NowFreeModel({
    required this.id,
    required this.groupName,
    required this.groupDescription,
    required this.groupType,
    required this.location,
    required this.time,
    required this.contactNo,
    this.imageUrl,
  });

  factory NowFreeModel.fromMap(Map<String, dynamic> map, {required String id}) {
    return NowFreeModel(
      id: id,
      groupName: map['groupName'] ?? '',
      groupDescription: map['groupDescription'] ?? '',
      groupType: map['groupType'] ?? '',
      location: map['location'] ?? '',
      time: map['time'] ?? '',
      contactNo: map['contactNo'] ?? '',
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupName': groupName,
      'groupDescription': groupDescription,
      'groupType': groupType,
      'location': location,
      'time': time,
      'contactNo': contactNo,
      'imageUrl': imageUrl,
    };
  }
}
