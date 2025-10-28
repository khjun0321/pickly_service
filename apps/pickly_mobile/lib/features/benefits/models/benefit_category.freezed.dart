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

 String get id; String get title; String get slug; String? get description;@JsonKey(name: 'icon_url') String? get iconUrl;@JsonKey(name: 'sort_order') int get sortOrder;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'parent_id') String? get parentId;@JsonKey(name: 'custom_fields') Map<String, dynamic>? get customFields;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of BenefitCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BenefitCategoryCopyWith<BenefitCategory> get copyWith => _$BenefitCategoryCopyWithImpl<BenefitCategory>(this as BenefitCategory, _$identity);

  /// Serializes this BenefitCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BenefitCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&const DeepCollectionEquality().equals(other.customFields, customFields)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,slug,description,iconUrl,sortOrder,isActive,parentId,const DeepCollectionEquality().hash(customFields),createdAt,updatedAt);

@override
String toString() {
  return 'BenefitCategory(id: $id, title: $title, slug: $slug, description: $description, iconUrl: $iconUrl, sortOrder: $sortOrder, isActive: $isActive, parentId: $parentId, customFields: $customFields, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $BenefitCategoryCopyWith<$Res>  {
  factory $BenefitCategoryCopyWith(BenefitCategory value, $Res Function(BenefitCategory) _then) = _$BenefitCategoryCopyWithImpl;
@useResult
$Res call({
 String id, String title, String slug, String? description,@JsonKey(name: 'icon_url') String? iconUrl,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'parent_id') String? parentId,@JsonKey(name: 'custom_fields') Map<String, dynamic>? customFields,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? slug = null,Object? description = freezed,Object? iconUrl = freezed,Object? sortOrder = null,Object? isActive = null,Object? parentId = freezed,Object? customFields = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,customFields: freezed == customFields ? _self.customFields : customFields // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String slug,  String? description, @JsonKey(name: 'icon_url')  String? iconUrl, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'parent_id')  String? parentId, @JsonKey(name: 'custom_fields')  Map<String, dynamic>? customFields, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BenefitCategory() when $default != null:
return $default(_that.id,_that.title,_that.slug,_that.description,_that.iconUrl,_that.sortOrder,_that.isActive,_that.parentId,_that.customFields,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String slug,  String? description, @JsonKey(name: 'icon_url')  String? iconUrl, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'parent_id')  String? parentId, @JsonKey(name: 'custom_fields')  Map<String, dynamic>? customFields, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _BenefitCategory():
return $default(_that.id,_that.title,_that.slug,_that.description,_that.iconUrl,_that.sortOrder,_that.isActive,_that.parentId,_that.customFields,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String slug,  String? description, @JsonKey(name: 'icon_url')  String? iconUrl, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'parent_id')  String? parentId, @JsonKey(name: 'custom_fields')  Map<String, dynamic>? customFields, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _BenefitCategory() when $default != null:
return $default(_that.id,_that.title,_that.slug,_that.description,_that.iconUrl,_that.sortOrder,_that.isActive,_that.parentId,_that.customFields,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BenefitCategory implements BenefitCategory {
  const _BenefitCategory({required this.id, required this.title, required this.slug, this.description, @JsonKey(name: 'icon_url') this.iconUrl, @JsonKey(name: 'sort_order') this.sortOrder = 0, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'parent_id') this.parentId, @JsonKey(name: 'custom_fields') final  Map<String, dynamic>? customFields, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt}): _customFields = customFields;
  factory _BenefitCategory.fromJson(Map<String, dynamic> json) => _$BenefitCategoryFromJson(json);

@override final  String id;
@override final  String title;
@override final  String slug;
@override final  String? description;
@override@JsonKey(name: 'icon_url') final  String? iconUrl;
@override@JsonKey(name: 'sort_order') final  int sortOrder;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'parent_id') final  String? parentId;
 final  Map<String, dynamic>? _customFields;
@override@JsonKey(name: 'custom_fields') Map<String, dynamic>? get customFields {
  final value = _customFields;
  if (value == null) return null;
  if (_customFields is EqualUnmodifiableMapView) return _customFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BenefitCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&const DeepCollectionEquality().equals(other._customFields, _customFields)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,slug,description,iconUrl,sortOrder,isActive,parentId,const DeepCollectionEquality().hash(_customFields),createdAt,updatedAt);

@override
String toString() {
  return 'BenefitCategory(id: $id, title: $title, slug: $slug, description: $description, iconUrl: $iconUrl, sortOrder: $sortOrder, isActive: $isActive, parentId: $parentId, customFields: $customFields, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BenefitCategoryCopyWith<$Res> implements $BenefitCategoryCopyWith<$Res> {
  factory _$BenefitCategoryCopyWith(_BenefitCategory value, $Res Function(_BenefitCategory) _then) = __$BenefitCategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String slug, String? description,@JsonKey(name: 'icon_url') String? iconUrl,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'parent_id') String? parentId,@JsonKey(name: 'custom_fields') Map<String, dynamic>? customFields,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? slug = null,Object? description = freezed,Object? iconUrl = freezed,Object? sortOrder = null,Object? isActive = null,Object? parentId = freezed,Object? customFields = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_BenefitCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,customFields: freezed == customFields ? _self._customFields : customFields // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
