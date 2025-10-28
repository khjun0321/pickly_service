// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'benefit_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BenefitDetail {

 String get id;@JsonKey(name: 'benefit_category_id') String get benefitCategoryId; String get title; String? get description;@JsonKey(name: 'icon_url') String? get iconUrl;@JsonKey(name: 'sort_order') int get sortOrder;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of BenefitDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BenefitDetailCopyWith<BenefitDetail> get copyWith => _$BenefitDetailCopyWithImpl<BenefitDetail>(this as BenefitDetail, _$identity);

  /// Serializes this BenefitDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BenefitDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.benefitCategoryId, benefitCategoryId) || other.benefitCategoryId == benefitCategoryId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,benefitCategoryId,title,description,iconUrl,sortOrder,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'BenefitDetail(id: $id, benefitCategoryId: $benefitCategoryId, title: $title, description: $description, iconUrl: $iconUrl, sortOrder: $sortOrder, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $BenefitDetailCopyWith<$Res>  {
  factory $BenefitDetailCopyWith(BenefitDetail value, $Res Function(BenefitDetail) _then) = _$BenefitDetailCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'benefit_category_id') String benefitCategoryId, String title, String? description,@JsonKey(name: 'icon_url') String? iconUrl,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$BenefitDetailCopyWithImpl<$Res>
    implements $BenefitDetailCopyWith<$Res> {
  _$BenefitDetailCopyWithImpl(this._self, this._then);

  final BenefitDetail _self;
  final $Res Function(BenefitDetail) _then;

/// Create a copy of BenefitDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? benefitCategoryId = null,Object? title = null,Object? description = freezed,Object? iconUrl = freezed,Object? sortOrder = null,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,benefitCategoryId: null == benefitCategoryId ? _self.benefitCategoryId : benefitCategoryId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BenefitDetail].
extension BenefitDetailPatterns on BenefitDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BenefitDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BenefitDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BenefitDetail value)  $default,){
final _that = this;
switch (_that) {
case _BenefitDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BenefitDetail value)?  $default,){
final _that = this;
switch (_that) {
case _BenefitDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'benefit_category_id')  String benefitCategoryId,  String title,  String? description, @JsonKey(name: 'icon_url')  String? iconUrl, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BenefitDetail() when $default != null:
return $default(_that.id,_that.benefitCategoryId,_that.title,_that.description,_that.iconUrl,_that.sortOrder,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'benefit_category_id')  String benefitCategoryId,  String title,  String? description, @JsonKey(name: 'icon_url')  String? iconUrl, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _BenefitDetail():
return $default(_that.id,_that.benefitCategoryId,_that.title,_that.description,_that.iconUrl,_that.sortOrder,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'benefit_category_id')  String benefitCategoryId,  String title,  String? description, @JsonKey(name: 'icon_url')  String? iconUrl, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _BenefitDetail() when $default != null:
return $default(_that.id,_that.benefitCategoryId,_that.title,_that.description,_that.iconUrl,_that.sortOrder,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BenefitDetail implements BenefitDetail {
  const _BenefitDetail({required this.id, @JsonKey(name: 'benefit_category_id') required this.benefitCategoryId, required this.title, this.description, @JsonKey(name: 'icon_url') this.iconUrl, @JsonKey(name: 'sort_order') this.sortOrder = 0, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _BenefitDetail.fromJson(Map<String, dynamic> json) => _$BenefitDetailFromJson(json);

@override final  String id;
@override@JsonKey(name: 'benefit_category_id') final  String benefitCategoryId;
@override final  String title;
@override final  String? description;
@override@JsonKey(name: 'icon_url') final  String? iconUrl;
@override@JsonKey(name: 'sort_order') final  int sortOrder;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of BenefitDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BenefitDetailCopyWith<_BenefitDetail> get copyWith => __$BenefitDetailCopyWithImpl<_BenefitDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BenefitDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BenefitDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.benefitCategoryId, benefitCategoryId) || other.benefitCategoryId == benefitCategoryId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,benefitCategoryId,title,description,iconUrl,sortOrder,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'BenefitDetail(id: $id, benefitCategoryId: $benefitCategoryId, title: $title, description: $description, iconUrl: $iconUrl, sortOrder: $sortOrder, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BenefitDetailCopyWith<$Res> implements $BenefitDetailCopyWith<$Res> {
  factory _$BenefitDetailCopyWith(_BenefitDetail value, $Res Function(_BenefitDetail) _then) = __$BenefitDetailCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'benefit_category_id') String benefitCategoryId, String title, String? description,@JsonKey(name: 'icon_url') String? iconUrl,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$BenefitDetailCopyWithImpl<$Res>
    implements _$BenefitDetailCopyWith<$Res> {
  __$BenefitDetailCopyWithImpl(this._self, this._then);

  final _BenefitDetail _self;
  final $Res Function(_BenefitDetail) _then;

/// Create a copy of BenefitDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? benefitCategoryId = null,Object? title = null,Object? description = freezed,Object? iconUrl = freezed,Object? sortOrder = null,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_BenefitDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,benefitCategoryId: null == benefitCategoryId ? _self.benefitCategoryId : benefitCategoryId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
