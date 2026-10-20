// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SyncEntry {

 String get countryCode; TravelStatus get status;/// ISO date (YYYY-MM-DD), exactly as stored.
 String? get visitedOn; int? get rating; WishlistPriority? get priority; int? get targetYear; String get notes; int get createdAt; int get updatedAt; bool get isDeleted;
/// Create a copy of SyncEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncEntryCopyWith<SyncEntry> get copyWith => _$SyncEntryCopyWithImpl<SyncEntry>(this as SyncEntry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SyncEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncEntry&&(identical(other.countryCode, _this.countryCode) || other.countryCode == _this.countryCode)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.visitedOn, _this.visitedOn) || other.visitedOn == _this.visitedOn)&&(identical(other.rating, _this.rating) || other.rating == _this.rating)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.targetYear, _this.targetYear) || other.targetYear == _this.targetYear)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.isDeleted, _this.isDeleted) || other.isDeleted == _this.isDeleted));
}


@override
int get hashCode {
  final _this = this as SyncEntry;
  return Object.hash(runtimeType,_this.countryCode,_this.status,_this.visitedOn,_this.rating,_this.priority,_this.targetYear,_this.notes,_this.createdAt,_this.updatedAt,_this.isDeleted);
}

@override
String toString() {
  final _this = this as SyncEntry;
  return 'SyncEntry(countryCode: ${_this.countryCode}, status: ${_this.status}, visitedOn: ${_this.visitedOn}, rating: ${_this.rating}, priority: ${_this.priority}, targetYear: ${_this.targetYear}, notes: ${_this.notes}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, isDeleted: ${_this.isDeleted})';
}


}

/// @nodoc
abstract mixin class $SyncEntryCopyWith<$Res>  {
  factory $SyncEntryCopyWith(SyncEntry value, $Res Function(SyncEntry) _then) = _$SyncEntryCopyWithImpl;
@useResult
$Res call({
 String countryCode, TravelStatus status, String? visitedOn, int? rating, WishlistPriority? priority, int? targetYear, String notes, int createdAt, int updatedAt, bool isDeleted
});




}
/// @nodoc
class _$SyncEntryCopyWithImpl<$Res>
    implements $SyncEntryCopyWith<$Res> {
  _$SyncEntryCopyWithImpl(this._self, this._then);

  final SyncEntry _self;
  final $Res Function(SyncEntry) _then;

/// Create a copy of SyncEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? countryCode = null,Object? status = null,Object? visitedOn = freezed,Object? rating = freezed,Object? priority = freezed,Object? targetYear = freezed,Object? notes = null,Object? createdAt = null,Object? updatedAt = null,Object? isDeleted = null,}) {
  return _then(SyncEntry(
countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TravelStatus,visitedOn: freezed == visitedOn ? _self.visitedOn : visitedOn // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as WishlistPriority?,targetYear: freezed == targetYear ? _self.targetYear : targetYear // ignore: cast_nullable_to_non_nullable
as int?,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncEntry].
extension SyncEntryPatterns on SyncEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncEntry value)  $default,){
final _that = this;
switch (_that) {
case _SyncEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncEntry value)?  $default,){
final _that = this;
switch (_that) {
case _SyncEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String countryCode,  TravelStatus status,  String? visitedOn,  int? rating,  WishlistPriority? priority,  int? targetYear,  String notes,  int createdAt,  int updatedAt,  bool isDeleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncEntry() when $default != null:
return $default(_that.countryCode,_that.status,_that.visitedOn,_that.rating,_that.priority,_that.targetYear,_that.notes,_that.createdAt,_that.updatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String countryCode,  TravelStatus status,  String? visitedOn,  int? rating,  WishlistPriority? priority,  int? targetYear,  String notes,  int createdAt,  int updatedAt,  bool isDeleted)  $default,) {final _that = this;
switch (_that) {
case _SyncEntry():
return $default(_that.countryCode,_that.status,_that.visitedOn,_that.rating,_that.priority,_that.targetYear,_that.notes,_that.createdAt,_that.updatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String countryCode,  TravelStatus status,  String? visitedOn,  int? rating,  WishlistPriority? priority,  int? targetYear,  String notes,  int createdAt,  int updatedAt,  bool isDeleted)?  $default,) {final _that = this;
switch (_that) {
case _SyncEntry() when $default != null:
return $default(_that.countryCode,_that.status,_that.visitedOn,_that.rating,_that.priority,_that.targetYear,_that.notes,_that.createdAt,_that.updatedAt,_that.isDeleted);case _:
  return null;

}
}

}

/// @nodoc


class _SyncEntry implements SyncEntry {
  const _SyncEntry({required this.countryCode, required this.status, this.visitedOn, this.rating, this.priority, this.targetYear, this.notes = '', required this.createdAt, required this.updatedAt, this.isDeleted = false});
  

@override final  String countryCode;
@override final  TravelStatus status;
/// ISO date (YYYY-MM-DD), exactly as stored.
@override final  String? visitedOn;
@override final  int? rating;
@override final  WishlistPriority? priority;
@override final  int? targetYear;
@override@JsonKey() final  String notes;
@override final  int createdAt;
@override final  int updatedAt;
@override@JsonKey() final  bool isDeleted;

/// Create a copy of SyncEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncEntryCopyWith<_SyncEntry> get copyWith => __$SyncEntryCopyWithImpl<_SyncEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncEntry&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.status, status) || other.status == status)&&(identical(other.visitedOn, visitedOn) || other.visitedOn == visitedOn)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.targetYear, targetYear) || other.targetYear == targetYear)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}


@override
int get hashCode {
    return Object.hash(runtimeType,countryCode,status,visitedOn,rating,priority,targetYear,notes,createdAt,updatedAt,isDeleted);
}

@override
String toString() {
    return 'SyncEntry(countryCode: $countryCode, status: $status, visitedOn: $visitedOn, rating: $rating, priority: $priority, targetYear: $targetYear, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class _$SyncEntryCopyWith<$Res> implements $SyncEntryCopyWith<$Res> {
  factory _$SyncEntryCopyWith(_SyncEntry value, $Res Function(_SyncEntry) _then) = __$SyncEntryCopyWithImpl;
@override @useResult
$Res call({
 String countryCode, TravelStatus status, String? visitedOn, int? rating, WishlistPriority? priority, int? targetYear, String notes, int createdAt, int updatedAt, bool isDeleted
});




}
/// @nodoc
class __$SyncEntryCopyWithImpl<$Res>
    implements _$SyncEntryCopyWith<$Res> {
  __$SyncEntryCopyWithImpl(this._self, this._then);

  final _SyncEntry _self;
  final $Res Function(_SyncEntry) _then;

/// Create a copy of SyncEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? countryCode = null,Object? status = null,Object? visitedOn = freezed,Object? rating = freezed,Object? priority = freezed,Object? targetYear = freezed,Object? notes = null,Object? createdAt = null,Object? updatedAt = null,Object? isDeleted = null,}) {
  return _then(_SyncEntry(
countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TravelStatus,visitedOn: freezed == visitedOn ? _self.visitedOn : visitedOn // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as WishlistPriority?,targetYear: freezed == targetYear ? _self.targetYear : targetYear // ignore: cast_nullable_to_non_nullable
as int?,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
