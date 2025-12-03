// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BehaviorIncident _$BehaviorIncidentFromJson(Map<String, dynamic> json) {
  return _BehaviorIncident.fromJson(json);
}

/// @nodoc
mixin _$BehaviorIncident {
  String get id =>
      throw _privateConstructorUsedError; // Local ID for the incident (UUID)
  @JsonKey(name: 'convex_id')
  String? get convexId => throw _privateConstructorUsedError; // Convex database ID (for reviews)
  @JsonKey(name: 'behaviors_displayed')
  List<String> get behaviorsDisplayed => throw _privateConstructorUsedError;
  String get duration => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _severityFromJson, toJson: _severityToJson)
  BehaviorSeverity get severity => throw _privateConstructorUsedError;
  @JsonKey(name: 'self_harm', fromJson: _boolFromJson)
  bool get selfHarm => throw _privateConstructorUsedError;
  @JsonKey(name: 'self_harm_types')
  List<String> get selfHarmTypes => throw _privateConstructorUsedError;
  @JsonKey(name: 'self_harm_count', fromJson: _selfHarmCountToInt)
  int get selfHarmCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'initial_intervention')
  String get initialIntervention => throw _privateConstructorUsedError;
  @JsonKey(name: 'intervention_description')
  String? get interventionDescription => throw _privateConstructorUsedError;
  @JsonKey(name: 'second_support_needed')
  List<String> get secondSupportNeeded => throw _privateConstructorUsedError;
  @JsonKey(name: 'second_support_description')
  String? get secondSupportDescription => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  /// Serializes this BehaviorIncident to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BehaviorIncident
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BehaviorIncidentCopyWith<BehaviorIncident> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BehaviorIncidentCopyWith<$Res> {
  factory $BehaviorIncidentCopyWith(
    BehaviorIncident value,
    $Res Function(BehaviorIncident) then,
  ) = _$BehaviorIncidentCopyWithImpl<$Res, BehaviorIncident>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'convex_id') String? convexId,
    @JsonKey(name: 'behaviors_displayed') List<String> behaviorsDisplayed,
    String duration,
    @JsonKey(fromJson: _severityFromJson, toJson: _severityToJson)
    BehaviorSeverity severity,
    @JsonKey(name: 'self_harm', fromJson: _boolFromJson) bool selfHarm,
    @JsonKey(name: 'self_harm_types') List<String> selfHarmTypes,
    @JsonKey(name: 'self_harm_count', fromJson: _selfHarmCountToInt)
    int selfHarmCount,
    @JsonKey(name: 'initial_intervention') String initialIntervention,
    @JsonKey(name: 'intervention_description') String? interventionDescription,
    @JsonKey(name: 'second_support_needed') List<String> secondSupportNeeded,
    @JsonKey(name: 'second_support_description')
    String? secondSupportDescription,
    String description,
  });
}

/// @nodoc
class _$BehaviorIncidentCopyWithImpl<$Res, $Val extends BehaviorIncident>
    implements $BehaviorIncidentCopyWith<$Res> {
  _$BehaviorIncidentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BehaviorIncident
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? convexId = freezed,
    Object? behaviorsDisplayed = null,
    Object? duration = null,
    Object? severity = null,
    Object? selfHarm = null,
    Object? selfHarmTypes = null,
    Object? selfHarmCount = null,
    Object? initialIntervention = null,
    Object? interventionDescription = freezed,
    Object? secondSupportNeeded = null,
    Object? secondSupportDescription = freezed,
    Object? description = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            convexId: freezed == convexId
                ? _value.convexId
                : convexId // ignore: cast_nullable_to_non_nullable
                      as String?,
            behaviorsDisplayed: null == behaviorsDisplayed
                ? _value.behaviorsDisplayed
                : behaviorsDisplayed // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            duration: null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as String,
            severity: null == severity
                ? _value.severity
                : severity // ignore: cast_nullable_to_non_nullable
                      as BehaviorSeverity,
            selfHarm: null == selfHarm
                ? _value.selfHarm
                : selfHarm // ignore: cast_nullable_to_non_nullable
                      as bool,
            selfHarmTypes: null == selfHarmTypes
                ? _value.selfHarmTypes
                : selfHarmTypes // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            selfHarmCount: null == selfHarmCount
                ? _value.selfHarmCount
                : selfHarmCount // ignore: cast_nullable_to_non_nullable
                      as int,
            initialIntervention: null == initialIntervention
                ? _value.initialIntervention
                : initialIntervention // ignore: cast_nullable_to_non_nullable
                      as String,
            interventionDescription: freezed == interventionDescription
                ? _value.interventionDescription
                : interventionDescription // ignore: cast_nullable_to_non_nullable
                      as String?,
            secondSupportNeeded: null == secondSupportNeeded
                ? _value.secondSupportNeeded
                : secondSupportNeeded // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            secondSupportDescription: freezed == secondSupportDescription
                ? _value.secondSupportDescription
                : secondSupportDescription // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BehaviorIncidentImplCopyWith<$Res>
    implements $BehaviorIncidentCopyWith<$Res> {
  factory _$$BehaviorIncidentImplCopyWith(
    _$BehaviorIncidentImpl value,
    $Res Function(_$BehaviorIncidentImpl) then,
  ) = __$$BehaviorIncidentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'convex_id') String? convexId,
    @JsonKey(name: 'behaviors_displayed') List<String> behaviorsDisplayed,
    String duration,
    @JsonKey(fromJson: _severityFromJson, toJson: _severityToJson)
    BehaviorSeverity severity,
    @JsonKey(name: 'self_harm', fromJson: _boolFromJson) bool selfHarm,
    @JsonKey(name: 'self_harm_types') List<String> selfHarmTypes,
    @JsonKey(name: 'self_harm_count', fromJson: _selfHarmCountToInt)
    int selfHarmCount,
    @JsonKey(name: 'initial_intervention') String initialIntervention,
    @JsonKey(name: 'intervention_description') String? interventionDescription,
    @JsonKey(name: 'second_support_needed') List<String> secondSupportNeeded,
    @JsonKey(name: 'second_support_description')
    String? secondSupportDescription,
    String description,
  });
}

/// @nodoc
class __$$BehaviorIncidentImplCopyWithImpl<$Res>
    extends _$BehaviorIncidentCopyWithImpl<$Res, _$BehaviorIncidentImpl>
    implements _$$BehaviorIncidentImplCopyWith<$Res> {
  __$$BehaviorIncidentImplCopyWithImpl(
    _$BehaviorIncidentImpl _value,
    $Res Function(_$BehaviorIncidentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BehaviorIncident
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? convexId = freezed,
    Object? behaviorsDisplayed = null,
    Object? duration = null,
    Object? severity = null,
    Object? selfHarm = null,
    Object? selfHarmTypes = null,
    Object? selfHarmCount = null,
    Object? initialIntervention = null,
    Object? interventionDescription = freezed,
    Object? secondSupportNeeded = null,
    Object? secondSupportDescription = freezed,
    Object? description = null,
  }) {
    return _then(
      _$BehaviorIncidentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        convexId: freezed == convexId
            ? _value.convexId
            : convexId // ignore: cast_nullable_to_non_nullable
                  as String?,
        behaviorsDisplayed: null == behaviorsDisplayed
            ? _value._behaviorsDisplayed
            : behaviorsDisplayed // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        duration: null == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as String,
        severity: null == severity
            ? _value.severity
            : severity // ignore: cast_nullable_to_non_nullable
                  as BehaviorSeverity,
        selfHarm: null == selfHarm
            ? _value.selfHarm
            : selfHarm // ignore: cast_nullable_to_non_nullable
                  as bool,
        selfHarmTypes: null == selfHarmTypes
            ? _value._selfHarmTypes
            : selfHarmTypes // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        selfHarmCount: null == selfHarmCount
            ? _value.selfHarmCount
            : selfHarmCount // ignore: cast_nullable_to_non_nullable
                  as int,
        initialIntervention: null == initialIntervention
            ? _value.initialIntervention
            : initialIntervention // ignore: cast_nullable_to_non_nullable
                  as String,
        interventionDescription: freezed == interventionDescription
            ? _value.interventionDescription
            : interventionDescription // ignore: cast_nullable_to_non_nullable
                  as String?,
        secondSupportNeeded: null == secondSupportNeeded
            ? _value._secondSupportNeeded
            : secondSupportNeeded // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        secondSupportDescription: freezed == secondSupportDescription
            ? _value.secondSupportDescription
            : secondSupportDescription // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BehaviorIncidentImpl implements _BehaviorIncident {
  const _$BehaviorIncidentImpl({
    required this.id,
    @JsonKey(name: 'convex_id') this.convexId,
    @JsonKey(name: 'behaviors_displayed')
    required final List<String> behaviorsDisplayed,
    required this.duration,
    @JsonKey(fromJson: _severityFromJson, toJson: _severityToJson)
    required this.severity,
    @JsonKey(name: 'self_harm', fromJson: _boolFromJson) required this.selfHarm,
    @JsonKey(name: 'self_harm_types')
    final List<String> selfHarmTypes = const [],
    @JsonKey(name: 'self_harm_count', fromJson: _selfHarmCountToInt)
    this.selfHarmCount = 0,
    @JsonKey(name: 'initial_intervention') required this.initialIntervention,
    @JsonKey(name: 'intervention_description') this.interventionDescription,
    @JsonKey(name: 'second_support_needed')
    final List<String> secondSupportNeeded = const [],
    @JsonKey(name: 'second_support_description') this.secondSupportDescription,
    required this.description,
  }) : _behaviorsDisplayed = behaviorsDisplayed,
       _selfHarmTypes = selfHarmTypes,
       _secondSupportNeeded = secondSupportNeeded;

  factory _$BehaviorIncidentImpl.fromJson(Map<String, dynamic> json) =>
      _$$BehaviorIncidentImplFromJson(json);

  @override
  final String id;
  // Local ID for the incident (UUID)
  @override
  @JsonKey(name: 'convex_id')
  final String? convexId;
  // Convex database ID (for reviews)
  final List<String> _behaviorsDisplayed;
  // Convex database ID (for reviews)
  @override
  @JsonKey(name: 'behaviors_displayed')
  List<String> get behaviorsDisplayed {
    if (_behaviorsDisplayed is EqualUnmodifiableListView)
      return _behaviorsDisplayed;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_behaviorsDisplayed);
  }

  @override
  final String duration;
  @override
  @JsonKey(fromJson: _severityFromJson, toJson: _severityToJson)
  final BehaviorSeverity severity;
  @override
  @JsonKey(name: 'self_harm', fromJson: _boolFromJson)
  final bool selfHarm;
  final List<String> _selfHarmTypes;
  @override
  @JsonKey(name: 'self_harm_types')
  List<String> get selfHarmTypes {
    if (_selfHarmTypes is EqualUnmodifiableListView) return _selfHarmTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selfHarmTypes);
  }

  @override
  @JsonKey(name: 'self_harm_count', fromJson: _selfHarmCountToInt)
  final int selfHarmCount;
  @override
  @JsonKey(name: 'initial_intervention')
  final String initialIntervention;
  @override
  @JsonKey(name: 'intervention_description')
  final String? interventionDescription;
  final List<String> _secondSupportNeeded;
  @override
  @JsonKey(name: 'second_support_needed')
  List<String> get secondSupportNeeded {
    if (_secondSupportNeeded is EqualUnmodifiableListView)
      return _secondSupportNeeded;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_secondSupportNeeded);
  }

  @override
  @JsonKey(name: 'second_support_description')
  final String? secondSupportDescription;
  @override
  final String description;

  @override
  String toString() {
    return 'BehaviorIncident(id: $id, convexId: $convexId, behaviorsDisplayed: $behaviorsDisplayed, duration: $duration, severity: $severity, selfHarm: $selfHarm, selfHarmTypes: $selfHarmTypes, selfHarmCount: $selfHarmCount, initialIntervention: $initialIntervention, interventionDescription: $interventionDescription, secondSupportNeeded: $secondSupportNeeded, secondSupportDescription: $secondSupportDescription, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BehaviorIncidentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.convexId, convexId) ||
                other.convexId == convexId) &&
            const DeepCollectionEquality().equals(
              other._behaviorsDisplayed,
              _behaviorsDisplayed,
            ) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.selfHarm, selfHarm) ||
                other.selfHarm == selfHarm) &&
            const DeepCollectionEquality().equals(
              other._selfHarmTypes,
              _selfHarmTypes,
            ) &&
            (identical(other.selfHarmCount, selfHarmCount) ||
                other.selfHarmCount == selfHarmCount) &&
            (identical(other.initialIntervention, initialIntervention) ||
                other.initialIntervention == initialIntervention) &&
            (identical(
                  other.interventionDescription,
                  interventionDescription,
                ) ||
                other.interventionDescription == interventionDescription) &&
            const DeepCollectionEquality().equals(
              other._secondSupportNeeded,
              _secondSupportNeeded,
            ) &&
            (identical(
                  other.secondSupportDescription,
                  secondSupportDescription,
                ) ||
                other.secondSupportDescription == secondSupportDescription) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    convexId,
    const DeepCollectionEquality().hash(_behaviorsDisplayed),
    duration,
    severity,
    selfHarm,
    const DeepCollectionEquality().hash(_selfHarmTypes),
    selfHarmCount,
    initialIntervention,
    interventionDescription,
    const DeepCollectionEquality().hash(_secondSupportNeeded),
    secondSupportDescription,
    description,
  );

  /// Create a copy of BehaviorIncident
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BehaviorIncidentImplCopyWith<_$BehaviorIncidentImpl> get copyWith =>
      __$$BehaviorIncidentImplCopyWithImpl<_$BehaviorIncidentImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BehaviorIncidentImplToJson(this);
  }
}

abstract class _BehaviorIncident implements BehaviorIncident {
  const factory _BehaviorIncident({
    required final String id,
    @JsonKey(name: 'convex_id') final String? convexId,
    @JsonKey(name: 'behaviors_displayed')
    required final List<String> behaviorsDisplayed,
    required final String duration,
    @JsonKey(fromJson: _severityFromJson, toJson: _severityToJson)
    required final BehaviorSeverity severity,
    @JsonKey(name: 'self_harm', fromJson: _boolFromJson)
    required final bool selfHarm,
    @JsonKey(name: 'self_harm_types') final List<String> selfHarmTypes,
    @JsonKey(name: 'self_harm_count', fromJson: _selfHarmCountToInt)
    final int selfHarmCount,
    @JsonKey(name: 'initial_intervention')
    required final String initialIntervention,
    @JsonKey(name: 'intervention_description')
    final String? interventionDescription,
    @JsonKey(name: 'second_support_needed')
    final List<String> secondSupportNeeded,
    @JsonKey(name: 'second_support_description')
    final String? secondSupportDescription,
    required final String description,
  }) = _$BehaviorIncidentImpl;

  factory _BehaviorIncident.fromJson(Map<String, dynamic> json) =
      _$BehaviorIncidentImpl.fromJson;

  @override
  String get id; // Local ID for the incident (UUID)
  @override
  @JsonKey(name: 'convex_id')
  String? get convexId; // Convex database ID (for reviews)
  @override
  @JsonKey(name: 'behaviors_displayed')
  List<String> get behaviorsDisplayed;
  @override
  String get duration;
  @override
  @JsonKey(fromJson: _severityFromJson, toJson: _severityToJson)
  BehaviorSeverity get severity;
  @override
  @JsonKey(name: 'self_harm', fromJson: _boolFromJson)
  bool get selfHarm;
  @override
  @JsonKey(name: 'self_harm_types')
  List<String> get selfHarmTypes;
  @override
  @JsonKey(name: 'self_harm_count', fromJson: _selfHarmCountToInt)
  int get selfHarmCount;
  @override
  @JsonKey(name: 'initial_intervention')
  String get initialIntervention;
  @override
  @JsonKey(name: 'intervention_description')
  String? get interventionDescription;
  @override
  @JsonKey(name: 'second_support_needed')
  List<String> get secondSupportNeeded;
  @override
  @JsonKey(name: 'second_support_description')
  String? get secondSupportDescription;
  @override
  String get description;

  /// Create a copy of BehaviorIncident
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BehaviorIncidentImplCopyWith<_$BehaviorIncidentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GoalProgressEntry _$GoalProgressEntryFromJson(Map<String, dynamic> json) {
  return _GoalProgressEntry.fromJson(json);
}

/// @nodoc
mixin _$GoalProgressEntry {
  @JsonKey(name: 'goal_id')
  String get goalId => throw _privateConstructorUsedError;
  @JsonKey(name: 'progress_observed', fromJson: _progressToInt)
  int get progressObserved => throw _privateConstructorUsedError; // 1-10 scale
  @JsonKey(name: 'evidence_notes')
  String get evidenceNotes => throw _privateConstructorUsedError;

  /// Serializes this GoalProgressEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GoalProgressEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GoalProgressEntryCopyWith<GoalProgressEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GoalProgressEntryCopyWith<$Res> {
  factory $GoalProgressEntryCopyWith(
    GoalProgressEntry value,
    $Res Function(GoalProgressEntry) then,
  ) = _$GoalProgressEntryCopyWithImpl<$Res, GoalProgressEntry>;
  @useResult
  $Res call({
    @JsonKey(name: 'goal_id') String goalId,
    @JsonKey(name: 'progress_observed', fromJson: _progressToInt)
    int progressObserved,
    @JsonKey(name: 'evidence_notes') String evidenceNotes,
  });
}

/// @nodoc
class _$GoalProgressEntryCopyWithImpl<$Res, $Val extends GoalProgressEntry>
    implements $GoalProgressEntryCopyWith<$Res> {
  _$GoalProgressEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GoalProgressEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? goalId = null,
    Object? progressObserved = null,
    Object? evidenceNotes = null,
  }) {
    return _then(
      _value.copyWith(
            goalId: null == goalId
                ? _value.goalId
                : goalId // ignore: cast_nullable_to_non_nullable
                      as String,
            progressObserved: null == progressObserved
                ? _value.progressObserved
                : progressObserved // ignore: cast_nullable_to_non_nullable
                      as int,
            evidenceNotes: null == evidenceNotes
                ? _value.evidenceNotes
                : evidenceNotes // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GoalProgressEntryImplCopyWith<$Res>
    implements $GoalProgressEntryCopyWith<$Res> {
  factory _$$GoalProgressEntryImplCopyWith(
    _$GoalProgressEntryImpl value,
    $Res Function(_$GoalProgressEntryImpl) then,
  ) = __$$GoalProgressEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'goal_id') String goalId,
    @JsonKey(name: 'progress_observed', fromJson: _progressToInt)
    int progressObserved,
    @JsonKey(name: 'evidence_notes') String evidenceNotes,
  });
}

/// @nodoc
class __$$GoalProgressEntryImplCopyWithImpl<$Res>
    extends _$GoalProgressEntryCopyWithImpl<$Res, _$GoalProgressEntryImpl>
    implements _$$GoalProgressEntryImplCopyWith<$Res> {
  __$$GoalProgressEntryImplCopyWithImpl(
    _$GoalProgressEntryImpl _value,
    $Res Function(_$GoalProgressEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GoalProgressEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? goalId = null,
    Object? progressObserved = null,
    Object? evidenceNotes = null,
  }) {
    return _then(
      _$GoalProgressEntryImpl(
        goalId: null == goalId
            ? _value.goalId
            : goalId // ignore: cast_nullable_to_non_nullable
                  as String,
        progressObserved: null == progressObserved
            ? _value.progressObserved
            : progressObserved // ignore: cast_nullable_to_non_nullable
                  as int,
        evidenceNotes: null == evidenceNotes
            ? _value.evidenceNotes
            : evidenceNotes // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GoalProgressEntryImpl implements _GoalProgressEntry {
  const _$GoalProgressEntryImpl({
    @JsonKey(name: 'goal_id') required this.goalId,
    @JsonKey(name: 'progress_observed', fromJson: _progressToInt)
    required this.progressObserved,
    @JsonKey(name: 'evidence_notes') required this.evidenceNotes,
  });

  factory _$GoalProgressEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$GoalProgressEntryImplFromJson(json);

  @override
  @JsonKey(name: 'goal_id')
  final String goalId;
  @override
  @JsonKey(name: 'progress_observed', fromJson: _progressToInt)
  final int progressObserved;
  // 1-10 scale
  @override
  @JsonKey(name: 'evidence_notes')
  final String evidenceNotes;

  @override
  String toString() {
    return 'GoalProgressEntry(goalId: $goalId, progressObserved: $progressObserved, evidenceNotes: $evidenceNotes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoalProgressEntryImpl &&
            (identical(other.goalId, goalId) || other.goalId == goalId) &&
            (identical(other.progressObserved, progressObserved) ||
                other.progressObserved == progressObserved) &&
            (identical(other.evidenceNotes, evidenceNotes) ||
                other.evidenceNotes == evidenceNotes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, goalId, progressObserved, evidenceNotes);

  /// Create a copy of GoalProgressEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GoalProgressEntryImplCopyWith<_$GoalProgressEntryImpl> get copyWith =>
      __$$GoalProgressEntryImplCopyWithImpl<_$GoalProgressEntryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GoalProgressEntryImplToJson(this);
  }
}

abstract class _GoalProgressEntry implements GoalProgressEntry {
  const factory _GoalProgressEntry({
    @JsonKey(name: 'goal_id') required final String goalId,
    @JsonKey(name: 'progress_observed', fromJson: _progressToInt)
    required final int progressObserved,
    @JsonKey(name: 'evidence_notes') required final String evidenceNotes,
  }) = _$GoalProgressEntryImpl;

  factory _GoalProgressEntry.fromJson(Map<String, dynamic> json) =
      _$GoalProgressEntryImpl.fromJson;

  @override
  @JsonKey(name: 'goal_id')
  String get goalId;
  @override
  @JsonKey(name: 'progress_observed', fromJson: _progressToInt)
  int get progressObserved; // 1-10 scale
  @override
  @JsonKey(name: 'evidence_notes')
  String get evidenceNotes;

  /// Create a copy of GoalProgressEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GoalProgressEntryImplCopyWith<_$GoalProgressEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MediaItem _$MediaItemFromJson(Map<String, dynamic> json) {
  return _MediaItem.fromJson(json);
}

/// @nodoc
mixin _$MediaItem {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'storage_id')
  String get storageId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError; // 'photo' or 'video'
  @JsonKey(name: 'file_name')
  String get fileName => throw _privateConstructorUsedError;
  @JsonKey(name: 'file_size', fromJson: _fileSizeToInt)
  int get fileSize => throw _privateConstructorUsedError;
  @JsonKey(name: 'mime_type')
  String get mimeType => throw _privateConstructorUsedError;
  @JsonKey(name: 'uploaded_at')
  DateTime? get uploadedAt => throw _privateConstructorUsedError;

  /// Serializes this MediaItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MediaItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MediaItemCopyWith<MediaItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MediaItemCopyWith<$Res> {
  factory $MediaItemCopyWith(MediaItem value, $Res Function(MediaItem) then) =
      _$MediaItemCopyWithImpl<$Res, MediaItem>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'storage_id') String storageId,
    String type,
    @JsonKey(name: 'file_name') String fileName,
    @JsonKey(name: 'file_size', fromJson: _fileSizeToInt) int fileSize,
    @JsonKey(name: 'mime_type') String mimeType,
    @JsonKey(name: 'uploaded_at') DateTime? uploadedAt,
  });
}

/// @nodoc
class _$MediaItemCopyWithImpl<$Res, $Val extends MediaItem>
    implements $MediaItemCopyWith<$Res> {
  _$MediaItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MediaItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storageId = null,
    Object? type = null,
    Object? fileName = null,
    Object? fileSize = null,
    Object? mimeType = null,
    Object? uploadedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            storageId: null == storageId
                ? _value.storageId
                : storageId // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            fileName: null == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                      as String,
            fileSize: null == fileSize
                ? _value.fileSize
                : fileSize // ignore: cast_nullable_to_non_nullable
                      as int,
            mimeType: null == mimeType
                ? _value.mimeType
                : mimeType // ignore: cast_nullable_to_non_nullable
                      as String,
            uploadedAt: freezed == uploadedAt
                ? _value.uploadedAt
                : uploadedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MediaItemImplCopyWith<$Res>
    implements $MediaItemCopyWith<$Res> {
  factory _$$MediaItemImplCopyWith(
    _$MediaItemImpl value,
    $Res Function(_$MediaItemImpl) then,
  ) = __$$MediaItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'storage_id') String storageId,
    String type,
    @JsonKey(name: 'file_name') String fileName,
    @JsonKey(name: 'file_size', fromJson: _fileSizeToInt) int fileSize,
    @JsonKey(name: 'mime_type') String mimeType,
    @JsonKey(name: 'uploaded_at') DateTime? uploadedAt,
  });
}

/// @nodoc
class __$$MediaItemImplCopyWithImpl<$Res>
    extends _$MediaItemCopyWithImpl<$Res, _$MediaItemImpl>
    implements _$$MediaItemImplCopyWith<$Res> {
  __$$MediaItemImplCopyWithImpl(
    _$MediaItemImpl _value,
    $Res Function(_$MediaItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MediaItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storageId = null,
    Object? type = null,
    Object? fileName = null,
    Object? fileSize = null,
    Object? mimeType = null,
    Object? uploadedAt = freezed,
  }) {
    return _then(
      _$MediaItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        storageId: null == storageId
            ? _value.storageId
            : storageId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        fileName: null == fileName
            ? _value.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String,
        fileSize: null == fileSize
            ? _value.fileSize
            : fileSize // ignore: cast_nullable_to_non_nullable
                  as int,
        mimeType: null == mimeType
            ? _value.mimeType
            : mimeType // ignore: cast_nullable_to_non_nullable
                  as String,
        uploadedAt: freezed == uploadedAt
            ? _value.uploadedAt
            : uploadedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MediaItemImpl implements _MediaItem {
  const _$MediaItemImpl({
    this.id = '',
    @JsonKey(name: 'storage_id') this.storageId = '',
    this.type = 'photo',
    @JsonKey(name: 'file_name') this.fileName = '',
    @JsonKey(name: 'file_size', fromJson: _fileSizeToInt) this.fileSize = 0,
    @JsonKey(name: 'mime_type') this.mimeType = '',
    @JsonKey(name: 'uploaded_at') this.uploadedAt,
  });

  factory _$MediaItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$MediaItemImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey(name: 'storage_id')
  final String storageId;
  @override
  @JsonKey()
  final String type;
  // 'photo' or 'video'
  @override
  @JsonKey(name: 'file_name')
  final String fileName;
  @override
  @JsonKey(name: 'file_size', fromJson: _fileSizeToInt)
  final int fileSize;
  @override
  @JsonKey(name: 'mime_type')
  final String mimeType;
  @override
  @JsonKey(name: 'uploaded_at')
  final DateTime? uploadedAt;

  @override
  String toString() {
    return 'MediaItem(id: $id, storageId: $storageId, type: $type, fileName: $fileName, fileSize: $fileSize, mimeType: $mimeType, uploadedAt: $uploadedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MediaItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.storageId, storageId) ||
                other.storageId == storageId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.uploadedAt, uploadedAt) ||
                other.uploadedAt == uploadedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    storageId,
    type,
    fileName,
    fileSize,
    mimeType,
    uploadedAt,
  );

  /// Create a copy of MediaItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MediaItemImplCopyWith<_$MediaItemImpl> get copyWith =>
      __$$MediaItemImplCopyWithImpl<_$MediaItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MediaItemImplToJson(this);
  }
}

abstract class _MediaItem implements MediaItem {
  const factory _MediaItem({
    final String id,
    @JsonKey(name: 'storage_id') final String storageId,
    final String type,
    @JsonKey(name: 'file_name') final String fileName,
    @JsonKey(name: 'file_size', fromJson: _fileSizeToInt) final int fileSize,
    @JsonKey(name: 'mime_type') final String mimeType,
    @JsonKey(name: 'uploaded_at') final DateTime? uploadedAt,
  }) = _$MediaItemImpl;

  factory _MediaItem.fromJson(Map<String, dynamic> json) =
      _$MediaItemImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'storage_id')
  String get storageId;
  @override
  String get type; // 'photo' or 'video'
  @override
  @JsonKey(name: 'file_name')
  String get fileName;
  @override
  @JsonKey(name: 'file_size', fromJson: _fileSizeToInt)
  int get fileSize;
  @override
  @JsonKey(name: 'mime_type')
  String get mimeType;
  @override
  @JsonKey(name: 'uploaded_at')
  DateTime? get uploadedAt;

  /// Create a copy of MediaItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MediaItemImplCopyWith<_$MediaItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ActivitySession _$ActivitySessionFromJson(Map<String, dynamic> json) {
  return _ActivitySession.fromJson(json);
}

/// @nodoc
mixin _$ActivitySession {
  @JsonKey(name: 'id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'activity_id')
  String get activityId => throw _privateConstructorUsedError;
  @JsonKey(name: 'client_id')
  String get clientId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get stakeholderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'shift_note_id')
  String? get shiftNoteId => throw _privateConstructorUsedError;
  @JsonKey(name: 'session_start_time')
  DateTime get sessionStartTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'session_end_time')
  DateTime get sessionEndTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_minutes', fromJson: _durationToInt)
  int get durationMinutes => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  @JsonKey(name: 'session_notes')
  String get sessionNotes => throw _privateConstructorUsedError;
  @JsonKey(
    name: 'participant_engagement',
    fromJson: _participantEngagementFromJson,
    toJson: _participantEngagementToJson,
  )
  ParticipantEngagement get participantEngagement =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'goal_progress')
  List<GoalProgressEntry> get goalProgress =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'behavior_incidents')
  List<BehaviorIncident> get behaviorIncidents =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'media')
  List<MediaItem> get media => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError; // Enriched fields (from backend query)
  @JsonKey(name: 'activity_title')
  String? get activityTitle => throw _privateConstructorUsedError;
  @JsonKey(name: 'activity_type')
  String? get activityType => throw _privateConstructorUsedError;
  @JsonKey(name: 'client_name')
  String? get clientName => throw _privateConstructorUsedError;
  @JsonKey(name: 'stakeholder_name')
  String? get stakeholderName => throw _privateConstructorUsedError;
  @JsonKey(name: 'goal_titles')
  List<String>? get goalTitles => throw _privateConstructorUsedError;

  /// Serializes this ActivitySession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActivitySession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivitySessionCopyWith<ActivitySession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivitySessionCopyWith<$Res> {
  factory $ActivitySessionCopyWith(
    ActivitySession value,
    $Res Function(ActivitySession) then,
  ) = _$ActivitySessionCopyWithImpl<$Res, ActivitySession>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') String id,
    @JsonKey(name: 'activity_id') String activityId,
    @JsonKey(name: 'client_id') String clientId,
    @JsonKey(name: 'user_id') String stakeholderId,
    @JsonKey(name: 'shift_note_id') String? shiftNoteId,
    @JsonKey(name: 'session_start_time') DateTime sessionStartTime,
    @JsonKey(name: 'session_end_time') DateTime sessionEndTime,
    @JsonKey(name: 'duration_minutes', fromJson: _durationToInt)
    int durationMinutes,
    String location,
    @JsonKey(name: 'session_notes') String sessionNotes,
    @JsonKey(
      name: 'participant_engagement',
      fromJson: _participantEngagementFromJson,
      toJson: _participantEngagementToJson,
    )
    ParticipantEngagement participantEngagement,
    @JsonKey(name: 'goal_progress') List<GoalProgressEntry> goalProgress,
    @JsonKey(name: 'behavior_incidents')
    List<BehaviorIncident> behaviorIncidents,
    @JsonKey(name: 'media') List<MediaItem> media,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    @JsonKey(name: 'activity_title') String? activityTitle,
    @JsonKey(name: 'activity_type') String? activityType,
    @JsonKey(name: 'client_name') String? clientName,
    @JsonKey(name: 'stakeholder_name') String? stakeholderName,
    @JsonKey(name: 'goal_titles') List<String>? goalTitles,
  });
}

/// @nodoc
class _$ActivitySessionCopyWithImpl<$Res, $Val extends ActivitySession>
    implements $ActivitySessionCopyWith<$Res> {
  _$ActivitySessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivitySession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? activityId = null,
    Object? clientId = null,
    Object? stakeholderId = null,
    Object? shiftNoteId = freezed,
    Object? sessionStartTime = null,
    Object? sessionEndTime = null,
    Object? durationMinutes = null,
    Object? location = null,
    Object? sessionNotes = null,
    Object? participantEngagement = null,
    Object? goalProgress = null,
    Object? behaviorIncidents = null,
    Object? media = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? activityTitle = freezed,
    Object? activityType = freezed,
    Object? clientName = freezed,
    Object? stakeholderName = freezed,
    Object? goalTitles = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            activityId: null == activityId
                ? _value.activityId
                : activityId // ignore: cast_nullable_to_non_nullable
                      as String,
            clientId: null == clientId
                ? _value.clientId
                : clientId // ignore: cast_nullable_to_non_nullable
                      as String,
            stakeholderId: null == stakeholderId
                ? _value.stakeholderId
                : stakeholderId // ignore: cast_nullable_to_non_nullable
                      as String,
            shiftNoteId: freezed == shiftNoteId
                ? _value.shiftNoteId
                : shiftNoteId // ignore: cast_nullable_to_non_nullable
                      as String?,
            sessionStartTime: null == sessionStartTime
                ? _value.sessionStartTime
                : sessionStartTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            sessionEndTime: null == sessionEndTime
                ? _value.sessionEndTime
                : sessionEndTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            durationMinutes: null == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            location: null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String,
            sessionNotes: null == sessionNotes
                ? _value.sessionNotes
                : sessionNotes // ignore: cast_nullable_to_non_nullable
                      as String,
            participantEngagement: null == participantEngagement
                ? _value.participantEngagement
                : participantEngagement // ignore: cast_nullable_to_non_nullable
                      as ParticipantEngagement,
            goalProgress: null == goalProgress
                ? _value.goalProgress
                : goalProgress // ignore: cast_nullable_to_non_nullable
                      as List<GoalProgressEntry>,
            behaviorIncidents: null == behaviorIncidents
                ? _value.behaviorIncidents
                : behaviorIncidents // ignore: cast_nullable_to_non_nullable
                      as List<BehaviorIncident>,
            media: null == media
                ? _value.media
                : media // ignore: cast_nullable_to_non_nullable
                      as List<MediaItem>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            activityTitle: freezed == activityTitle
                ? _value.activityTitle
                : activityTitle // ignore: cast_nullable_to_non_nullable
                      as String?,
            activityType: freezed == activityType
                ? _value.activityType
                : activityType // ignore: cast_nullable_to_non_nullable
                      as String?,
            clientName: freezed == clientName
                ? _value.clientName
                : clientName // ignore: cast_nullable_to_non_nullable
                      as String?,
            stakeholderName: freezed == stakeholderName
                ? _value.stakeholderName
                : stakeholderName // ignore: cast_nullable_to_non_nullable
                      as String?,
            goalTitles: freezed == goalTitles
                ? _value.goalTitles
                : goalTitles // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ActivitySessionImplCopyWith<$Res>
    implements $ActivitySessionCopyWith<$Res> {
  factory _$$ActivitySessionImplCopyWith(
    _$ActivitySessionImpl value,
    $Res Function(_$ActivitySessionImpl) then,
  ) = __$$ActivitySessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') String id,
    @JsonKey(name: 'activity_id') String activityId,
    @JsonKey(name: 'client_id') String clientId,
    @JsonKey(name: 'user_id') String stakeholderId,
    @JsonKey(name: 'shift_note_id') String? shiftNoteId,
    @JsonKey(name: 'session_start_time') DateTime sessionStartTime,
    @JsonKey(name: 'session_end_time') DateTime sessionEndTime,
    @JsonKey(name: 'duration_minutes', fromJson: _durationToInt)
    int durationMinutes,
    String location,
    @JsonKey(name: 'session_notes') String sessionNotes,
    @JsonKey(
      name: 'participant_engagement',
      fromJson: _participantEngagementFromJson,
      toJson: _participantEngagementToJson,
    )
    ParticipantEngagement participantEngagement,
    @JsonKey(name: 'goal_progress') List<GoalProgressEntry> goalProgress,
    @JsonKey(name: 'behavior_incidents')
    List<BehaviorIncident> behaviorIncidents,
    @JsonKey(name: 'media') List<MediaItem> media,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    @JsonKey(name: 'activity_title') String? activityTitle,
    @JsonKey(name: 'activity_type') String? activityType,
    @JsonKey(name: 'client_name') String? clientName,
    @JsonKey(name: 'stakeholder_name') String? stakeholderName,
    @JsonKey(name: 'goal_titles') List<String>? goalTitles,
  });
}

/// @nodoc
class __$$ActivitySessionImplCopyWithImpl<$Res>
    extends _$ActivitySessionCopyWithImpl<$Res, _$ActivitySessionImpl>
    implements _$$ActivitySessionImplCopyWith<$Res> {
  __$$ActivitySessionImplCopyWithImpl(
    _$ActivitySessionImpl _value,
    $Res Function(_$ActivitySessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActivitySession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? activityId = null,
    Object? clientId = null,
    Object? stakeholderId = null,
    Object? shiftNoteId = freezed,
    Object? sessionStartTime = null,
    Object? sessionEndTime = null,
    Object? durationMinutes = null,
    Object? location = null,
    Object? sessionNotes = null,
    Object? participantEngagement = null,
    Object? goalProgress = null,
    Object? behaviorIncidents = null,
    Object? media = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? activityTitle = freezed,
    Object? activityType = freezed,
    Object? clientName = freezed,
    Object? stakeholderName = freezed,
    Object? goalTitles = freezed,
  }) {
    return _then(
      _$ActivitySessionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        activityId: null == activityId
            ? _value.activityId
            : activityId // ignore: cast_nullable_to_non_nullable
                  as String,
        clientId: null == clientId
            ? _value.clientId
            : clientId // ignore: cast_nullable_to_non_nullable
                  as String,
        stakeholderId: null == stakeholderId
            ? _value.stakeholderId
            : stakeholderId // ignore: cast_nullable_to_non_nullable
                  as String,
        shiftNoteId: freezed == shiftNoteId
            ? _value.shiftNoteId
            : shiftNoteId // ignore: cast_nullable_to_non_nullable
                  as String?,
        sessionStartTime: null == sessionStartTime
            ? _value.sessionStartTime
            : sessionStartTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        sessionEndTime: null == sessionEndTime
            ? _value.sessionEndTime
            : sessionEndTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        durationMinutes: null == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        location: null == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionNotes: null == sessionNotes
            ? _value.sessionNotes
            : sessionNotes // ignore: cast_nullable_to_non_nullable
                  as String,
        participantEngagement: null == participantEngagement
            ? _value.participantEngagement
            : participantEngagement // ignore: cast_nullable_to_non_nullable
                  as ParticipantEngagement,
        goalProgress: null == goalProgress
            ? _value._goalProgress
            : goalProgress // ignore: cast_nullable_to_non_nullable
                  as List<GoalProgressEntry>,
        behaviorIncidents: null == behaviorIncidents
            ? _value._behaviorIncidents
            : behaviorIncidents // ignore: cast_nullable_to_non_nullable
                  as List<BehaviorIncident>,
        media: null == media
            ? _value._media
            : media // ignore: cast_nullable_to_non_nullable
                  as List<MediaItem>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        activityTitle: freezed == activityTitle
            ? _value.activityTitle
            : activityTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        activityType: freezed == activityType
            ? _value.activityType
            : activityType // ignore: cast_nullable_to_non_nullable
                  as String?,
        clientName: freezed == clientName
            ? _value.clientName
            : clientName // ignore: cast_nullable_to_non_nullable
                  as String?,
        stakeholderName: freezed == stakeholderName
            ? _value.stakeholderName
            : stakeholderName // ignore: cast_nullable_to_non_nullable
                  as String?,
        goalTitles: freezed == goalTitles
            ? _value._goalTitles
            : goalTitles // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivitySessionImpl implements _ActivitySession {
  const _$ActivitySessionImpl({
    @JsonKey(name: 'id') required this.id,
    @JsonKey(name: 'activity_id') required this.activityId,
    @JsonKey(name: 'client_id') required this.clientId,
    @JsonKey(name: 'user_id') required this.stakeholderId,
    @JsonKey(name: 'shift_note_id') this.shiftNoteId,
    @JsonKey(name: 'session_start_time') required this.sessionStartTime,
    @JsonKey(name: 'session_end_time') required this.sessionEndTime,
    @JsonKey(name: 'duration_minutes', fromJson: _durationToInt)
    required this.durationMinutes,
    this.location = 'Unknown',
    @JsonKey(name: 'session_notes') this.sessionNotes = '',
    @JsonKey(
      name: 'participant_engagement',
      fromJson: _participantEngagementFromJson,
      toJson: _participantEngagementToJson,
    )
    required this.participantEngagement,
    @JsonKey(name: 'goal_progress')
    final List<GoalProgressEntry> goalProgress = const [],
    @JsonKey(name: 'behavior_incidents')
    final List<BehaviorIncident> behaviorIncidents = const [],
    @JsonKey(name: 'media') final List<MediaItem> media = const [],
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
    @JsonKey(name: 'activity_title') this.activityTitle,
    @JsonKey(name: 'activity_type') this.activityType,
    @JsonKey(name: 'client_name') this.clientName,
    @JsonKey(name: 'stakeholder_name') this.stakeholderName,
    @JsonKey(name: 'goal_titles') final List<String>? goalTitles,
  }) : _goalProgress = goalProgress,
       _behaviorIncidents = behaviorIncidents,
       _media = media,
       _goalTitles = goalTitles;

  factory _$ActivitySessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivitySessionImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final String id;
  @override
  @JsonKey(name: 'activity_id')
  final String activityId;
  @override
  @JsonKey(name: 'client_id')
  final String clientId;
  @override
  @JsonKey(name: 'user_id')
  final String stakeholderId;
  @override
  @JsonKey(name: 'shift_note_id')
  final String? shiftNoteId;
  @override
  @JsonKey(name: 'session_start_time')
  final DateTime sessionStartTime;
  @override
  @JsonKey(name: 'session_end_time')
  final DateTime sessionEndTime;
  @override
  @JsonKey(name: 'duration_minutes', fromJson: _durationToInt)
  final int durationMinutes;
  @override
  @JsonKey()
  final String location;
  @override
  @JsonKey(name: 'session_notes')
  final String sessionNotes;
  @override
  @JsonKey(
    name: 'participant_engagement',
    fromJson: _participantEngagementFromJson,
    toJson: _participantEngagementToJson,
  )
  final ParticipantEngagement participantEngagement;
  final List<GoalProgressEntry> _goalProgress;
  @override
  @JsonKey(name: 'goal_progress')
  List<GoalProgressEntry> get goalProgress {
    if (_goalProgress is EqualUnmodifiableListView) return _goalProgress;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_goalProgress);
  }

  final List<BehaviorIncident> _behaviorIncidents;
  @override
  @JsonKey(name: 'behavior_incidents')
  List<BehaviorIncident> get behaviorIncidents {
    if (_behaviorIncidents is EqualUnmodifiableListView)
      return _behaviorIncidents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_behaviorIncidents);
  }

  final List<MediaItem> _media;
  @override
  @JsonKey(name: 'media')
  List<MediaItem> get media {
    if (_media is EqualUnmodifiableListView) return _media;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_media);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  // Enriched fields (from backend query)
  @override
  @JsonKey(name: 'activity_title')
  final String? activityTitle;
  @override
  @JsonKey(name: 'activity_type')
  final String? activityType;
  @override
  @JsonKey(name: 'client_name')
  final String? clientName;
  @override
  @JsonKey(name: 'stakeholder_name')
  final String? stakeholderName;
  final List<String>? _goalTitles;
  @override
  @JsonKey(name: 'goal_titles')
  List<String>? get goalTitles {
    final value = _goalTitles;
    if (value == null) return null;
    if (_goalTitles is EqualUnmodifiableListView) return _goalTitles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ActivitySession(id: $id, activityId: $activityId, clientId: $clientId, stakeholderId: $stakeholderId, shiftNoteId: $shiftNoteId, sessionStartTime: $sessionStartTime, sessionEndTime: $sessionEndTime, durationMinutes: $durationMinutes, location: $location, sessionNotes: $sessionNotes, participantEngagement: $participantEngagement, goalProgress: $goalProgress, behaviorIncidents: $behaviorIncidents, media: $media, createdAt: $createdAt, updatedAt: $updatedAt, activityTitle: $activityTitle, activityType: $activityType, clientName: $clientName, stakeholderName: $stakeholderName, goalTitles: $goalTitles)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivitySessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.activityId, activityId) ||
                other.activityId == activityId) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.stakeholderId, stakeholderId) ||
                other.stakeholderId == stakeholderId) &&
            (identical(other.shiftNoteId, shiftNoteId) ||
                other.shiftNoteId == shiftNoteId) &&
            (identical(other.sessionStartTime, sessionStartTime) ||
                other.sessionStartTime == sessionStartTime) &&
            (identical(other.sessionEndTime, sessionEndTime) ||
                other.sessionEndTime == sessionEndTime) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.sessionNotes, sessionNotes) ||
                other.sessionNotes == sessionNotes) &&
            (identical(other.participantEngagement, participantEngagement) ||
                other.participantEngagement == participantEngagement) &&
            const DeepCollectionEquality().equals(
              other._goalProgress,
              _goalProgress,
            ) &&
            const DeepCollectionEquality().equals(
              other._behaviorIncidents,
              _behaviorIncidents,
            ) &&
            const DeepCollectionEquality().equals(other._media, _media) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.activityTitle, activityTitle) ||
                other.activityTitle == activityTitle) &&
            (identical(other.activityType, activityType) ||
                other.activityType == activityType) &&
            (identical(other.clientName, clientName) ||
                other.clientName == clientName) &&
            (identical(other.stakeholderName, stakeholderName) ||
                other.stakeholderName == stakeholderName) &&
            const DeepCollectionEquality().equals(
              other._goalTitles,
              _goalTitles,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    activityId,
    clientId,
    stakeholderId,
    shiftNoteId,
    sessionStartTime,
    sessionEndTime,
    durationMinutes,
    location,
    sessionNotes,
    participantEngagement,
    const DeepCollectionEquality().hash(_goalProgress),
    const DeepCollectionEquality().hash(_behaviorIncidents),
    const DeepCollectionEquality().hash(_media),
    createdAt,
    updatedAt,
    activityTitle,
    activityType,
    clientName,
    stakeholderName,
    const DeepCollectionEquality().hash(_goalTitles),
  ]);

  /// Create a copy of ActivitySession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivitySessionImplCopyWith<_$ActivitySessionImpl> get copyWith =>
      __$$ActivitySessionImplCopyWithImpl<_$ActivitySessionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivitySessionImplToJson(this);
  }
}

abstract class _ActivitySession implements ActivitySession {
  const factory _ActivitySession({
    @JsonKey(name: 'id') required final String id,
    @JsonKey(name: 'activity_id') required final String activityId,
    @JsonKey(name: 'client_id') required final String clientId,
    @JsonKey(name: 'user_id') required final String stakeholderId,
    @JsonKey(name: 'shift_note_id') final String? shiftNoteId,
    @JsonKey(name: 'session_start_time')
    required final DateTime sessionStartTime,
    @JsonKey(name: 'session_end_time') required final DateTime sessionEndTime,
    @JsonKey(name: 'duration_minutes', fromJson: _durationToInt)
    required final int durationMinutes,
    final String location,
    @JsonKey(name: 'session_notes') final String sessionNotes,
    @JsonKey(
      name: 'participant_engagement',
      fromJson: _participantEngagementFromJson,
      toJson: _participantEngagementToJson,
    )
    required final ParticipantEngagement participantEngagement,
    @JsonKey(name: 'goal_progress') final List<GoalProgressEntry> goalProgress,
    @JsonKey(name: 'behavior_incidents')
    final List<BehaviorIncident> behaviorIncidents,
    @JsonKey(name: 'media') final List<MediaItem> media,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
    @JsonKey(name: 'activity_title') final String? activityTitle,
    @JsonKey(name: 'activity_type') final String? activityType,
    @JsonKey(name: 'client_name') final String? clientName,
    @JsonKey(name: 'stakeholder_name') final String? stakeholderName,
    @JsonKey(name: 'goal_titles') final List<String>? goalTitles,
  }) = _$ActivitySessionImpl;

  factory _ActivitySession.fromJson(Map<String, dynamic> json) =
      _$ActivitySessionImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  String get id;
  @override
  @JsonKey(name: 'activity_id')
  String get activityId;
  @override
  @JsonKey(name: 'client_id')
  String get clientId;
  @override
  @JsonKey(name: 'user_id')
  String get stakeholderId;
  @override
  @JsonKey(name: 'shift_note_id')
  String? get shiftNoteId;
  @override
  @JsonKey(name: 'session_start_time')
  DateTime get sessionStartTime;
  @override
  @JsonKey(name: 'session_end_time')
  DateTime get sessionEndTime;
  @override
  @JsonKey(name: 'duration_minutes', fromJson: _durationToInt)
  int get durationMinutes;
  @override
  String get location;
  @override
  @JsonKey(name: 'session_notes')
  String get sessionNotes;
  @override
  @JsonKey(
    name: 'participant_engagement',
    fromJson: _participantEngagementFromJson,
    toJson: _participantEngagementToJson,
  )
  ParticipantEngagement get participantEngagement;
  @override
  @JsonKey(name: 'goal_progress')
  List<GoalProgressEntry> get goalProgress;
  @override
  @JsonKey(name: 'behavior_incidents')
  List<BehaviorIncident> get behaviorIncidents;
  @override
  @JsonKey(name: 'media')
  List<MediaItem> get media;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt; // Enriched fields (from backend query)
  @override
  @JsonKey(name: 'activity_title')
  String? get activityTitle;
  @override
  @JsonKey(name: 'activity_type')
  String? get activityType;
  @override
  @JsonKey(name: 'client_name')
  String? get clientName;
  @override
  @JsonKey(name: 'stakeholder_name')
  String? get stakeholderName;
  @override
  @JsonKey(name: 'goal_titles')
  List<String>? get goalTitles;

  /// Create a copy of ActivitySession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivitySessionImplCopyWith<_$ActivitySessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DraftActivitySession _$DraftActivitySessionFromJson(Map<String, dynamic> json) {
  return _DraftActivitySession.fromJson(json);
}

/// @nodoc
mixin _$DraftActivitySession {
  String get id => throw _privateConstructorUsedError; // Local UUID
  @JsonKey(name: 'activity_id')
  String get activityId => throw _privateConstructorUsedError;
  @JsonKey(name: 'client_id')
  String get clientId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get stakeholderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'performed_at')
  DateTime get performedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_minutes')
  int? get durationMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'session_notes')
  String? get sessionNotes => throw _privateConstructorUsedError;
  @JsonKey(
    name: 'participant_engagement',
    fromJson: _participantEngagementFromJsonNullable,
    toJson: _participantEngagementToJsonNullable,
  )
  ParticipantEngagement? get participantEngagement =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'goal_progress')
  List<GoalProgressEntry> get goalProgress =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'behavior_incident_ids')
  List<String> get behaviorIncidentIds => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(
    name: 'sync_status',
    fromJson: _syncStatusFromJson,
    toJson: _syncStatusToJson,
  )
  SyncStatus get syncStatus => throw _privateConstructorUsedError;

  /// Serializes this DraftActivitySession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DraftActivitySession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DraftActivitySessionCopyWith<DraftActivitySession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DraftActivitySessionCopyWith<$Res> {
  factory $DraftActivitySessionCopyWith(
    DraftActivitySession value,
    $Res Function(DraftActivitySession) then,
  ) = _$DraftActivitySessionCopyWithImpl<$Res, DraftActivitySession>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'activity_id') String activityId,
    @JsonKey(name: 'client_id') String clientId,
    @JsonKey(name: 'user_id') String stakeholderId,
    @JsonKey(name: 'performed_at') DateTime performedAt,
    @JsonKey(name: 'duration_minutes') int? durationMinutes,
    @JsonKey(name: 'session_notes') String? sessionNotes,
    @JsonKey(
      name: 'participant_engagement',
      fromJson: _participantEngagementFromJsonNullable,
      toJson: _participantEngagementToJsonNullable,
    )
    ParticipantEngagement? participantEngagement,
    @JsonKey(name: 'goal_progress') List<GoalProgressEntry> goalProgress,
    @JsonKey(name: 'behavior_incident_ids') List<String> behaviorIncidentIds,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    @JsonKey(
      name: 'sync_status',
      fromJson: _syncStatusFromJson,
      toJson: _syncStatusToJson,
    )
    SyncStatus syncStatus,
  });
}

/// @nodoc
class _$DraftActivitySessionCopyWithImpl<
  $Res,
  $Val extends DraftActivitySession
>
    implements $DraftActivitySessionCopyWith<$Res> {
  _$DraftActivitySessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DraftActivitySession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? activityId = null,
    Object? clientId = null,
    Object? stakeholderId = null,
    Object? performedAt = null,
    Object? durationMinutes = freezed,
    Object? sessionNotes = freezed,
    Object? participantEngagement = freezed,
    Object? goalProgress = null,
    Object? behaviorIncidentIds = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? syncStatus = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            activityId: null == activityId
                ? _value.activityId
                : activityId // ignore: cast_nullable_to_non_nullable
                      as String,
            clientId: null == clientId
                ? _value.clientId
                : clientId // ignore: cast_nullable_to_non_nullable
                      as String,
            stakeholderId: null == stakeholderId
                ? _value.stakeholderId
                : stakeholderId // ignore: cast_nullable_to_non_nullable
                      as String,
            performedAt: null == performedAt
                ? _value.performedAt
                : performedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            durationMinutes: freezed == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            sessionNotes: freezed == sessionNotes
                ? _value.sessionNotes
                : sessionNotes // ignore: cast_nullable_to_non_nullable
                      as String?,
            participantEngagement: freezed == participantEngagement
                ? _value.participantEngagement
                : participantEngagement // ignore: cast_nullable_to_non_nullable
                      as ParticipantEngagement?,
            goalProgress: null == goalProgress
                ? _value.goalProgress
                : goalProgress // ignore: cast_nullable_to_non_nullable
                      as List<GoalProgressEntry>,
            behaviorIncidentIds: null == behaviorIncidentIds
                ? _value.behaviorIncidentIds
                : behaviorIncidentIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            syncStatus: null == syncStatus
                ? _value.syncStatus
                : syncStatus // ignore: cast_nullable_to_non_nullable
                      as SyncStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DraftActivitySessionImplCopyWith<$Res>
    implements $DraftActivitySessionCopyWith<$Res> {
  factory _$$DraftActivitySessionImplCopyWith(
    _$DraftActivitySessionImpl value,
    $Res Function(_$DraftActivitySessionImpl) then,
  ) = __$$DraftActivitySessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'activity_id') String activityId,
    @JsonKey(name: 'client_id') String clientId,
    @JsonKey(name: 'user_id') String stakeholderId,
    @JsonKey(name: 'performed_at') DateTime performedAt,
    @JsonKey(name: 'duration_minutes') int? durationMinutes,
    @JsonKey(name: 'session_notes') String? sessionNotes,
    @JsonKey(
      name: 'participant_engagement',
      fromJson: _participantEngagementFromJsonNullable,
      toJson: _participantEngagementToJsonNullable,
    )
    ParticipantEngagement? participantEngagement,
    @JsonKey(name: 'goal_progress') List<GoalProgressEntry> goalProgress,
    @JsonKey(name: 'behavior_incident_ids') List<String> behaviorIncidentIds,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    @JsonKey(
      name: 'sync_status',
      fromJson: _syncStatusFromJson,
      toJson: _syncStatusToJson,
    )
    SyncStatus syncStatus,
  });
}

/// @nodoc
class __$$DraftActivitySessionImplCopyWithImpl<$Res>
    extends _$DraftActivitySessionCopyWithImpl<$Res, _$DraftActivitySessionImpl>
    implements _$$DraftActivitySessionImplCopyWith<$Res> {
  __$$DraftActivitySessionImplCopyWithImpl(
    _$DraftActivitySessionImpl _value,
    $Res Function(_$DraftActivitySessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DraftActivitySession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? activityId = null,
    Object? clientId = null,
    Object? stakeholderId = null,
    Object? performedAt = null,
    Object? durationMinutes = freezed,
    Object? sessionNotes = freezed,
    Object? participantEngagement = freezed,
    Object? goalProgress = null,
    Object? behaviorIncidentIds = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? syncStatus = null,
  }) {
    return _then(
      _$DraftActivitySessionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        activityId: null == activityId
            ? _value.activityId
            : activityId // ignore: cast_nullable_to_non_nullable
                  as String,
        clientId: null == clientId
            ? _value.clientId
            : clientId // ignore: cast_nullable_to_non_nullable
                  as String,
        stakeholderId: null == stakeholderId
            ? _value.stakeholderId
            : stakeholderId // ignore: cast_nullable_to_non_nullable
                  as String,
        performedAt: null == performedAt
            ? _value.performedAt
            : performedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        durationMinutes: freezed == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        sessionNotes: freezed == sessionNotes
            ? _value.sessionNotes
            : sessionNotes // ignore: cast_nullable_to_non_nullable
                  as String?,
        participantEngagement: freezed == participantEngagement
            ? _value.participantEngagement
            : participantEngagement // ignore: cast_nullable_to_non_nullable
                  as ParticipantEngagement?,
        goalProgress: null == goalProgress
            ? _value._goalProgress
            : goalProgress // ignore: cast_nullable_to_non_nullable
                  as List<GoalProgressEntry>,
        behaviorIncidentIds: null == behaviorIncidentIds
            ? _value._behaviorIncidentIds
            : behaviorIncidentIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        syncStatus: null == syncStatus
            ? _value.syncStatus
            : syncStatus // ignore: cast_nullable_to_non_nullable
                  as SyncStatus,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DraftActivitySessionImpl implements _DraftActivitySession {
  const _$DraftActivitySessionImpl({
    required this.id,
    @JsonKey(name: 'activity_id') required this.activityId,
    @JsonKey(name: 'client_id') required this.clientId,
    @JsonKey(name: 'user_id') required this.stakeholderId,
    @JsonKey(name: 'performed_at') required this.performedAt,
    @JsonKey(name: 'duration_minutes') this.durationMinutes,
    @JsonKey(name: 'session_notes') this.sessionNotes,
    @JsonKey(
      name: 'participant_engagement',
      fromJson: _participantEngagementFromJsonNullable,
      toJson: _participantEngagementToJsonNullable,
    )
    this.participantEngagement,
    @JsonKey(name: 'goal_progress')
    final List<GoalProgressEntry> goalProgress = const [],
    @JsonKey(name: 'behavior_incident_ids')
    final List<String> behaviorIncidentIds = const [],
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
    @JsonKey(
      name: 'sync_status',
      fromJson: _syncStatusFromJson,
      toJson: _syncStatusToJson,
    )
    required this.syncStatus,
  }) : _goalProgress = goalProgress,
       _behaviorIncidentIds = behaviorIncidentIds;

  factory _$DraftActivitySessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$DraftActivitySessionImplFromJson(json);

  @override
  final String id;
  // Local UUID
  @override
  @JsonKey(name: 'activity_id')
  final String activityId;
  @override
  @JsonKey(name: 'client_id')
  final String clientId;
  @override
  @JsonKey(name: 'user_id')
  final String stakeholderId;
  @override
  @JsonKey(name: 'performed_at')
  final DateTime performedAt;
  @override
  @JsonKey(name: 'duration_minutes')
  final int? durationMinutes;
  @override
  @JsonKey(name: 'session_notes')
  final String? sessionNotes;
  @override
  @JsonKey(
    name: 'participant_engagement',
    fromJson: _participantEngagementFromJsonNullable,
    toJson: _participantEngagementToJsonNullable,
  )
  final ParticipantEngagement? participantEngagement;
  final List<GoalProgressEntry> _goalProgress;
  @override
  @JsonKey(name: 'goal_progress')
  List<GoalProgressEntry> get goalProgress {
    if (_goalProgress is EqualUnmodifiableListView) return _goalProgress;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_goalProgress);
  }

  final List<String> _behaviorIncidentIds;
  @override
  @JsonKey(name: 'behavior_incident_ids')
  List<String> get behaviorIncidentIds {
    if (_behaviorIncidentIds is EqualUnmodifiableListView)
      return _behaviorIncidentIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_behaviorIncidentIds);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @override
  @JsonKey(
    name: 'sync_status',
    fromJson: _syncStatusFromJson,
    toJson: _syncStatusToJson,
  )
  final SyncStatus syncStatus;

  @override
  String toString() {
    return 'DraftActivitySession(id: $id, activityId: $activityId, clientId: $clientId, stakeholderId: $stakeholderId, performedAt: $performedAt, durationMinutes: $durationMinutes, sessionNotes: $sessionNotes, participantEngagement: $participantEngagement, goalProgress: $goalProgress, behaviorIncidentIds: $behaviorIncidentIds, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DraftActivitySessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.activityId, activityId) ||
                other.activityId == activityId) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.stakeholderId, stakeholderId) ||
                other.stakeholderId == stakeholderId) &&
            (identical(other.performedAt, performedAt) ||
                other.performedAt == performedAt) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.sessionNotes, sessionNotes) ||
                other.sessionNotes == sessionNotes) &&
            (identical(other.participantEngagement, participantEngagement) ||
                other.participantEngagement == participantEngagement) &&
            const DeepCollectionEquality().equals(
              other._goalProgress,
              _goalProgress,
            ) &&
            const DeepCollectionEquality().equals(
              other._behaviorIncidentIds,
              _behaviorIncidentIds,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    activityId,
    clientId,
    stakeholderId,
    performedAt,
    durationMinutes,
    sessionNotes,
    participantEngagement,
    const DeepCollectionEquality().hash(_goalProgress),
    const DeepCollectionEquality().hash(_behaviorIncidentIds),
    createdAt,
    updatedAt,
    syncStatus,
  );

  /// Create a copy of DraftActivitySession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DraftActivitySessionImplCopyWith<_$DraftActivitySessionImpl>
  get copyWith =>
      __$$DraftActivitySessionImplCopyWithImpl<_$DraftActivitySessionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DraftActivitySessionImplToJson(this);
  }
}

abstract class _DraftActivitySession implements DraftActivitySession {
  const factory _DraftActivitySession({
    required final String id,
    @JsonKey(name: 'activity_id') required final String activityId,
    @JsonKey(name: 'client_id') required final String clientId,
    @JsonKey(name: 'user_id') required final String stakeholderId,
    @JsonKey(name: 'performed_at') required final DateTime performedAt,
    @JsonKey(name: 'duration_minutes') final int? durationMinutes,
    @JsonKey(name: 'session_notes') final String? sessionNotes,
    @JsonKey(
      name: 'participant_engagement',
      fromJson: _participantEngagementFromJsonNullable,
      toJson: _participantEngagementToJsonNullable,
    )
    final ParticipantEngagement? participantEngagement,
    @JsonKey(name: 'goal_progress') final List<GoalProgressEntry> goalProgress,
    @JsonKey(name: 'behavior_incident_ids')
    final List<String> behaviorIncidentIds,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
    @JsonKey(
      name: 'sync_status',
      fromJson: _syncStatusFromJson,
      toJson: _syncStatusToJson,
    )
    required final SyncStatus syncStatus,
  }) = _$DraftActivitySessionImpl;

  factory _DraftActivitySession.fromJson(Map<String, dynamic> json) =
      _$DraftActivitySessionImpl.fromJson;

  @override
  String get id; // Local UUID
  @override
  @JsonKey(name: 'activity_id')
  String get activityId;
  @override
  @JsonKey(name: 'client_id')
  String get clientId;
  @override
  @JsonKey(name: 'user_id')
  String get stakeholderId;
  @override
  @JsonKey(name: 'performed_at')
  DateTime get performedAt;
  @override
  @JsonKey(name: 'duration_minutes')
  int? get durationMinutes;
  @override
  @JsonKey(name: 'session_notes')
  String? get sessionNotes;
  @override
  @JsonKey(
    name: 'participant_engagement',
    fromJson: _participantEngagementFromJsonNullable,
    toJson: _participantEngagementToJsonNullable,
  )
  ParticipantEngagement? get participantEngagement;
  @override
  @JsonKey(name: 'goal_progress')
  List<GoalProgressEntry> get goalProgress;
  @override
  @JsonKey(name: 'behavior_incident_ids')
  List<String> get behaviorIncidentIds;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  @JsonKey(
    name: 'sync_status',
    fromJson: _syncStatusFromJson,
    toJson: _syncStatusToJson,
  )
  SyncStatus get syncStatus;

  /// Create a copy of DraftActivitySession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DraftActivitySessionImplCopyWith<_$DraftActivitySessionImpl>
  get copyWith => throw _privateConstructorUsedError;
}
