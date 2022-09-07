// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyGroup _$MyGroupFromJson(Map<String, dynamic> json) => MyGroup(
      id: json['id'] as int,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      leading: $enumDecode(_$GroupWidgetEnumMap, json['leading']),
      deviceIds: (json['deviceIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MyGroupToJson(MyGroup instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'leading': _$GroupWidgetEnumMap[instance.leading]!,
      'deviceIds': instance.deviceIds,
    };

const _$GroupWidgetEnumMap = {
  GroupWidget.outdoor: 'outdoor',
  GroupWidget.indoor: 'indoor',
};
