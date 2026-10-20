// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'travel_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TravelEntry {

 String get countryCode; TravelStatus get status;/// Date only; visited only.
 DateTime? get visitedOn;/// 1 to 5; visited only.
 int? get rating;/// Wishlist only.
 WishlistPriority? get priority;/// Wishlist only.
 int? get targetYear; String get notes; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of TravelEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TravelEntryCopyWith<TravelEntry> get copyWith => _$TravelEntryCopyWithImpl<TravelEntry>(this as TravelEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TravelEntry&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.status, status) || other.status == status)&&(identical(other.visitedOn, visitedOn) || other.visitedOn == visitedOn)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.targetYear, targetYear) || other.targetYear == targetYear)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,countryCode,status,visitedOn,rating,priority,targetYear,notes,createdAt,updatedAt);

@override
String toString() {
  return 'TravelEntry(countryCode: $countryCode, status: $status, visitedOn: $visitedOn, rating: $rating, priority: $priority, targetYear: $targetYear, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $TravelEntryCopyWith<$Res>  {
  factory $TravelEntryCopyWith(TravelEntry value, $Res Function(TravelEntry) _then) = _$TravelEntryCopyWithImpl;
@useResult
$Res call({
 String countryCode, TravelStatus status, DateTime? visitedOn, int? rating, WishlistPriority? priority, int? targetYear, String notes, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$TravelEntryCopyWithImpl<$Res>
    implements $TravelEntryCopyWith<$Res> {
  _$TravelEntryCopyWithImpl(this._self, this._then);

  final TravelEntry _self;
  final $Res Function(TravelEntry) _then;

/// Create a copy of TravelEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? countryCode = null,Object? status = null,Object? visitedOn = freezed,Object? rating = freezed,Object? priority = freezed,Object? targetYear = freezed,Object? notes = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TravelStatus,visitedOn: freezed == visitedOn ? _self.visitedOn : visitedOn // ignore: cast_nullable_to_non_nullable
as DateTime?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as WishlistPriority?,targetYear: freezed == targetYear ? _self.targetYear : targetYear // ignore: cast_nullable_to_non_nullable
as int?,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TravelEntry].
extension TravelEntryPatterns on TravelEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TravelEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TravelEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TravelEntry value)  $default,){
final _that = this;
switch (_that) {
case _TravelEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TravelEntry value)?  $default,){
final _that = this;
switch (_that) {
case _TravelEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String countryCode,  TravelStatus status,  DateTime? visitedOn,  int? rating,  WishlistPriority? priority,  int? targetYear,  String notes,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TravelEntry() when $default != null:
return $default(_that.countryCode,_that.status,_that.visitedOn,_that.rating,_that.priority,_that.targetYear,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String countryCode,  TravelStatus status,  DateTime? visitedOn,  int? rating,  WishlistPriority? priority,  int? targetYear,  String notes,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _TravelEntry():
return $default(_that.countryCode,_that.status,_that.visitedOn,_that.rating,_that.priority,_that.targetYear,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String countryCode,  TravelStatus status,  DateTime? visitedOn,  int? rating,  WishlistPriority? priority,  int? targetYear,  String notes,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _TravelEntry() when $default != null:
return $default(_that.countryCode,_that.status,_that.visitedOn,_that.rating,_that.priority,_that.targetYear,_that.notes,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _TravelEntry implements TravelEntry {
  const _TravelEntry({required this.countryCode, required this.status, this.visitedOn, this.rating, this.priority, this.targetYear, this.notes = '', required this.createdAt, required this.updatedAt});
  

@override final  String countryCode;
@override final  TravelStatus status;
/// Date only; visited only.
@override final  DateTime? visitedOn;
/// 1 to 5; visited only.
@override final  int? rating;
/// Wishlist only.
@override final  WishlistPriority? priority;
/// Wishlist only.
@override final  int? targetYear;
@override@JsonKey() final  String notes;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of TravelEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TravelEntryCopyWith<_TravelEntry> get copyWith => __$TravelEntryCopyWithImpl<_TravelEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TravelEntry&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.status, status) || other.status == status)&&(identical(other.visitedOn, visitedOn) || other.visitedOn == visitedOn)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.targetYear, targetYear) || other.targetYear == targetYear)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,countryCode,status,visitedOn,rating,priority,targetYear,notes,createdAt,updatedAt);

@override
String toString() {
  return 'TravelEntry(countryCode: $countryCode, status: $status, visitedOn: $visitedOn, rating: $rating, priority: $priority, targetYear: $targetYear, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TravelEntryCopyWith<$Res> implements $TravelEntryCopyWith<$Res> {
  factory _$TravelEntryCopyWith(_TravelEntry value, $Res Function(_TravelEntry) _then) = __$TravelEntryCopyWithImpl;
@override @useResult
$Res call({
 String countryCode, TravelStatus status, DateTime? visitedOn, int? rating, WishlistPriority? priority, int? targetYear, String notes, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$TravelEntryCopyWithImpl<$Res>
    implements _$TravelEntryCopyWith<$Res> {
  __$TravelEntryCopyWithImpl(this._self, this._then);

  final _TravelEntry _self;
  final $Res Function(_TravelEntry) _then;

/// Create a copy of TravelEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? countryCode = null,Object? status = null,Object? visitedOn = freezed,Object? rating = freezed,Object? priority = freezed,Object? targetYear = freezed,Object? notes = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_TravelEntry(
countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TravelStatus,visitedOn: freezed == visitedOn ? _self.visitedOn : visitedOn // ignore: cast_nullable_to_non_nullable
as DateTime?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as WishlistPriority?,targetYear: freezed == targetYear ? _self.targetYear : targetYear // ignore: cast_nullable_to_non_nullable
as int?,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
