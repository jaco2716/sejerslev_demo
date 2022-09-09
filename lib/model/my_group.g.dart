// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyGroup _$MyGroupFromJson(Map<String, dynamic> json) => MyGroup(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      groupCategory: $enumDecode(_$GroupCategoryEnumMap, json['groupCategory']),
      temperatureUnit: $enumDecodeNullable(
              _$TemperatureUnitEnumMap, json['temperatureUnit']) ??
          TemperatureUnit.celsius,
      energyDeviceIds: (json['energyDeviceIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [''],
      flowDeviceIds: (json['flowDeviceIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['', ''],
    );

Map<String, dynamic> _$MyGroupToJson(MyGroup instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'groupCategory': _$GroupCategoryEnumMap[instance.groupCategory]!,
      'temperatureUnit': _$TemperatureUnitEnumMap[instance.temperatureUnit]!,
      'energyDeviceIds': instance.energyDeviceIds,
      'flowDeviceIds': instance.flowDeviceIds,
    };

const _$GroupCategoryEnumMap = {
  GroupCategory.outdoor: 'outdoor',
  GroupCategory.indoor: 'indoor',
};

const _$TemperatureUnitEnumMap = {
  TemperatureUnit.celsius: 'celsius',
  TemperatureUnit.fahrenheit: 'fahrenheit',
};
