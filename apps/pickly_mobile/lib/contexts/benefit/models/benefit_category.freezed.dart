// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'benefit_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BenefitCategory {

 String get id; String get name; String get slug; String? get description; String? get iconUrl; String? get bannerImageUrl; String? get bannerLinkUrl; DateTime get createdAt; DateTime? get updatedAt; bool get isActive; int get displayOrder;
/// Create a copy of BenefitCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BenefitCategoryCopyWith<BenefitCategory> get copyWith => _$BenefitCategoryCopyWithImpl<BenefitCategory>(this as BenefitCategory, _$identity);

  /// Serializes this BenefitCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BenefitCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.bannerImageUrl, bannerImageUrl) || other.bannerImageUrl == bannerImageUrl)&&(identical(other.bannerLinkUrl, bannerLinkUrl) || other.bannerLinkUrl == bannerLinkUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,slug,description,iconUrl,bannerImageUrl,bannerLinkUrl,createdAt,updatedAt,isActive,displayOrder);

@override
String toString() {
  return 'BenefitCategory(id: $id, name: $name, slug: $slug, description: $description, iconUrl: $iconUrl, bannerImageUrl: $bannerImageUrl, bannerLinkUrl: $bannerLinkUrl, createdAt: $createdAt, updatedAt: $updatedAt, isActive: $isActive, displayOrder: $displayOrder)';
}


}

/// @nodoc
abstract mixin class $BenefitCategoryCopyWith<$Res>  {
  factory $BenefitCategoryCopyWith(BenefitCategory value, $Res Function(BenefitCategory) _then) = _$BenefitCategoryCopyWithImpl;
@useResult
$Res call({
 String id, String name, String slug, String? description, String? iconUrl, String? bannerImageUrl, String? bannerLinkUrl, DateTime createdAt, DateTime? updatedAt, bool isActive, int displayOrder
});




}
/// @nodoc
class _$BenefitCategoryCopyWithImpl<$Res>
    implements $BenefitCategoryCopyWith<$Res> {
  _$BenefitCategoryCopyWithImpl(this._self, this._then);

  final BenefitCategory _self;
  final $Res Function(BenefitCategory) _then;

/// Create a copy of BenefitCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? slug = null,Object? description = freezed,Object? iconUrl = freezed,Object? bannerImageUrl = freezed,Object? bannerLinkUrl = freezed,Object? createdAt = null,Object? updatedAt = freezed,Object? isActive = null,Object? displayOrder = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerImageUrl: freezed == bannerImageUrl ? _self.bannerImageUrl : bannerImageUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerLinkUrl: freezed == bannerLinkUrl ? _self.bannerLinkUrl : bannerLinkUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BenefitCategory].
extension BenefitCategoryPatterns on BenefitCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BenefitCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BenefitCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BenefitCategory value)  $default,){
final _that = this;
switch (_that) {
case _BenefitCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BenefitCategory value)?  $default,){
final _that = this;
switch (_that) {
case _BenefitCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String slug,  String? description,  String? iconUrl,  String? bannerImageUrl,  String? bannerLinkUrl,  DateTime createdAt,  DateTime? updatedAt,  bool isActive,  int displayOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BenefitCategory() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.description,_that.iconUrl,_that.bannerImageUrl,_that.bannerLinkUrl,_that.createdAt,_that.updatedAt,_that.isActive,_that.displayOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String slug,  String? description,  String? iconUrl,  String? bannerImageUrl,  String? bannerLinkUrl,  DateTime createdAt,  DateTime? updatedAt,  bool isActive,  int displayOrder)  $default,) {final _that = this;
switch (_that) {
case _BenefitCategory():
return $default(_that.id,_that.name,_that.slug,_that.description,_that.iconUrl,_that.bannerImageUrl,_that.bannerLinkUrl,_that.createdAt,_that.updatedAt,_that.isActive,_that.displayOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String slug,  String? description,  String? iconUrl,  String? bannerImageUrl,  String? bannerLinkUrl,  DateTime createdAt,  DateTime? updatedAt,  bool isActive,  int displayOrder)?  $default,) {final _that = this;
switch (_that) {
case _BenefitCategory() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.description,_that.iconUrl,_that.bannerImageUrl,_that.bannerLinkUrl,_that.createdAt,_that.updatedAt,_that.isActive,_that.displayOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BenefitCategory implements BenefitCategory {
  const _BenefitCategory({required this.id, required this.name, required this.slug, this.description, this.iconUrl, this.bannerImageUrl, this.bannerLinkUrl, required this.createdAt, this.updatedAt, this.isActive = true, this.displayOrder = 0});
  factory _BenefitCategory.fromJson(Map<String, dynamic> json) => _$BenefitCategoryFromJson(json);

@override final  String id;
@override final  String name;
@override final  String slug;
@override final  String? description;
@override final  String? iconUrl;
@override final  String? bannerImageUrl;
@override final  String? bannerLinkUrl;
@override final  DateTime createdAt;
@override final  DateTime? updatedAt;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  int displayOrder;

/// Create a copy of BenefitCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BenefitCategoryCopyWith<_BenefitCategory> get copyWith => __$BenefitCategoryCopyWithImpl<_BenefitCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BenefitCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BenefitCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.bannerImageUrl, bannerImageUrl) || other.bannerImageUrl == bannerImageUrl)&&(identical(other.bannerLinkUrl, bannerLinkUrl) || other.bannerLinkUrl == bannerLinkUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,slug,description,iconUrl,bannerImageUrl,bannerLinkUrl,createdAt,updatedAt,isActive,displayOrder);

@override
String toString() {
  return 'BenefitCategory(id: $id, name: $name, slug: $slug, description: $description, iconUrl: $iconUrl, bannerImageUrl: $bannerImageUrl, bannerLinkUrl: $bannerLinkUrl, createdAt: $createdAt, updatedAt: $updatedAt, isActive: $isActive, displayOrder: $displayOrder)';
}


}

/// @nodoc
abstract mixin class _$BenefitCategoryCopyWith<$Res> implements $BenefitCategoryCopyWith<$Res> {
  factory _$BenefitCategoryCopyWith(_BenefitCategory value, $Res Function(_BenefitCategory) _then) = __$BenefitCategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String slug, String? description, String? iconUrl, String? bannerImageUrl, String? bannerLinkUrl, DateTime createdAt, DateTime? updatedAt, bool isActive, int displayOrder
});




}
/// @nodoc
class __$BenefitCategoryCopyWithImpl<$Res>
    implements _$BenefitCategoryCopyWith<$Res> {
  __$BenefitCategoryCopyWithImpl(this._self, this._then);

  final _BenefitCategory _self;
  final $Res Function(_BenefitCategory) _then;

/// Create a copy of BenefitCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? slug = null,Object? description = freezed,Object? iconUrl = freezed,Object? bannerImageUrl = freezed,Object? bannerLinkUrl = freezed,Object? createdAt = null,Object? updatedAt = freezed,Object? isActive = null,Object? displayOrder = null,}) {
  return _then(_BenefitCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerImageUrl: freezed == bannerImageUrl ? _self.bannerImageUrl : bannerImageUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerLinkUrl: freezed == bannerLinkUrl ? _self.bannerLinkUrl : bannerLinkUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
