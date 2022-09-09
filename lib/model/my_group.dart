import 'package:json_annotation/json_annotation.dart';
part 'my_group.g.dart';

enum GroupCategory { outdoor, indoor }

enum TemperatureUnit { celsius, fahrenheit }

@JsonSerializable()
class MyGroup {
  int id;
  String title;
  String description;
  GroupCategory groupCategory;
  TemperatureUnit temperatureUnit;
  List<String> energyDeviceIds;
  List<String> flowDeviceIds;
  MyGroup({
    required this.id,
    required this.title,
    required this.description,
    required this.groupCategory,
    this.temperatureUnit = TemperatureUnit.celsius,
    this.energyDeviceIds = const [''],
    this.flowDeviceIds = const ['', ''],
  });

  factory MyGroup.fromJson(Map<String, dynamic> json) => _$MyGroupFromJson(json);

  Map<String, dynamic> toJson() => _$MyGroupToJson(this);
}

// List<dynamic> newgroups = jsonDecode(jsonString);
// List<MyGroup> gggroups = newgroups.map((e) => MyGroup.fromJson(e)).toList();



