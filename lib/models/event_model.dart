class EventModel {
  final String id;
  final String eventType;
  final String groupName;
  final String groupDescription;
  final String groupType;
  final int peopleNeeded;
  final int? minPeople;
  final int? maxPeople;
  final String location;
  final String time;
  final String contactNo;

  EventModel({
    required this.id,
    required this.eventType,
    required this.groupName,
    required this.groupDescription,
    required this.groupType,
    required this.peopleNeeded,
    this.minPeople,
    this.maxPeople,
    required this.location,
    required this.time,
    required this.contactNo,
  });

  factory EventModel.fromMap(Map<String, dynamic> map, {required String id}) {
    return EventModel(
      id: id,
      eventType: map['eventType'] ?? '',
      groupName: map['groupName'] ?? '',
      groupDescription: map['groupDescription'] ?? '',
      groupType: map['groupType'] ?? '',
      peopleNeeded: map['peopleNeeded'] ?? 0,
      minPeople: map['minPeople'],
      maxPeople: map['maxPeople'],
      location: map['location'] ?? '',
      time: map['time'] ?? '',
      contactNo: map['contactNo'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventType': eventType,
      'groupName': groupName,
      'groupDescription': groupDescription,
      'groupType': groupType,
      'peopleNeeded': peopleNeeded,
      'minPeople': minPeople,
      'maxPeople': maxPeople,
      'location': location,
      'time': time,
      'contactNo': contactNo,
    };
  }
}
