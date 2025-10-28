// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'benefit_announcement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BenefitAnnouncement {

 String get id;@JsonKey(name: 'category_id') String get categoryId;@JsonKey(name: 'benefit_detail_id') String? get benefitDetailId; String get title; String? get subtitle; String get organization;@JsonKey(name: 'application_period_start') DateTime? get applicationPeriodStart;@JsonKey(name: 'application_period_end') DateTime? get applicationPeriodEnd;@JsonKey(name: 'announcement_date') DateTime? get announcementDate; String get status;@JsonKey(name: 'is_featured') bool get isFeatured;@JsonKey(name: 'views_count') int get viewsCount; String? get summary;@JsonKey(name: 'thumbnail_url') String? get thumbnailUrl;@JsonKey(name: 'external_url') String? get externalUrl; List<String> get tags;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;@JsonKey(name: 'published_at') DateTime? get publishedAt;@JsonKey(name: 'display_order') int get displayOrder;@JsonKey(name: 'custom_data') Map<String, dynamic>? get customData; String? get content;
/// Create a copy of BenefitAnnouncement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BenefitAnnouncementCopyWith<BenefitAnnouncement> get copyWith => _$BenefitAnnouncementCopyWithImpl<BenefitAnnouncement>(this as BenefitAnnouncement, _$identity);

  /// Serializes this BenefitAnnouncement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BenefitAnnouncement&&(identical(other.id, id) || other.id == id)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.benefitDetailId, benefitDetailId) || other.benefitDetailId == benefitDetailId)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.organization, organization) || other.organization == organization)&&(identical(other.applicationPeriodStart, applicationPeriodStart) || other.applicationPeriodStart == applicationPeriodStart)&&(identical(other.applicationPeriodEnd, applicationPeriodEnd) || other.applicationPeriodEnd == applicationPeriodEnd)&&(identical(other.announcementDate, announcementDate) || other.announcementDate == announcementDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.viewsCount, viewsCount) || other.viewsCount == viewsCount)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.externalUrl, externalUrl) || other.externalUrl == externalUrl)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&const DeepCollectionEquality().equals(other.customData, customData)&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,categoryId,benefitDetailId,title,subtitle,organization,applicationPeriodStart,applicationPeriodEnd,announcementDate,status,isFeatured,viewsCount,summary,thumbnailUrl,externalUrl,const DeepCollectionEquality().hash(tags),createdAt,updatedAt,publishedAt,displayOrder,const DeepCollectionEquality().hash(customData),content]);

@override
String toString() {
  return 'BenefitAnnouncement(id: $id, categoryId: $categoryId, benefitDetailId: $benefitDetailId, title: $title, subtitle: $subtitle, organization: $organization, applicationPeriodStart: $applicationPeriodStart, applicationPeriodEnd: $applicationPeriodEnd, announcementDate: $announcementDate, status: $status, isFeatured: $isFeatured, viewsCount: $viewsCount, summary: $summary, thumbnailUrl: $thumbnailUrl, externalUrl: $externalUrl, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt, publishedAt: $publishedAt, displayOrder: $displayOrder, customData: $customData, content: $content)';
}


}

/// @nodoc
abstract mixin class $BenefitAnnouncementCopyWith<$Res>  {
  factory $BenefitAnnouncementCopyWith(BenefitAnnouncement value, $Res Function(BenefitAnnouncement) _then) = _$BenefitAnnouncementCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'category_id') String categoryId,@JsonKey(name: 'benefit_detail_id') String? benefitDetailId, String title, String? subtitle, String organization,@JsonKey(name: 'application_period_start') DateTime? applicationPeriodStart,@JsonKey(name: 'application_period_end') DateTime? applicationPeriodEnd,@JsonKey(name: 'announcement_date') DateTime? announcementDate, String status,@JsonKey(name: 'is_featured') bool isFeatured,@JsonKey(name: 'views_count') int viewsCount, String? summary,@JsonKey(name: 'thumbnail_url') String? thumbnailUrl,@JsonKey(name: 'external_url') String? externalUrl, List<String> tags,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'published_at') DateTime? publishedAt,@JsonKey(name: 'display_order') int displayOrder,@JsonKey(name: 'custom_data') Map<String, dynamic>? customData, String? content
});




}
/// @nodoc
class _$BenefitAnnouncementCopyWithImpl<$Res>
    implements $BenefitAnnouncementCopyWith<$Res> {
  _$BenefitAnnouncementCopyWithImpl(this._self, this._then);

  final BenefitAnnouncement _self;
  final $Res Function(BenefitAnnouncement) _then;

/// Create a copy of BenefitAnnouncement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? categoryId = null,Object? benefitDetailId = freezed,Object? title = null,Object? subtitle = freezed,Object? organization = null,Object? applicationPeriodStart = freezed,Object? applicationPeriodEnd = freezed,Object? announcementDate = freezed,Object? status = null,Object? isFeatured = null,Object? viewsCount = null,Object? summary = freezed,Object? thumbnailUrl = freezed,Object? externalUrl = freezed,Object? tags = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? publishedAt = freezed,Object? displayOrder = null,Object? customData = freezed,Object? content = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,benefitDetailId: freezed == benefitDetailId ? _self.benefitDetailId : benefitDetailId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,organization: null == organization ? _self.organization : organization // ignore: cast_nullable_to_non_nullable
as String,applicationPeriodStart: freezed == applicationPeriodStart ? _self.applicationPeriodStart : applicationPeriodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,applicationPeriodEnd: freezed == applicationPeriodEnd ? _self.applicationPeriodEnd : applicationPeriodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,announcementDate: freezed == announcementDate ? _self.announcementDate : announcementDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,viewsCount: null == viewsCount ? _self.viewsCount : viewsCount // ignore: cast_nullable_to_non_nullable
as int,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,externalUrl: freezed == externalUrl ? _self.externalUrl : externalUrl // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,customData: freezed == customData ? _self.customData : customData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BenefitAnnouncement].
extension BenefitAnnouncementPatterns on BenefitAnnouncement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BenefitAnnouncement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BenefitAnnouncement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BenefitAnnouncement value)  $default,){
final _that = this;
switch (_that) {
case _BenefitAnnouncement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BenefitAnnouncement value)?  $default,){
final _that = this;
switch (_that) {
case _BenefitAnnouncement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'category_id')  String categoryId, @JsonKey(name: 'benefit_detail_id')  String? benefitDetailId,  String title,  String? subtitle,  String organization, @JsonKey(name: 'application_period_start')  DateTime? applicationPeriodStart, @JsonKey(name: 'application_period_end')  DateTime? applicationPeriodEnd, @JsonKey(name: 'announcement_date')  DateTime? announcementDate,  String status, @JsonKey(name: 'is_featured')  bool isFeatured, @JsonKey(name: 'views_count')  int viewsCount,  String? summary, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'external_url')  String? externalUrl,  List<String> tags, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'published_at')  DateTime? publishedAt, @JsonKey(name: 'display_order')  int displayOrder, @JsonKey(name: 'custom_data')  Map<String, dynamic>? customData,  String? content)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BenefitAnnouncement() when $default != null:
return $default(_that.id,_that.categoryId,_that.benefitDetailId,_that.title,_that.subtitle,_that.organization,_that.applicationPeriodStart,_that.applicationPeriodEnd,_that.announcementDate,_that.status,_that.isFeatured,_that.viewsCount,_that.summary,_that.thumbnailUrl,_that.externalUrl,_that.tags,_that.createdAt,_that.updatedAt,_that.publishedAt,_that.displayOrder,_that.customData,_that.content);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'category_id')  String categoryId, @JsonKey(name: 'benefit_detail_id')  String? benefitDetailId,  String title,  String? subtitle,  String organization, @JsonKey(name: 'application_period_start')  DateTime? applicationPeriodStart, @JsonKey(name: 'application_period_end')  DateTime? applicationPeriodEnd, @JsonKey(name: 'announcement_date')  DateTime? announcementDate,  String status, @JsonKey(name: 'is_featured')  bool isFeatured, @JsonKey(name: 'views_count')  int viewsCount,  String? summary, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'external_url')  String? externalUrl,  List<String> tags, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'published_at')  DateTime? publishedAt, @JsonKey(name: 'display_order')  int displayOrder, @JsonKey(name: 'custom_data')  Map<String, dynamic>? customData,  String? content)  $default,) {final _that = this;
switch (_that) {
case _BenefitAnnouncement():
return $default(_that.id,_that.categoryId,_that.benefitDetailId,_that.title,_that.subtitle,_that.organization,_that.applicationPeriodStart,_that.applicationPeriodEnd,_that.announcementDate,_that.status,_that.isFeatured,_that.viewsCount,_that.summary,_that.thumbnailUrl,_that.externalUrl,_that.tags,_that.createdAt,_that.updatedAt,_that.publishedAt,_that.displayOrder,_that.customData,_that.content);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'category_id')  String categoryId, @JsonKey(name: 'benefit_detail_id')  String? benefitDetailId,  String title,  String? subtitle,  String organization, @JsonKey(name: 'application_period_start')  DateTime? applicationPeriodStart, @JsonKey(name: 'application_period_end')  DateTime? applicationPeriodEnd, @JsonKey(name: 'announcement_date')  DateTime? announcementDate,  String status, @JsonKey(name: 'is_featured')  bool isFeatured, @JsonKey(name: 'views_count')  int viewsCount,  String? summary, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'external_url')  String? externalUrl,  List<String> tags, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'published_at')  DateTime? publishedAt, @JsonKey(name: 'display_order')  int displayOrder, @JsonKey(name: 'custom_data')  Map<String, dynamic>? customData,  String? content)?  $default,) {final _that = this;
switch (_that) {
case _BenefitAnnouncement() when $default != null:
return $default(_that.id,_that.categoryId,_that.benefitDetailId,_that.title,_that.subtitle,_that.organization,_that.applicationPeriodStart,_that.applicationPeriodEnd,_that.announcementDate,_that.status,_that.isFeatured,_that.viewsCount,_that.summary,_that.thumbnailUrl,_that.externalUrl,_that.tags,_that.createdAt,_that.updatedAt,_that.publishedAt,_that.displayOrder,_that.customData,_that.content);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BenefitAnnouncement implements BenefitAnnouncement {
  const _BenefitAnnouncement({required this.id, @JsonKey(name: 'category_id') required this.categoryId, @JsonKey(name: 'benefit_detail_id') this.benefitDetailId, required this.title, this.subtitle, required this.organization, @JsonKey(name: 'application_period_start') this.applicationPeriodStart, @JsonKey(name: 'application_period_end') this.applicationPeriodEnd, @JsonKey(name: 'announcement_date') this.announcementDate, this.status = 'draft', @JsonKey(name: 'is_featured') this.isFeatured = false, @JsonKey(name: 'views_count') this.viewsCount = 0, this.summary, @JsonKey(name: 'thumbnail_url') this.thumbnailUrl, @JsonKey(name: 'external_url') this.externalUrl, final  List<String> tags = const [], @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt, @JsonKey(name: 'published_at') this.publishedAt, @JsonKey(name: 'display_order') this.displayOrder = 0, @JsonKey(name: 'custom_data') final  Map<String, dynamic>? customData, this.content}): _tags = tags,_customData = customData;
  factory _BenefitAnnouncement.fromJson(Map<String, dynamic> json) => _$BenefitAnnouncementFromJson(json);

@override final  String id;
@override@JsonKey(name: 'category_id') final  String categoryId;
@override@JsonKey(name: 'benefit_detail_id') final  String? benefitDetailId;
@override final  String title;
@override final  String? subtitle;
@override final  String organization;
@override@JsonKey(name: 'application_period_start') final  DateTime? applicationPeriodStart;
@override@JsonKey(name: 'application_period_end') final  DateTime? applicationPeriodEnd;
@override@JsonKey(name: 'announcement_date') final  DateTime? announcementDate;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'is_featured') final  bool isFeatured;
@override@JsonKey(name: 'views_count') final  int viewsCount;
@override final  String? summary;
@override@JsonKey(name: 'thumbnail_url') final  String? thumbnailUrl;
@override@JsonKey(name: 'external_url') final  String? externalUrl;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;
@override@JsonKey(name: 'published_at') final  DateTime? publishedAt;
@override@JsonKey(name: 'display_order') final  int displayOrder;
 final  Map<String, dynamic>? _customData;
@override@JsonKey(name: 'custom_data') Map<String, dynamic>? get customData {
  final value = _customData;
  if (value == null) return null;
  if (_customData is EqualUnmodifiableMapView) return _customData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? content;

/// Create a copy of BenefitAnnouncement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BenefitAnnouncementCopyWith<_BenefitAnnouncement> get copyWith => __$BenefitAnnouncementCopyWithImpl<_BenefitAnnouncement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BenefitAnnouncementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BenefitAnnouncement&&(identical(other.id, id) || other.id == id)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.benefitDetailId, benefitDetailId) || other.benefitDetailId == benefitDetailId)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.organization, organization) || other.organization == organization)&&(identical(other.applicationPeriodStart, applicationPeriodStart) || other.applicationPeriodStart == applicationPeriodStart)&&(identical(other.applicationPeriodEnd, applicationPeriodEnd) || other.applicationPeriodEnd == applicationPeriodEnd)&&(identical(other.announcementDate, announcementDate) || other.announcementDate == announcementDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.viewsCount, viewsCount) || other.viewsCount == viewsCount)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.externalUrl, externalUrl) || other.externalUrl == externalUrl)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&const DeepCollectionEquality().equals(other._customData, _customData)&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,categoryId,benefitDetailId,title,subtitle,organization,applicationPeriodStart,applicationPeriodEnd,announcementDate,status,isFeatured,viewsCount,summary,thumbnailUrl,externalUrl,const DeepCollectionEquality().hash(_tags),createdAt,updatedAt,publishedAt,displayOrder,const DeepCollectionEquality().hash(_customData),content]);

@override
String toString() {
  return 'BenefitAnnouncement(id: $id, categoryId: $categoryId, benefitDetailId: $benefitDetailId, title: $title, subtitle: $subtitle, organization: $organization, applicationPeriodStart: $applicationPeriodStart, applicationPeriodEnd: $applicationPeriodEnd, announcementDate: $announcementDate, status: $status, isFeatured: $isFeatured, viewsCount: $viewsCount, summary: $summary, thumbnailUrl: $thumbnailUrl, externalUrl: $externalUrl, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt, publishedAt: $publishedAt, displayOrder: $displayOrder, customData: $customData, content: $content)';
}


}

/// @nodoc
abstract mixin class _$BenefitAnnouncementCopyWith<$Res> implements $BenefitAnnouncementCopyWith<$Res> {
  factory _$BenefitAnnouncementCopyWith(_BenefitAnnouncement value, $Res Function(_BenefitAnnouncement) _then) = __$BenefitAnnouncementCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'category_id') String categoryId,@JsonKey(name: 'benefit_detail_id') String? benefitDetailId, String title, String? subtitle, String organization,@JsonKey(name: 'application_period_start') DateTime? applicationPeriodStart,@JsonKey(name: 'application_period_end') DateTime? applicationPeriodEnd,@JsonKey(name: 'announcement_date') DateTime? announcementDate, String status,@JsonKey(name: 'is_featured') bool isFeatured,@JsonKey(name: 'views_count') int viewsCount, String? summary,@JsonKey(name: 'thumbnail_url') String? thumbnailUrl,@JsonKey(name: 'external_url') String? externalUrl, List<String> tags,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'published_at') DateTime? publishedAt,@JsonKey(name: 'display_order') int displayOrder,@JsonKey(name: 'custom_data') Map<String, dynamic>? customData, String? content
});




}
/// @nodoc
class __$BenefitAnnouncementCopyWithImpl<$Res>
    implements _$BenefitAnnouncementCopyWith<$Res> {
  __$BenefitAnnouncementCopyWithImpl(this._self, this._then);

  final _BenefitAnnouncement _self;
  final $Res Function(_BenefitAnnouncement) _then;

/// Create a copy of BenefitAnnouncement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? categoryId = null,Object? benefitDetailId = freezed,Object? title = null,Object? subtitle = freezed,Object? organization = null,Object? applicationPeriodStart = freezed,Object? applicationPeriodEnd = freezed,Object? announcementDate = freezed,Object? status = null,Object? isFeatured = null,Object? viewsCount = null,Object? summary = freezed,Object? thumbnailUrl = freezed,Object? externalUrl = freezed,Object? tags = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? publishedAt = freezed,Object? displayOrder = null,Object? customData = freezed,Object? content = freezed,}) {
  return _then(_BenefitAnnouncement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,benefitDetailId: freezed == benefitDetailId ? _self.benefitDetailId : benefitDetailId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,organization: null == organization ? _self.organization : organization // ignore: cast_nullable_to_non_nullable
as String,applicationPeriodStart: freezed == applicationPeriodStart ? _self.applicationPeriodStart : applicationPeriodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,applicationPeriodEnd: freezed == applicationPeriodEnd ? _self.applicationPeriodEnd : applicationPeriodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,announcementDate: freezed == announcementDate ? _self.announcementDate : announcementDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,viewsCount: null == viewsCount ? _self.viewsCount : viewsCount // ignore: cast_nullable_to_non_nullable
as int,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,externalUrl: freezed == externalUrl ? _self.externalUrl : externalUrl // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,customData: freezed == customData ? _self._customData : customData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
