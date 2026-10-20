// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CountriesTable extends Countries
    with TableInfo<$CountriesTable, CountryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CountriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _alpha2Meta = const VerificationMeta('alpha2');
  @override
  late final GeneratedColumn<String> alpha2 = GeneratedColumn<String>(
    'alpha2',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameOfficialEnMeta = const VerificationMeta(
    'nameOfficialEn',
  );
  @override
  late final GeneratedColumn<String> nameOfficialEn = GeneratedColumn<String>(
    'name_official_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameArMeta = const VerificationMeta('nameAr');
  @override
  late final GeneratedColumn<String> nameAr = GeneratedColumn<String>(
    'name_ar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameOfficialArMeta = const VerificationMeta(
    'nameOfficialAr',
  );
  @override
  late final GeneratedColumn<String> nameOfficialAr = GeneratedColumn<String>(
    'name_official_ar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subregionMeta = const VerificationMeta(
    'subregion',
  );
  @override
  late final GeneratedColumn<String> subregion = GeneratedColumn<String>(
    'subregion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capitalMeta = const VerificationMeta(
    'capital',
  );
  @override
  late final GeneratedColumn<String> capital = GeneratedColumn<String>(
    'capital',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _populationMeta = const VerificationMeta(
    'population',
  );
  @override
  late final GeneratedColumn<int> population = GeneratedColumn<int>(
    'population',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaKm2Meta = const VerificationMeta(
    'areaKm2',
  );
  @override
  late final GeneratedColumn<double> areaKm2 = GeneratedColumn<double>(
    'area_km2',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> languages =
      GeneratedColumn<String>(
        'languages',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($CountriesTable.$converterlanguages);
  @override
  late final GeneratedColumnWithTypeConverter<List<Currency>, String>
  currencies = GeneratedColumn<String>(
    'currencies',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<Currency>>($CountriesTable.$convertercurrencies);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> borders =
      GeneratedColumn<String>(
        'borders',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($CountriesTable.$converterborders);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> timezones =
      GeneratedColumn<String>(
        'timezones',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($CountriesTable.$convertertimezones);
  static const VerificationMeta _mapsUrlMeta = const VerificationMeta(
    'mapsUrl',
  );
  @override
  late final GeneratedColumn<String> mapsUrl = GeneratedColumn<String>(
    'maps_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _flagAltMeta = const VerificationMeta(
    'flagAlt',
  );
  @override
  late final GeneratedColumn<String> flagAlt = GeneratedColumn<String>(
    'flag_alt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _flagColorMeta = const VerificationMeta(
    'flagColor',
  );
  @override
  late final GeneratedColumn<String> flagColor = GeneratedColumn<String>(
    'flag_color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<int> fetchedAt = GeneratedColumn<int>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    code,
    alpha2,
    nameEn,
    nameOfficialEn,
    nameAr,
    nameOfficialAr,
    region,
    subregion,
    capital,
    population,
    areaKm2,
    languages,
    currencies,
    borders,
    timezones,
    mapsUrl,
    flagAlt,
    flagColor,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'countries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CountryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('alpha2')) {
      context.handle(
        _alpha2Meta,
        alpha2.isAcceptableOrUnknown(data['alpha2']!, _alpha2Meta),
      );
    } else if (isInserting) {
      context.missing(_alpha2Meta);
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('name_official_en')) {
      context.handle(
        _nameOfficialEnMeta,
        nameOfficialEn.isAcceptableOrUnknown(
          data['name_official_en']!,
          _nameOfficialEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nameOfficialEnMeta);
    }
    if (data.containsKey('name_ar')) {
      context.handle(
        _nameArMeta,
        nameAr.isAcceptableOrUnknown(data['name_ar']!, _nameArMeta),
      );
    }
    if (data.containsKey('name_official_ar')) {
      context.handle(
        _nameOfficialArMeta,
        nameOfficialAr.isAcceptableOrUnknown(
          data['name_official_ar']!,
          _nameOfficialArMeta,
        ),
      );
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    } else if (isInserting) {
      context.missing(_regionMeta);
    }
    if (data.containsKey('subregion')) {
      context.handle(
        _subregionMeta,
        subregion.isAcceptableOrUnknown(data['subregion']!, _subregionMeta),
      );
    }
    if (data.containsKey('capital')) {
      context.handle(
        _capitalMeta,
        capital.isAcceptableOrUnknown(data['capital']!, _capitalMeta),
      );
    }
    if (data.containsKey('population')) {
      context.handle(
        _populationMeta,
        population.isAcceptableOrUnknown(data['population']!, _populationMeta),
      );
    } else if (isInserting) {
      context.missing(_populationMeta);
    }
    if (data.containsKey('area_km2')) {
      context.handle(
        _areaKm2Meta,
        areaKm2.isAcceptableOrUnknown(data['area_km2']!, _areaKm2Meta),
      );
    }
    if (data.containsKey('maps_url')) {
      context.handle(
        _mapsUrlMeta,
        mapsUrl.isAcceptableOrUnknown(data['maps_url']!, _mapsUrlMeta),
      );
    }
    if (data.containsKey('flag_alt')) {
      context.handle(
        _flagAltMeta,
        flagAlt.isAcceptableOrUnknown(data['flag_alt']!, _flagAltMeta),
      );
    }
    if (data.containsKey('flag_color')) {
      context.handle(
        _flagColorMeta,
        flagColor.isAcceptableOrUnknown(data['flag_color']!, _flagColorMeta),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  CountryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CountryRow(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      alpha2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alpha2'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      )!,
      nameOfficialEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_official_en'],
      )!,
      nameAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_ar'],
      ),
      nameOfficialAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_official_ar'],
      ),
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      )!,
      subregion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subregion'],
      ),
      capital: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}capital'],
      ),
      population: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}population'],
      )!,
      areaKm2: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}area_km2'],
      ),
      languages: $CountriesTable.$converterlanguages.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}languages'],
        )!,
      ),
      currencies: $CountriesTable.$convertercurrencies.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}currencies'],
        )!,
      ),
      borders: $CountriesTable.$converterborders.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}borders'],
        )!,
      ),
      timezones: $CountriesTable.$convertertimezones.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}timezones'],
        )!,
      ),
      mapsUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}maps_url'],
      ),
      flagAlt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flag_alt'],
      ),
      flagColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flag_color'],
      ),
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $CountriesTable createAlias(String alias) {
    return $CountriesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterlanguages =
      const StringListConverter();
  static TypeConverter<List<Currency>, String> $convertercurrencies =
      const CurrencyListConverter();
  static TypeConverter<List<String>, String> $converterborders =
      const StringListConverter();
  static TypeConverter<List<String>, String> $convertertimezones =
      const StringListConverter();
}

class CountryRow extends DataClass implements Insertable<CountryRow> {
  final String code;
  final String alpha2;
  final String nameEn;
  final String nameOfficialEn;
  final String? nameAr;
  final String? nameOfficialAr;
  final String region;
  final String? subregion;
  final String? capital;
  final int population;
  final double? areaKm2;
  final List<String> languages;
  final List<Currency> currencies;
  final List<String> borders;
  final List<String> timezones;
  final String? mapsUrl;
  final String? flagAlt;
  final String? flagColor;

  /// Epoch milliseconds: snapshot time or last refresh.
  final int fetchedAt;
  const CountryRow({
    required this.code,
    required this.alpha2,
    required this.nameEn,
    required this.nameOfficialEn,
    this.nameAr,
    this.nameOfficialAr,
    required this.region,
    this.subregion,
    this.capital,
    required this.population,
    this.areaKm2,
    required this.languages,
    required this.currencies,
    required this.borders,
    required this.timezones,
    this.mapsUrl,
    this.flagAlt,
    this.flagColor,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['alpha2'] = Variable<String>(alpha2);
    map['name_en'] = Variable<String>(nameEn);
    map['name_official_en'] = Variable<String>(nameOfficialEn);
    if (!nullToAbsent || nameAr != null) {
      map['name_ar'] = Variable<String>(nameAr);
    }
    if (!nullToAbsent || nameOfficialAr != null) {
      map['name_official_ar'] = Variable<String>(nameOfficialAr);
    }
    map['region'] = Variable<String>(region);
    if (!nullToAbsent || subregion != null) {
      map['subregion'] = Variable<String>(subregion);
    }
    if (!nullToAbsent || capital != null) {
      map['capital'] = Variable<String>(capital);
    }
    map['population'] = Variable<int>(population);
    if (!nullToAbsent || areaKm2 != null) {
      map['area_km2'] = Variable<double>(areaKm2);
    }
    {
      map['languages'] = Variable<String>(
        $CountriesTable.$converterlanguages.toSql(languages),
      );
    }
    {
      map['currencies'] = Variable<String>(
        $CountriesTable.$convertercurrencies.toSql(currencies),
      );
    }
    {
      map['borders'] = Variable<String>(
        $CountriesTable.$converterborders.toSql(borders),
      );
    }
    {
      map['timezones'] = Variable<String>(
        $CountriesTable.$convertertimezones.toSql(timezones),
      );
    }
    if (!nullToAbsent || mapsUrl != null) {
      map['maps_url'] = Variable<String>(mapsUrl);
    }
    if (!nullToAbsent || flagAlt != null) {
      map['flag_alt'] = Variable<String>(flagAlt);
    }
    if (!nullToAbsent || flagColor != null) {
      map['flag_color'] = Variable<String>(flagColor);
    }
    map['fetched_at'] = Variable<int>(fetchedAt);
    return map;
  }

  CountriesCompanion toCompanion(bool nullToAbsent) {
    return CountriesCompanion(
      code: Value(code),
      alpha2: Value(alpha2),
      nameEn: Value(nameEn),
      nameOfficialEn: Value(nameOfficialEn),
      nameAr: nameAr == null && nullToAbsent
          ? const Value.absent()
          : Value(nameAr),
      nameOfficialAr: nameOfficialAr == null && nullToAbsent
          ? const Value.absent()
          : Value(nameOfficialAr),
      region: Value(region),
      subregion: subregion == null && nullToAbsent
          ? const Value.absent()
          : Value(subregion),
      capital: capital == null && nullToAbsent
          ? const Value.absent()
          : Value(capital),
      population: Value(population),
      areaKm2: areaKm2 == null && nullToAbsent
          ? const Value.absent()
          : Value(areaKm2),
      languages: Value(languages),
      currencies: Value(currencies),
      borders: Value(borders),
      timezones: Value(timezones),
      mapsUrl: mapsUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(mapsUrl),
      flagAlt: flagAlt == null && nullToAbsent
          ? const Value.absent()
          : Value(flagAlt),
      flagColor: flagColor == null && nullToAbsent
          ? const Value.absent()
          : Value(flagColor),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory CountryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CountryRow(
      code: serializer.fromJson<String>(json['code']),
      alpha2: serializer.fromJson<String>(json['alpha2']),
      nameEn: serializer.fromJson<String>(json['nameEn']),
      nameOfficialEn: serializer.fromJson<String>(json['nameOfficialEn']),
      nameAr: serializer.fromJson<String?>(json['nameAr']),
      nameOfficialAr: serializer.fromJson<String?>(json['nameOfficialAr']),
      region: serializer.fromJson<String>(json['region']),
      subregion: serializer.fromJson<String?>(json['subregion']),
      capital: serializer.fromJson<String?>(json['capital']),
      population: serializer.fromJson<int>(json['population']),
      areaKm2: serializer.fromJson<double?>(json['areaKm2']),
      languages: serializer.fromJson<List<String>>(json['languages']),
      currencies: serializer.fromJson<List<Currency>>(json['currencies']),
      borders: serializer.fromJson<List<String>>(json['borders']),
      timezones: serializer.fromJson<List<String>>(json['timezones']),
      mapsUrl: serializer.fromJson<String?>(json['mapsUrl']),
      flagAlt: serializer.fromJson<String?>(json['flagAlt']),
      flagColor: serializer.fromJson<String?>(json['flagColor']),
      fetchedAt: serializer.fromJson<int>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'alpha2': serializer.toJson<String>(alpha2),
      'nameEn': serializer.toJson<String>(nameEn),
      'nameOfficialEn': serializer.toJson<String>(nameOfficialEn),
      'nameAr': serializer.toJson<String?>(nameAr),
      'nameOfficialAr': serializer.toJson<String?>(nameOfficialAr),
      'region': serializer.toJson<String>(region),
      'subregion': serializer.toJson<String?>(subregion),
      'capital': serializer.toJson<String?>(capital),
      'population': serializer.toJson<int>(population),
      'areaKm2': serializer.toJson<double?>(areaKm2),
      'languages': serializer.toJson<List<String>>(languages),
      'currencies': serializer.toJson<List<Currency>>(currencies),
      'borders': serializer.toJson<List<String>>(borders),
      'timezones': serializer.toJson<List<String>>(timezones),
      'mapsUrl': serializer.toJson<String?>(mapsUrl),
      'flagAlt': serializer.toJson<String?>(flagAlt),
      'flagColor': serializer.toJson<String?>(flagColor),
      'fetchedAt': serializer.toJson<int>(fetchedAt),
    };
  }

  CountryRow copyWith({
    String? code,
    String? alpha2,
    String? nameEn,
    String? nameOfficialEn,
    Value<String?> nameAr = const Value.absent(),
    Value<String?> nameOfficialAr = const Value.absent(),
    String? region,
    Value<String?> subregion = const Value.absent(),
    Value<String?> capital = const Value.absent(),
    int? population,
    Value<double?> areaKm2 = const Value.absent(),
    List<String>? languages,
    List<Currency>? currencies,
    List<String>? borders,
    List<String>? timezones,
    Value<String?> mapsUrl = const Value.absent(),
    Value<String?> flagAlt = const Value.absent(),
    Value<String?> flagColor = const Value.absent(),
    int? fetchedAt,
  }) => CountryRow(
    code: code ?? this.code,
    alpha2: alpha2 ?? this.alpha2,
    nameEn: nameEn ?? this.nameEn,
    nameOfficialEn: nameOfficialEn ?? this.nameOfficialEn,
    nameAr: nameAr.present ? nameAr.value : this.nameAr,
    nameOfficialAr: nameOfficialAr.present
        ? nameOfficialAr.value
        : this.nameOfficialAr,
    region: region ?? this.region,
    subregion: subregion.present ? subregion.value : this.subregion,
    capital: capital.present ? capital.value : this.capital,
    population: population ?? this.population,
    areaKm2: areaKm2.present ? areaKm2.value : this.areaKm2,
    languages: languages ?? this.languages,
    currencies: currencies ?? this.currencies,
    borders: borders ?? this.borders,
    timezones: timezones ?? this.timezones,
    mapsUrl: mapsUrl.present ? mapsUrl.value : this.mapsUrl,
    flagAlt: flagAlt.present ? flagAlt.value : this.flagAlt,
    flagColor: flagColor.present ? flagColor.value : this.flagColor,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  CountryRow copyWithCompanion(CountriesCompanion data) {
    return CountryRow(
      code: data.code.present ? data.code.value : this.code,
      alpha2: data.alpha2.present ? data.alpha2.value : this.alpha2,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      nameOfficialEn: data.nameOfficialEn.present
          ? data.nameOfficialEn.value
          : this.nameOfficialEn,
      nameAr: data.nameAr.present ? data.nameAr.value : this.nameAr,
      nameOfficialAr: data.nameOfficialAr.present
          ? data.nameOfficialAr.value
          : this.nameOfficialAr,
      region: data.region.present ? data.region.value : this.region,
      subregion: data.subregion.present ? data.subregion.value : this.subregion,
      capital: data.capital.present ? data.capital.value : this.capital,
      population: data.population.present
          ? data.population.value
          : this.population,
      areaKm2: data.areaKm2.present ? data.areaKm2.value : this.areaKm2,
      languages: data.languages.present ? data.languages.value : this.languages,
      currencies: data.currencies.present
          ? data.currencies.value
          : this.currencies,
      borders: data.borders.present ? data.borders.value : this.borders,
      timezones: data.timezones.present ? data.timezones.value : this.timezones,
      mapsUrl: data.mapsUrl.present ? data.mapsUrl.value : this.mapsUrl,
      flagAlt: data.flagAlt.present ? data.flagAlt.value : this.flagAlt,
      flagColor: data.flagColor.present ? data.flagColor.value : this.flagColor,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CountryRow(')
          ..write('code: $code, ')
          ..write('alpha2: $alpha2, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameOfficialEn: $nameOfficialEn, ')
          ..write('nameAr: $nameAr, ')
          ..write('nameOfficialAr: $nameOfficialAr, ')
          ..write('region: $region, ')
          ..write('subregion: $subregion, ')
          ..write('capital: $capital, ')
          ..write('population: $population, ')
          ..write('areaKm2: $areaKm2, ')
          ..write('languages: $languages, ')
          ..write('currencies: $currencies, ')
          ..write('borders: $borders, ')
          ..write('timezones: $timezones, ')
          ..write('mapsUrl: $mapsUrl, ')
          ..write('flagAlt: $flagAlt, ')
          ..write('flagColor: $flagColor, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    code,
    alpha2,
    nameEn,
    nameOfficialEn,
    nameAr,
    nameOfficialAr,
    region,
    subregion,
    capital,
    population,
    areaKm2,
    languages,
    currencies,
    borders,
    timezones,
    mapsUrl,
    flagAlt,
    flagColor,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CountryRow &&
          other.code == this.code &&
          other.alpha2 == this.alpha2 &&
          other.nameEn == this.nameEn &&
          other.nameOfficialEn == this.nameOfficialEn &&
          other.nameAr == this.nameAr &&
          other.nameOfficialAr == this.nameOfficialAr &&
          other.region == this.region &&
          other.subregion == this.subregion &&
          other.capital == this.capital &&
          other.population == this.population &&
          other.areaKm2 == this.areaKm2 &&
          other.languages == this.languages &&
          other.currencies == this.currencies &&
          other.borders == this.borders &&
          other.timezones == this.timezones &&
          other.mapsUrl == this.mapsUrl &&
          other.flagAlt == this.flagAlt &&
          other.flagColor == this.flagColor &&
          other.fetchedAt == this.fetchedAt);
}

class CountriesCompanion extends UpdateCompanion<CountryRow> {
  final Value<String> code;
  final Value<String> alpha2;
  final Value<String> nameEn;
  final Value<String> nameOfficialEn;
  final Value<String?> nameAr;
  final Value<String?> nameOfficialAr;
  final Value<String> region;
  final Value<String?> subregion;
  final Value<String?> capital;
  final Value<int> population;
  final Value<double?> areaKm2;
  final Value<List<String>> languages;
  final Value<List<Currency>> currencies;
  final Value<List<String>> borders;
  final Value<List<String>> timezones;
  final Value<String?> mapsUrl;
  final Value<String?> flagAlt;
  final Value<String?> flagColor;
  final Value<int> fetchedAt;
  final Value<int> rowid;
  const CountriesCompanion({
    this.code = const Value.absent(),
    this.alpha2 = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.nameOfficialEn = const Value.absent(),
    this.nameAr = const Value.absent(),
    this.nameOfficialAr = const Value.absent(),
    this.region = const Value.absent(),
    this.subregion = const Value.absent(),
    this.capital = const Value.absent(),
    this.population = const Value.absent(),
    this.areaKm2 = const Value.absent(),
    this.languages = const Value.absent(),
    this.currencies = const Value.absent(),
    this.borders = const Value.absent(),
    this.timezones = const Value.absent(),
    this.mapsUrl = const Value.absent(),
    this.flagAlt = const Value.absent(),
    this.flagColor = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CountriesCompanion.insert({
    required String code,
    required String alpha2,
    required String nameEn,
    required String nameOfficialEn,
    this.nameAr = const Value.absent(),
    this.nameOfficialAr = const Value.absent(),
    required String region,
    this.subregion = const Value.absent(),
    this.capital = const Value.absent(),
    required int population,
    this.areaKm2 = const Value.absent(),
    required List<String> languages,
    required List<Currency> currencies,
    required List<String> borders,
    required List<String> timezones,
    this.mapsUrl = const Value.absent(),
    this.flagAlt = const Value.absent(),
    this.flagColor = const Value.absent(),
    required int fetchedAt,
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       alpha2 = Value(alpha2),
       nameEn = Value(nameEn),
       nameOfficialEn = Value(nameOfficialEn),
       region = Value(region),
       population = Value(population),
       languages = Value(languages),
       currencies = Value(currencies),
       borders = Value(borders),
       timezones = Value(timezones),
       fetchedAt = Value(fetchedAt);
  static Insertable<CountryRow> custom({
    Expression<String>? code,
    Expression<String>? alpha2,
    Expression<String>? nameEn,
    Expression<String>? nameOfficialEn,
    Expression<String>? nameAr,
    Expression<String>? nameOfficialAr,
    Expression<String>? region,
    Expression<String>? subregion,
    Expression<String>? capital,
    Expression<int>? population,
    Expression<double>? areaKm2,
    Expression<String>? languages,
    Expression<String>? currencies,
    Expression<String>? borders,
    Expression<String>? timezones,
    Expression<String>? mapsUrl,
    Expression<String>? flagAlt,
    Expression<String>? flagColor,
    Expression<int>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (alpha2 != null) 'alpha2': alpha2,
      if (nameEn != null) 'name_en': nameEn,
      if (nameOfficialEn != null) 'name_official_en': nameOfficialEn,
      if (nameAr != null) 'name_ar': nameAr,
      if (nameOfficialAr != null) 'name_official_ar': nameOfficialAr,
      if (region != null) 'region': region,
      if (subregion != null) 'subregion': subregion,
      if (capital != null) 'capital': capital,
      if (population != null) 'population': population,
      if (areaKm2 != null) 'area_km2': areaKm2,
      if (languages != null) 'languages': languages,
      if (currencies != null) 'currencies': currencies,
      if (borders != null) 'borders': borders,
      if (timezones != null) 'timezones': timezones,
      if (mapsUrl != null) 'maps_url': mapsUrl,
      if (flagAlt != null) 'flag_alt': flagAlt,
      if (flagColor != null) 'flag_color': flagColor,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CountriesCompanion copyWith({
    Value<String>? code,
    Value<String>? alpha2,
    Value<String>? nameEn,
    Value<String>? nameOfficialEn,
    Value<String?>? nameAr,
    Value<String?>? nameOfficialAr,
    Value<String>? region,
    Value<String?>? subregion,
    Value<String?>? capital,
    Value<int>? population,
    Value<double?>? areaKm2,
    Value<List<String>>? languages,
    Value<List<Currency>>? currencies,
    Value<List<String>>? borders,
    Value<List<String>>? timezones,
    Value<String?>? mapsUrl,
    Value<String?>? flagAlt,
    Value<String?>? flagColor,
    Value<int>? fetchedAt,
    Value<int>? rowid,
  }) {
    return CountriesCompanion(
      code: code ?? this.code,
      alpha2: alpha2 ?? this.alpha2,
      nameEn: nameEn ?? this.nameEn,
      nameOfficialEn: nameOfficialEn ?? this.nameOfficialEn,
      nameAr: nameAr ?? this.nameAr,
      nameOfficialAr: nameOfficialAr ?? this.nameOfficialAr,
      region: region ?? this.region,
      subregion: subregion ?? this.subregion,
      capital: capital ?? this.capital,
      population: population ?? this.population,
      areaKm2: areaKm2 ?? this.areaKm2,
      languages: languages ?? this.languages,
      currencies: currencies ?? this.currencies,
      borders: borders ?? this.borders,
      timezones: timezones ?? this.timezones,
      mapsUrl: mapsUrl ?? this.mapsUrl,
      flagAlt: flagAlt ?? this.flagAlt,
      flagColor: flagColor ?? this.flagColor,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (alpha2.present) {
      map['alpha2'] = Variable<String>(alpha2.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (nameOfficialEn.present) {
      map['name_official_en'] = Variable<String>(nameOfficialEn.value);
    }
    if (nameAr.present) {
      map['name_ar'] = Variable<String>(nameAr.value);
    }
    if (nameOfficialAr.present) {
      map['name_official_ar'] = Variable<String>(nameOfficialAr.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (subregion.present) {
      map['subregion'] = Variable<String>(subregion.value);
    }
    if (capital.present) {
      map['capital'] = Variable<String>(capital.value);
    }
    if (population.present) {
      map['population'] = Variable<int>(population.value);
    }
    if (areaKm2.present) {
      map['area_km2'] = Variable<double>(areaKm2.value);
    }
    if (languages.present) {
      map['languages'] = Variable<String>(
        $CountriesTable.$converterlanguages.toSql(languages.value),
      );
    }
    if (currencies.present) {
      map['currencies'] = Variable<String>(
        $CountriesTable.$convertercurrencies.toSql(currencies.value),
      );
    }
    if (borders.present) {
      map['borders'] = Variable<String>(
        $CountriesTable.$converterborders.toSql(borders.value),
      );
    }
    if (timezones.present) {
      map['timezones'] = Variable<String>(
        $CountriesTable.$convertertimezones.toSql(timezones.value),
      );
    }
    if (mapsUrl.present) {
      map['maps_url'] = Variable<String>(mapsUrl.value);
    }
    if (flagAlt.present) {
      map['flag_alt'] = Variable<String>(flagAlt.value);
    }
    if (flagColor.present) {
      map['flag_color'] = Variable<String>(flagColor.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CountriesCompanion(')
          ..write('code: $code, ')
          ..write('alpha2: $alpha2, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameOfficialEn: $nameOfficialEn, ')
          ..write('nameAr: $nameAr, ')
          ..write('nameOfficialAr: $nameOfficialAr, ')
          ..write('region: $region, ')
          ..write('subregion: $subregion, ')
          ..write('capital: $capital, ')
          ..write('population: $population, ')
          ..write('areaKm2: $areaKm2, ')
          ..write('languages: $languages, ')
          ..write('currencies: $currencies, ')
          ..write('borders: $borders, ')
          ..write('timezones: $timezones, ')
          ..write('mapsUrl: $mapsUrl, ')
          ..write('flagAlt: $flagAlt, ')
          ..write('flagColor: $flagColor, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TravelEntriesTable extends TravelEntries
    with TableInfo<$TravelEntriesTable, TravelEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TravelEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _countryCodeMeta = const VerificationMeta(
    'countryCode',
  );
  @override
  late final GeneratedColumn<String> countryCode = GeneratedColumn<String>(
    'country_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TravelStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TravelStatus>($TravelEntriesTable.$converterstatus);
  static const VerificationMeta _visitedOnMeta = const VerificationMeta(
    'visitedOn',
  );
  @override
  late final GeneratedColumn<String> visitedOn = GeneratedColumn<String>(
    'visited_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WishlistPriority?, String>
  priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<WishlistPriority?>($TravelEntriesTable.$converterpriorityn);
  static const VerificationMeta _targetYearMeta = const VerificationMeta(
    'targetYear',
  );
  @override
  late final GeneratedColumn<int> targetYear = GeneratedColumn<int>(
    'target_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    countryCode,
    status,
    visitedOn,
    rating,
    priority,
    targetYear,
    notes,
    createdAt,
    updatedAt,
    isDeleted,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'travel_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<TravelEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('country_code')) {
      context.handle(
        _countryCodeMeta,
        countryCode.isAcceptableOrUnknown(
          data['country_code']!,
          _countryCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_countryCodeMeta);
    }
    if (data.containsKey('visited_on')) {
      context.handle(
        _visitedOnMeta,
        visitedOn.isAcceptableOrUnknown(data['visited_on']!, _visitedOnMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('target_year')) {
      context.handle(
        _targetYearMeta,
        targetYear.isAcceptableOrUnknown(data['target_year']!, _targetYearMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {countryCode};
  @override
  TravelEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TravelEntryRow(
      countryCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country_code'],
      )!,
      status: $TravelEntriesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      visitedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visited_on'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      ),
      priority: $TravelEntriesTable.$converterpriorityn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}priority'],
        ),
      ),
      targetYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_year'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $TravelEntriesTable createAlias(String alias) {
    return $TravelEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TravelStatus, String, String> $converterstatus =
      const EnumNameConverter<TravelStatus>(TravelStatus.values);
  static JsonTypeConverter2<WishlistPriority, String, String>
  $converterpriority = const EnumNameConverter<WishlistPriority>(
    WishlistPriority.values,
  );
  static JsonTypeConverter2<WishlistPriority?, String?, String?>
  $converterpriorityn = JsonTypeConverter2.asNullable($converterpriority);
}

class TravelEntryRow extends DataClass implements Insertable<TravelEntryRow> {
  final String countryCode;
  final TravelStatus status;

  /// ISO date (YYYY-MM-DD); visited only.
  final String? visitedOn;
  final int? rating;
  final WishlistPriority? priority;
  final int? targetYear;
  final String notes;

  /// Epoch milliseconds.
  final int createdAt;

  /// Epoch milliseconds; set on every change and used by the merge.
  final int updatedAt;

  /// Soft delete, so deletions can sync. Screens never show deleted rows.
  final bool isDeleted;

  /// Null or older than [updatedAt] means the entry needs uploading.
  final int? syncedAt;
  const TravelEntryRow({
    required this.countryCode,
    required this.status,
    this.visitedOn,
    this.rating,
    this.priority,
    this.targetYear,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['country_code'] = Variable<String>(countryCode);
    {
      map['status'] = Variable<String>(
        $TravelEntriesTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || visitedOn != null) {
      map['visited_on'] = Variable<String>(visitedOn);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    if (!nullToAbsent || priority != null) {
      map['priority'] = Variable<String>(
        $TravelEntriesTable.$converterpriorityn.toSql(priority),
      );
    }
    if (!nullToAbsent || targetYear != null) {
      map['target_year'] = Variable<int>(targetYear);
    }
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<int>(syncedAt);
    }
    return map;
  }

  TravelEntriesCompanion toCompanion(bool nullToAbsent) {
    return TravelEntriesCompanion(
      countryCode: Value(countryCode),
      status: Value(status),
      visitedOn: visitedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(visitedOn),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      priority: priority == null && nullToAbsent
          ? const Value.absent()
          : Value(priority),
      targetYear: targetYear == null && nullToAbsent
          ? const Value.absent()
          : Value(targetYear),
      notes: Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory TravelEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TravelEntryRow(
      countryCode: serializer.fromJson<String>(json['countryCode']),
      status: $TravelEntriesTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      visitedOn: serializer.fromJson<String?>(json['visitedOn']),
      rating: serializer.fromJson<int?>(json['rating']),
      priority: $TravelEntriesTable.$converterpriorityn.fromJson(
        serializer.fromJson<String?>(json['priority']),
      ),
      targetYear: serializer.fromJson<int?>(json['targetYear']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      syncedAt: serializer.fromJson<int?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'countryCode': serializer.toJson<String>(countryCode),
      'status': serializer.toJson<String>(
        $TravelEntriesTable.$converterstatus.toJson(status),
      ),
      'visitedOn': serializer.toJson<String?>(visitedOn),
      'rating': serializer.toJson<int?>(rating),
      'priority': serializer.toJson<String?>(
        $TravelEntriesTable.$converterpriorityn.toJson(priority),
      ),
      'targetYear': serializer.toJson<int?>(targetYear),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'syncedAt': serializer.toJson<int?>(syncedAt),
    };
  }

  TravelEntryRow copyWith({
    String? countryCode,
    TravelStatus? status,
    Value<String?> visitedOn = const Value.absent(),
    Value<int?> rating = const Value.absent(),
    Value<WishlistPriority?> priority = const Value.absent(),
    Value<int?> targetYear = const Value.absent(),
    String? notes,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    Value<int?> syncedAt = const Value.absent(),
  }) => TravelEntryRow(
    countryCode: countryCode ?? this.countryCode,
    status: status ?? this.status,
    visitedOn: visitedOn.present ? visitedOn.value : this.visitedOn,
    rating: rating.present ? rating.value : this.rating,
    priority: priority.present ? priority.value : this.priority,
    targetYear: targetYear.present ? targetYear.value : this.targetYear,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  TravelEntryRow copyWithCompanion(TravelEntriesCompanion data) {
    return TravelEntryRow(
      countryCode: data.countryCode.present
          ? data.countryCode.value
          : this.countryCode,
      status: data.status.present ? data.status.value : this.status,
      visitedOn: data.visitedOn.present ? data.visitedOn.value : this.visitedOn,
      rating: data.rating.present ? data.rating.value : this.rating,
      priority: data.priority.present ? data.priority.value : this.priority,
      targetYear: data.targetYear.present
          ? data.targetYear.value
          : this.targetYear,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TravelEntryRow(')
          ..write('countryCode: $countryCode, ')
          ..write('status: $status, ')
          ..write('visitedOn: $visitedOn, ')
          ..write('rating: $rating, ')
          ..write('priority: $priority, ')
          ..write('targetYear: $targetYear, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    countryCode,
    status,
    visitedOn,
    rating,
    priority,
    targetYear,
    notes,
    createdAt,
    updatedAt,
    isDeleted,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TravelEntryRow &&
          other.countryCode == this.countryCode &&
          other.status == this.status &&
          other.visitedOn == this.visitedOn &&
          other.rating == this.rating &&
          other.priority == this.priority &&
          other.targetYear == this.targetYear &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.syncedAt == this.syncedAt);
}

class TravelEntriesCompanion extends UpdateCompanion<TravelEntryRow> {
  final Value<String> countryCode;
  final Value<TravelStatus> status;
  final Value<String?> visitedOn;
  final Value<int?> rating;
  final Value<WishlistPriority?> priority;
  final Value<int?> targetYear;
  final Value<String> notes;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isDeleted;
  final Value<int?> syncedAt;
  final Value<int> rowid;
  const TravelEntriesCompanion({
    this.countryCode = const Value.absent(),
    this.status = const Value.absent(),
    this.visitedOn = const Value.absent(),
    this.rating = const Value.absent(),
    this.priority = const Value.absent(),
    this.targetYear = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TravelEntriesCompanion.insert({
    required String countryCode,
    required TravelStatus status,
    this.visitedOn = const Value.absent(),
    this.rating = const Value.absent(),
    this.priority = const Value.absent(),
    this.targetYear = const Value.absent(),
    this.notes = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.isDeleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : countryCode = Value(countryCode),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TravelEntryRow> custom({
    Expression<String>? countryCode,
    Expression<String>? status,
    Expression<String>? visitedOn,
    Expression<int>? rating,
    Expression<String>? priority,
    Expression<int>? targetYear,
    Expression<String>? notes,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (countryCode != null) 'country_code': countryCode,
      if (status != null) 'status': status,
      if (visitedOn != null) 'visited_on': visitedOn,
      if (rating != null) 'rating': rating,
      if (priority != null) 'priority': priority,
      if (targetYear != null) 'target_year': targetYear,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TravelEntriesCompanion copyWith({
    Value<String>? countryCode,
    Value<TravelStatus>? status,
    Value<String?>? visitedOn,
    Value<int?>? rating,
    Value<WishlistPriority?>? priority,
    Value<int?>? targetYear,
    Value<String>? notes,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isDeleted,
    Value<int?>? syncedAt,
    Value<int>? rowid,
  }) {
    return TravelEntriesCompanion(
      countryCode: countryCode ?? this.countryCode,
      status: status ?? this.status,
      visitedOn: visitedOn ?? this.visitedOn,
      rating: rating ?? this.rating,
      priority: priority ?? this.priority,
      targetYear: targetYear ?? this.targetYear,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (countryCode.present) {
      map['country_code'] = Variable<String>(countryCode.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $TravelEntriesTable.$converterstatus.toSql(status.value),
      );
    }
    if (visitedOn.present) {
      map['visited_on'] = Variable<String>(visitedOn.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(
        $TravelEntriesTable.$converterpriorityn.toSql(priority.value),
      );
    }
    if (targetYear.present) {
      map['target_year'] = Variable<int>(targetYear.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<int>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TravelEntriesCompanion(')
          ..write('countryCode: $countryCode, ')
          ..write('status: $status, ')
          ..write('visitedOn: $visitedOn, ')
          ..write('rating: $rating, ')
          ..write('priority: $priority, ')
          ..write('targetYear: $targetYear, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CountriesTable countries = $CountriesTable(this);
  late final $TravelEntriesTable travelEntries = $TravelEntriesTable(this);
  late final Index countriesRegion = Index(
    'countries_region',
    'CREATE INDEX countries_region ON countries (region)',
  );
  late final Index travelEntriesStatus = Index(
    'travel_entries_status',
    'CREATE INDEX travel_entries_status ON travel_entries (status)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    countries,
    travelEntries,
    countriesRegion,
    travelEntriesStatus,
  ];
}

typedef $$CountriesTableCreateCompanionBuilder =
    CountriesCompanion Function({
      required String code,
      required String alpha2,
      required String nameEn,
      required String nameOfficialEn,
      Value<String?> nameAr,
      Value<String?> nameOfficialAr,
      required String region,
      Value<String?> subregion,
      Value<String?> capital,
      required int population,
      Value<double?> areaKm2,
      required List<String> languages,
      required List<Currency> currencies,
      required List<String> borders,
      required List<String> timezones,
      Value<String?> mapsUrl,
      Value<String?> flagAlt,
      Value<String?> flagColor,
      required int fetchedAt,
      Value<int> rowid,
    });
typedef $$CountriesTableUpdateCompanionBuilder =
    CountriesCompanion Function({
      Value<String> code,
      Value<String> alpha2,
      Value<String> nameEn,
      Value<String> nameOfficialEn,
      Value<String?> nameAr,
      Value<String?> nameOfficialAr,
      Value<String> region,
      Value<String?> subregion,
      Value<String?> capital,
      Value<int> population,
      Value<double?> areaKm2,
      Value<List<String>> languages,
      Value<List<Currency>> currencies,
      Value<List<String>> borders,
      Value<List<String>> timezones,
      Value<String?> mapsUrl,
      Value<String?> flagAlt,
      Value<String?> flagColor,
      Value<int> fetchedAt,
      Value<int> rowid,
    });

class $$CountriesTableFilterComposer
    extends Composer<_$AppDatabase, $CountriesTable> {
  $$CountriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alpha2 => $composableBuilder(
    column: $table.alpha2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameOfficialEn => $composableBuilder(
    column: $table.nameOfficialEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameAr => $composableBuilder(
    column: $table.nameAr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameOfficialAr => $composableBuilder(
    column: $table.nameOfficialAr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subregion => $composableBuilder(
    column: $table.subregion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get capital => $composableBuilder(
    column: $table.capital,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get population => $composableBuilder(
    column: $table.population,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get areaKm2 => $composableBuilder(
    column: $table.areaKm2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get languages => $composableBuilder(
    column: $table.languages,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<Currency>, List<Currency>, String>
  get currencies => $composableBuilder(
    column: $table.currencies,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get borders => $composableBuilder(
    column: $table.borders,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get timezones => $composableBuilder(
    column: $table.timezones,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get mapsUrl => $composableBuilder(
    column: $table.mapsUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flagAlt => $composableBuilder(
    column: $table.flagAlt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flagColor => $composableBuilder(
    column: $table.flagColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CountriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CountriesTable> {
  $$CountriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alpha2 => $composableBuilder(
    column: $table.alpha2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameOfficialEn => $composableBuilder(
    column: $table.nameOfficialEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameAr => $composableBuilder(
    column: $table.nameAr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameOfficialAr => $composableBuilder(
    column: $table.nameOfficialAr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subregion => $composableBuilder(
    column: $table.subregion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get capital => $composableBuilder(
    column: $table.capital,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get population => $composableBuilder(
    column: $table.population,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get areaKm2 => $composableBuilder(
    column: $table.areaKm2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languages => $composableBuilder(
    column: $table.languages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencies => $composableBuilder(
    column: $table.currencies,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get borders => $composableBuilder(
    column: $table.borders,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezones => $composableBuilder(
    column: $table.timezones,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mapsUrl => $composableBuilder(
    column: $table.mapsUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flagAlt => $composableBuilder(
    column: $table.flagAlt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flagColor => $composableBuilder(
    column: $table.flagColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CountriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CountriesTable> {
  $$CountriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get alpha2 =>
      $composableBuilder(column: $table.alpha2, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get nameOfficialEn => $composableBuilder(
    column: $table.nameOfficialEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nameAr =>
      $composableBuilder(column: $table.nameAr, builder: (column) => column);

  GeneratedColumn<String> get nameOfficialAr => $composableBuilder(
    column: $table.nameOfficialAr,
    builder: (column) => column,
  );

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<String> get subregion =>
      $composableBuilder(column: $table.subregion, builder: (column) => column);

  GeneratedColumn<String> get capital =>
      $composableBuilder(column: $table.capital, builder: (column) => column);

  GeneratedColumn<int> get population => $composableBuilder(
    column: $table.population,
    builder: (column) => column,
  );

  GeneratedColumn<double> get areaKm2 =>
      $composableBuilder(column: $table.areaKm2, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get languages =>
      $composableBuilder(column: $table.languages, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<Currency>, String> get currencies =>
      $composableBuilder(
        column: $table.currencies,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<String>, String> get borders =>
      $composableBuilder(column: $table.borders, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get timezones =>
      $composableBuilder(column: $table.timezones, builder: (column) => column);

  GeneratedColumn<String> get mapsUrl =>
      $composableBuilder(column: $table.mapsUrl, builder: (column) => column);

  GeneratedColumn<String> get flagAlt =>
      $composableBuilder(column: $table.flagAlt, builder: (column) => column);

  GeneratedColumn<String> get flagColor =>
      $composableBuilder(column: $table.flagColor, builder: (column) => column);

  GeneratedColumn<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$CountriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CountriesTable,
          CountryRow,
          $$CountriesTableFilterComposer,
          $$CountriesTableOrderingComposer,
          $$CountriesTableAnnotationComposer,
          $$CountriesTableCreateCompanionBuilder,
          $$CountriesTableUpdateCompanionBuilder,
          (
            CountryRow,
            BaseReferences<_$AppDatabase, $CountriesTable, CountryRow>,
          ),
          CountryRow,
          PrefetchHooks Function()
        > {
  $$CountriesTableTableManager(_$AppDatabase db, $CountriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CountriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CountriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CountriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> alpha2 = const Value.absent(),
                Value<String> nameEn = const Value.absent(),
                Value<String> nameOfficialEn = const Value.absent(),
                Value<String?> nameAr = const Value.absent(),
                Value<String?> nameOfficialAr = const Value.absent(),
                Value<String> region = const Value.absent(),
                Value<String?> subregion = const Value.absent(),
                Value<String?> capital = const Value.absent(),
                Value<int> population = const Value.absent(),
                Value<double?> areaKm2 = const Value.absent(),
                Value<List<String>> languages = const Value.absent(),
                Value<List<Currency>> currencies = const Value.absent(),
                Value<List<String>> borders = const Value.absent(),
                Value<List<String>> timezones = const Value.absent(),
                Value<String?> mapsUrl = const Value.absent(),
                Value<String?> flagAlt = const Value.absent(),
                Value<String?> flagColor = const Value.absent(),
                Value<int> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CountriesCompanion(
                code: code,
                alpha2: alpha2,
                nameEn: nameEn,
                nameOfficialEn: nameOfficialEn,
                nameAr: nameAr,
                nameOfficialAr: nameOfficialAr,
                region: region,
                subregion: subregion,
                capital: capital,
                population: population,
                areaKm2: areaKm2,
                languages: languages,
                currencies: currencies,
                borders: borders,
                timezones: timezones,
                mapsUrl: mapsUrl,
                flagAlt: flagAlt,
                flagColor: flagColor,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String alpha2,
                required String nameEn,
                required String nameOfficialEn,
                Value<String?> nameAr = const Value.absent(),
                Value<String?> nameOfficialAr = const Value.absent(),
                required String region,
                Value<String?> subregion = const Value.absent(),
                Value<String?> capital = const Value.absent(),
                required int population,
                Value<double?> areaKm2 = const Value.absent(),
                required List<String> languages,
                required List<Currency> currencies,
                required List<String> borders,
                required List<String> timezones,
                Value<String?> mapsUrl = const Value.absent(),
                Value<String?> flagAlt = const Value.absent(),
                Value<String?> flagColor = const Value.absent(),
                required int fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => CountriesCompanion.insert(
                code: code,
                alpha2: alpha2,
                nameEn: nameEn,
                nameOfficialEn: nameOfficialEn,
                nameAr: nameAr,
                nameOfficialAr: nameOfficialAr,
                region: region,
                subregion: subregion,
                capital: capital,
                population: population,
                areaKm2: areaKm2,
                languages: languages,
                currencies: currencies,
                borders: borders,
                timezones: timezones,
                mapsUrl: mapsUrl,
                flagAlt: flagAlt,
                flagColor: flagColor,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CountriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CountriesTable,
      CountryRow,
      $$CountriesTableFilterComposer,
      $$CountriesTableOrderingComposer,
      $$CountriesTableAnnotationComposer,
      $$CountriesTableCreateCompanionBuilder,
      $$CountriesTableUpdateCompanionBuilder,
      (CountryRow, BaseReferences<_$AppDatabase, $CountriesTable, CountryRow>),
      CountryRow,
      PrefetchHooks Function()
    >;
typedef $$TravelEntriesTableCreateCompanionBuilder =
    TravelEntriesCompanion Function({
      required String countryCode,
      required TravelStatus status,
      Value<String?> visitedOn,
      Value<int?> rating,
      Value<WishlistPriority?> priority,
      Value<int?> targetYear,
      Value<String> notes,
      required int createdAt,
      required int updatedAt,
      Value<bool> isDeleted,
      Value<int?> syncedAt,
      Value<int> rowid,
    });
typedef $$TravelEntriesTableUpdateCompanionBuilder =
    TravelEntriesCompanion Function({
      Value<String> countryCode,
      Value<TravelStatus> status,
      Value<String?> visitedOn,
      Value<int?> rating,
      Value<WishlistPriority?> priority,
      Value<int?> targetYear,
      Value<String> notes,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isDeleted,
      Value<int?> syncedAt,
      Value<int> rowid,
    });

class $$TravelEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $TravelEntriesTable> {
  $$TravelEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TravelStatus, TravelStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get visitedOn => $composableBuilder(
    column: $table.visitedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WishlistPriority?, WishlistPriority, String>
  get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get targetYear => $composableBuilder(
    column: $table.targetYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TravelEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TravelEntriesTable> {
  $$TravelEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visitedOn => $composableBuilder(
    column: $table.visitedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetYear => $composableBuilder(
    column: $table.targetYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TravelEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TravelEntriesTable> {
  $$TravelEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TravelStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get visitedOn =>
      $composableBuilder(column: $table.visitedOn, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WishlistPriority?, String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get targetYear => $composableBuilder(
    column: $table.targetYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$TravelEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TravelEntriesTable,
          TravelEntryRow,
          $$TravelEntriesTableFilterComposer,
          $$TravelEntriesTableOrderingComposer,
          $$TravelEntriesTableAnnotationComposer,
          $$TravelEntriesTableCreateCompanionBuilder,
          $$TravelEntriesTableUpdateCompanionBuilder,
          (
            TravelEntryRow,
            BaseReferences<_$AppDatabase, $TravelEntriesTable, TravelEntryRow>,
          ),
          TravelEntryRow,
          PrefetchHooks Function()
        > {
  $$TravelEntriesTableTableManager(_$AppDatabase db, $TravelEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TravelEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TravelEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TravelEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> countryCode = const Value.absent(),
                Value<TravelStatus> status = const Value.absent(),
                Value<String?> visitedOn = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<WishlistPriority?> priority = const Value.absent(),
                Value<int?> targetYear = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TravelEntriesCompanion(
                countryCode: countryCode,
                status: status,
                visitedOn: visitedOn,
                rating: rating,
                priority: priority,
                targetYear: targetYear,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String countryCode,
                required TravelStatus status,
                Value<String?> visitedOn = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<WishlistPriority?> priority = const Value.absent(),
                Value<int?> targetYear = const Value.absent(),
                Value<String> notes = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TravelEntriesCompanion.insert(
                countryCode: countryCode,
                status: status,
                visitedOn: visitedOn,
                rating: rating,
                priority: priority,
                targetYear: targetYear,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TravelEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TravelEntriesTable,
      TravelEntryRow,
      $$TravelEntriesTableFilterComposer,
      $$TravelEntriesTableOrderingComposer,
      $$TravelEntriesTableAnnotationComposer,
      $$TravelEntriesTableCreateCompanionBuilder,
      $$TravelEntriesTableUpdateCompanionBuilder,
      (
        TravelEntryRow,
        BaseReferences<_$AppDatabase, $TravelEntriesTable, TravelEntryRow>,
      ),
      TravelEntryRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CountriesTableTableManager get countries =>
      $$CountriesTableTableManager(_db, _db.countries);
  $$TravelEntriesTableTableManager get travelEntries =>
      $$TravelEntriesTableTableManager(_db, _db.travelEntries);
}
