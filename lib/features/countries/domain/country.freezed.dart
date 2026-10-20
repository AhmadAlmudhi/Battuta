// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'country.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Country {

/// 3-letter ISO code, for example SAU. Primary key and route parameter.
 String get code;/// Lowercase 2-letter ISO code, used for flag URLs.
 String get alpha2; String get nameEn; String get nameOfficialEn; String? get nameAr; String? get nameOfficialAr; String get region; String? get subregion; String? get capital; int get population; double? get areaKm2; List<String> get languages; List<Currency> get currencies;/// 3-letter codes of neighboring countries; empty for no land borders.
 List<String> get borders; List<String> get timezones; String? get mapsUrl; String? get flagAlt;/// Dominant flag color as hex, for example #006C35.
 String? get flagColor;
/// Create a copy of Country
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountryCopyWith<Country> get copyWith => _$CountryCopyWithImpl<Country>(this as Country, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Country&&(identical(other.code, code) || other.code == code)&&(identical(other.alpha2, alpha2) || other.alpha2 == alpha2)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.nameOfficialEn, nameOfficialEn) || other.nameOfficialEn == nameOfficialEn)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.nameOfficialAr, nameOfficialAr) || other.nameOfficialAr == nameOfficialAr)&&(identical(other.region, region) || other.region == region)&&(identical(other.subregion, subregion) || other.subregion == subregion)&&(identical(other.capital, capital) || other.capital == capital)&&(identical(other.population, population) || other.population == population)&&(identical(other.areaKm2, areaKm2) || other.areaKm2 == areaKm2)&&const DeepCollectionEquality().equals(other.languages, languages)&&const DeepCollectionEquality().equals(other.currencies, currencies)&&const DeepCollectionEquality().equals(other.borders, borders)&&const DeepCollectionEquality().equals(other.timezones, timezones)&&(identical(other.mapsUrl, mapsUrl) || other.mapsUrl == mapsUrl)&&(identical(other.flagAlt, flagAlt) || other.flagAlt == flagAlt)&&(identical(other.flagColor, flagColor) || other.flagColor == flagColor));
}


@override
int get hashCode => Object.hash(runtimeType,code,alpha2,nameEn,nameOfficialEn,nameAr,nameOfficialAr,region,subregion,capital,population,areaKm2,const DeepCollectionEquality().hash(languages),const DeepCollectionEquality().hash(currencies),const DeepCollectionEquality().hash(borders),const DeepCollectionEquality().hash(timezones),mapsUrl,flagAlt,flagColor);

@override
String toString() {
  return 'Country(code: $code, alpha2: $alpha2, nameEn: $nameEn, nameOfficialEn: $nameOfficialEn, nameAr: $nameAr, nameOfficialAr: $nameOfficialAr, region: $region, subregion: $subregion, capital: $capital, population: $population, areaKm2: $areaKm2, languages: $languages, currencies: $currencies, borders: $borders, timezones: $timezones, mapsUrl: $mapsUrl, flagAlt: $flagAlt, flagColor: $flagColor)';
}


}

/// @nodoc
abstract mixin class $CountryCopyWith<$Res>  {
  factory $CountryCopyWith(Country value, $Res Function(Country) _then) = _$CountryCopyWithImpl;
@useResult
$Res call({
 String code, String alpha2, String nameEn, String nameOfficialEn, String? nameAr, String? nameOfficialAr, String region, String? subregion, String? capital, int population, double? areaKm2, List<String> languages, List<Currency> currencies, List<String> borders, List<String> timezones, String? mapsUrl, String? flagAlt, String? flagColor
});




}
/// @nodoc
class _$CountryCopyWithImpl<$Res>
    implements $CountryCopyWith<$Res> {
  _$CountryCopyWithImpl(this._self, this._then);

  final Country _self;
  final $Res Function(Country) _then;

/// Create a copy of Country
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? alpha2 = null,Object? nameEn = null,Object? nameOfficialEn = null,Object? nameAr = freezed,Object? nameOfficialAr = freezed,Object? region = null,Object? subregion = freezed,Object? capital = freezed,Object? population = null,Object? areaKm2 = freezed,Object? languages = null,Object? currencies = null,Object? borders = null,Object? timezones = null,Object? mapsUrl = freezed,Object? flagAlt = freezed,Object? flagColor = freezed,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,alpha2: null == alpha2 ? _self.alpha2 : alpha2 // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,nameOfficialEn: null == nameOfficialEn ? _self.nameOfficialEn : nameOfficialEn // ignore: cast_nullable_to_non_nullable
as String,nameAr: freezed == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String?,nameOfficialAr: freezed == nameOfficialAr ? _self.nameOfficialAr : nameOfficialAr // ignore: cast_nullable_to_non_nullable
as String?,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,subregion: freezed == subregion ? _self.subregion : subregion // ignore: cast_nullable_to_non_nullable
as String?,capital: freezed == capital ? _self.capital : capital // ignore: cast_nullable_to_non_nullable
as String?,population: null == population ? _self.population : population // ignore: cast_nullable_to_non_nullable
as int,areaKm2: freezed == areaKm2 ? _self.areaKm2 : areaKm2 // ignore: cast_nullable_to_non_nullable
as double?,languages: null == languages ? _self.languages : languages // ignore: cast_nullable_to_non_nullable
as List<String>,currencies: null == currencies ? _self.currencies : currencies // ignore: cast_nullable_to_non_nullable
as List<Currency>,borders: null == borders ? _self.borders : borders // ignore: cast_nullable_to_non_nullable
as List<String>,timezones: null == timezones ? _self.timezones : timezones // ignore: cast_nullable_to_non_nullable
as List<String>,mapsUrl: freezed == mapsUrl ? _self.mapsUrl : mapsUrl // ignore: cast_nullable_to_non_nullable
as String?,flagAlt: freezed == flagAlt ? _self.flagAlt : flagAlt // ignore: cast_nullable_to_non_nullable
as String?,flagColor: freezed == flagColor ? _self.flagColor : flagColor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Country].
extension CountryPatterns on Country {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Country value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Country() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Country value)  $default,){
final _that = this;
switch (_that) {
case _Country():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Country value)?  $default,){
final _that = this;
switch (_that) {
case _Country() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String alpha2,  String nameEn,  String nameOfficialEn,  String? nameAr,  String? nameOfficialAr,  String region,  String? subregion,  String? capital,  int population,  double? areaKm2,  List<String> languages,  List<Currency> currencies,  List<String> borders,  List<String> timezones,  String? mapsUrl,  String? flagAlt,  String? flagColor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Country() when $default != null:
return $default(_that.code,_that.alpha2,_that.nameEn,_that.nameOfficialEn,_that.nameAr,_that.nameOfficialAr,_that.region,_that.subregion,_that.capital,_that.population,_that.areaKm2,_that.languages,_that.currencies,_that.borders,_that.timezones,_that.mapsUrl,_that.flagAlt,_that.flagColor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String alpha2,  String nameEn,  String nameOfficialEn,  String? nameAr,  String? nameOfficialAr,  String region,  String? subregion,  String? capital,  int population,  double? areaKm2,  List<String> languages,  List<Currency> currencies,  List<String> borders,  List<String> timezones,  String? mapsUrl,  String? flagAlt,  String? flagColor)  $default,) {final _that = this;
switch (_that) {
case _Country():
return $default(_that.code,_that.alpha2,_that.nameEn,_that.nameOfficialEn,_that.nameAr,_that.nameOfficialAr,_that.region,_that.subregion,_that.capital,_that.population,_that.areaKm2,_that.languages,_that.currencies,_that.borders,_that.timezones,_that.mapsUrl,_that.flagAlt,_that.flagColor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String alpha2,  String nameEn,  String nameOfficialEn,  String? nameAr,  String? nameOfficialAr,  String region,  String? subregion,  String? capital,  int population,  double? areaKm2,  List<String> languages,  List<Currency> currencies,  List<String> borders,  List<String> timezones,  String? mapsUrl,  String? flagAlt,  String? flagColor)?  $default,) {final _that = this;
switch (_that) {
case _Country() when $default != null:
return $default(_that.code,_that.alpha2,_that.nameEn,_that.nameOfficialEn,_that.nameAr,_that.nameOfficialAr,_that.region,_that.subregion,_that.capital,_that.population,_that.areaKm2,_that.languages,_that.currencies,_that.borders,_that.timezones,_that.mapsUrl,_that.flagAlt,_that.flagColor);case _:
  return null;

}
}

}

/// @nodoc


class _Country extends Country {
  const _Country({required this.code, required this.alpha2, required this.nameEn, required this.nameOfficialEn, this.nameAr, this.nameOfficialAr, required this.region, this.subregion, this.capital, required this.population, this.areaKm2, final  List<String> languages = const [], final  List<Currency> currencies = const [], final  List<String> borders = const [], final  List<String> timezones = const [], this.mapsUrl, this.flagAlt, this.flagColor}): _languages = languages,_currencies = currencies,_borders = borders,_timezones = timezones,super._();
  

/// 3-letter ISO code, for example SAU. Primary key and route parameter.
@override final  String code;
/// Lowercase 2-letter ISO code, used for flag URLs.
@override final  String alpha2;
@override final  String nameEn;
@override final  String nameOfficialEn;
@override final  String? nameAr;
@override final  String? nameOfficialAr;
@override final  String region;
@override final  String? subregion;
@override final  String? capital;
@override final  int population;
@override final  double? areaKm2;
 final  List<String> _languages;
@override@JsonKey() List<String> get languages {
  if (_languages is EqualUnmodifiableListView) return _languages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_languages);
}

 final  List<Currency> _currencies;
@override@JsonKey() List<Currency> get currencies {
  if (_currencies is EqualUnmodifiableListView) return _currencies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_currencies);
}

/// 3-letter codes of neighboring countries; empty for no land borders.
 final  List<String> _borders;
/// 3-letter codes of neighboring countries; empty for no land borders.
@override@JsonKey() List<String> get borders {
  if (_borders is EqualUnmodifiableListView) return _borders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_borders);
}

 final  List<String> _timezones;
@override@JsonKey() List<String> get timezones {
  if (_timezones is EqualUnmodifiableListView) return _timezones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_timezones);
}

@override final  String? mapsUrl;
@override final  String? flagAlt;
/// Dominant flag color as hex, for example #006C35.
@override final  String? flagColor;

/// Create a copy of Country
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CountryCopyWith<_Country> get copyWith => __$CountryCopyWithImpl<_Country>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Country&&(identical(other.code, code) || other.code == code)&&(identical(other.alpha2, alpha2) || other.alpha2 == alpha2)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.nameOfficialEn, nameOfficialEn) || other.nameOfficialEn == nameOfficialEn)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.nameOfficialAr, nameOfficialAr) || other.nameOfficialAr == nameOfficialAr)&&(identical(other.region, region) || other.region == region)&&(identical(other.subregion, subregion) || other.subregion == subregion)&&(identical(other.capital, capital) || other.capital == capital)&&(identical(other.population, population) || other.population == population)&&(identical(other.areaKm2, areaKm2) || other.areaKm2 == areaKm2)&&const DeepCollectionEquality().equals(other._languages, _languages)&&const DeepCollectionEquality().equals(other._currencies, _currencies)&&const DeepCollectionEquality().equals(other._borders, _borders)&&const DeepCollectionEquality().equals(other._timezones, _timezones)&&(identical(other.mapsUrl, mapsUrl) || other.mapsUrl == mapsUrl)&&(identical(other.flagAlt, flagAlt) || other.flagAlt == flagAlt)&&(identical(other.flagColor, flagColor) || other.flagColor == flagColor));
}


@override
int get hashCode => Object.hash(runtimeType,code,alpha2,nameEn,nameOfficialEn,nameAr,nameOfficialAr,region,subregion,capital,population,areaKm2,const DeepCollectionEquality().hash(_languages),const DeepCollectionEquality().hash(_currencies),const DeepCollectionEquality().hash(_borders),const DeepCollectionEquality().hash(_timezones),mapsUrl,flagAlt,flagColor);

@override
String toString() {
  return 'Country(code: $code, alpha2: $alpha2, nameEn: $nameEn, nameOfficialEn: $nameOfficialEn, nameAr: $nameAr, nameOfficialAr: $nameOfficialAr, region: $region, subregion: $subregion, capital: $capital, population: $population, areaKm2: $areaKm2, languages: $languages, currencies: $currencies, borders: $borders, timezones: $timezones, mapsUrl: $mapsUrl, flagAlt: $flagAlt, flagColor: $flagColor)';
}


}

/// @nodoc
abstract mixin class _$CountryCopyWith<$Res> implements $CountryCopyWith<$Res> {
  factory _$CountryCopyWith(_Country value, $Res Function(_Country) _then) = __$CountryCopyWithImpl;
@override @useResult
$Res call({
 String code, String alpha2, String nameEn, String nameOfficialEn, String? nameAr, String? nameOfficialAr, String region, String? subregion, String? capital, int population, double? areaKm2, List<String> languages, List<Currency> currencies, List<String> borders, List<String> timezones, String? mapsUrl, String? flagAlt, String? flagColor
});




}
/// @nodoc
class __$CountryCopyWithImpl<$Res>
    implements _$CountryCopyWith<$Res> {
  __$CountryCopyWithImpl(this._self, this._then);

  final _Country _self;
  final $Res Function(_Country) _then;

/// Create a copy of Country
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? alpha2 = null,Object? nameEn = null,Object? nameOfficialEn = null,Object? nameAr = freezed,Object? nameOfficialAr = freezed,Object? region = null,Object? subregion = freezed,Object? capital = freezed,Object? population = null,Object? areaKm2 = freezed,Object? languages = null,Object? currencies = null,Object? borders = null,Object? timezones = null,Object? mapsUrl = freezed,Object? flagAlt = freezed,Object? flagColor = freezed,}) {
  return _then(_Country(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,alpha2: null == alpha2 ? _self.alpha2 : alpha2 // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,nameOfficialEn: null == nameOfficialEn ? _self.nameOfficialEn : nameOfficialEn // ignore: cast_nullable_to_non_nullable
as String,nameAr: freezed == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String?,nameOfficialAr: freezed == nameOfficialAr ? _self.nameOfficialAr : nameOfficialAr // ignore: cast_nullable_to_non_nullable
as String?,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,subregion: freezed == subregion ? _self.subregion : subregion // ignore: cast_nullable_to_non_nullable
as String?,capital: freezed == capital ? _self.capital : capital // ignore: cast_nullable_to_non_nullable
as String?,population: null == population ? _self.population : population // ignore: cast_nullable_to_non_nullable
as int,areaKm2: freezed == areaKm2 ? _self.areaKm2 : areaKm2 // ignore: cast_nullable_to_non_nullable
as double?,languages: null == languages ? _self._languages : languages // ignore: cast_nullable_to_non_nullable
as List<String>,currencies: null == currencies ? _self._currencies : currencies // ignore: cast_nullable_to_non_nullable
as List<Currency>,borders: null == borders ? _self._borders : borders // ignore: cast_nullable_to_non_nullable
as List<String>,timezones: null == timezones ? _self._timezones : timezones // ignore: cast_nullable_to_non_nullable
as List<String>,mapsUrl: freezed == mapsUrl ? _self.mapsUrl : mapsUrl // ignore: cast_nullable_to_non_nullable
as String?,flagAlt: freezed == flagAlt ? _self.flagAlt : flagAlt // ignore: cast_nullable_to_non_nullable
as String?,flagColor: freezed == flagColor ? _self.flagColor : flagColor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Currency {

 String get code; String get name; String? get symbol;
/// Create a copy of Currency
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrencyCopyWith<Currency> get copyWith => _$CurrencyCopyWithImpl<Currency>(this as Currency, _$identity);

  /// Serializes this Currency to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Currency&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.symbol, symbol) || other.symbol == symbol));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,name,symbol);

@override
String toString() {
  return 'Currency(code: $code, name: $name, symbol: $symbol)';
}


}

/// @nodoc
abstract mixin class $CurrencyCopyWith<$Res>  {
  factory $CurrencyCopyWith(Currency value, $Res Function(Currency) _then) = _$CurrencyCopyWithImpl;
@useResult
$Res call({
 String code, String name, String? symbol
});




}
/// @nodoc
class _$CurrencyCopyWithImpl<$Res>
    implements $CurrencyCopyWith<$Res> {
  _$CurrencyCopyWithImpl(this._self, this._then);

  final Currency _self;
  final $Res Function(Currency) _then;

/// Create a copy of Currency
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? name = null,Object? symbol = freezed,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,symbol: freezed == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Currency].
extension CurrencyPatterns on Currency {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Currency value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Currency() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Currency value)  $default,){
final _that = this;
switch (_that) {
case _Currency():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Currency value)?  $default,){
final _that = this;
switch (_that) {
case _Currency() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String name,  String? symbol)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Currency() when $default != null:
return $default(_that.code,_that.name,_that.symbol);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String name,  String? symbol)  $default,) {final _that = this;
switch (_that) {
case _Currency():
return $default(_that.code,_that.name,_that.symbol);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String name,  String? symbol)?  $default,) {final _that = this;
switch (_that) {
case _Currency() when $default != null:
return $default(_that.code,_that.name,_that.symbol);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Currency implements Currency {
  const _Currency({required this.code, required this.name, this.symbol});
  factory _Currency.fromJson(Map<String, dynamic> json) => _$CurrencyFromJson(json);

@override final  String code;
@override final  String name;
@override final  String? symbol;

/// Create a copy of Currency
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurrencyCopyWith<_Currency> get copyWith => __$CurrencyCopyWithImpl<_Currency>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CurrencyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Currency&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.symbol, symbol) || other.symbol == symbol));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,name,symbol);

@override
String toString() {
  return 'Currency(code: $code, name: $name, symbol: $symbol)';
}


}

/// @nodoc
abstract mixin class _$CurrencyCopyWith<$Res> implements $CurrencyCopyWith<$Res> {
  factory _$CurrencyCopyWith(_Currency value, $Res Function(_Currency) _then) = __$CurrencyCopyWithImpl;
@override @useResult
$Res call({
 String code, String name, String? symbol
});




}
/// @nodoc
class __$CurrencyCopyWithImpl<$Res>
    implements _$CurrencyCopyWith<$Res> {
  __$CurrencyCopyWithImpl(this._self, this._then);

  final _Currency _self;
  final $Res Function(_Currency) _then;

/// Create a copy of Currency
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? name = null,Object? symbol = freezed,}) {
  return _then(_Currency(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,symbol: freezed == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
