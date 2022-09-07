import 'package:json_annotation/json_annotation.dart';
part 'my_group.g.dart';

enum GroupWidget { outdoor, indoor }

@JsonSerializable()
class MyGroup {
  int id;
  String title;
  String subtitle;
  GroupWidget leading;
  List<String> deviceIds;
  MyGroup({required this.id, required this.title, required this.subtitle, required this.leading, this.deviceIds = const []});

  factory MyGroup.fromJson(Map<String, dynamic> json) => _$MyGroupFromJson(json);

  Map<String, dynamic> toJson() => _$MyGroupToJson(this);
}


// List<dynamic> newgroups = jsonDecode(jsonString);
// List<MyGroup> gggroups = newgroups.map((e) => MyGroup.fromJson(e)).toList();