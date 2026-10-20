// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'explore_query.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExploreQuery {

 String get search;/// Regions to include; empty means all. OR within the field (FR-EXP-07).
 Set<String> get regions;/// Subregions to include, limited to the selected regions.
 Set<String> get subregions;/// A language name, for example French.
 String? get language;/// A currency code, for example EUR.
 String? get currency; CountrySort get sort;
/// Create a copy of ExploreQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExploreQueryCopyWith<ExploreQuery> get copyWith => _$ExploreQueryCopyWithImpl<ExploreQuery>(this as ExploreQuery, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExploreQuery&&(identical(other.search, search) || other.search == search)&&const DeepCollectionEquality().equals(other.regions, regions)&&const DeepCollectionEquality().equals(other.subregions, subregions)&&(identical(other.language, language) || other.language == language)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.sort, sort) || other.sort == sort));
}


@override
int get hashCode => Object.hash(runtimeType,search,const DeepCollectionEquality().hash(regions),const DeepCollectionEquality().hash(subregions),language,currency,sort);

@override
String toString() {
  return 'ExploreQuery(search: $search, regions: $regions, subregions: $subregions, language: $language, currency: $currency, sort: $sort)';
}


}

/// @nodoc
abstract mixin class $ExploreQueryCopyWith<$Res>  {
  factory $ExploreQueryCopyWith(ExploreQuery value, $Res Function(ExploreQuery) _then) = _$ExploreQueryCopyWithImpl;
@useResult
$Res call({
 String search, Set<String> regions, Set<String> subregions, String? language, String? currency, CountrySort sort
});




}
/// @nodoc
class _$ExploreQueryCopyWithImpl<$Res>
    implements $ExploreQueryCopyWith<$Res> {
  _$ExploreQueryCopyWithImpl(this._self, this._then);

  final ExploreQuery _self;
  final $Res Function(ExploreQuery) _then;

/// Create a copy of ExploreQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? search = null,Object? regions = null,Object? subregions = null,Object? language = freezed,Object? currency = freezed,Object? sort = null,}) {
  return _then(_self.copyWith(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,regions: null == regions ? _self.regions : regions // ignore: cast_nullable_to_non_nullable
as Set<String>,subregions: null == subregions ? _self.subregions : subregions // ignore: cast_nullable_to_non_nullable
as Set<String>,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as CountrySort,
  ));
}

}


/// Adds pattern-matching-related methods to [ExploreQuery].
extension ExploreQueryPatterns on ExploreQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExploreQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExploreQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExploreQuery value)  $default,){
final _that = this;
switch (_that) {
case _ExploreQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExploreQuery value)?  $default,){
final _that = this;
switch (_that) {
case _ExploreQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String search,  Set<String> regions,  Set<String> subregions,  String? language,  String? currency,  CountrySort sort)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExploreQuery() when $default != null:
return $default(_that.search,_that.regions,_that.subregions,_that.language,_that.currency,_that.sort);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String search,  Set<String> regions,  Set<String> subregions,  String? language,  String? currency,  CountrySort sort)  $default,) {final _that = this;
switch (_that) {
case _ExploreQuery():
return $default(_that.search,_that.regions,_that.subregions,_that.language,_that.currency,_that.sort);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String search,  Set<String> regions,  Set<String> subregions,  String? language,  String? currency,  CountrySort sort)?  $default,) {final _that = this;
switch (_that) {
case _ExploreQuery() when $default != null:
return $default(_that.search,_that.regions,_that.subregions,_that.language,_that.currency,_that.sort);case _:
  return null;

}
}

}

/// @nodoc


class _ExploreQuery extends ExploreQuery {
  const _ExploreQuery({this.search = '', final  Set<String> regions = const <String>{}, final  Set<String> subregions = const <String>{}, this.language, this.currency, this.sort = CountrySort.nameAsc}): _regions = regions,_subregions = subregions,super._();
  

@override@JsonKey() final  String search;
/// Regions to include; empty means all. OR within the field (FR-EXP-07).
 final  Set<String> _regions;
/// Regions to include; empty means all. OR within the field (FR-EXP-07).
@override@JsonKey() Set<String> get regions {
  if (_regions is EqualUnmodifiableSetView) return _regions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_regions);
}

/// Subregions to include, limited to the selected regions.
 final  Set<String> _subregions;
/// Subregions to include, limited to the selected regions.
@override@JsonKey() Set<String> get subregions {
  if (_subregions is EqualUnmodifiableSetView) return _subregions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_subregions);
}

/// A language name, for example French.
@override final  String? language;
/// A currency code, for example EUR.
@override final  String? currency;
@override@JsonKey() final  CountrySort sort;

/// Create a copy of ExploreQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExploreQueryCopyWith<_ExploreQuery> get copyWith => __$ExploreQueryCopyWithImpl<_ExploreQuery>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExploreQuery&&(identical(other.search, search) || other.search == search)&&const DeepCollectionEquality().equals(other._regions, _regions)&&const DeepCollectionEquality().equals(other._subregions, _subregions)&&(identical(other.language, language) || other.language == language)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.sort, sort) || other.sort == sort));
}


@override
int get hashCode => Object.hash(runtimeType,search,const DeepCollectionEquality().hash(_regions),const DeepCollectionEquality().hash(_subregions),language,currency,sort);

@override
String toString() {
  return 'ExploreQuery(search: $search, regions: $regions, subregions: $subregions, language: $language, currency: $currency, sort: $sort)';
}


}

/// @nodoc
abstract mixin class _$ExploreQueryCopyWith<$Res> implements $ExploreQueryCopyWith<$Res> {
  factory _$ExploreQueryCopyWith(_ExploreQuery value, $Res Function(_ExploreQuery) _then) = __$ExploreQueryCopyWithImpl;
@override @useResult
$Res call({
 String search, Set<String> regions, Set<String> subregions, String? language, String? currency, CountrySort sort
});




}
/// @nodoc
class __$ExploreQueryCopyWithImpl<$Res>
    implements _$ExploreQueryCopyWith<$Res> {
  __$ExploreQueryCopyWithImpl(this._self, this._then);

  final _ExploreQuery _self;
  final $Res Function(_ExploreQuery) _then;

/// Create a copy of ExploreQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? search = null,Object? regions = null,Object? subregions = null,Object? language = freezed,Object? currency = freezed,Object? sort = null,}) {
  return _then(_ExploreQuery(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,regions: null == regions ? _self._regions : regions // ignore: cast_nullable_to_non_nullable
as Set<String>,subregions: null == subregions ? _self._subregions : subregions // ignore: cast_nullable_to_non_nullable
as Set<String>,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as CountrySort,
  ));
}


}

// dart format on
