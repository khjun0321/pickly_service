// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'announcement_file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AnnouncementFile {

 String get id; String get announcementId; String get fileName; String get fileUrl; String? get fileType; int? get fileSize; String? get description; DateTime get createdAt; DateTime? get updatedAt; int get displayOrder; Map<String, dynamic> get customData;
/// Create a copy of AnnouncementFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnnouncementFileCopyWith<AnnouncementFile> get copyWith => _$AnnouncementFileCopyWithImpl<AnnouncementFile>(this as AnnouncementFile, _$identity);

  /// Serializes this AnnouncementFile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnnouncementFile&&(identical(other.id, id) || other.id == id)&&(identical(other.announcementId, announcementId) || other.announcementId == announcementId)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.fileType, fileType) || other.fileType == fileType)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&const DeepCollectionEquality().equals(other.customData, customData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,announcementId,fileName,fileUrl,fileType,fileSize,description,createdAt,updatedAt,displayOrder,const DeepCollectionEquality().hash(customData));

@override
String toString() {
  return 'AnnouncementFile(id: $id, announcementId: $announcementId, fileName: $fileName, fileUrl: $fileUrl, fileType: $fileType, fileSize: $fileSize, description: $description, createdAt: $createdAt, updatedAt: $updatedAt, displayOrder: $displayOrder, customData: $customData)';
}


}

/// @nodoc
abstract mixin class $AnnouncementFileCopyWith<$Res>  {
  factory $AnnouncementFileCopyWith(AnnouncementFile value, $Res Function(AnnouncementFile) _then) = _$AnnouncementFileCopyWithImpl;
@useResult
$Res call({
 String id, String announcementId, String fileName, String fileUrl, String? fileType, int? fileSize, String? description, DateTime createdAt, DateTime? updatedAt, int displayOrder, Map<String, dynamic> customData
});




}
/// @nodoc
class _$AnnouncementFileCopyWithImpl<$Res>
    implements $AnnouncementFileCopyWith<$Res> {
  _$AnnouncementFileCopyWithImpl(this._self, this._then);

  final AnnouncementFile _self;
  final $Res Function(AnnouncementFile) _then;

/// Create a copy of AnnouncementFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? announcementId = null,Object? fileName = null,Object? fileUrl = null,Object? fileType = freezed,Object? fileSize = freezed,Object? description = freezed,Object? createdAt = null,Object? updatedAt = freezed,Object? displayOrder = null,Object? customData = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,announcementId: null == announcementId ? _self.announcementId : announcementId // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,fileUrl: null == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String,fileType: freezed == fileType ? _self.fileType : fileType // ignore: cast_nullable_to_non_nullable
as String?,fileSize: freezed == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,customData: null == customData ? _self.customData : customData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [AnnouncementFile].
extension AnnouncementFilePatterns on AnnouncementFile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnnouncementFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnnouncementFile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnnouncementFile value)  $default,){
final _that = this;
switch (_that) {
case _AnnouncementFile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnnouncementFile value)?  $default,){
final _that = this;
switch (_that) {
case _AnnouncementFile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String announcementId,  String fileName,  String fileUrl,  String? fileType,  int? fileSize,  String? description,  DateTime createdAt,  DateTime? updatedAt,  int displayOrder,  Map<String, dynamic> customData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnnouncementFile() when $default != null:
return $default(_that.id,_that.announcementId,_that.fileName,_that.fileUrl,_that.fileType,_that.fileSize,_that.description,_that.createdAt,_that.updatedAt,_that.displayOrder,_that.customData);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String announcementId,  String fileName,  String fileUrl,  String? fileType,  int? fileSize,  String? description,  DateTime createdAt,  DateTime? updatedAt,  int displayOrder,  Map<String, dynamic> customData)  $default,) {final _that = this;
switch (_that) {
case _AnnouncementFile():
return $default(_that.id,_that.announcementId,_that.fileName,_that.fileUrl,_that.fileType,_that.fileSize,_that.description,_that.createdAt,_that.updatedAt,_that.displayOrder,_that.customData);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String announcementId,  String fileName,  String fileUrl,  String? fileType,  int? fileSize,  String? description,  DateTime createdAt,  DateTime? updatedAt,  int displayOrder,  Map<String, dynamic> customData)?  $default,) {final _that = this;
switch (_that) {
case _AnnouncementFile() when $default != null:
return $default(_that.id,_that.announcementId,_that.fileName,_that.fileUrl,_that.fileType,_that.fileSize,_that.description,_that.createdAt,_that.updatedAt,_that.displayOrder,_that.customData);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnnouncementFile extends AnnouncementFile {
  const _AnnouncementFile({required this.id, required this.announcementId, required this.fileName, required this.fileUrl, this.fileType, this.fileSize, this.description, required this.createdAt, this.updatedAt, this.displayOrder = 0, final  Map<String, dynamic> customData = const {}}): _customData = customData,super._();
  factory _AnnouncementFile.fromJson(Map<String, dynamic> json) => _$AnnouncementFileFromJson(json);

@override final  String id;
@override final  String announcementId;
@override final  String fileName;
@override final  String fileUrl;
@override final  String? fileType;
@override final  int? fileSize;
@override final  String? description;
@override final  DateTime createdAt;
@override final  DateTime? updatedAt;
@override@JsonKey() final  int displayOrder;
 final  Map<String, dynamic> _customData;
@override@JsonKey() Map<String, dynamic> get customData {
  if (_customData is EqualUnmodifiableMapView) return _customData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_customData);
}


/// Create a copy of AnnouncementFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnnouncementFileCopyWith<_AnnouncementFile> get copyWith => __$AnnouncementFileCopyWithImpl<_AnnouncementFile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnnouncementFileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnnouncementFile&&(identical(other.id, id) || other.id == id)&&(identical(other.announcementId, announcementId) || other.announcementId == announcementId)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.fileType, fileType) || other.fileType == fileType)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&const DeepCollectionEquality().equals(other._customData, _customData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,announcementId,fileName,fileUrl,fileType,fileSize,description,createdAt,updatedAt,displayOrder,const DeepCollectionEquality().hash(_customData));

@override
String toString() {
  return 'AnnouncementFile(id: $id, announcementId: $announcementId, fileName: $fileName, fileUrl: $fileUrl, fileType: $fileType, fileSize: $fileSize, description: $description, createdAt: $createdAt, updatedAt: $updatedAt, displayOrder: $displayOrder, customData: $customData)';
}


}

/// @nodoc
abstract mixin class _$AnnouncementFileCopyWith<$Res> implements $AnnouncementFileCopyWith<$Res> {
  factory _$AnnouncementFileCopyWith(_AnnouncementFile value, $Res Function(_AnnouncementFile) _then) = __$AnnouncementFileCopyWithImpl;
@override @useResult
$Res call({
 String id, String announcementId, String fileName, String fileUrl, String? fileType, int? fileSize, String? description, DateTime createdAt, DateTime? updatedAt, int displayOrder, Map<String, dynamic> customData
});




}
/// @nodoc
class __$AnnouncementFileCopyWithImpl<$Res>
    implements _$AnnouncementFileCopyWith<$Res> {
  __$AnnouncementFileCopyWithImpl(this._self, this._then);

  final _AnnouncementFile _self;
  final $Res Function(_AnnouncementFile) _then;

/// Create a copy of AnnouncementFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? announcementId = null,Object? fileName = null,Object? fileUrl = null,Object? fileType = freezed,Object? fileSize = freezed,Object? description = freezed,Object? createdAt = null,Object? updatedAt = freezed,Object? displayOrder = null,Object? customData = null,}) {
  return _then(_AnnouncementFile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,announcementId: null == announcementId ? _self.announcementId : announcementId // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,fileUrl: null == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String,fileType: freezed == fileType ? _self.fileType : fileType // ignore: cast_nullable_to_non_nullable
as String?,fileSize: freezed == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,customData: null == customData ? _self._customData : customData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
