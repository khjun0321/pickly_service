// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'announcement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Announcement {

 String get id; String get categoryId; String get title; String? get subtitle; String? get organization; DateTime? get applicationPeriodStart; DateTime? get applicationPeriodEnd; DateTime? get announcementDate; AnnouncementStatus get status; bool get isFeatured; int get viewsCount; String? get summary; String? get thumbnailUrl; String? get externalUrl; String? get externalId; List<String> get tags; DateTime? get publishedAt; DateTime get createdAt; DateTime get updatedAt; Map<String, dynamic> get customData; String? get description; String? get content; String? get agency; String? get contactInfo; DateTime? get deadline; int get displayOrder; int get bookmarkCount; List<String> get targetGroups;
/// Create a copy of Announcement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnnouncementCopyWith<Announcement> get copyWith => _$AnnouncementCopyWithImpl<Announcement>(this as Announcement, _$identity);

  /// Serializes this Announcement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Announcement&&(identical(other.id, id) || other.id == id)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.organization, organization) || other.organization == organization)&&(identical(other.applicationPeriodStart, applicationPeriodStart) || other.applicationPeriodStart == applicationPeriodStart)&&(identical(other.applicationPeriodEnd, applicationPeriodEnd) || other.applicationPeriodEnd == applicationPeriodEnd)&&(identical(other.announcementDate, announcementDate) || other.announcementDate == announcementDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.viewsCount, viewsCount) || other.viewsCount == viewsCount)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.externalUrl, externalUrl) || other.externalUrl == externalUrl)&&(identical(other.externalId, externalId) || other.externalId == externalId)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.customData, customData)&&(identical(other.description, description) || other.description == description)&&(identical(other.content, content) || other.content == content)&&(identical(other.agency, agency) || other.agency == agency)&&(identical(other.contactInfo, contactInfo) || other.contactInfo == contactInfo)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.bookmarkCount, bookmarkCount) || other.bookmarkCount == bookmarkCount)&&const DeepCollectionEquality().equals(other.targetGroups, targetGroups));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,categoryId,title,subtitle,organization,applicationPeriodStart,applicationPeriodEnd,announcementDate,status,isFeatured,viewsCount,summary,thumbnailUrl,externalUrl,externalId,const DeepCollectionEquality().hash(tags),publishedAt,createdAt,updatedAt,const DeepCollectionEquality().hash(customData),description,content,agency,contactInfo,deadline,displayOrder,bookmarkCount,const DeepCollectionEquality().hash(targetGroups)]);

@override
String toString() {
  return 'Announcement(id: $id, categoryId: $categoryId, title: $title, subtitle: $subtitle, organization: $organization, applicationPeriodStart: $applicationPeriodStart, applicationPeriodEnd: $applicationPeriodEnd, announcementDate: $announcementDate, status: $status, isFeatured: $isFeatured, viewsCount: $viewsCount, summary: $summary, thumbnailUrl: $thumbnailUrl, externalUrl: $externalUrl, externalId: $externalId, tags: $tags, publishedAt: $publishedAt, createdAt: $createdAt, updatedAt: $updatedAt, customData: $customData, description: $description, content: $content, agency: $agency, contactInfo: $contactInfo, deadline: $deadline, displayOrder: $displayOrder, bookmarkCount: $bookmarkCount, targetGroups: $targetGroups)';
}


}

/// @nodoc
abstract mixin class $AnnouncementCopyWith<$Res>  {
  factory $AnnouncementCopyWith(Announcement value, $Res Function(Announcement) _then) = _$AnnouncementCopyWithImpl;
@useResult
$Res call({
 String id, String categoryId, String title, String? subtitle, String? organization, DateTime? applicationPeriodStart, DateTime? applicationPeriodEnd, DateTime? announcementDate, AnnouncementStatus status, bool isFeatured, int viewsCount, String? summary, String? thumbnailUrl, String? externalUrl, String? externalId, List<String> tags, DateTime? publishedAt, DateTime createdAt, DateTime updatedAt, Map<String, dynamic> customData, String? description, String? content, String? agency, String? contactInfo, DateTime? deadline, int displayOrder, int bookmarkCount, List<String> targetGroups
});




}
/// @nodoc
class _$AnnouncementCopyWithImpl<$Res>
    implements $AnnouncementCopyWith<$Res> {
  _$AnnouncementCopyWithImpl(this._self, this._then);

  final Announcement _self;
  final $Res Function(Announcement) _then;

/// Create a copy of Announcement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? categoryId = null,Object? title = null,Object? subtitle = freezed,Object? organization = freezed,Object? applicationPeriodStart = freezed,Object? applicationPeriodEnd = freezed,Object? announcementDate = freezed,Object? status = null,Object? isFeatured = null,Object? viewsCount = null,Object? summary = freezed,Object? thumbnailUrl = freezed,Object? externalUrl = freezed,Object? externalId = freezed,Object? tags = null,Object? publishedAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? customData = null,Object? description = freezed,Object? content = freezed,Object? agency = freezed,Object? contactInfo = freezed,Object? deadline = freezed,Object? displayOrder = null,Object? bookmarkCount = null,Object? targetGroups = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,organization: freezed == organization ? _self.organization : organization // ignore: cast_nullable_to_non_nullable
as String?,applicationPeriodStart: freezed == applicationPeriodStart ? _self.applicationPeriodStart : applicationPeriodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,applicationPeriodEnd: freezed == applicationPeriodEnd ? _self.applicationPeriodEnd : applicationPeriodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,announcementDate: freezed == announcementDate ? _self.announcementDate : announcementDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AnnouncementStatus,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,viewsCount: null == viewsCount ? _self.viewsCount : viewsCount // ignore: cast_nullable_to_non_nullable
as int,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,externalUrl: freezed == externalUrl ? _self.externalUrl : externalUrl // ignore: cast_nullable_to_non_nullable
as String?,externalId: freezed == externalId ? _self.externalId : externalId // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,customData: null == customData ? _self.customData : customData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,agency: freezed == agency ? _self.agency : agency // ignore: cast_nullable_to_non_nullable
as String?,contactInfo: freezed == contactInfo ? _self.contactInfo : contactInfo // ignore: cast_nullable_to_non_nullable
as String?,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime?,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,bookmarkCount: null == bookmarkCount ? _self.bookmarkCount : bookmarkCount // ignore: cast_nullable_to_non_nullable
as int,targetGroups: null == targetGroups ? _self.targetGroups : targetGroups // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Announcement].
extension AnnouncementPatterns on Announcement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Announcement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Announcement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Announcement value)  $default,){
final _that = this;
switch (_that) {
case _Announcement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Announcement value)?  $default,){
final _that = this;
switch (_that) {
case _Announcement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String categoryId,  String title,  String? subtitle,  String? organization,  DateTime? applicationPeriodStart,  DateTime? applicationPeriodEnd,  DateTime? announcementDate,  AnnouncementStatus status,  bool isFeatured,  int viewsCount,  String? summary,  String? thumbnailUrl,  String? externalUrl,  String? externalId,  List<String> tags,  DateTime? publishedAt,  DateTime createdAt,  DateTime updatedAt,  Map<String, dynamic> customData,  String? description,  String? content,  String? agency,  String? contactInfo,  DateTime? deadline,  int displayOrder,  int bookmarkCount,  List<String> targetGroups)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Announcement() when $default != null:
return $default(_that.id,_that.categoryId,_that.title,_that.subtitle,_that.organization,_that.applicationPeriodStart,_that.applicationPeriodEnd,_that.announcementDate,_that.status,_that.isFeatured,_that.viewsCount,_that.summary,_that.thumbnailUrl,_that.externalUrl,_that.externalId,_that.tags,_that.publishedAt,_that.createdAt,_that.updatedAt,_that.customData,_that.description,_that.content,_that.agency,_that.contactInfo,_that.deadline,_that.displayOrder,_that.bookmarkCount,_that.targetGroups);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String categoryId,  String title,  String? subtitle,  String? organization,  DateTime? applicationPeriodStart,  DateTime? applicationPeriodEnd,  DateTime? announcementDate,  AnnouncementStatus status,  bool isFeatured,  int viewsCount,  String? summary,  String? thumbnailUrl,  String? externalUrl,  String? externalId,  List<String> tags,  DateTime? publishedAt,  DateTime createdAt,  DateTime updatedAt,  Map<String, dynamic> customData,  String? description,  String? content,  String? agency,  String? contactInfo,  DateTime? deadline,  int displayOrder,  int bookmarkCount,  List<String> targetGroups)  $default,) {final _that = this;
switch (_that) {
case _Announcement():
return $default(_that.id,_that.categoryId,_that.title,_that.subtitle,_that.organization,_that.applicationPeriodStart,_that.applicationPeriodEnd,_that.announcementDate,_that.status,_that.isFeatured,_that.viewsCount,_that.summary,_that.thumbnailUrl,_that.externalUrl,_that.externalId,_that.tags,_that.publishedAt,_that.createdAt,_that.updatedAt,_that.customData,_that.description,_that.content,_that.agency,_that.contactInfo,_that.deadline,_that.displayOrder,_that.bookmarkCount,_that.targetGroups);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String categoryId,  String title,  String? subtitle,  String? organization,  DateTime? applicationPeriodStart,  DateTime? applicationPeriodEnd,  DateTime? announcementDate,  AnnouncementStatus status,  bool isFeatured,  int viewsCount,  String? summary,  String? thumbnailUrl,  String? externalUrl,  String? externalId,  List<String> tags,  DateTime? publishedAt,  DateTime createdAt,  DateTime updatedAt,  Map<String, dynamic> customData,  String? description,  String? content,  String? agency,  String? contactInfo,  DateTime? deadline,  int displayOrder,  int bookmarkCount,  List<String> targetGroups)?  $default,) {final _that = this;
switch (_that) {
case _Announcement() when $default != null:
return $default(_that.id,_that.categoryId,_that.title,_that.subtitle,_that.organization,_that.applicationPeriodStart,_that.applicationPeriodEnd,_that.announcementDate,_that.status,_that.isFeatured,_that.viewsCount,_that.summary,_that.thumbnailUrl,_that.externalUrl,_that.externalId,_that.tags,_that.publishedAt,_that.createdAt,_that.updatedAt,_that.customData,_that.description,_that.content,_that.agency,_that.contactInfo,_that.deadline,_that.displayOrder,_that.bookmarkCount,_that.targetGroups);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Announcement extends Announcement {
  const _Announcement({required this.id, required this.categoryId, required this.title, this.subtitle, this.organization, this.applicationPeriodStart, this.applicationPeriodEnd, this.announcementDate, this.status = AnnouncementStatus.draft, this.isFeatured = false, this.viewsCount = 0, this.summary, this.thumbnailUrl, this.externalUrl, this.externalId, final  List<String> tags = const [], this.publishedAt, required this.createdAt, required this.updatedAt, final  Map<String, dynamic> customData = const {}, this.description, this.content, this.agency, this.contactInfo, this.deadline, this.displayOrder = 0, this.bookmarkCount = 0, final  List<String> targetGroups = const []}): _tags = tags,_customData = customData,_targetGroups = targetGroups,super._();
  factory _Announcement.fromJson(Map<String, dynamic> json) => _$AnnouncementFromJson(json);

@override final  String id;
@override final  String categoryId;
@override final  String title;
@override final  String? subtitle;
@override final  String? organization;
@override final  DateTime? applicationPeriodStart;
@override final  DateTime? applicationPeriodEnd;
@override final  DateTime? announcementDate;
@override@JsonKey() final  AnnouncementStatus status;
@override@JsonKey() final  bool isFeatured;
@override@JsonKey() final  int viewsCount;
@override final  String? summary;
@override final  String? thumbnailUrl;
@override final  String? externalUrl;
@override final  String? externalId;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  DateTime? publishedAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
 final  Map<String, dynamic> _customData;
@override@JsonKey() Map<String, dynamic> get customData {
  if (_customData is EqualUnmodifiableMapView) return _customData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_customData);
}

@override final  String? description;
@override final  String? content;
@override final  String? agency;
@override final  String? contactInfo;
@override final  DateTime? deadline;
@override@JsonKey() final  int displayOrder;
@override@JsonKey() final  int bookmarkCount;
 final  List<String> _targetGroups;
@override@JsonKey() List<String> get targetGroups {
  if (_targetGroups is EqualUnmodifiableListView) return _targetGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_targetGroups);
}


/// Create a copy of Announcement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnnouncementCopyWith<_Announcement> get copyWith => __$AnnouncementCopyWithImpl<_Announcement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnnouncementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Announcement&&(identical(other.id, id) || other.id == id)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.organization, organization) || other.organization == organization)&&(identical(other.applicationPeriodStart, applicationPeriodStart) || other.applicationPeriodStart == applicationPeriodStart)&&(identical(other.applicationPeriodEnd, applicationPeriodEnd) || other.applicationPeriodEnd == applicationPeriodEnd)&&(identical(other.announcementDate, announcementDate) || other.announcementDate == announcementDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.viewsCount, viewsCount) || other.viewsCount == viewsCount)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.externalUrl, externalUrl) || other.externalUrl == externalUrl)&&(identical(other.externalId, externalId) || other.externalId == externalId)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._customData, _customData)&&(identical(other.description, description) || other.description == description)&&(identical(other.content, content) || other.content == content)&&(identical(other.agency, agency) || other.agency == agency)&&(identical(other.contactInfo, contactInfo) || other.contactInfo == contactInfo)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.bookmarkCount, bookmarkCount) || other.bookmarkCount == bookmarkCount)&&const DeepCollectionEquality().equals(other._targetGroups, _targetGroups));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,categoryId,title,subtitle,organization,applicationPeriodStart,applicationPeriodEnd,announcementDate,status,isFeatured,viewsCount,summary,thumbnailUrl,externalUrl,externalId,const DeepCollectionEquality().hash(_tags),publishedAt,createdAt,updatedAt,const DeepCollectionEquality().hash(_customData),description,content,agency,contactInfo,deadline,displayOrder,bookmarkCount,const DeepCollectionEquality().hash(_targetGroups)]);

@override
String toString() {
  return 'Announcement(id: $id, categoryId: $categoryId, title: $title, subtitle: $subtitle, organization: $organization, applicationPeriodStart: $applicationPeriodStart, applicationPeriodEnd: $applicationPeriodEnd, announcementDate: $announcementDate, status: $status, isFeatured: $isFeatured, viewsCount: $viewsCount, summary: $summary, thumbnailUrl: $thumbnailUrl, externalUrl: $externalUrl, externalId: $externalId, tags: $tags, publishedAt: $publishedAt, createdAt: $createdAt, updatedAt: $updatedAt, customData: $customData, description: $description, content: $content, agency: $agency, contactInfo: $contactInfo, deadline: $deadline, displayOrder: $displayOrder, bookmarkCount: $bookmarkCount, targetGroups: $targetGroups)';
}


}

/// @nodoc
abstract mixin class _$AnnouncementCopyWith<$Res> implements $AnnouncementCopyWith<$Res> {
  factory _$AnnouncementCopyWith(_Announcement value, $Res Function(_Announcement) _then) = __$AnnouncementCopyWithImpl;
@override @useResult
$Res call({
 String id, String categoryId, String title, String? subtitle, String? organization, DateTime? applicationPeriodStart, DateTime? applicationPeriodEnd, DateTime? announcementDate, AnnouncementStatus status, bool isFeatured, int viewsCount, String? summary, String? thumbnailUrl, String? externalUrl, String? externalId, List<String> tags, DateTime? publishedAt, DateTime createdAt, DateTime updatedAt, Map<String, dynamic> customData, String? description, String? content, String? agency, String? contactInfo, DateTime? deadline, int displayOrder, int bookmarkCount, List<String> targetGroups
});




}
/// @nodoc
class __$AnnouncementCopyWithImpl<$Res>
    implements _$AnnouncementCopyWith<$Res> {
  __$AnnouncementCopyWithImpl(this._self, this._then);

  final _Announcement _self;
  final $Res Function(_Announcement) _then;

/// Create a copy of Announcement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? categoryId = null,Object? title = null,Object? subtitle = freezed,Object? organization = freezed,Object? applicationPeriodStart = freezed,Object? applicationPeriodEnd = freezed,Object? announcementDate = freezed,Object? status = null,Object? isFeatured = null,Object? viewsCount = null,Object? summary = freezed,Object? thumbnailUrl = freezed,Object? externalUrl = freezed,Object? externalId = freezed,Object? tags = null,Object? publishedAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? customData = null,Object? description = freezed,Object? content = freezed,Object? agency = freezed,Object? contactInfo = freezed,Object? deadline = freezed,Object? displayOrder = null,Object? bookmarkCount = null,Object? targetGroups = null,}) {
  return _then(_Announcement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,organization: freezed == organization ? _self.organization : organization // ignore: cast_nullable_to_non_nullable
as String?,applicationPeriodStart: freezed == applicationPeriodStart ? _self.applicationPeriodStart : applicationPeriodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,applicationPeriodEnd: freezed == applicationPeriodEnd ? _self.applicationPeriodEnd : applicationPeriodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,announcementDate: freezed == announcementDate ? _self.announcementDate : announcementDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AnnouncementStatus,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,viewsCount: null == viewsCount ? _self.viewsCount : viewsCount // ignore: cast_nullable_to_non_nullable
as int,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,externalUrl: freezed == externalUrl ? _self.externalUrl : externalUrl // ignore: cast_nullable_to_non_nullable
as String?,externalId: freezed == externalId ? _self.externalId : externalId // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,customData: null == customData ? _self._customData : customData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,agency: freezed == agency ? _self.agency : agency // ignore: cast_nullable_to_non_nullable
as String?,contactInfo: freezed == contactInfo ? _self.contactInfo : contactInfo // ignore: cast_nullable_to_non_nullable
as String?,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime?,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,bookmarkCount: null == bookmarkCount ? _self.bookmarkCount : bookmarkCount // ignore: cast_nullable_to_non_nullable
as int,targetGroups: null == targetGroups ? _self._targetGroups : targetGroups // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
