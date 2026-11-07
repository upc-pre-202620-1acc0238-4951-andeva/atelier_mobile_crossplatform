// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PendingOperationsTable extends PendingOperations
    with TableInfo<$PendingOperationsTable, PendingOperationEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dedupeKeyMeta = const VerificationMeta(
    'dedupeKey',
  );
  @override
  late final GeneratedColumn<String> dedupeKey = GeneratedColumn<String>(
    'dedupe_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<int> nextAttemptAt = GeneratedColumn<int>(
    'next_attempt_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastHttpStatusMeta = const VerificationMeta(
    'lastHttpStatus',
  );
  @override
  late final GeneratedColumn<int> lastHttpStatus = GeneratedColumn<int>(
    'last_http_status',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorCodeMeta = const VerificationMeta(
    'lastErrorCode',
  );
  @override
  late final GeneratedColumn<String> lastErrorCode = GeneratedColumn<String>(
    'last_error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMessageMeta = const VerificationMeta(
    'lastErrorMessage',
  );
  @override
  late final GeneratedColumn<String> lastErrorMessage = GeneratedColumn<String>(
    'last_error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _dependsOnMeta = const VerificationMeta(
    'dependsOn',
  );
  @override
  late final GeneratedColumn<String> dependsOn = GeneratedColumn<String>(
    'depends_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    payload,
    dedupeKey,
    userId,
    tenantId,
    status,
    attempts,
    nextAttemptAt,
    lastHttpStatus,
    lastErrorCode,
    lastErrorMessage,
    createdAt,
    dependsOn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingOperationEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('dedupe_key')) {
      context.handle(
        _dedupeKeyMeta,
        dedupeKey.isAcceptableOrUnknown(data['dedupe_key']!, _dedupeKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dedupeKeyMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextAttemptAtMeta);
    }
    if (data.containsKey('last_http_status')) {
      context.handle(
        _lastHttpStatusMeta,
        lastHttpStatus.isAcceptableOrUnknown(
          data['last_http_status']!,
          _lastHttpStatusMeta,
        ),
      );
    }
    if (data.containsKey('last_error_code')) {
      context.handle(
        _lastErrorCodeMeta,
        lastErrorCode.isAcceptableOrUnknown(
          data['last_error_code']!,
          _lastErrorCodeMeta,
        ),
      );
    }
    if (data.containsKey('last_error_message')) {
      context.handle(
        _lastErrorMessageMeta,
        lastErrorMessage.isAcceptableOrUnknown(
          data['last_error_message']!,
          _lastErrorMessageMeta,
        ),
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
    if (data.containsKey('depends_on')) {
      context.handle(
        _dependsOnMeta,
        dependsOn.isAcceptableOrUnknown(data['depends_on']!, _dependsOnMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingOperationEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingOperationEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      dedupeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dedupe_key'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_attempt_at'],
      )!,
      lastHttpStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_http_status'],
      ),
      lastErrorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_code'],
      ),
      lastErrorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_message'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      dependsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}depends_on'],
      ),
    );
  }

  @override
  $PendingOperationsTable createAlias(String alias) {
    return $PendingOperationsTable(attachedDatabase, alias);
  }
}

class PendingOperationEntity extends DataClass
    implements Insertable<PendingOperationEntity> {
  final String id;
  final String type;
  final String payload;
  final String dedupeKey;
  final String userId;
  final String tenantId;
  final String status;
  final int attempts;
  final int nextAttemptAt;
  final int? lastHttpStatus;
  final String? lastErrorCode;
  final String? lastErrorMessage;
  final int createdAt;
  final String? dependsOn;
  const PendingOperationEntity({
    required this.id,
    required this.type,
    required this.payload,
    required this.dedupeKey,
    required this.userId,
    required this.tenantId,
    required this.status,
    required this.attempts,
    required this.nextAttemptAt,
    this.lastHttpStatus,
    this.lastErrorCode,
    this.lastErrorMessage,
    required this.createdAt,
    this.dependsOn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['payload'] = Variable<String>(payload);
    map['dedupe_key'] = Variable<String>(dedupeKey);
    map['user_id'] = Variable<String>(userId);
    map['tenant_id'] = Variable<String>(tenantId);
    map['status'] = Variable<String>(status);
    map['attempts'] = Variable<int>(attempts);
    map['next_attempt_at'] = Variable<int>(nextAttemptAt);
    if (!nullToAbsent || lastHttpStatus != null) {
      map['last_http_status'] = Variable<int>(lastHttpStatus);
    }
    if (!nullToAbsent || lastErrorCode != null) {
      map['last_error_code'] = Variable<String>(lastErrorCode);
    }
    if (!nullToAbsent || lastErrorMessage != null) {
      map['last_error_message'] = Variable<String>(lastErrorMessage);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || dependsOn != null) {
      map['depends_on'] = Variable<String>(dependsOn);
    }
    return map;
  }

  PendingOperationsCompanion toCompanion(bool nullToAbsent) {
    return PendingOperationsCompanion(
      id: Value(id),
      type: Value(type),
      payload: Value(payload),
      dedupeKey: Value(dedupeKey),
      userId: Value(userId),
      tenantId: Value(tenantId),
      status: Value(status),
      attempts: Value(attempts),
      nextAttemptAt: Value(nextAttemptAt),
      lastHttpStatus: lastHttpStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(lastHttpStatus),
      lastErrorCode: lastErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCode),
      lastErrorMessage: lastErrorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorMessage),
      createdAt: Value(createdAt),
      dependsOn: dependsOn == null && nullToAbsent
          ? const Value.absent()
          : Value(dependsOn),
    );
  }

  factory PendingOperationEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingOperationEntity(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      payload: serializer.fromJson<String>(json['payload']),
      dedupeKey: serializer.fromJson<String>(json['dedupeKey']),
      userId: serializer.fromJson<String>(json['userId']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      status: serializer.fromJson<String>(json['status']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextAttemptAt: serializer.fromJson<int>(json['nextAttemptAt']),
      lastHttpStatus: serializer.fromJson<int?>(json['lastHttpStatus']),
      lastErrorCode: serializer.fromJson<String?>(json['lastErrorCode']),
      lastErrorMessage: serializer.fromJson<String?>(json['lastErrorMessage']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      dependsOn: serializer.fromJson<String?>(json['dependsOn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'payload': serializer.toJson<String>(payload),
      'dedupeKey': serializer.toJson<String>(dedupeKey),
      'userId': serializer.toJson<String>(userId),
      'tenantId': serializer.toJson<String>(tenantId),
      'status': serializer.toJson<String>(status),
      'attempts': serializer.toJson<int>(attempts),
      'nextAttemptAt': serializer.toJson<int>(nextAttemptAt),
      'lastHttpStatus': serializer.toJson<int?>(lastHttpStatus),
      'lastErrorCode': serializer.toJson<String?>(lastErrorCode),
      'lastErrorMessage': serializer.toJson<String?>(lastErrorMessage),
      'createdAt': serializer.toJson<int>(createdAt),
      'dependsOn': serializer.toJson<String?>(dependsOn),
    };
  }

  PendingOperationEntity copyWith({
    String? id,
    String? type,
    String? payload,
    String? dedupeKey,
    String? userId,
    String? tenantId,
    String? status,
    int? attempts,
    int? nextAttemptAt,
    Value<int?> lastHttpStatus = const Value.absent(),
    Value<String?> lastErrorCode = const Value.absent(),
    Value<String?> lastErrorMessage = const Value.absent(),
    int? createdAt,
    Value<String?> dependsOn = const Value.absent(),
  }) => PendingOperationEntity(
    id: id ?? this.id,
    type: type ?? this.type,
    payload: payload ?? this.payload,
    dedupeKey: dedupeKey ?? this.dedupeKey,
    userId: userId ?? this.userId,
    tenantId: tenantId ?? this.tenantId,
    status: status ?? this.status,
    attempts: attempts ?? this.attempts,
    nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
    lastHttpStatus: lastHttpStatus.present
        ? lastHttpStatus.value
        : this.lastHttpStatus,
    lastErrorCode: lastErrorCode.present
        ? lastErrorCode.value
        : this.lastErrorCode,
    lastErrorMessage: lastErrorMessage.present
        ? lastErrorMessage.value
        : this.lastErrorMessage,
    createdAt: createdAt ?? this.createdAt,
    dependsOn: dependsOn.present ? dependsOn.value : this.dependsOn,
  );
  PendingOperationEntity copyWithCompanion(PendingOperationsCompanion data) {
    return PendingOperationEntity(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      payload: data.payload.present ? data.payload.value : this.payload,
      dedupeKey: data.dedupeKey.present ? data.dedupeKey.value : this.dedupeKey,
      userId: data.userId.present ? data.userId.value : this.userId,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      status: data.status.present ? data.status.value : this.status,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      lastHttpStatus: data.lastHttpStatus.present
          ? data.lastHttpStatus.value
          : this.lastHttpStatus,
      lastErrorCode: data.lastErrorCode.present
          ? data.lastErrorCode.value
          : this.lastErrorCode,
      lastErrorMessage: data.lastErrorMessage.present
          ? data.lastErrorMessage.value
          : this.lastErrorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      dependsOn: data.dependsOn.present ? data.dependsOn.value : this.dependsOn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingOperationEntity(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('payload: $payload, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('userId: $userId, ')
          ..write('tenantId: $tenantId, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastHttpStatus: $lastHttpStatus, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('lastErrorMessage: $lastErrorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('dependsOn: $dependsOn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    payload,
    dedupeKey,
    userId,
    tenantId,
    status,
    attempts,
    nextAttemptAt,
    lastHttpStatus,
    lastErrorCode,
    lastErrorMessage,
    createdAt,
    dependsOn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingOperationEntity &&
          other.id == this.id &&
          other.type == this.type &&
          other.payload == this.payload &&
          other.dedupeKey == this.dedupeKey &&
          other.userId == this.userId &&
          other.tenantId == this.tenantId &&
          other.status == this.status &&
          other.attempts == this.attempts &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.lastHttpStatus == this.lastHttpStatus &&
          other.lastErrorCode == this.lastErrorCode &&
          other.lastErrorMessage == this.lastErrorMessage &&
          other.createdAt == this.createdAt &&
          other.dependsOn == this.dependsOn);
}

class PendingOperationsCompanion
    extends UpdateCompanion<PendingOperationEntity> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> payload;
  final Value<String> dedupeKey;
  final Value<String> userId;
  final Value<String> tenantId;
  final Value<String> status;
  final Value<int> attempts;
  final Value<int> nextAttemptAt;
  final Value<int?> lastHttpStatus;
  final Value<String?> lastErrorCode;
  final Value<String?> lastErrorMessage;
  final Value<int> createdAt;
  final Value<String?> dependsOn;
  final Value<int> rowid;
  const PendingOperationsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.payload = const Value.absent(),
    this.dedupeKey = const Value.absent(),
    this.userId = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastHttpStatus = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.lastErrorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.dependsOn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingOperationsCompanion.insert({
    required String id,
    required String type,
    required String payload,
    required String dedupeKey,
    required String userId,
    required String tenantId,
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    required int nextAttemptAt,
    this.lastHttpStatus = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.lastErrorMessage = const Value.absent(),
    required int createdAt,
    this.dependsOn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       payload = Value(payload),
       dedupeKey = Value(dedupeKey),
       userId = Value(userId),
       tenantId = Value(tenantId),
       nextAttemptAt = Value(nextAttemptAt),
       createdAt = Value(createdAt);
  static Insertable<PendingOperationEntity> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? payload,
    Expression<String>? dedupeKey,
    Expression<String>? userId,
    Expression<String>? tenantId,
    Expression<String>? status,
    Expression<int>? attempts,
    Expression<int>? nextAttemptAt,
    Expression<int>? lastHttpStatus,
    Expression<String>? lastErrorCode,
    Expression<String>? lastErrorMessage,
    Expression<int>? createdAt,
    Expression<String>? dependsOn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (payload != null) 'payload': payload,
      if (dedupeKey != null) 'dedupe_key': dedupeKey,
      if (userId != null) 'user_id': userId,
      if (tenantId != null) 'tenant_id': tenantId,
      if (status != null) 'status': status,
      if (attempts != null) 'attempts': attempts,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (lastHttpStatus != null) 'last_http_status': lastHttpStatus,
      if (lastErrorCode != null) 'last_error_code': lastErrorCode,
      if (lastErrorMessage != null) 'last_error_message': lastErrorMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (dependsOn != null) 'depends_on': dependsOn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingOperationsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? payload,
    Value<String>? dedupeKey,
    Value<String>? userId,
    Value<String>? tenantId,
    Value<String>? status,
    Value<int>? attempts,
    Value<int>? nextAttemptAt,
    Value<int?>? lastHttpStatus,
    Value<String?>? lastErrorCode,
    Value<String?>? lastErrorMessage,
    Value<int>? createdAt,
    Value<String?>? dependsOn,
    Value<int>? rowid,
  }) {
    return PendingOperationsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      dedupeKey: dedupeKey ?? this.dedupeKey,
      userId: userId ?? this.userId,
      tenantId: tenantId ?? this.tenantId,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      lastHttpStatus: lastHttpStatus ?? this.lastHttpStatus,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      lastErrorMessage: lastErrorMessage ?? this.lastErrorMessage,
      createdAt: createdAt ?? this.createdAt,
      dependsOn: dependsOn ?? this.dependsOn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (dedupeKey.present) {
      map['dedupe_key'] = Variable<String>(dedupeKey.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<int>(nextAttemptAt.value);
    }
    if (lastHttpStatus.present) {
      map['last_http_status'] = Variable<int>(lastHttpStatus.value);
    }
    if (lastErrorCode.present) {
      map['last_error_code'] = Variable<String>(lastErrorCode.value);
    }
    if (lastErrorMessage.present) {
      map['last_error_message'] = Variable<String>(lastErrorMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (dependsOn.present) {
      map['depends_on'] = Variable<String>(dependsOn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingOperationsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('payload: $payload, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('userId: $userId, ')
          ..write('tenantId: $tenantId, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastHttpStatus: $lastHttpStatus, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('lastErrorMessage: $lastErrorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('dependsOn: $dependsOn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingUploadsTable extends PendingUploads
    with TableInfo<$PendingUploadsTable, PendingUploadEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingUploadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localFilePathMeta = const VerificationMeta(
    'localFilePath',
  );
  @override
  late final GeneratedColumn<String> localFilePath = GeneratedColumn<String>(
    'local_file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storagePathMeta = const VerificationMeta(
    'storagePath',
  );
  @override
  late final GeneratedColumn<String> storagePath = GeneratedColumn<String>(
    'storage_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<String> target = GeneratedColumn<String>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publicUrlMeta = const VerificationMeta(
    'publicUrl',
  );
  @override
  late final GeneratedColumn<String> publicUrl = GeneratedColumn<String>(
    'public_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    localFilePath,
    storagePath,
    target,
    publicUrl,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_uploads';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingUploadEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('local_file_path')) {
      context.handle(
        _localFilePathMeta,
        localFilePath.isAcceptableOrUnknown(
          data['local_file_path']!,
          _localFilePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localFilePathMeta);
    }
    if (data.containsKey('storage_path')) {
      context.handle(
        _storagePathMeta,
        storagePath.isAcceptableOrUnknown(
          data['storage_path']!,
          _storagePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storagePathMeta);
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    if (data.containsKey('public_url')) {
      context.handle(
        _publicUrlMeta,
        publicUrl.isAcceptableOrUnknown(data['public_url']!, _publicUrlMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingUploadEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingUploadEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      localFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_file_path'],
      )!,
      storagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_path'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target'],
      )!,
      publicUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PendingUploadsTable createAlias(String alias) {
    return $PendingUploadsTable(attachedDatabase, alias);
  }
}

class PendingUploadEntity extends DataClass
    implements Insertable<PendingUploadEntity> {
  final String id;
  final String localFilePath;
  final String storagePath;
  final String target;
  final String? publicUrl;
  final int createdAt;
  const PendingUploadEntity({
    required this.id,
    required this.localFilePath,
    required this.storagePath,
    required this.target,
    this.publicUrl,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['local_file_path'] = Variable<String>(localFilePath);
    map['storage_path'] = Variable<String>(storagePath);
    map['target'] = Variable<String>(target);
    if (!nullToAbsent || publicUrl != null) {
      map['public_url'] = Variable<String>(publicUrl);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  PendingUploadsCompanion toCompanion(bool nullToAbsent) {
    return PendingUploadsCompanion(
      id: Value(id),
      localFilePath: Value(localFilePath),
      storagePath: Value(storagePath),
      target: Value(target),
      publicUrl: publicUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(publicUrl),
      createdAt: Value(createdAt),
    );
  }

  factory PendingUploadEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingUploadEntity(
      id: serializer.fromJson<String>(json['id']),
      localFilePath: serializer.fromJson<String>(json['localFilePath']),
      storagePath: serializer.fromJson<String>(json['storagePath']),
      target: serializer.fromJson<String>(json['target']),
      publicUrl: serializer.fromJson<String?>(json['publicUrl']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'localFilePath': serializer.toJson<String>(localFilePath),
      'storagePath': serializer.toJson<String>(storagePath),
      'target': serializer.toJson<String>(target),
      'publicUrl': serializer.toJson<String?>(publicUrl),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  PendingUploadEntity copyWith({
    String? id,
    String? localFilePath,
    String? storagePath,
    String? target,
    Value<String?> publicUrl = const Value.absent(),
    int? createdAt,
  }) => PendingUploadEntity(
    id: id ?? this.id,
    localFilePath: localFilePath ?? this.localFilePath,
    storagePath: storagePath ?? this.storagePath,
    target: target ?? this.target,
    publicUrl: publicUrl.present ? publicUrl.value : this.publicUrl,
    createdAt: createdAt ?? this.createdAt,
  );
  PendingUploadEntity copyWithCompanion(PendingUploadsCompanion data) {
    return PendingUploadEntity(
      id: data.id.present ? data.id.value : this.id,
      localFilePath: data.localFilePath.present
          ? data.localFilePath.value
          : this.localFilePath,
      storagePath: data.storagePath.present
          ? data.storagePath.value
          : this.storagePath,
      target: data.target.present ? data.target.value : this.target,
      publicUrl: data.publicUrl.present ? data.publicUrl.value : this.publicUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingUploadEntity(')
          ..write('id: $id, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('storagePath: $storagePath, ')
          ..write('target: $target, ')
          ..write('publicUrl: $publicUrl, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, localFilePath, storagePath, target, publicUrl, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingUploadEntity &&
          other.id == this.id &&
          other.localFilePath == this.localFilePath &&
          other.storagePath == this.storagePath &&
          other.target == this.target &&
          other.publicUrl == this.publicUrl &&
          other.createdAt == this.createdAt);
}

class PendingUploadsCompanion extends UpdateCompanion<PendingUploadEntity> {
  final Value<String> id;
  final Value<String> localFilePath;
  final Value<String> storagePath;
  final Value<String> target;
  final Value<String?> publicUrl;
  final Value<int> createdAt;
  final Value<int> rowid;
  const PendingUploadsCompanion({
    this.id = const Value.absent(),
    this.localFilePath = const Value.absent(),
    this.storagePath = const Value.absent(),
    this.target = const Value.absent(),
    this.publicUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingUploadsCompanion.insert({
    required String id,
    required String localFilePath,
    required String storagePath,
    required String target,
    this.publicUrl = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       localFilePath = Value(localFilePath),
       storagePath = Value(storagePath),
       target = Value(target),
       createdAt = Value(createdAt);
  static Insertable<PendingUploadEntity> custom({
    Expression<String>? id,
    Expression<String>? localFilePath,
    Expression<String>? storagePath,
    Expression<String>? target,
    Expression<String>? publicUrl,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localFilePath != null) 'local_file_path': localFilePath,
      if (storagePath != null) 'storage_path': storagePath,
      if (target != null) 'target': target,
      if (publicUrl != null) 'public_url': publicUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingUploadsCompanion copyWith({
    Value<String>? id,
    Value<String>? localFilePath,
    Value<String>? storagePath,
    Value<String>? target,
    Value<String?>? publicUrl,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return PendingUploadsCompanion(
      id: id ?? this.id,
      localFilePath: localFilePath ?? this.localFilePath,
      storagePath: storagePath ?? this.storagePath,
      target: target ?? this.target,
      publicUrl: publicUrl ?? this.publicUrl,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (localFilePath.present) {
      map['local_file_path'] = Variable<String>(localFilePath.value);
    }
    if (storagePath.present) {
      map['storage_path'] = Variable<String>(storagePath.value);
    }
    if (target.present) {
      map['target'] = Variable<String>(target.value);
    }
    if (publicUrl.present) {
      map['public_url'] = Variable<String>(publicUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingUploadsCompanion(')
          ..write('id: $id, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('storagePath: $storagePath, ')
          ..write('target: $target, ')
          ..write('publicUrl: $publicUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CacheMetadataTable extends CacheMetadata
    with TableInfo<$CacheMetadataTable, CacheMetadataEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<int> lastSyncedAt = GeneratedColumn<int>(
    'last_synced_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordCountMeta = const VerificationMeta(
    'recordCount',
  );
  @override
  late final GeneratedColumn<int> recordCount = GeneratedColumn<int>(
    'record_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [scope, lastSyncedAt, recordCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<CacheMetadataEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSyncedAtMeta);
    }
    if (data.containsKey('record_count')) {
      context.handle(
        _recordCountMeta,
        recordCount.isAcceptableOrUnknown(
          data['record_count']!,
          _recordCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {scope};
  @override
  CacheMetadataEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheMetadataEntity(
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_at'],
      )!,
      recordCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}record_count'],
      )!,
    );
  }

  @override
  $CacheMetadataTable createAlias(String alias) {
    return $CacheMetadataTable(attachedDatabase, alias);
  }
}

class CacheMetadataEntity extends DataClass
    implements Insertable<CacheMetadataEntity> {
  final String scope;
  final int lastSyncedAt;
  final int recordCount;
  const CacheMetadataEntity({
    required this.scope,
    required this.lastSyncedAt,
    required this.recordCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['scope'] = Variable<String>(scope);
    map['last_synced_at'] = Variable<int>(lastSyncedAt);
    map['record_count'] = Variable<int>(recordCount);
    return map;
  }

  CacheMetadataCompanion toCompanion(bool nullToAbsent) {
    return CacheMetadataCompanion(
      scope: Value(scope),
      lastSyncedAt: Value(lastSyncedAt),
      recordCount: Value(recordCount),
    );
  }

  factory CacheMetadataEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheMetadataEntity(
      scope: serializer.fromJson<String>(json['scope']),
      lastSyncedAt: serializer.fromJson<int>(json['lastSyncedAt']),
      recordCount: serializer.fromJson<int>(json['recordCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'scope': serializer.toJson<String>(scope),
      'lastSyncedAt': serializer.toJson<int>(lastSyncedAt),
      'recordCount': serializer.toJson<int>(recordCount),
    };
  }

  CacheMetadataEntity copyWith({
    String? scope,
    int? lastSyncedAt,
    int? recordCount,
  }) => CacheMetadataEntity(
    scope: scope ?? this.scope,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    recordCount: recordCount ?? this.recordCount,
  );
  CacheMetadataEntity copyWithCompanion(CacheMetadataCompanion data) {
    return CacheMetadataEntity(
      scope: data.scope.present ? data.scope.value : this.scope,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      recordCount: data.recordCount.present
          ? data.recordCount.value
          : this.recordCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheMetadataEntity(')
          ..write('scope: $scope, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('recordCount: $recordCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(scope, lastSyncedAt, recordCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheMetadataEntity &&
          other.scope == this.scope &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.recordCount == this.recordCount);
}

class CacheMetadataCompanion extends UpdateCompanion<CacheMetadataEntity> {
  final Value<String> scope;
  final Value<int> lastSyncedAt;
  final Value<int> recordCount;
  final Value<int> rowid;
  const CacheMetadataCompanion({
    this.scope = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.recordCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheMetadataCompanion.insert({
    required String scope,
    required int lastSyncedAt,
    required int recordCount,
    this.rowid = const Value.absent(),
  }) : scope = Value(scope),
       lastSyncedAt = Value(lastSyncedAt),
       recordCount = Value(recordCount);
  static Insertable<CacheMetadataEntity> custom({
    Expression<String>? scope,
    Expression<int>? lastSyncedAt,
    Expression<int>? recordCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (scope != null) 'scope': scope,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (recordCount != null) 'record_count': recordCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheMetadataCompanion copyWith({
    Value<String>? scope,
    Value<int>? lastSyncedAt,
    Value<int>? recordCount,
    Value<int>? rowid,
  }) {
    return CacheMetadataCompanion(
      scope: scope ?? this.scope,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      recordCount: recordCount ?? this.recordCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt.value);
    }
    if (recordCount.present) {
      map['record_count'] = Variable<int>(recordCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheMetadataCompanion(')
          ..write('scope: $scope, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('recordCount: $recordCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttendancesTable extends Attendances
    with TableInfo<$AttendancesTable, AttendanceEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _branchIdMeta = const VerificationMeta(
    'branchId',
  );
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
    'branch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _membershipIdMeta = const VerificationMeta(
    'membershipId',
  );
  @override
  late final GeneratedColumn<String> membershipId = GeneratedColumn<String>(
    'membership_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shiftIdMeta = const VerificationMeta(
    'shiftId',
  );
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
    'shift_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clockInMeta = const VerificationMeta(
    'clockIn',
  );
  @override
  late final GeneratedColumn<int> clockIn = GeneratedColumn<int>(
    'clock_in',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clockOutMeta = const VerificationMeta(
    'clockOut',
  );
  @override
  late final GeneratedColumn<int> clockOut = GeneratedColumn<int>(
    'clock_out',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceToBranchMetersMeta =
      const VerificationMeta('distanceToBranchMeters');
  @override
  late final GeneratedColumn<double> distanceToBranchMeters =
      GeneratedColumn<double>(
        'distance_to_branch_m',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _workedMinutesMeta = const VerificationMeta(
    'workedMinutes',
  );
  @override
  late final GeneratedColumn<int> workedMinutes = GeneratedColumn<int>(
    'worked_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _regularMinutesMeta = const VerificationMeta(
    'regularMinutes',
  );
  @override
  late final GeneratedColumn<int> regularMinutes = GeneratedColumn<int>(
    'regular_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _overtimeMinutesMeta = const VerificationMeta(
    'overtimeMinutes',
  );
  @override
  late final GeneratedColumn<int> overtimeMinutes = GeneratedColumn<int>(
    'overtime_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _justificationReasonMeta =
      const VerificationMeta('justificationReason');
  @override
  late final GeneratedColumn<String> justificationReason =
      GeneratedColumn<String>(
        'justification_reason',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _justificationStatusMeta =
      const VerificationMeta('justificationStatus');
  @override
  late final GeneratedColumn<String> justificationStatus =
      GeneratedColumn<String>(
        'justification_status',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    branchId,
    membershipId,
    shiftId,
    clockIn,
    clockOut,
    status,
    latitude,
    longitude,
    distanceToBranchMeters,
    workedMinutes,
    regularMinutes,
    overtimeMinutes,
    justificationReason,
    justificationStatus,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendances';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(
        _branchIdMeta,
        branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('membership_id')) {
      context.handle(
        _membershipIdMeta,
        membershipId.isAcceptableOrUnknown(
          data['membership_id']!,
          _membershipIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_membershipIdMeta);
    }
    if (data.containsKey('shift_id')) {
      context.handle(
        _shiftIdMeta,
        shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shiftIdMeta);
    }
    if (data.containsKey('clock_in')) {
      context.handle(
        _clockInMeta,
        clockIn.isAcceptableOrUnknown(data['clock_in']!, _clockInMeta),
      );
    } else if (isInserting) {
      context.missing(_clockInMeta);
    }
    if (data.containsKey('clock_out')) {
      context.handle(
        _clockOutMeta,
        clockOut.isAcceptableOrUnknown(data['clock_out']!, _clockOutMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('distance_to_branch_m')) {
      context.handle(
        _distanceToBranchMetersMeta,
        distanceToBranchMeters.isAcceptableOrUnknown(
          data['distance_to_branch_m']!,
          _distanceToBranchMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_distanceToBranchMetersMeta);
    }
    if (data.containsKey('worked_minutes')) {
      context.handle(
        _workedMinutesMeta,
        workedMinutes.isAcceptableOrUnknown(
          data['worked_minutes']!,
          _workedMinutesMeta,
        ),
      );
    }
    if (data.containsKey('regular_minutes')) {
      context.handle(
        _regularMinutesMeta,
        regularMinutes.isAcceptableOrUnknown(
          data['regular_minutes']!,
          _regularMinutesMeta,
        ),
      );
    }
    if (data.containsKey('overtime_minutes')) {
      context.handle(
        _overtimeMinutesMeta,
        overtimeMinutes.isAcceptableOrUnknown(
          data['overtime_minutes']!,
          _overtimeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('justification_reason')) {
      context.handle(
        _justificationReasonMeta,
        justificationReason.isAcceptableOrUnknown(
          data['justification_reason']!,
          _justificationReasonMeta,
        ),
      );
    }
    if (data.containsKey('justification_status')) {
      context.handle(
        _justificationStatusMeta,
        justificationStatus.isAcceptableOrUnknown(
          data['justification_status']!,
          _justificationStatusMeta,
        ),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttendanceEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      branchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_id'],
      )!,
      membershipId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}membership_id'],
      )!,
      shiftId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shift_id'],
      )!,
      clockIn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}clock_in'],
      )!,
      clockOut: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}clock_out'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      distanceToBranchMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_to_branch_m'],
      )!,
      workedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}worked_minutes'],
      ),
      regularMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}regular_minutes'],
      ),
      overtimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}overtime_minutes'],
      ),
      justificationReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}justification_reason'],
      ),
      justificationStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}justification_status'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $AttendancesTable createAlias(String alias) {
    return $AttendancesTable(attachedDatabase, alias);
  }
}

class AttendanceEntity extends DataClass
    implements Insertable<AttendanceEntity> {
  final String id;
  final String branchId;
  final String membershipId;
  final String shiftId;
  final int clockIn;
  final int? clockOut;
  final String status;
  final double latitude;
  final double longitude;
  final double distanceToBranchMeters;
  final int? workedMinutes;
  final int? regularMinutes;
  final int? overtimeMinutes;
  final String? justificationReason;
  final String? justificationStatus;
  final int syncedAt;
  const AttendanceEntity({
    required this.id,
    required this.branchId,
    required this.membershipId,
    required this.shiftId,
    required this.clockIn,
    this.clockOut,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.distanceToBranchMeters,
    this.workedMinutes,
    this.regularMinutes,
    this.overtimeMinutes,
    this.justificationReason,
    this.justificationStatus,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['branch_id'] = Variable<String>(branchId);
    map['membership_id'] = Variable<String>(membershipId);
    map['shift_id'] = Variable<String>(shiftId);
    map['clock_in'] = Variable<int>(clockIn);
    if (!nullToAbsent || clockOut != null) {
      map['clock_out'] = Variable<int>(clockOut);
    }
    map['status'] = Variable<String>(status);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['distance_to_branch_m'] = Variable<double>(distanceToBranchMeters);
    if (!nullToAbsent || workedMinutes != null) {
      map['worked_minutes'] = Variable<int>(workedMinutes);
    }
    if (!nullToAbsent || regularMinutes != null) {
      map['regular_minutes'] = Variable<int>(regularMinutes);
    }
    if (!nullToAbsent || overtimeMinutes != null) {
      map['overtime_minutes'] = Variable<int>(overtimeMinutes);
    }
    if (!nullToAbsent || justificationReason != null) {
      map['justification_reason'] = Variable<String>(justificationReason);
    }
    if (!nullToAbsent || justificationStatus != null) {
      map['justification_status'] = Variable<String>(justificationStatus);
    }
    map['synced_at'] = Variable<int>(syncedAt);
    return map;
  }

  AttendancesCompanion toCompanion(bool nullToAbsent) {
    return AttendancesCompanion(
      id: Value(id),
      branchId: Value(branchId),
      membershipId: Value(membershipId),
      shiftId: Value(shiftId),
      clockIn: Value(clockIn),
      clockOut: clockOut == null && nullToAbsent
          ? const Value.absent()
          : Value(clockOut),
      status: Value(status),
      latitude: Value(latitude),
      longitude: Value(longitude),
      distanceToBranchMeters: Value(distanceToBranchMeters),
      workedMinutes: workedMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(workedMinutes),
      regularMinutes: regularMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(regularMinutes),
      overtimeMinutes: overtimeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(overtimeMinutes),
      justificationReason: justificationReason == null && nullToAbsent
          ? const Value.absent()
          : Value(justificationReason),
      justificationStatus: justificationStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(justificationStatus),
      syncedAt: Value(syncedAt),
    );
  }

  factory AttendanceEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceEntity(
      id: serializer.fromJson<String>(json['id']),
      branchId: serializer.fromJson<String>(json['branchId']),
      membershipId: serializer.fromJson<String>(json['membershipId']),
      shiftId: serializer.fromJson<String>(json['shiftId']),
      clockIn: serializer.fromJson<int>(json['clockIn']),
      clockOut: serializer.fromJson<int?>(json['clockOut']),
      status: serializer.fromJson<String>(json['status']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      distanceToBranchMeters: serializer.fromJson<double>(
        json['distanceToBranchMeters'],
      ),
      workedMinutes: serializer.fromJson<int?>(json['workedMinutes']),
      regularMinutes: serializer.fromJson<int?>(json['regularMinutes']),
      overtimeMinutes: serializer.fromJson<int?>(json['overtimeMinutes']),
      justificationReason: serializer.fromJson<String?>(
        json['justificationReason'],
      ),
      justificationStatus: serializer.fromJson<String?>(
        json['justificationStatus'],
      ),
      syncedAt: serializer.fromJson<int>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'branchId': serializer.toJson<String>(branchId),
      'membershipId': serializer.toJson<String>(membershipId),
      'shiftId': serializer.toJson<String>(shiftId),
      'clockIn': serializer.toJson<int>(clockIn),
      'clockOut': serializer.toJson<int?>(clockOut),
      'status': serializer.toJson<String>(status),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'distanceToBranchMeters': serializer.toJson<double>(
        distanceToBranchMeters,
      ),
      'workedMinutes': serializer.toJson<int?>(workedMinutes),
      'regularMinutes': serializer.toJson<int?>(regularMinutes),
      'overtimeMinutes': serializer.toJson<int?>(overtimeMinutes),
      'justificationReason': serializer.toJson<String?>(justificationReason),
      'justificationStatus': serializer.toJson<String?>(justificationStatus),
      'syncedAt': serializer.toJson<int>(syncedAt),
    };
  }

  AttendanceEntity copyWith({
    String? id,
    String? branchId,
    String? membershipId,
    String? shiftId,
    int? clockIn,
    Value<int?> clockOut = const Value.absent(),
    String? status,
    double? latitude,
    double? longitude,
    double? distanceToBranchMeters,
    Value<int?> workedMinutes = const Value.absent(),
    Value<int?> regularMinutes = const Value.absent(),
    Value<int?> overtimeMinutes = const Value.absent(),
    Value<String?> justificationReason = const Value.absent(),
    Value<String?> justificationStatus = const Value.absent(),
    int? syncedAt,
  }) => AttendanceEntity(
    id: id ?? this.id,
    branchId: branchId ?? this.branchId,
    membershipId: membershipId ?? this.membershipId,
    shiftId: shiftId ?? this.shiftId,
    clockIn: clockIn ?? this.clockIn,
    clockOut: clockOut.present ? clockOut.value : this.clockOut,
    status: status ?? this.status,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    distanceToBranchMeters:
        distanceToBranchMeters ?? this.distanceToBranchMeters,
    workedMinutes: workedMinutes.present
        ? workedMinutes.value
        : this.workedMinutes,
    regularMinutes: regularMinutes.present
        ? regularMinutes.value
        : this.regularMinutes,
    overtimeMinutes: overtimeMinutes.present
        ? overtimeMinutes.value
        : this.overtimeMinutes,
    justificationReason: justificationReason.present
        ? justificationReason.value
        : this.justificationReason,
    justificationStatus: justificationStatus.present
        ? justificationStatus.value
        : this.justificationStatus,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  AttendanceEntity copyWithCompanion(AttendancesCompanion data) {
    return AttendanceEntity(
      id: data.id.present ? data.id.value : this.id,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      membershipId: data.membershipId.present
          ? data.membershipId.value
          : this.membershipId,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      clockIn: data.clockIn.present ? data.clockIn.value : this.clockIn,
      clockOut: data.clockOut.present ? data.clockOut.value : this.clockOut,
      status: data.status.present ? data.status.value : this.status,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      distanceToBranchMeters: data.distanceToBranchMeters.present
          ? data.distanceToBranchMeters.value
          : this.distanceToBranchMeters,
      workedMinutes: data.workedMinutes.present
          ? data.workedMinutes.value
          : this.workedMinutes,
      regularMinutes: data.regularMinutes.present
          ? data.regularMinutes.value
          : this.regularMinutes,
      overtimeMinutes: data.overtimeMinutes.present
          ? data.overtimeMinutes.value
          : this.overtimeMinutes,
      justificationReason: data.justificationReason.present
          ? data.justificationReason.value
          : this.justificationReason,
      justificationStatus: data.justificationStatus.present
          ? data.justificationStatus.value
          : this.justificationStatus,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceEntity(')
          ..write('id: $id, ')
          ..write('branchId: $branchId, ')
          ..write('membershipId: $membershipId, ')
          ..write('shiftId: $shiftId, ')
          ..write('clockIn: $clockIn, ')
          ..write('clockOut: $clockOut, ')
          ..write('status: $status, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('distanceToBranchMeters: $distanceToBranchMeters, ')
          ..write('workedMinutes: $workedMinutes, ')
          ..write('regularMinutes: $regularMinutes, ')
          ..write('overtimeMinutes: $overtimeMinutes, ')
          ..write('justificationReason: $justificationReason, ')
          ..write('justificationStatus: $justificationStatus, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    branchId,
    membershipId,
    shiftId,
    clockIn,
    clockOut,
    status,
    latitude,
    longitude,
    distanceToBranchMeters,
    workedMinutes,
    regularMinutes,
    overtimeMinutes,
    justificationReason,
    justificationStatus,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceEntity &&
          other.id == this.id &&
          other.branchId == this.branchId &&
          other.membershipId == this.membershipId &&
          other.shiftId == this.shiftId &&
          other.clockIn == this.clockIn &&
          other.clockOut == this.clockOut &&
          other.status == this.status &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.distanceToBranchMeters == this.distanceToBranchMeters &&
          other.workedMinutes == this.workedMinutes &&
          other.regularMinutes == this.regularMinutes &&
          other.overtimeMinutes == this.overtimeMinutes &&
          other.justificationReason == this.justificationReason &&
          other.justificationStatus == this.justificationStatus &&
          other.syncedAt == this.syncedAt);
}

class AttendancesCompanion extends UpdateCompanion<AttendanceEntity> {
  final Value<String> id;
  final Value<String> branchId;
  final Value<String> membershipId;
  final Value<String> shiftId;
  final Value<int> clockIn;
  final Value<int?> clockOut;
  final Value<String> status;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double> distanceToBranchMeters;
  final Value<int?> workedMinutes;
  final Value<int?> regularMinutes;
  final Value<int?> overtimeMinutes;
  final Value<String?> justificationReason;
  final Value<String?> justificationStatus;
  final Value<int> syncedAt;
  final Value<int> rowid;
  const AttendancesCompanion({
    this.id = const Value.absent(),
    this.branchId = const Value.absent(),
    this.membershipId = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.clockIn = const Value.absent(),
    this.clockOut = const Value.absent(),
    this.status = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.distanceToBranchMeters = const Value.absent(),
    this.workedMinutes = const Value.absent(),
    this.regularMinutes = const Value.absent(),
    this.overtimeMinutes = const Value.absent(),
    this.justificationReason = const Value.absent(),
    this.justificationStatus = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttendancesCompanion.insert({
    required String id,
    required String branchId,
    required String membershipId,
    required String shiftId,
    required int clockIn,
    this.clockOut = const Value.absent(),
    required String status,
    required double latitude,
    required double longitude,
    required double distanceToBranchMeters,
    this.workedMinutes = const Value.absent(),
    this.regularMinutes = const Value.absent(),
    this.overtimeMinutes = const Value.absent(),
    this.justificationReason = const Value.absent(),
    this.justificationStatus = const Value.absent(),
    required int syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       branchId = Value(branchId),
       membershipId = Value(membershipId),
       shiftId = Value(shiftId),
       clockIn = Value(clockIn),
       status = Value(status),
       latitude = Value(latitude),
       longitude = Value(longitude),
       distanceToBranchMeters = Value(distanceToBranchMeters),
       syncedAt = Value(syncedAt);
  static Insertable<AttendanceEntity> custom({
    Expression<String>? id,
    Expression<String>? branchId,
    Expression<String>? membershipId,
    Expression<String>? shiftId,
    Expression<int>? clockIn,
    Expression<int>? clockOut,
    Expression<String>? status,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? distanceToBranchMeters,
    Expression<int>? workedMinutes,
    Expression<int>? regularMinutes,
    Expression<int>? overtimeMinutes,
    Expression<String>? justificationReason,
    Expression<String>? justificationStatus,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (branchId != null) 'branch_id': branchId,
      if (membershipId != null) 'membership_id': membershipId,
      if (shiftId != null) 'shift_id': shiftId,
      if (clockIn != null) 'clock_in': clockIn,
      if (clockOut != null) 'clock_out': clockOut,
      if (status != null) 'status': status,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (distanceToBranchMeters != null)
        'distance_to_branch_m': distanceToBranchMeters,
      if (workedMinutes != null) 'worked_minutes': workedMinutes,
      if (regularMinutes != null) 'regular_minutes': regularMinutes,
      if (overtimeMinutes != null) 'overtime_minutes': overtimeMinutes,
      if (justificationReason != null)
        'justification_reason': justificationReason,
      if (justificationStatus != null)
        'justification_status': justificationStatus,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttendancesCompanion copyWith({
    Value<String>? id,
    Value<String>? branchId,
    Value<String>? membershipId,
    Value<String>? shiftId,
    Value<int>? clockIn,
    Value<int?>? clockOut,
    Value<String>? status,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double>? distanceToBranchMeters,
    Value<int?>? workedMinutes,
    Value<int?>? regularMinutes,
    Value<int?>? overtimeMinutes,
    Value<String?>? justificationReason,
    Value<String?>? justificationStatus,
    Value<int>? syncedAt,
    Value<int>? rowid,
  }) {
    return AttendancesCompanion(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      membershipId: membershipId ?? this.membershipId,
      shiftId: shiftId ?? this.shiftId,
      clockIn: clockIn ?? this.clockIn,
      clockOut: clockOut ?? this.clockOut,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceToBranchMeters:
          distanceToBranchMeters ?? this.distanceToBranchMeters,
      workedMinutes: workedMinutes ?? this.workedMinutes,
      regularMinutes: regularMinutes ?? this.regularMinutes,
      overtimeMinutes: overtimeMinutes ?? this.overtimeMinutes,
      justificationReason: justificationReason ?? this.justificationReason,
      justificationStatus: justificationStatus ?? this.justificationStatus,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (membershipId.present) {
      map['membership_id'] = Variable<String>(membershipId.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (clockIn.present) {
      map['clock_in'] = Variable<int>(clockIn.value);
    }
    if (clockOut.present) {
      map['clock_out'] = Variable<int>(clockOut.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (distanceToBranchMeters.present) {
      map['distance_to_branch_m'] = Variable<double>(
        distanceToBranchMeters.value,
      );
    }
    if (workedMinutes.present) {
      map['worked_minutes'] = Variable<int>(workedMinutes.value);
    }
    if (regularMinutes.present) {
      map['regular_minutes'] = Variable<int>(regularMinutes.value);
    }
    if (overtimeMinutes.present) {
      map['overtime_minutes'] = Variable<int>(overtimeMinutes.value);
    }
    if (justificationReason.present) {
      map['justification_reason'] = Variable<String>(justificationReason.value);
    }
    if (justificationStatus.present) {
      map['justification_status'] = Variable<String>(justificationStatus.value);
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
    return (StringBuffer('AttendancesCompanion(')
          ..write('id: $id, ')
          ..write('branchId: $branchId, ')
          ..write('membershipId: $membershipId, ')
          ..write('shiftId: $shiftId, ')
          ..write('clockIn: $clockIn, ')
          ..write('clockOut: $clockOut, ')
          ..write('status: $status, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('distanceToBranchMeters: $distanceToBranchMeters, ')
          ..write('workedMinutes: $workedMinutes, ')
          ..write('regularMinutes: $regularMinutes, ')
          ..write('overtimeMinutes: $overtimeMinutes, ')
          ..write('justificationReason: $justificationReason, ')
          ..write('justificationStatus: $justificationStatus, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShiftsTable extends Shifts with TableInfo<$ShiftsTable, ShiftEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShiftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gracePeriodMinutesMeta =
      const VerificationMeta('gracePeriodMinutes');
  @override
  late final GeneratedColumn<int> gracePeriodMinutes = GeneratedColumn<int>(
    'grace_period_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workDaysMeta = const VerificationMeta(
    'workDays',
  );
  @override
  late final GeneratedColumn<String> workDays = GeneratedColumn<String>(
    'work_days',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restDaysMeta = const VerificationMeta(
    'restDays',
  );
  @override
  late final GeneratedColumn<String> restDays = GeneratedColumn<String>(
    'rest_days',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    startTime,
    endTime,
    gracePeriodMinutes,
    workDays,
    restDays,
    isActive,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shifts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShiftEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('grace_period_minutes')) {
      context.handle(
        _gracePeriodMinutesMeta,
        gracePeriodMinutes.isAcceptableOrUnknown(
          data['grace_period_minutes']!,
          _gracePeriodMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_gracePeriodMinutesMeta);
    }
    if (data.containsKey('work_days')) {
      context.handle(
        _workDaysMeta,
        workDays.isAcceptableOrUnknown(data['work_days']!, _workDaysMeta),
      );
    } else if (isInserting) {
      context.missing(_workDaysMeta);
    }
    if (data.containsKey('rest_days')) {
      context.handle(
        _restDaysMeta,
        restDays.isAcceptableOrUnknown(data['rest_days']!, _restDaysMeta),
      );
    } else if (isInserting) {
      context.missing(_restDaysMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShiftEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShiftEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_time'],
      )!,
      gracePeriodMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grace_period_minutes'],
      )!,
      workDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_days'],
      )!,
      restDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rest_days'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $ShiftsTable createAlias(String alias) {
    return $ShiftsTable(attachedDatabase, alias);
  }
}

class ShiftEntity extends DataClass implements Insertable<ShiftEntity> {
  final String id;
  final String name;
  final String startTime;
  final String endTime;
  final int gracePeriodMinutes;
  final String workDays;
  final String restDays;
  final bool isActive;
  final int syncedAt;
  const ShiftEntity({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.gracePeriodMinutes,
    required this.workDays,
    required this.restDays,
    required this.isActive,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['start_time'] = Variable<String>(startTime);
    map['end_time'] = Variable<String>(endTime);
    map['grace_period_minutes'] = Variable<int>(gracePeriodMinutes);
    map['work_days'] = Variable<String>(workDays);
    map['rest_days'] = Variable<String>(restDays);
    map['is_active'] = Variable<bool>(isActive);
    map['synced_at'] = Variable<int>(syncedAt);
    return map;
  }

  ShiftsCompanion toCompanion(bool nullToAbsent) {
    return ShiftsCompanion(
      id: Value(id),
      name: Value(name),
      startTime: Value(startTime),
      endTime: Value(endTime),
      gracePeriodMinutes: Value(gracePeriodMinutes),
      workDays: Value(workDays),
      restDays: Value(restDays),
      isActive: Value(isActive),
      syncedAt: Value(syncedAt),
    );
  }

  factory ShiftEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShiftEntity(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      startTime: serializer.fromJson<String>(json['startTime']),
      endTime: serializer.fromJson<String>(json['endTime']),
      gracePeriodMinutes: serializer.fromJson<int>(json['gracePeriodMinutes']),
      workDays: serializer.fromJson<String>(json['workDays']),
      restDays: serializer.fromJson<String>(json['restDays']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      syncedAt: serializer.fromJson<int>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'startTime': serializer.toJson<String>(startTime),
      'endTime': serializer.toJson<String>(endTime),
      'gracePeriodMinutes': serializer.toJson<int>(gracePeriodMinutes),
      'workDays': serializer.toJson<String>(workDays),
      'restDays': serializer.toJson<String>(restDays),
      'isActive': serializer.toJson<bool>(isActive),
      'syncedAt': serializer.toJson<int>(syncedAt),
    };
  }

  ShiftEntity copyWith({
    String? id,
    String? name,
    String? startTime,
    String? endTime,
    int? gracePeriodMinutes,
    String? workDays,
    String? restDays,
    bool? isActive,
    int? syncedAt,
  }) => ShiftEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    gracePeriodMinutes: gracePeriodMinutes ?? this.gracePeriodMinutes,
    workDays: workDays ?? this.workDays,
    restDays: restDays ?? this.restDays,
    isActive: isActive ?? this.isActive,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  ShiftEntity copyWithCompanion(ShiftsCompanion data) {
    return ShiftEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      gracePeriodMinutes: data.gracePeriodMinutes.present
          ? data.gracePeriodMinutes.value
          : this.gracePeriodMinutes,
      workDays: data.workDays.present ? data.workDays.value : this.workDays,
      restDays: data.restDays.present ? data.restDays.value : this.restDays,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShiftEntity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('gracePeriodMinutes: $gracePeriodMinutes, ')
          ..write('workDays: $workDays, ')
          ..write('restDays: $restDays, ')
          ..write('isActive: $isActive, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    startTime,
    endTime,
    gracePeriodMinutes,
    workDays,
    restDays,
    isActive,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShiftEntity &&
          other.id == this.id &&
          other.name == this.name &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.gracePeriodMinutes == this.gracePeriodMinutes &&
          other.workDays == this.workDays &&
          other.restDays == this.restDays &&
          other.isActive == this.isActive &&
          other.syncedAt == this.syncedAt);
}

class ShiftsCompanion extends UpdateCompanion<ShiftEntity> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> startTime;
  final Value<String> endTime;
  final Value<int> gracePeriodMinutes;
  final Value<String> workDays;
  final Value<String> restDays;
  final Value<bool> isActive;
  final Value<int> syncedAt;
  final Value<int> rowid;
  const ShiftsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.gracePeriodMinutes = const Value.absent(),
    this.workDays = const Value.absent(),
    this.restDays = const Value.absent(),
    this.isActive = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShiftsCompanion.insert({
    required String id,
    required String name,
    required String startTime,
    required String endTime,
    required int gracePeriodMinutes,
    required String workDays,
    required String restDays,
    required bool isActive,
    required int syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       startTime = Value(startTime),
       endTime = Value(endTime),
       gracePeriodMinutes = Value(gracePeriodMinutes),
       workDays = Value(workDays),
       restDays = Value(restDays),
       isActive = Value(isActive),
       syncedAt = Value(syncedAt);
  static Insertable<ShiftEntity> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<int>? gracePeriodMinutes,
    Expression<String>? workDays,
    Expression<String>? restDays,
    Expression<bool>? isActive,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (gracePeriodMinutes != null)
        'grace_period_minutes': gracePeriodMinutes,
      if (workDays != null) 'work_days': workDays,
      if (restDays != null) 'rest_days': restDays,
      if (isActive != null) 'is_active': isActive,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShiftsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? startTime,
    Value<String>? endTime,
    Value<int>? gracePeriodMinutes,
    Value<String>? workDays,
    Value<String>? restDays,
    Value<bool>? isActive,
    Value<int>? syncedAt,
    Value<int>? rowid,
  }) {
    return ShiftsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      gracePeriodMinutes: gracePeriodMinutes ?? this.gracePeriodMinutes,
      workDays: workDays ?? this.workDays,
      restDays: restDays ?? this.restDays,
      isActive: isActive ?? this.isActive,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (gracePeriodMinutes.present) {
      map['grace_period_minutes'] = Variable<int>(gracePeriodMinutes.value);
    }
    if (workDays.present) {
      map['work_days'] = Variable<String>(workDays.value);
    }
    if (restDays.present) {
      map['rest_days'] = Variable<String>(restDays.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
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
    return (StringBuffer('ShiftsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('gracePeriodMinutes: $gracePeriodMinutes, ')
          ..write('workDays: $workDays, ')
          ..write('restDays: $restDays, ')
          ..write('isActive: $isActive, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BranchesTable extends Branches
    with TableInfo<$BranchesTable, BranchEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BranchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _geofenceRadiusMetersMeta =
      const VerificationMeta('geofenceRadiusMeters');
  @override
  late final GeneratedColumn<double> geofenceRadiusMeters =
      GeneratedColumn<double>(
        'geofence_radius_m',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    latitude,
    longitude,
    geofenceRadiusMeters,
    isActive,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'branches';
  @override
  VerificationContext validateIntegrity(
    Insertable<BranchEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('geofence_radius_m')) {
      context.handle(
        _geofenceRadiusMetersMeta,
        geofenceRadiusMeters.isAcceptableOrUnknown(
          data['geofence_radius_m']!,
          _geofenceRadiusMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_geofenceRadiusMetersMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BranchEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BranchEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      geofenceRadiusMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}geofence_radius_m'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $BranchesTable createAlias(String alias) {
    return $BranchesTable(attachedDatabase, alias);
  }
}

class BranchEntity extends DataClass implements Insertable<BranchEntity> {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double geofenceRadiusMeters;
  final bool isActive;
  final int syncedAt;
  const BranchEntity({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.geofenceRadiusMeters,
    required this.isActive,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['geofence_radius_m'] = Variable<double>(geofenceRadiusMeters);
    map['is_active'] = Variable<bool>(isActive);
    map['synced_at'] = Variable<int>(syncedAt);
    return map;
  }

  BranchesCompanion toCompanion(bool nullToAbsent) {
    return BranchesCompanion(
      id: Value(id),
      name: Value(name),
      latitude: Value(latitude),
      longitude: Value(longitude),
      geofenceRadiusMeters: Value(geofenceRadiusMeters),
      isActive: Value(isActive),
      syncedAt: Value(syncedAt),
    );
  }

  factory BranchEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BranchEntity(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      geofenceRadiusMeters: serializer.fromJson<double>(
        json['geofenceRadiusMeters'],
      ),
      isActive: serializer.fromJson<bool>(json['isActive']),
      syncedAt: serializer.fromJson<int>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'geofenceRadiusMeters': serializer.toJson<double>(geofenceRadiusMeters),
      'isActive': serializer.toJson<bool>(isActive),
      'syncedAt': serializer.toJson<int>(syncedAt),
    };
  }

  BranchEntity copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    double? geofenceRadiusMeters,
    bool? isActive,
    int? syncedAt,
  }) => BranchEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    geofenceRadiusMeters: geofenceRadiusMeters ?? this.geofenceRadiusMeters,
    isActive: isActive ?? this.isActive,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  BranchEntity copyWithCompanion(BranchesCompanion data) {
    return BranchEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      geofenceRadiusMeters: data.geofenceRadiusMeters.present
          ? data.geofenceRadiusMeters.value
          : this.geofenceRadiusMeters,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BranchEntity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('geofenceRadiusMeters: $geofenceRadiusMeters, ')
          ..write('isActive: $isActive, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    latitude,
    longitude,
    geofenceRadiusMeters,
    isActive,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BranchEntity &&
          other.id == this.id &&
          other.name == this.name &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.geofenceRadiusMeters == this.geofenceRadiusMeters &&
          other.isActive == this.isActive &&
          other.syncedAt == this.syncedAt);
}

class BranchesCompanion extends UpdateCompanion<BranchEntity> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double> geofenceRadiusMeters;
  final Value<bool> isActive;
  final Value<int> syncedAt;
  final Value<int> rowid;
  const BranchesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.geofenceRadiusMeters = const Value.absent(),
    this.isActive = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BranchesCompanion.insert({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    required double geofenceRadiusMeters,
    required bool isActive,
    required int syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       latitude = Value(latitude),
       longitude = Value(longitude),
       geofenceRadiusMeters = Value(geofenceRadiusMeters),
       isActive = Value(isActive),
       syncedAt = Value(syncedAt);
  static Insertable<BranchEntity> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? geofenceRadiusMeters,
    Expression<bool>? isActive,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (geofenceRadiusMeters != null)
        'geofence_radius_m': geofenceRadiusMeters,
      if (isActive != null) 'is_active': isActive,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BranchesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double>? geofenceRadiusMeters,
    Value<bool>? isActive,
    Value<int>? syncedAt,
    Value<int>? rowid,
  }) {
    return BranchesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geofenceRadiusMeters: geofenceRadiusMeters ?? this.geofenceRadiusMeters,
      isActive: isActive ?? this.isActive,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (geofenceRadiusMeters.present) {
      map['geofence_radius_m'] = Variable<double>(geofenceRadiusMeters.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
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
    return (StringBuffer('BranchesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('geofenceRadiusMeters: $geofenceRadiusMeters, ')
          ..write('isActive: $isActive, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, TaskEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workOrderIdMeta = const VerificationMeta(
    'workOrderId',
  );
  @override
  late final GeneratedColumn<String> workOrderId = GeneratedColumn<String>(
    'work_order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workOrderNumberMeta = const VerificationMeta(
    'workOrderNumber',
  );
  @override
  late final GeneratedColumn<int> workOrderNumber = GeneratedColumn<int>(
    'work_order_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workOrderStatusMeta = const VerificationMeta(
    'workOrderStatus',
  );
  @override
  late final GeneratedColumn<String> workOrderStatus = GeneratedColumn<String>(
    'work_order_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _branchIdMeta = const VerificationMeta(
    'branchId',
  );
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
    'branch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bayIdMeta = const VerificationMeta('bayId');
  @override
  late final GeneratedColumn<String> bayId = GeneratedColumn<String>(
    'bay_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serviceNameMeta = const VerificationMeta(
    'serviceName',
  );
  @override
  late final GeneratedColumn<String> serviceName = GeneratedColumn<String>(
    'service_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mechanicIdMeta = const VerificationMeta(
    'mechanicId',
  );
  @override
  late final GeneratedColumn<String> mechanicId = GeneratedColumn<String>(
    'mechanic_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedHoursMeta = const VerificationMeta(
    'estimatedHours',
  );
  @override
  late final GeneratedColumn<String> estimatedHours = GeneratedColumn<String>(
    'estimated_hours',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _holdReasonMeta = const VerificationMeta(
    'holdReason',
  );
  @override
  late final GeneratedColumn<String> holdReason = GeneratedColumn<String>(
    'hold_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _missingItemDescriptionMeta =
      const VerificationMeta('missingItemDescription');
  @override
  late final GeneratedColumn<String> missingItemDescription =
      GeneratedColumn<String>(
        'missing_item_description',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _pendingSuspensionReasonMeta =
      const VerificationMeta('pendingSuspensionReason');
  @override
  late final GeneratedColumn<String> pendingSuspensionReason =
      GeneratedColumn<String>(
        'pending_suspension_reason',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalPausedSecondsMeta =
      const VerificationMeta('totalPausedSeconds');
  @override
  late final GeneratedColumn<int> totalPausedSeconds = GeneratedColumn<int>(
    'total_paused_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workOrderId,
    workOrderNumber,
    workOrderStatus,
    vehicleId,
    branchId,
    bayId,
    serviceName,
    mechanicId,
    status,
    description,
    estimatedHours,
    holdReason,
    missingItemDescription,
    pendingSuspensionReason,
    startedAt,
    totalPausedSeconds,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('work_order_id')) {
      context.handle(
        _workOrderIdMeta,
        workOrderId.isAcceptableOrUnknown(
          data['work_order_id']!,
          _workOrderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workOrderIdMeta);
    }
    if (data.containsKey('work_order_number')) {
      context.handle(
        _workOrderNumberMeta,
        workOrderNumber.isAcceptableOrUnknown(
          data['work_order_number']!,
          _workOrderNumberMeta,
        ),
      );
    }
    if (data.containsKey('work_order_status')) {
      context.handle(
        _workOrderStatusMeta,
        workOrderStatus.isAcceptableOrUnknown(
          data['work_order_status']!,
          _workOrderStatusMeta,
        ),
      );
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(
        _branchIdMeta,
        branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta),
      );
    }
    if (data.containsKey('bay_id')) {
      context.handle(
        _bayIdMeta,
        bayId.isAcceptableOrUnknown(data['bay_id']!, _bayIdMeta),
      );
    }
    if (data.containsKey('service_name')) {
      context.handle(
        _serviceNameMeta,
        serviceName.isAcceptableOrUnknown(
          data['service_name']!,
          _serviceNameMeta,
        ),
      );
    }
    if (data.containsKey('mechanic_id')) {
      context.handle(
        _mechanicIdMeta,
        mechanicId.isAcceptableOrUnknown(data['mechanic_id']!, _mechanicIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('estimated_hours')) {
      context.handle(
        _estimatedHoursMeta,
        estimatedHours.isAcceptableOrUnknown(
          data['estimated_hours']!,
          _estimatedHoursMeta,
        ),
      );
    }
    if (data.containsKey('hold_reason')) {
      context.handle(
        _holdReasonMeta,
        holdReason.isAcceptableOrUnknown(data['hold_reason']!, _holdReasonMeta),
      );
    }
    if (data.containsKey('missing_item_description')) {
      context.handle(
        _missingItemDescriptionMeta,
        missingItemDescription.isAcceptableOrUnknown(
          data['missing_item_description']!,
          _missingItemDescriptionMeta,
        ),
      );
    }
    if (data.containsKey('pending_suspension_reason')) {
      context.handle(
        _pendingSuspensionReasonMeta,
        pendingSuspensionReason.isAcceptableOrUnknown(
          data['pending_suspension_reason']!,
          _pendingSuspensionReasonMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('total_paused_seconds')) {
      context.handle(
        _totalPausedSecondsMeta,
        totalPausedSeconds.isAcceptableOrUnknown(
          data['total_paused_seconds']!,
          _totalPausedSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalPausedSecondsMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workOrderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_order_id'],
      )!,
      workOrderNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}work_order_number'],
      ),
      workOrderStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_order_status'],
      ),
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      branchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_id'],
      ),
      bayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bay_id'],
      ),
      serviceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_name'],
      ),
      mechanicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mechanic_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      estimatedHours: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estimated_hours'],
      ),
      holdReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hold_reason'],
      ),
      missingItemDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}missing_item_description'],
      ),
      pendingSuspensionReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pending_suspension_reason'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      ),
      totalPausedSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_paused_seconds'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class TaskEntity extends DataClass implements Insertable<TaskEntity> {
  final String id;
  final String workOrderId;
  final int? workOrderNumber;
  final String? workOrderStatus;
  final String vehicleId;
  final String? branchId;
  final String? bayId;
  final String? serviceName;
  final String? mechanicId;
  final String status;
  final String description;
  final String? estimatedHours;
  final String? holdReason;
  final String? missingItemDescription;
  final String? pendingSuspensionReason;
  final int? startedAt;
  final int totalPausedSeconds;
  final int syncedAt;
  const TaskEntity({
    required this.id,
    required this.workOrderId,
    this.workOrderNumber,
    this.workOrderStatus,
    required this.vehicleId,
    this.branchId,
    this.bayId,
    this.serviceName,
    this.mechanicId,
    required this.status,
    required this.description,
    this.estimatedHours,
    this.holdReason,
    this.missingItemDescription,
    this.pendingSuspensionReason,
    this.startedAt,
    required this.totalPausedSeconds,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['work_order_id'] = Variable<String>(workOrderId);
    if (!nullToAbsent || workOrderNumber != null) {
      map['work_order_number'] = Variable<int>(workOrderNumber);
    }
    if (!nullToAbsent || workOrderStatus != null) {
      map['work_order_status'] = Variable<String>(workOrderStatus);
    }
    map['vehicle_id'] = Variable<String>(vehicleId);
    if (!nullToAbsent || branchId != null) {
      map['branch_id'] = Variable<String>(branchId);
    }
    if (!nullToAbsent || bayId != null) {
      map['bay_id'] = Variable<String>(bayId);
    }
    if (!nullToAbsent || serviceName != null) {
      map['service_name'] = Variable<String>(serviceName);
    }
    if (!nullToAbsent || mechanicId != null) {
      map['mechanic_id'] = Variable<String>(mechanicId);
    }
    map['status'] = Variable<String>(status);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || estimatedHours != null) {
      map['estimated_hours'] = Variable<String>(estimatedHours);
    }
    if (!nullToAbsent || holdReason != null) {
      map['hold_reason'] = Variable<String>(holdReason);
    }
    if (!nullToAbsent || missingItemDescription != null) {
      map['missing_item_description'] = Variable<String>(
        missingItemDescription,
      );
    }
    if (!nullToAbsent || pendingSuspensionReason != null) {
      map['pending_suspension_reason'] = Variable<String>(
        pendingSuspensionReason,
      );
    }
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<int>(startedAt);
    }
    map['total_paused_seconds'] = Variable<int>(totalPausedSeconds);
    map['synced_at'] = Variable<int>(syncedAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      workOrderId: Value(workOrderId),
      workOrderNumber: workOrderNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(workOrderNumber),
      workOrderStatus: workOrderStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(workOrderStatus),
      vehicleId: Value(vehicleId),
      branchId: branchId == null && nullToAbsent
          ? const Value.absent()
          : Value(branchId),
      bayId: bayId == null && nullToAbsent
          ? const Value.absent()
          : Value(bayId),
      serviceName: serviceName == null && nullToAbsent
          ? const Value.absent()
          : Value(serviceName),
      mechanicId: mechanicId == null && nullToAbsent
          ? const Value.absent()
          : Value(mechanicId),
      status: Value(status),
      description: Value(description),
      estimatedHours: estimatedHours == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedHours),
      holdReason: holdReason == null && nullToAbsent
          ? const Value.absent()
          : Value(holdReason),
      missingItemDescription: missingItemDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(missingItemDescription),
      pendingSuspensionReason: pendingSuspensionReason == null && nullToAbsent
          ? const Value.absent()
          : Value(pendingSuspensionReason),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      totalPausedSeconds: Value(totalPausedSeconds),
      syncedAt: Value(syncedAt),
    );
  }

  factory TaskEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskEntity(
      id: serializer.fromJson<String>(json['id']),
      workOrderId: serializer.fromJson<String>(json['workOrderId']),
      workOrderNumber: serializer.fromJson<int?>(json['workOrderNumber']),
      workOrderStatus: serializer.fromJson<String?>(json['workOrderStatus']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      branchId: serializer.fromJson<String?>(json['branchId']),
      bayId: serializer.fromJson<String?>(json['bayId']),
      serviceName: serializer.fromJson<String?>(json['serviceName']),
      mechanicId: serializer.fromJson<String?>(json['mechanicId']),
      status: serializer.fromJson<String>(json['status']),
      description: serializer.fromJson<String>(json['description']),
      estimatedHours: serializer.fromJson<String?>(json['estimatedHours']),
      holdReason: serializer.fromJson<String?>(json['holdReason']),
      missingItemDescription: serializer.fromJson<String?>(
        json['missingItemDescription'],
      ),
      pendingSuspensionReason: serializer.fromJson<String?>(
        json['pendingSuspensionReason'],
      ),
      startedAt: serializer.fromJson<int?>(json['startedAt']),
      totalPausedSeconds: serializer.fromJson<int>(json['totalPausedSeconds']),
      syncedAt: serializer.fromJson<int>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workOrderId': serializer.toJson<String>(workOrderId),
      'workOrderNumber': serializer.toJson<int?>(workOrderNumber),
      'workOrderStatus': serializer.toJson<String?>(workOrderStatus),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'branchId': serializer.toJson<String?>(branchId),
      'bayId': serializer.toJson<String?>(bayId),
      'serviceName': serializer.toJson<String?>(serviceName),
      'mechanicId': serializer.toJson<String?>(mechanicId),
      'status': serializer.toJson<String>(status),
      'description': serializer.toJson<String>(description),
      'estimatedHours': serializer.toJson<String?>(estimatedHours),
      'holdReason': serializer.toJson<String?>(holdReason),
      'missingItemDescription': serializer.toJson<String?>(
        missingItemDescription,
      ),
      'pendingSuspensionReason': serializer.toJson<String?>(
        pendingSuspensionReason,
      ),
      'startedAt': serializer.toJson<int?>(startedAt),
      'totalPausedSeconds': serializer.toJson<int>(totalPausedSeconds),
      'syncedAt': serializer.toJson<int>(syncedAt),
    };
  }

  TaskEntity copyWith({
    String? id,
    String? workOrderId,
    Value<int?> workOrderNumber = const Value.absent(),
    Value<String?> workOrderStatus = const Value.absent(),
    String? vehicleId,
    Value<String?> branchId = const Value.absent(),
    Value<String?> bayId = const Value.absent(),
    Value<String?> serviceName = const Value.absent(),
    Value<String?> mechanicId = const Value.absent(),
    String? status,
    String? description,
    Value<String?> estimatedHours = const Value.absent(),
    Value<String?> holdReason = const Value.absent(),
    Value<String?> missingItemDescription = const Value.absent(),
    Value<String?> pendingSuspensionReason = const Value.absent(),
    Value<int?> startedAt = const Value.absent(),
    int? totalPausedSeconds,
    int? syncedAt,
  }) => TaskEntity(
    id: id ?? this.id,
    workOrderId: workOrderId ?? this.workOrderId,
    workOrderNumber: workOrderNumber.present
        ? workOrderNumber.value
        : this.workOrderNumber,
    workOrderStatus: workOrderStatus.present
        ? workOrderStatus.value
        : this.workOrderStatus,
    vehicleId: vehicleId ?? this.vehicleId,
    branchId: branchId.present ? branchId.value : this.branchId,
    bayId: bayId.present ? bayId.value : this.bayId,
    serviceName: serviceName.present ? serviceName.value : this.serviceName,
    mechanicId: mechanicId.present ? mechanicId.value : this.mechanicId,
    status: status ?? this.status,
    description: description ?? this.description,
    estimatedHours: estimatedHours.present
        ? estimatedHours.value
        : this.estimatedHours,
    holdReason: holdReason.present ? holdReason.value : this.holdReason,
    missingItemDescription: missingItemDescription.present
        ? missingItemDescription.value
        : this.missingItemDescription,
    pendingSuspensionReason: pendingSuspensionReason.present
        ? pendingSuspensionReason.value
        : this.pendingSuspensionReason,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    totalPausedSeconds: totalPausedSeconds ?? this.totalPausedSeconds,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  TaskEntity copyWithCompanion(TasksCompanion data) {
    return TaskEntity(
      id: data.id.present ? data.id.value : this.id,
      workOrderId: data.workOrderId.present
          ? data.workOrderId.value
          : this.workOrderId,
      workOrderNumber: data.workOrderNumber.present
          ? data.workOrderNumber.value
          : this.workOrderNumber,
      workOrderStatus: data.workOrderStatus.present
          ? data.workOrderStatus.value
          : this.workOrderStatus,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      bayId: data.bayId.present ? data.bayId.value : this.bayId,
      serviceName: data.serviceName.present
          ? data.serviceName.value
          : this.serviceName,
      mechanicId: data.mechanicId.present
          ? data.mechanicId.value
          : this.mechanicId,
      status: data.status.present ? data.status.value : this.status,
      description: data.description.present
          ? data.description.value
          : this.description,
      estimatedHours: data.estimatedHours.present
          ? data.estimatedHours.value
          : this.estimatedHours,
      holdReason: data.holdReason.present
          ? data.holdReason.value
          : this.holdReason,
      missingItemDescription: data.missingItemDescription.present
          ? data.missingItemDescription.value
          : this.missingItemDescription,
      pendingSuspensionReason: data.pendingSuspensionReason.present
          ? data.pendingSuspensionReason.value
          : this.pendingSuspensionReason,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      totalPausedSeconds: data.totalPausedSeconds.present
          ? data.totalPausedSeconds.value
          : this.totalPausedSeconds,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskEntity(')
          ..write('id: $id, ')
          ..write('workOrderId: $workOrderId, ')
          ..write('workOrderNumber: $workOrderNumber, ')
          ..write('workOrderStatus: $workOrderStatus, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('branchId: $branchId, ')
          ..write('bayId: $bayId, ')
          ..write('serviceName: $serviceName, ')
          ..write('mechanicId: $mechanicId, ')
          ..write('status: $status, ')
          ..write('description: $description, ')
          ..write('estimatedHours: $estimatedHours, ')
          ..write('holdReason: $holdReason, ')
          ..write('missingItemDescription: $missingItemDescription, ')
          ..write('pendingSuspensionReason: $pendingSuspensionReason, ')
          ..write('startedAt: $startedAt, ')
          ..write('totalPausedSeconds: $totalPausedSeconds, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workOrderId,
    workOrderNumber,
    workOrderStatus,
    vehicleId,
    branchId,
    bayId,
    serviceName,
    mechanicId,
    status,
    description,
    estimatedHours,
    holdReason,
    missingItemDescription,
    pendingSuspensionReason,
    startedAt,
    totalPausedSeconds,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskEntity &&
          other.id == this.id &&
          other.workOrderId == this.workOrderId &&
          other.workOrderNumber == this.workOrderNumber &&
          other.workOrderStatus == this.workOrderStatus &&
          other.vehicleId == this.vehicleId &&
          other.branchId == this.branchId &&
          other.bayId == this.bayId &&
          other.serviceName == this.serviceName &&
          other.mechanicId == this.mechanicId &&
          other.status == this.status &&
          other.description == this.description &&
          other.estimatedHours == this.estimatedHours &&
          other.holdReason == this.holdReason &&
          other.missingItemDescription == this.missingItemDescription &&
          other.pendingSuspensionReason == this.pendingSuspensionReason &&
          other.startedAt == this.startedAt &&
          other.totalPausedSeconds == this.totalPausedSeconds &&
          other.syncedAt == this.syncedAt);
}

class TasksCompanion extends UpdateCompanion<TaskEntity> {
  final Value<String> id;
  final Value<String> workOrderId;
  final Value<int?> workOrderNumber;
  final Value<String?> workOrderStatus;
  final Value<String> vehicleId;
  final Value<String?> branchId;
  final Value<String?> bayId;
  final Value<String?> serviceName;
  final Value<String?> mechanicId;
  final Value<String> status;
  final Value<String> description;
  final Value<String?> estimatedHours;
  final Value<String?> holdReason;
  final Value<String?> missingItemDescription;
  final Value<String?> pendingSuspensionReason;
  final Value<int?> startedAt;
  final Value<int> totalPausedSeconds;
  final Value<int> syncedAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.workOrderId = const Value.absent(),
    this.workOrderNumber = const Value.absent(),
    this.workOrderStatus = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.branchId = const Value.absent(),
    this.bayId = const Value.absent(),
    this.serviceName = const Value.absent(),
    this.mechanicId = const Value.absent(),
    this.status = const Value.absent(),
    this.description = const Value.absent(),
    this.estimatedHours = const Value.absent(),
    this.holdReason = const Value.absent(),
    this.missingItemDescription = const Value.absent(),
    this.pendingSuspensionReason = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.totalPausedSeconds = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String workOrderId,
    this.workOrderNumber = const Value.absent(),
    this.workOrderStatus = const Value.absent(),
    required String vehicleId,
    this.branchId = const Value.absent(),
    this.bayId = const Value.absent(),
    this.serviceName = const Value.absent(),
    this.mechanicId = const Value.absent(),
    required String status,
    required String description,
    this.estimatedHours = const Value.absent(),
    this.holdReason = const Value.absent(),
    this.missingItemDescription = const Value.absent(),
    this.pendingSuspensionReason = const Value.absent(),
    this.startedAt = const Value.absent(),
    required int totalPausedSeconds,
    required int syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workOrderId = Value(workOrderId),
       vehicleId = Value(vehicleId),
       status = Value(status),
       description = Value(description),
       totalPausedSeconds = Value(totalPausedSeconds),
       syncedAt = Value(syncedAt);
  static Insertable<TaskEntity> custom({
    Expression<String>? id,
    Expression<String>? workOrderId,
    Expression<int>? workOrderNumber,
    Expression<String>? workOrderStatus,
    Expression<String>? vehicleId,
    Expression<String>? branchId,
    Expression<String>? bayId,
    Expression<String>? serviceName,
    Expression<String>? mechanicId,
    Expression<String>? status,
    Expression<String>? description,
    Expression<String>? estimatedHours,
    Expression<String>? holdReason,
    Expression<String>? missingItemDescription,
    Expression<String>? pendingSuspensionReason,
    Expression<int>? startedAt,
    Expression<int>? totalPausedSeconds,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workOrderId != null) 'work_order_id': workOrderId,
      if (workOrderNumber != null) 'work_order_number': workOrderNumber,
      if (workOrderStatus != null) 'work_order_status': workOrderStatus,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (branchId != null) 'branch_id': branchId,
      if (bayId != null) 'bay_id': bayId,
      if (serviceName != null) 'service_name': serviceName,
      if (mechanicId != null) 'mechanic_id': mechanicId,
      if (status != null) 'status': status,
      if (description != null) 'description': description,
      if (estimatedHours != null) 'estimated_hours': estimatedHours,
      if (holdReason != null) 'hold_reason': holdReason,
      if (missingItemDescription != null)
        'missing_item_description': missingItemDescription,
      if (pendingSuspensionReason != null)
        'pending_suspension_reason': pendingSuspensionReason,
      if (startedAt != null) 'started_at': startedAt,
      if (totalPausedSeconds != null)
        'total_paused_seconds': totalPausedSeconds,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<String>? workOrderId,
    Value<int?>? workOrderNumber,
    Value<String?>? workOrderStatus,
    Value<String>? vehicleId,
    Value<String?>? branchId,
    Value<String?>? bayId,
    Value<String?>? serviceName,
    Value<String?>? mechanicId,
    Value<String>? status,
    Value<String>? description,
    Value<String?>? estimatedHours,
    Value<String?>? holdReason,
    Value<String?>? missingItemDescription,
    Value<String?>? pendingSuspensionReason,
    Value<int?>? startedAt,
    Value<int>? totalPausedSeconds,
    Value<int>? syncedAt,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      workOrderId: workOrderId ?? this.workOrderId,
      workOrderNumber: workOrderNumber ?? this.workOrderNumber,
      workOrderStatus: workOrderStatus ?? this.workOrderStatus,
      vehicleId: vehicleId ?? this.vehicleId,
      branchId: branchId ?? this.branchId,
      bayId: bayId ?? this.bayId,
      serviceName: serviceName ?? this.serviceName,
      mechanicId: mechanicId ?? this.mechanicId,
      status: status ?? this.status,
      description: description ?? this.description,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      holdReason: holdReason ?? this.holdReason,
      missingItemDescription:
          missingItemDescription ?? this.missingItemDescription,
      pendingSuspensionReason:
          pendingSuspensionReason ?? this.pendingSuspensionReason,
      startedAt: startedAt ?? this.startedAt,
      totalPausedSeconds: totalPausedSeconds ?? this.totalPausedSeconds,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workOrderId.present) {
      map['work_order_id'] = Variable<String>(workOrderId.value);
    }
    if (workOrderNumber.present) {
      map['work_order_number'] = Variable<int>(workOrderNumber.value);
    }
    if (workOrderStatus.present) {
      map['work_order_status'] = Variable<String>(workOrderStatus.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (bayId.present) {
      map['bay_id'] = Variable<String>(bayId.value);
    }
    if (serviceName.present) {
      map['service_name'] = Variable<String>(serviceName.value);
    }
    if (mechanicId.present) {
      map['mechanic_id'] = Variable<String>(mechanicId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (estimatedHours.present) {
      map['estimated_hours'] = Variable<String>(estimatedHours.value);
    }
    if (holdReason.present) {
      map['hold_reason'] = Variable<String>(holdReason.value);
    }
    if (missingItemDescription.present) {
      map['missing_item_description'] = Variable<String>(
        missingItemDescription.value,
      );
    }
    if (pendingSuspensionReason.present) {
      map['pending_suspension_reason'] = Variable<String>(
        pendingSuspensionReason.value,
      );
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (totalPausedSeconds.present) {
      map['total_paused_seconds'] = Variable<int>(totalPausedSeconds.value);
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
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('workOrderId: $workOrderId, ')
          ..write('workOrderNumber: $workOrderNumber, ')
          ..write('workOrderStatus: $workOrderStatus, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('branchId: $branchId, ')
          ..write('bayId: $bayId, ')
          ..write('serviceName: $serviceName, ')
          ..write('mechanicId: $mechanicId, ')
          ..write('status: $status, ')
          ..write('description: $description, ')
          ..write('estimatedHours: $estimatedHours, ')
          ..write('holdReason: $holdReason, ')
          ..write('missingItemDescription: $missingItemDescription, ')
          ..write('pendingSuspensionReason: $pendingSuspensionReason, ')
          ..write('startedAt: $startedAt, ')
          ..write('totalPausedSeconds: $totalPausedSeconds, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkOrdersTable extends WorkOrders
    with TableInfo<$WorkOrdersTable, WorkOrderEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _internalNumberMeta = const VerificationMeta(
    'internalNumber',
  );
  @override
  late final GeneratedColumn<int> internalNumber = GeneratedColumn<int>(
    'internal_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _branchIdMeta = const VerificationMeta(
    'branchId',
  );
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
    'branch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentBayIdMeta = const VerificationMeta(
    'currentBayId',
  );
  @override
  late final GeneratedColumn<String> currentBayId = GeneratedColumn<String>(
    'current_bay_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bayNameMeta = const VerificationMeta(
    'bayName',
  );
  @override
  late final GeneratedColumn<String> bayName = GeneratedColumn<String>(
    'bay_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diagnosticSummaryMeta = const VerificationMeta(
    'diagnosticSummary',
  );
  @override
  late final GeneratedColumn<String> diagnosticSummary =
      GeneratedColumn<String>(
        'diagnostic_summary',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _mileageInMeta = const VerificationMeta(
    'mileageIn',
  );
  @override
  late final GeneratedColumn<int> mileageIn = GeneratedColumn<int>(
    'mileage_in',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<String> subtotal = GeneratedColumn<String>(
    'subtotal',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taxAmountMeta = const VerificationMeta(
    'taxAmount',
  );
  @override
  late final GeneratedColumn<String> taxAmount = GeneratedColumn<String>(
    'tax_amount',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<String> totalAmount = GeneratedColumn<String>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    internalNumber,
    branchId,
    vehicleId,
    customerId,
    currentBayId,
    bayName,
    status,
    diagnosticSummary,
    mileageIn,
    subtotal,
    taxAmount,
    totalAmount,
    currency,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkOrderEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('internal_number')) {
      context.handle(
        _internalNumberMeta,
        internalNumber.isAcceptableOrUnknown(
          data['internal_number']!,
          _internalNumberMeta,
        ),
      );
    }
    if (data.containsKey('branch_id')) {
      context.handle(
        _branchIdMeta,
        branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('current_bay_id')) {
      context.handle(
        _currentBayIdMeta,
        currentBayId.isAcceptableOrUnknown(
          data['current_bay_id']!,
          _currentBayIdMeta,
        ),
      );
    }
    if (data.containsKey('bay_name')) {
      context.handle(
        _bayNameMeta,
        bayName.isAcceptableOrUnknown(data['bay_name']!, _bayNameMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('diagnostic_summary')) {
      context.handle(
        _diagnosticSummaryMeta,
        diagnosticSummary.isAcceptableOrUnknown(
          data['diagnostic_summary']!,
          _diagnosticSummaryMeta,
        ),
      );
    }
    if (data.containsKey('mileage_in')) {
      context.handle(
        _mileageInMeta,
        mileageIn.isAcceptableOrUnknown(data['mileage_in']!, _mileageInMeta),
      );
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    }
    if (data.containsKey('tax_amount')) {
      context.handle(
        _taxAmountMeta,
        taxAmount.isAcceptableOrUnknown(data['tax_amount']!, _taxAmountMeta),
      );
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkOrderEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkOrderEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      internalNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}internal_number'],
      ),
      branchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      currentBayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_bay_id'],
      ),
      bayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bay_name'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      diagnosticSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diagnostic_summary'],
      ),
      mileageIn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mileage_in'],
      ),
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtotal'],
      ),
      taxAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tax_amount'],
      ),
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}total_amount'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $WorkOrdersTable createAlias(String alias) {
    return $WorkOrdersTable(attachedDatabase, alias);
  }
}

class WorkOrderEntity extends DataClass implements Insertable<WorkOrderEntity> {
  final String id;
  final int? internalNumber;
  final String branchId;
  final String vehicleId;
  final String customerId;
  final String? currentBayId;
  final String? bayName;
  final String status;
  final String? diagnosticSummary;
  final int? mileageIn;
  final String? subtotal;
  final String? taxAmount;
  final String totalAmount;
  final String currency;
  final int syncedAt;
  const WorkOrderEntity({
    required this.id,
    this.internalNumber,
    required this.branchId,
    required this.vehicleId,
    required this.customerId,
    this.currentBayId,
    this.bayName,
    required this.status,
    this.diagnosticSummary,
    this.mileageIn,
    this.subtotal,
    this.taxAmount,
    required this.totalAmount,
    required this.currency,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || internalNumber != null) {
      map['internal_number'] = Variable<int>(internalNumber);
    }
    map['branch_id'] = Variable<String>(branchId);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['customer_id'] = Variable<String>(customerId);
    if (!nullToAbsent || currentBayId != null) {
      map['current_bay_id'] = Variable<String>(currentBayId);
    }
    if (!nullToAbsent || bayName != null) {
      map['bay_name'] = Variable<String>(bayName);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || diagnosticSummary != null) {
      map['diagnostic_summary'] = Variable<String>(diagnosticSummary);
    }
    if (!nullToAbsent || mileageIn != null) {
      map['mileage_in'] = Variable<int>(mileageIn);
    }
    if (!nullToAbsent || subtotal != null) {
      map['subtotal'] = Variable<String>(subtotal);
    }
    if (!nullToAbsent || taxAmount != null) {
      map['tax_amount'] = Variable<String>(taxAmount);
    }
    map['total_amount'] = Variable<String>(totalAmount);
    map['currency'] = Variable<String>(currency);
    map['synced_at'] = Variable<int>(syncedAt);
    return map;
  }

  WorkOrdersCompanion toCompanion(bool nullToAbsent) {
    return WorkOrdersCompanion(
      id: Value(id),
      internalNumber: internalNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(internalNumber),
      branchId: Value(branchId),
      vehicleId: Value(vehicleId),
      customerId: Value(customerId),
      currentBayId: currentBayId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentBayId),
      bayName: bayName == null && nullToAbsent
          ? const Value.absent()
          : Value(bayName),
      status: Value(status),
      diagnosticSummary: diagnosticSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(diagnosticSummary),
      mileageIn: mileageIn == null && nullToAbsent
          ? const Value.absent()
          : Value(mileageIn),
      subtotal: subtotal == null && nullToAbsent
          ? const Value.absent()
          : Value(subtotal),
      taxAmount: taxAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(taxAmount),
      totalAmount: Value(totalAmount),
      currency: Value(currency),
      syncedAt: Value(syncedAt),
    );
  }

  factory WorkOrderEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkOrderEntity(
      id: serializer.fromJson<String>(json['id']),
      internalNumber: serializer.fromJson<int?>(json['internalNumber']),
      branchId: serializer.fromJson<String>(json['branchId']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      customerId: serializer.fromJson<String>(json['customerId']),
      currentBayId: serializer.fromJson<String?>(json['currentBayId']),
      bayName: serializer.fromJson<String?>(json['bayName']),
      status: serializer.fromJson<String>(json['status']),
      diagnosticSummary: serializer.fromJson<String?>(
        json['diagnosticSummary'],
      ),
      mileageIn: serializer.fromJson<int?>(json['mileageIn']),
      subtotal: serializer.fromJson<String?>(json['subtotal']),
      taxAmount: serializer.fromJson<String?>(json['taxAmount']),
      totalAmount: serializer.fromJson<String>(json['totalAmount']),
      currency: serializer.fromJson<String>(json['currency']),
      syncedAt: serializer.fromJson<int>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'internalNumber': serializer.toJson<int?>(internalNumber),
      'branchId': serializer.toJson<String>(branchId),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'customerId': serializer.toJson<String>(customerId),
      'currentBayId': serializer.toJson<String?>(currentBayId),
      'bayName': serializer.toJson<String?>(bayName),
      'status': serializer.toJson<String>(status),
      'diagnosticSummary': serializer.toJson<String?>(diagnosticSummary),
      'mileageIn': serializer.toJson<int?>(mileageIn),
      'subtotal': serializer.toJson<String?>(subtotal),
      'taxAmount': serializer.toJson<String?>(taxAmount),
      'totalAmount': serializer.toJson<String>(totalAmount),
      'currency': serializer.toJson<String>(currency),
      'syncedAt': serializer.toJson<int>(syncedAt),
    };
  }

  WorkOrderEntity copyWith({
    String? id,
    Value<int?> internalNumber = const Value.absent(),
    String? branchId,
    String? vehicleId,
    String? customerId,
    Value<String?> currentBayId = const Value.absent(),
    Value<String?> bayName = const Value.absent(),
    String? status,
    Value<String?> diagnosticSummary = const Value.absent(),
    Value<int?> mileageIn = const Value.absent(),
    Value<String?> subtotal = const Value.absent(),
    Value<String?> taxAmount = const Value.absent(),
    String? totalAmount,
    String? currency,
    int? syncedAt,
  }) => WorkOrderEntity(
    id: id ?? this.id,
    internalNumber: internalNumber.present
        ? internalNumber.value
        : this.internalNumber,
    branchId: branchId ?? this.branchId,
    vehicleId: vehicleId ?? this.vehicleId,
    customerId: customerId ?? this.customerId,
    currentBayId: currentBayId.present ? currentBayId.value : this.currentBayId,
    bayName: bayName.present ? bayName.value : this.bayName,
    status: status ?? this.status,
    diagnosticSummary: diagnosticSummary.present
        ? diagnosticSummary.value
        : this.diagnosticSummary,
    mileageIn: mileageIn.present ? mileageIn.value : this.mileageIn,
    subtotal: subtotal.present ? subtotal.value : this.subtotal,
    taxAmount: taxAmount.present ? taxAmount.value : this.taxAmount,
    totalAmount: totalAmount ?? this.totalAmount,
    currency: currency ?? this.currency,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  WorkOrderEntity copyWithCompanion(WorkOrdersCompanion data) {
    return WorkOrderEntity(
      id: data.id.present ? data.id.value : this.id,
      internalNumber: data.internalNumber.present
          ? data.internalNumber.value
          : this.internalNumber,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      currentBayId: data.currentBayId.present
          ? data.currentBayId.value
          : this.currentBayId,
      bayName: data.bayName.present ? data.bayName.value : this.bayName,
      status: data.status.present ? data.status.value : this.status,
      diagnosticSummary: data.diagnosticSummary.present
          ? data.diagnosticSummary.value
          : this.diagnosticSummary,
      mileageIn: data.mileageIn.present ? data.mileageIn.value : this.mileageIn,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      taxAmount: data.taxAmount.present ? data.taxAmount.value : this.taxAmount,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      currency: data.currency.present ? data.currency.value : this.currency,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkOrderEntity(')
          ..write('id: $id, ')
          ..write('internalNumber: $internalNumber, ')
          ..write('branchId: $branchId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('customerId: $customerId, ')
          ..write('currentBayId: $currentBayId, ')
          ..write('bayName: $bayName, ')
          ..write('status: $status, ')
          ..write('diagnosticSummary: $diagnosticSummary, ')
          ..write('mileageIn: $mileageIn, ')
          ..write('subtotal: $subtotal, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('currency: $currency, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    internalNumber,
    branchId,
    vehicleId,
    customerId,
    currentBayId,
    bayName,
    status,
    diagnosticSummary,
    mileageIn,
    subtotal,
    taxAmount,
    totalAmount,
    currency,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkOrderEntity &&
          other.id == this.id &&
          other.internalNumber == this.internalNumber &&
          other.branchId == this.branchId &&
          other.vehicleId == this.vehicleId &&
          other.customerId == this.customerId &&
          other.currentBayId == this.currentBayId &&
          other.bayName == this.bayName &&
          other.status == this.status &&
          other.diagnosticSummary == this.diagnosticSummary &&
          other.mileageIn == this.mileageIn &&
          other.subtotal == this.subtotal &&
          other.taxAmount == this.taxAmount &&
          other.totalAmount == this.totalAmount &&
          other.currency == this.currency &&
          other.syncedAt == this.syncedAt);
}

class WorkOrdersCompanion extends UpdateCompanion<WorkOrderEntity> {
  final Value<String> id;
  final Value<int?> internalNumber;
  final Value<String> branchId;
  final Value<String> vehicleId;
  final Value<String> customerId;
  final Value<String?> currentBayId;
  final Value<String?> bayName;
  final Value<String> status;
  final Value<String?> diagnosticSummary;
  final Value<int?> mileageIn;
  final Value<String?> subtotal;
  final Value<String?> taxAmount;
  final Value<String> totalAmount;
  final Value<String> currency;
  final Value<int> syncedAt;
  final Value<int> rowid;
  const WorkOrdersCompanion({
    this.id = const Value.absent(),
    this.internalNumber = const Value.absent(),
    this.branchId = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.currentBayId = const Value.absent(),
    this.bayName = const Value.absent(),
    this.status = const Value.absent(),
    this.diagnosticSummary = const Value.absent(),
    this.mileageIn = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.currency = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkOrdersCompanion.insert({
    required String id,
    this.internalNumber = const Value.absent(),
    required String branchId,
    required String vehicleId,
    required String customerId,
    this.currentBayId = const Value.absent(),
    this.bayName = const Value.absent(),
    required String status,
    this.diagnosticSummary = const Value.absent(),
    this.mileageIn = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.taxAmount = const Value.absent(),
    required String totalAmount,
    required String currency,
    required int syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       branchId = Value(branchId),
       vehicleId = Value(vehicleId),
       customerId = Value(customerId),
       status = Value(status),
       totalAmount = Value(totalAmount),
       currency = Value(currency),
       syncedAt = Value(syncedAt);
  static Insertable<WorkOrderEntity> custom({
    Expression<String>? id,
    Expression<int>? internalNumber,
    Expression<String>? branchId,
    Expression<String>? vehicleId,
    Expression<String>? customerId,
    Expression<String>? currentBayId,
    Expression<String>? bayName,
    Expression<String>? status,
    Expression<String>? diagnosticSummary,
    Expression<int>? mileageIn,
    Expression<String>? subtotal,
    Expression<String>? taxAmount,
    Expression<String>? totalAmount,
    Expression<String>? currency,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (internalNumber != null) 'internal_number': internalNumber,
      if (branchId != null) 'branch_id': branchId,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (customerId != null) 'customer_id': customerId,
      if (currentBayId != null) 'current_bay_id': currentBayId,
      if (bayName != null) 'bay_name': bayName,
      if (status != null) 'status': status,
      if (diagnosticSummary != null) 'diagnostic_summary': diagnosticSummary,
      if (mileageIn != null) 'mileage_in': mileageIn,
      if (subtotal != null) 'subtotal': subtotal,
      if (taxAmount != null) 'tax_amount': taxAmount,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (currency != null) 'currency': currency,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkOrdersCompanion copyWith({
    Value<String>? id,
    Value<int?>? internalNumber,
    Value<String>? branchId,
    Value<String>? vehicleId,
    Value<String>? customerId,
    Value<String?>? currentBayId,
    Value<String?>? bayName,
    Value<String>? status,
    Value<String?>? diagnosticSummary,
    Value<int?>? mileageIn,
    Value<String?>? subtotal,
    Value<String?>? taxAmount,
    Value<String>? totalAmount,
    Value<String>? currency,
    Value<int>? syncedAt,
    Value<int>? rowid,
  }) {
    return WorkOrdersCompanion(
      id: id ?? this.id,
      internalNumber: internalNumber ?? this.internalNumber,
      branchId: branchId ?? this.branchId,
      vehicleId: vehicleId ?? this.vehicleId,
      customerId: customerId ?? this.customerId,
      currentBayId: currentBayId ?? this.currentBayId,
      bayName: bayName ?? this.bayName,
      status: status ?? this.status,
      diagnosticSummary: diagnosticSummary ?? this.diagnosticSummary,
      mileageIn: mileageIn ?? this.mileageIn,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (internalNumber.present) {
      map['internal_number'] = Variable<int>(internalNumber.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (currentBayId.present) {
      map['current_bay_id'] = Variable<String>(currentBayId.value);
    }
    if (bayName.present) {
      map['bay_name'] = Variable<String>(bayName.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (diagnosticSummary.present) {
      map['diagnostic_summary'] = Variable<String>(diagnosticSummary.value);
    }
    if (mileageIn.present) {
      map['mileage_in'] = Variable<int>(mileageIn.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<String>(subtotal.value);
    }
    if (taxAmount.present) {
      map['tax_amount'] = Variable<String>(taxAmount.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<String>(totalAmount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
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
    return (StringBuffer('WorkOrdersCompanion(')
          ..write('id: $id, ')
          ..write('internalNumber: $internalNumber, ')
          ..write('branchId: $branchId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('customerId: $customerId, ')
          ..write('currentBayId: $currentBayId, ')
          ..write('bayName: $bayName, ')
          ..write('status: $status, ')
          ..write('diagnosticSummary: $diagnosticSummary, ')
          ..write('mileageIn: $mileageIn, ')
          ..write('subtotal: $subtotal, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('currency: $currency, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BaysTable extends Bays with TableInfo<$BaysTable, BayEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _branchIdMeta = const VerificationMeta(
    'branchId',
  );
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
    'branch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bayTypeMeta = const VerificationMeta(
    'bayType',
  );
  @override
  late final GeneratedColumn<String> bayType = GeneratedColumn<String>(
    'bay_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentWorkOrderIdMeta =
      const VerificationMeta('currentWorkOrderId');
  @override
  late final GeneratedColumn<String> currentWorkOrderId =
      GeneratedColumn<String>(
        'current_work_order_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    branchId,
    name,
    bayType,
    status,
    currentWorkOrderId,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bays';
  @override
  VerificationContext validateIntegrity(
    Insertable<BayEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(
        _branchIdMeta,
        branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('bay_type')) {
      context.handle(
        _bayTypeMeta,
        bayType.isAcceptableOrUnknown(data['bay_type']!, _bayTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_bayTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('current_work_order_id')) {
      context.handle(
        _currentWorkOrderIdMeta,
        currentWorkOrderId.isAcceptableOrUnknown(
          data['current_work_order_id']!,
          _currentWorkOrderIdMeta,
        ),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BayEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BayEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      branchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      bayType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bay_type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      currentWorkOrderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_work_order_id'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $BaysTable createAlias(String alias) {
    return $BaysTable(attachedDatabase, alias);
  }
}

class BayEntity extends DataClass implements Insertable<BayEntity> {
  final String id;
  final String branchId;
  final String name;
  final String bayType;
  final String status;
  final String? currentWorkOrderId;
  final int syncedAt;
  const BayEntity({
    required this.id,
    required this.branchId,
    required this.name,
    required this.bayType,
    required this.status,
    this.currentWorkOrderId,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['branch_id'] = Variable<String>(branchId);
    map['name'] = Variable<String>(name);
    map['bay_type'] = Variable<String>(bayType);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || currentWorkOrderId != null) {
      map['current_work_order_id'] = Variable<String>(currentWorkOrderId);
    }
    map['synced_at'] = Variable<int>(syncedAt);
    return map;
  }

  BaysCompanion toCompanion(bool nullToAbsent) {
    return BaysCompanion(
      id: Value(id),
      branchId: Value(branchId),
      name: Value(name),
      bayType: Value(bayType),
      status: Value(status),
      currentWorkOrderId: currentWorkOrderId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentWorkOrderId),
      syncedAt: Value(syncedAt),
    );
  }

  factory BayEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BayEntity(
      id: serializer.fromJson<String>(json['id']),
      branchId: serializer.fromJson<String>(json['branchId']),
      name: serializer.fromJson<String>(json['name']),
      bayType: serializer.fromJson<String>(json['bayType']),
      status: serializer.fromJson<String>(json['status']),
      currentWorkOrderId: serializer.fromJson<String?>(
        json['currentWorkOrderId'],
      ),
      syncedAt: serializer.fromJson<int>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'branchId': serializer.toJson<String>(branchId),
      'name': serializer.toJson<String>(name),
      'bayType': serializer.toJson<String>(bayType),
      'status': serializer.toJson<String>(status),
      'currentWorkOrderId': serializer.toJson<String?>(currentWorkOrderId),
      'syncedAt': serializer.toJson<int>(syncedAt),
    };
  }

  BayEntity copyWith({
    String? id,
    String? branchId,
    String? name,
    String? bayType,
    String? status,
    Value<String?> currentWorkOrderId = const Value.absent(),
    int? syncedAt,
  }) => BayEntity(
    id: id ?? this.id,
    branchId: branchId ?? this.branchId,
    name: name ?? this.name,
    bayType: bayType ?? this.bayType,
    status: status ?? this.status,
    currentWorkOrderId: currentWorkOrderId.present
        ? currentWorkOrderId.value
        : this.currentWorkOrderId,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  BayEntity copyWithCompanion(BaysCompanion data) {
    return BayEntity(
      id: data.id.present ? data.id.value : this.id,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      name: data.name.present ? data.name.value : this.name,
      bayType: data.bayType.present ? data.bayType.value : this.bayType,
      status: data.status.present ? data.status.value : this.status,
      currentWorkOrderId: data.currentWorkOrderId.present
          ? data.currentWorkOrderId.value
          : this.currentWorkOrderId,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BayEntity(')
          ..write('id: $id, ')
          ..write('branchId: $branchId, ')
          ..write('name: $name, ')
          ..write('bayType: $bayType, ')
          ..write('status: $status, ')
          ..write('currentWorkOrderId: $currentWorkOrderId, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    branchId,
    name,
    bayType,
    status,
    currentWorkOrderId,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BayEntity &&
          other.id == this.id &&
          other.branchId == this.branchId &&
          other.name == this.name &&
          other.bayType == this.bayType &&
          other.status == this.status &&
          other.currentWorkOrderId == this.currentWorkOrderId &&
          other.syncedAt == this.syncedAt);
}

class BaysCompanion extends UpdateCompanion<BayEntity> {
  final Value<String> id;
  final Value<String> branchId;
  final Value<String> name;
  final Value<String> bayType;
  final Value<String> status;
  final Value<String?> currentWorkOrderId;
  final Value<int> syncedAt;
  final Value<int> rowid;
  const BaysCompanion({
    this.id = const Value.absent(),
    this.branchId = const Value.absent(),
    this.name = const Value.absent(),
    this.bayType = const Value.absent(),
    this.status = const Value.absent(),
    this.currentWorkOrderId = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BaysCompanion.insert({
    required String id,
    required String branchId,
    required String name,
    required String bayType,
    required String status,
    this.currentWorkOrderId = const Value.absent(),
    required int syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       branchId = Value(branchId),
       name = Value(name),
       bayType = Value(bayType),
       status = Value(status),
       syncedAt = Value(syncedAt);
  static Insertable<BayEntity> custom({
    Expression<String>? id,
    Expression<String>? branchId,
    Expression<String>? name,
    Expression<String>? bayType,
    Expression<String>? status,
    Expression<String>? currentWorkOrderId,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (branchId != null) 'branch_id': branchId,
      if (name != null) 'name': name,
      if (bayType != null) 'bay_type': bayType,
      if (status != null) 'status': status,
      if (currentWorkOrderId != null)
        'current_work_order_id': currentWorkOrderId,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BaysCompanion copyWith({
    Value<String>? id,
    Value<String>? branchId,
    Value<String>? name,
    Value<String>? bayType,
    Value<String>? status,
    Value<String?>? currentWorkOrderId,
    Value<int>? syncedAt,
    Value<int>? rowid,
  }) {
    return BaysCompanion(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      name: name ?? this.name,
      bayType: bayType ?? this.bayType,
      status: status ?? this.status,
      currentWorkOrderId: currentWorkOrderId ?? this.currentWorkOrderId,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (bayType.present) {
      map['bay_type'] = Variable<String>(bayType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (currentWorkOrderId.present) {
      map['current_work_order_id'] = Variable<String>(currentWorkOrderId.value);
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
    return (StringBuffer('BaysCompanion(')
          ..write('id: $id, ')
          ..write('branchId: $branchId, ')
          ..write('name: $name, ')
          ..write('bayType: $bayType, ')
          ..write('status: $status, ')
          ..write('currentWorkOrderId: $currentWorkOrderId, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, CustomerEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taxIdMeta = const VerificationMeta('taxId');
  @override
  late final GeneratedColumn<String> taxId = GeneratedColumn<String>(
    'tax_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    displayName,
    taxId,
    email,
    phone,
    status,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('tax_id')) {
      context.handle(
        _taxIdMeta,
        taxId.isAcceptableOrUnknown(data['tax_id']!, _taxIdMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      taxId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tax_id'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class CustomerEntity extends DataClass implements Insertable<CustomerEntity> {
  final String id;
  final String type;
  final String displayName;
  final String? taxId;
  final String? email;
  final String? phone;
  final String status;
  final int syncedAt;
  const CustomerEntity({
    required this.id,
    required this.type,
    required this.displayName,
    this.taxId,
    this.email,
    this.phone,
    required this.status,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || taxId != null) {
      map['tax_id'] = Variable<String>(taxId);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['status'] = Variable<String>(status);
    map['synced_at'] = Variable<int>(syncedAt);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      type: Value(type),
      displayName: Value(displayName),
      taxId: taxId == null && nullToAbsent
          ? const Value.absent()
          : Value(taxId),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      status: Value(status),
      syncedAt: Value(syncedAt),
    );
  }

  factory CustomerEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerEntity(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      displayName: serializer.fromJson<String>(json['displayName']),
      taxId: serializer.fromJson<String?>(json['taxId']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      status: serializer.fromJson<String>(json['status']),
      syncedAt: serializer.fromJson<int>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'displayName': serializer.toJson<String>(displayName),
      'taxId': serializer.toJson<String?>(taxId),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'status': serializer.toJson<String>(status),
      'syncedAt': serializer.toJson<int>(syncedAt),
    };
  }

  CustomerEntity copyWith({
    String? id,
    String? type,
    String? displayName,
    Value<String?> taxId = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    String? status,
    int? syncedAt,
  }) => CustomerEntity(
    id: id ?? this.id,
    type: type ?? this.type,
    displayName: displayName ?? this.displayName,
    taxId: taxId.present ? taxId.value : this.taxId,
    email: email.present ? email.value : this.email,
    phone: phone.present ? phone.value : this.phone,
    status: status ?? this.status,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  CustomerEntity copyWithCompanion(CustomersCompanion data) {
    return CustomerEntity(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      taxId: data.taxId.present ? data.taxId.value : this.taxId,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      status: data.status.present ? data.status.value : this.status,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerEntity(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('displayName: $displayName, ')
          ..write('taxId: $taxId, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('status: $status, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, displayName, taxId, email, phone, status, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerEntity &&
          other.id == this.id &&
          other.type == this.type &&
          other.displayName == this.displayName &&
          other.taxId == this.taxId &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.status == this.status &&
          other.syncedAt == this.syncedAt);
}

class CustomersCompanion extends UpdateCompanion<CustomerEntity> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> displayName;
  final Value<String?> taxId;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String> status;
  final Value<int> syncedAt;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.displayName = const Value.absent(),
    this.taxId = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.status = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    required String type,
    required String displayName,
    this.taxId = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    required String status,
    required int syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       displayName = Value(displayName),
       status = Value(status),
       syncedAt = Value(syncedAt);
  static Insertable<CustomerEntity> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? displayName,
    Expression<String>? taxId,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? status,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (displayName != null) 'display_name': displayName,
      if (taxId != null) 'tax_id': taxId,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (status != null) 'status': status,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? displayName,
    Value<String?>? taxId,
    Value<String?>? email,
    Value<String?>? phone,
    Value<String>? status,
    Value<int>? syncedAt,
    Value<int>? rowid,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      displayName: displayName ?? this.displayName,
      taxId: taxId ?? this.taxId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (taxId.present) {
      map['tax_id'] = Variable<String>(taxId.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('displayName: $displayName, ')
          ..write('taxId: $taxId, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('status: $status, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VehiclesTable extends Vehicles
    with TableInfo<$VehiclesTable, VehicleEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plateMeta = const VerificationMeta('plate');
  @override
  late final GeneratedColumn<String> plate = GeneratedColumn<String>(
    'plate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vinMeta = const VerificationMeta('vin');
  @override
  late final GeneratedColumn<String> vin = GeneratedColumn<String>(
    'vin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _engineTypeMeta = const VerificationMeta(
    'engineType',
  );
  @override
  late final GeneratedColumn<String> engineType = GeneratedColumn<String>(
    'engine_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentOwnerIdMeta = const VerificationMeta(
    'currentOwnerId',
  );
  @override
  late final GeneratedColumn<String> currentOwnerId = GeneratedColumn<String>(
    'current_owner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentMileageMeta = const VerificationMeta(
    'currentMileage',
  );
  @override
  late final GeneratedColumn<int> currentMileage = GeneratedColumn<int>(
    'current_mileage',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    plate,
    vin,
    brand,
    model,
    year,
    engineType,
    currentOwnerId,
    currentMileage,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles';
  @override
  VerificationContext validateIntegrity(
    Insertable<VehicleEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plate')) {
      context.handle(
        _plateMeta,
        plate.isAcceptableOrUnknown(data['plate']!, _plateMeta),
      );
    } else if (isInserting) {
      context.missing(_plateMeta);
    }
    if (data.containsKey('vin')) {
      context.handle(
        _vinMeta,
        vin.isAcceptableOrUnknown(data['vin']!, _vinMeta),
      );
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    } else if (isInserting) {
      context.missing(_brandMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('engine_type')) {
      context.handle(
        _engineTypeMeta,
        engineType.isAcceptableOrUnknown(data['engine_type']!, _engineTypeMeta),
      );
    }
    if (data.containsKey('current_owner_id')) {
      context.handle(
        _currentOwnerIdMeta,
        currentOwnerId.isAcceptableOrUnknown(
          data['current_owner_id']!,
          _currentOwnerIdMeta,
        ),
      );
    }
    if (data.containsKey('current_mileage')) {
      context.handle(
        _currentMileageMeta,
        currentMileage.isAcceptableOrUnknown(
          data['current_mileage']!,
          _currentMileageMeta,
        ),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VehicleEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VehicleEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      plate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plate'],
      )!,
      vin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vin'],
      ),
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      engineType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}engine_type'],
      ),
      currentOwnerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_owner_id'],
      ),
      currentMileage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_mileage'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $VehiclesTable createAlias(String alias) {
    return $VehiclesTable(attachedDatabase, alias);
  }
}

class VehicleEntity extends DataClass implements Insertable<VehicleEntity> {
  final String id;
  final String plate;
  final String? vin;
  final String brand;
  final String model;
  final int? year;
  final String? engineType;
  final String? currentOwnerId;
  final int? currentMileage;
  final int syncedAt;
  const VehicleEntity({
    required this.id,
    required this.plate,
    this.vin,
    required this.brand,
    required this.model,
    this.year,
    this.engineType,
    this.currentOwnerId,
    this.currentMileage,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plate'] = Variable<String>(plate);
    if (!nullToAbsent || vin != null) {
      map['vin'] = Variable<String>(vin);
    }
    map['brand'] = Variable<String>(brand);
    map['model'] = Variable<String>(model);
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || engineType != null) {
      map['engine_type'] = Variable<String>(engineType);
    }
    if (!nullToAbsent || currentOwnerId != null) {
      map['current_owner_id'] = Variable<String>(currentOwnerId);
    }
    if (!nullToAbsent || currentMileage != null) {
      map['current_mileage'] = Variable<int>(currentMileage);
    }
    map['synced_at'] = Variable<int>(syncedAt);
    return map;
  }

  VehiclesCompanion toCompanion(bool nullToAbsent) {
    return VehiclesCompanion(
      id: Value(id),
      plate: Value(plate),
      vin: vin == null && nullToAbsent ? const Value.absent() : Value(vin),
      brand: Value(brand),
      model: Value(model),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      engineType: engineType == null && nullToAbsent
          ? const Value.absent()
          : Value(engineType),
      currentOwnerId: currentOwnerId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentOwnerId),
      currentMileage: currentMileage == null && nullToAbsent
          ? const Value.absent()
          : Value(currentMileage),
      syncedAt: Value(syncedAt),
    );
  }

  factory VehicleEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VehicleEntity(
      id: serializer.fromJson<String>(json['id']),
      plate: serializer.fromJson<String>(json['plate']),
      vin: serializer.fromJson<String?>(json['vin']),
      brand: serializer.fromJson<String>(json['brand']),
      model: serializer.fromJson<String>(json['model']),
      year: serializer.fromJson<int?>(json['year']),
      engineType: serializer.fromJson<String?>(json['engineType']),
      currentOwnerId: serializer.fromJson<String?>(json['currentOwnerId']),
      currentMileage: serializer.fromJson<int?>(json['currentMileage']),
      syncedAt: serializer.fromJson<int>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'plate': serializer.toJson<String>(plate),
      'vin': serializer.toJson<String?>(vin),
      'brand': serializer.toJson<String>(brand),
      'model': serializer.toJson<String>(model),
      'year': serializer.toJson<int?>(year),
      'engineType': serializer.toJson<String?>(engineType),
      'currentOwnerId': serializer.toJson<String?>(currentOwnerId),
      'currentMileage': serializer.toJson<int?>(currentMileage),
      'syncedAt': serializer.toJson<int>(syncedAt),
    };
  }

  VehicleEntity copyWith({
    String? id,
    String? plate,
    Value<String?> vin = const Value.absent(),
    String? brand,
    String? model,
    Value<int?> year = const Value.absent(),
    Value<String?> engineType = const Value.absent(),
    Value<String?> currentOwnerId = const Value.absent(),
    Value<int?> currentMileage = const Value.absent(),
    int? syncedAt,
  }) => VehicleEntity(
    id: id ?? this.id,
    plate: plate ?? this.plate,
    vin: vin.present ? vin.value : this.vin,
    brand: brand ?? this.brand,
    model: model ?? this.model,
    year: year.present ? year.value : this.year,
    engineType: engineType.present ? engineType.value : this.engineType,
    currentOwnerId: currentOwnerId.present
        ? currentOwnerId.value
        : this.currentOwnerId,
    currentMileage: currentMileage.present
        ? currentMileage.value
        : this.currentMileage,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  VehicleEntity copyWithCompanion(VehiclesCompanion data) {
    return VehicleEntity(
      id: data.id.present ? data.id.value : this.id,
      plate: data.plate.present ? data.plate.value : this.plate,
      vin: data.vin.present ? data.vin.value : this.vin,
      brand: data.brand.present ? data.brand.value : this.brand,
      model: data.model.present ? data.model.value : this.model,
      year: data.year.present ? data.year.value : this.year,
      engineType: data.engineType.present
          ? data.engineType.value
          : this.engineType,
      currentOwnerId: data.currentOwnerId.present
          ? data.currentOwnerId.value
          : this.currentOwnerId,
      currentMileage: data.currentMileage.present
          ? data.currentMileage.value
          : this.currentMileage,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VehicleEntity(')
          ..write('id: $id, ')
          ..write('plate: $plate, ')
          ..write('vin: $vin, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('engineType: $engineType, ')
          ..write('currentOwnerId: $currentOwnerId, ')
          ..write('currentMileage: $currentMileage, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    plate,
    vin,
    brand,
    model,
    year,
    engineType,
    currentOwnerId,
    currentMileage,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VehicleEntity &&
          other.id == this.id &&
          other.plate == this.plate &&
          other.vin == this.vin &&
          other.brand == this.brand &&
          other.model == this.model &&
          other.year == this.year &&
          other.engineType == this.engineType &&
          other.currentOwnerId == this.currentOwnerId &&
          other.currentMileage == this.currentMileage &&
          other.syncedAt == this.syncedAt);
}

class VehiclesCompanion extends UpdateCompanion<VehicleEntity> {
  final Value<String> id;
  final Value<String> plate;
  final Value<String?> vin;
  final Value<String> brand;
  final Value<String> model;
  final Value<int?> year;
  final Value<String?> engineType;
  final Value<String?> currentOwnerId;
  final Value<int?> currentMileage;
  final Value<int> syncedAt;
  final Value<int> rowid;
  const VehiclesCompanion({
    this.id = const Value.absent(),
    this.plate = const Value.absent(),
    this.vin = const Value.absent(),
    this.brand = const Value.absent(),
    this.model = const Value.absent(),
    this.year = const Value.absent(),
    this.engineType = const Value.absent(),
    this.currentOwnerId = const Value.absent(),
    this.currentMileage = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VehiclesCompanion.insert({
    required String id,
    required String plate,
    this.vin = const Value.absent(),
    required String brand,
    required String model,
    this.year = const Value.absent(),
    this.engineType = const Value.absent(),
    this.currentOwnerId = const Value.absent(),
    this.currentMileage = const Value.absent(),
    required int syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       plate = Value(plate),
       brand = Value(brand),
       model = Value(model),
       syncedAt = Value(syncedAt);
  static Insertable<VehicleEntity> custom({
    Expression<String>? id,
    Expression<String>? plate,
    Expression<String>? vin,
    Expression<String>? brand,
    Expression<String>? model,
    Expression<int>? year,
    Expression<String>? engineType,
    Expression<String>? currentOwnerId,
    Expression<int>? currentMileage,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plate != null) 'plate': plate,
      if (vin != null) 'vin': vin,
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      if (year != null) 'year': year,
      if (engineType != null) 'engine_type': engineType,
      if (currentOwnerId != null) 'current_owner_id': currentOwnerId,
      if (currentMileage != null) 'current_mileage': currentMileage,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VehiclesCompanion copyWith({
    Value<String>? id,
    Value<String>? plate,
    Value<String?>? vin,
    Value<String>? brand,
    Value<String>? model,
    Value<int?>? year,
    Value<String?>? engineType,
    Value<String?>? currentOwnerId,
    Value<int?>? currentMileage,
    Value<int>? syncedAt,
    Value<int>? rowid,
  }) {
    return VehiclesCompanion(
      id: id ?? this.id,
      plate: plate ?? this.plate,
      vin: vin ?? this.vin,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      engineType: engineType ?? this.engineType,
      currentOwnerId: currentOwnerId ?? this.currentOwnerId,
      currentMileage: currentMileage ?? this.currentMileage,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (plate.present) {
      map['plate'] = Variable<String>(plate.value);
    }
    if (vin.present) {
      map['vin'] = Variable<String>(vin.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (engineType.present) {
      map['engine_type'] = Variable<String>(engineType.value);
    }
    if (currentOwnerId.present) {
      map['current_owner_id'] = Variable<String>(currentOwnerId.value);
    }
    if (currentMileage.present) {
      map['current_mileage'] = Variable<int>(currentMileage.value);
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
    return (StringBuffer('VehiclesCompanion(')
          ..write('id: $id, ')
          ..write('plate: $plate, ')
          ..write('vin: $vin, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('engineType: $engineType, ')
          ..write('currentOwnerId: $currentOwnerId, ')
          ..write('currentMileage: $currentMileage, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppointmentsTable extends Appointments
    with TableInfo<$AppointmentsTable, AppointmentEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppointmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _branchIdMeta = const VerificationMeta(
    'branchId',
  );
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
    'branch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<int> scheduledAt = GeneratedColumn<int>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedDurationMinutesMeta =
      const VerificationMeta('estimatedDurationMinutes');
  @override
  late final GeneratedColumn<int> estimatedDurationMinutes =
      GeneratedColumn<int>(
        'estimated_duration_minutes',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    branchId,
    customerId,
    vehicleId,
    scheduledAt,
    estimatedDurationMinutes,
    reason,
    status,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'appointments';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppointmentEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(
        _branchIdMeta,
        branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('estimated_duration_minutes')) {
      context.handle(
        _estimatedDurationMinutesMeta,
        estimatedDurationMinutes.isAcceptableOrUnknown(
          data['estimated_duration_minutes']!,
          _estimatedDurationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppointmentEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppointmentEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      branchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_at'],
      )!,
      estimatedDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_duration_minutes'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $AppointmentsTable createAlias(String alias) {
    return $AppointmentsTable(attachedDatabase, alias);
  }
}

class AppointmentEntity extends DataClass
    implements Insertable<AppointmentEntity> {
  final String id;
  final String branchId;
  final String customerId;
  final String vehicleId;
  final int scheduledAt;
  final int? estimatedDurationMinutes;
  final String? reason;
  final String status;
  final int syncedAt;
  const AppointmentEntity({
    required this.id,
    required this.branchId,
    required this.customerId,
    required this.vehicleId,
    required this.scheduledAt,
    this.estimatedDurationMinutes,
    this.reason,
    required this.status,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['branch_id'] = Variable<String>(branchId);
    map['customer_id'] = Variable<String>(customerId);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['scheduled_at'] = Variable<int>(scheduledAt);
    if (!nullToAbsent || estimatedDurationMinutes != null) {
      map['estimated_duration_minutes'] = Variable<int>(
        estimatedDurationMinutes,
      );
    }
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['status'] = Variable<String>(status);
    map['synced_at'] = Variable<int>(syncedAt);
    return map;
  }

  AppointmentsCompanion toCompanion(bool nullToAbsent) {
    return AppointmentsCompanion(
      id: Value(id),
      branchId: Value(branchId),
      customerId: Value(customerId),
      vehicleId: Value(vehicleId),
      scheduledAt: Value(scheduledAt),
      estimatedDurationMinutes: estimatedDurationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedDurationMinutes),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      status: Value(status),
      syncedAt: Value(syncedAt),
    );
  }

  factory AppointmentEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppointmentEntity(
      id: serializer.fromJson<String>(json['id']),
      branchId: serializer.fromJson<String>(json['branchId']),
      customerId: serializer.fromJson<String>(json['customerId']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      scheduledAt: serializer.fromJson<int>(json['scheduledAt']),
      estimatedDurationMinutes: serializer.fromJson<int?>(
        json['estimatedDurationMinutes'],
      ),
      reason: serializer.fromJson<String?>(json['reason']),
      status: serializer.fromJson<String>(json['status']),
      syncedAt: serializer.fromJson<int>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'branchId': serializer.toJson<String>(branchId),
      'customerId': serializer.toJson<String>(customerId),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'scheduledAt': serializer.toJson<int>(scheduledAt),
      'estimatedDurationMinutes': serializer.toJson<int?>(
        estimatedDurationMinutes,
      ),
      'reason': serializer.toJson<String?>(reason),
      'status': serializer.toJson<String>(status),
      'syncedAt': serializer.toJson<int>(syncedAt),
    };
  }

  AppointmentEntity copyWith({
    String? id,
    String? branchId,
    String? customerId,
    String? vehicleId,
    int? scheduledAt,
    Value<int?> estimatedDurationMinutes = const Value.absent(),
    Value<String?> reason = const Value.absent(),
    String? status,
    int? syncedAt,
  }) => AppointmentEntity(
    id: id ?? this.id,
    branchId: branchId ?? this.branchId,
    customerId: customerId ?? this.customerId,
    vehicleId: vehicleId ?? this.vehicleId,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    estimatedDurationMinutes: estimatedDurationMinutes.present
        ? estimatedDurationMinutes.value
        : this.estimatedDurationMinutes,
    reason: reason.present ? reason.value : this.reason,
    status: status ?? this.status,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  AppointmentEntity copyWithCompanion(AppointmentsCompanion data) {
    return AppointmentEntity(
      id: data.id.present ? data.id.value : this.id,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      estimatedDurationMinutes: data.estimatedDurationMinutes.present
          ? data.estimatedDurationMinutes.value
          : this.estimatedDurationMinutes,
      reason: data.reason.present ? data.reason.value : this.reason,
      status: data.status.present ? data.status.value : this.status,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppointmentEntity(')
          ..write('id: $id, ')
          ..write('branchId: $branchId, ')
          ..write('customerId: $customerId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('estimatedDurationMinutes: $estimatedDurationMinutes, ')
          ..write('reason: $reason, ')
          ..write('status: $status, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    branchId,
    customerId,
    vehicleId,
    scheduledAt,
    estimatedDurationMinutes,
    reason,
    status,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppointmentEntity &&
          other.id == this.id &&
          other.branchId == this.branchId &&
          other.customerId == this.customerId &&
          other.vehicleId == this.vehicleId &&
          other.scheduledAt == this.scheduledAt &&
          other.estimatedDurationMinutes == this.estimatedDurationMinutes &&
          other.reason == this.reason &&
          other.status == this.status &&
          other.syncedAt == this.syncedAt);
}

class AppointmentsCompanion extends UpdateCompanion<AppointmentEntity> {
  final Value<String> id;
  final Value<String> branchId;
  final Value<String> customerId;
  final Value<String> vehicleId;
  final Value<int> scheduledAt;
  final Value<int?> estimatedDurationMinutes;
  final Value<String?> reason;
  final Value<String> status;
  final Value<int> syncedAt;
  final Value<int> rowid;
  const AppointmentsCompanion({
    this.id = const Value.absent(),
    this.branchId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.estimatedDurationMinutes = const Value.absent(),
    this.reason = const Value.absent(),
    this.status = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppointmentsCompanion.insert({
    required String id,
    required String branchId,
    required String customerId,
    required String vehicleId,
    required int scheduledAt,
    this.estimatedDurationMinutes = const Value.absent(),
    this.reason = const Value.absent(),
    required String status,
    required int syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       branchId = Value(branchId),
       customerId = Value(customerId),
       vehicleId = Value(vehicleId),
       scheduledAt = Value(scheduledAt),
       status = Value(status),
       syncedAt = Value(syncedAt);
  static Insertable<AppointmentEntity> custom({
    Expression<String>? id,
    Expression<String>? branchId,
    Expression<String>? customerId,
    Expression<String>? vehicleId,
    Expression<int>? scheduledAt,
    Expression<int>? estimatedDurationMinutes,
    Expression<String>? reason,
    Expression<String>? status,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (branchId != null) 'branch_id': branchId,
      if (customerId != null) 'customer_id': customerId,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (estimatedDurationMinutes != null)
        'estimated_duration_minutes': estimatedDurationMinutes,
      if (reason != null) 'reason': reason,
      if (status != null) 'status': status,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppointmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? branchId,
    Value<String>? customerId,
    Value<String>? vehicleId,
    Value<int>? scheduledAt,
    Value<int?>? estimatedDurationMinutes,
    Value<String?>? reason,
    Value<String>? status,
    Value<int>? syncedAt,
    Value<int>? rowid,
  }) {
    return AppointmentsCompanion(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      customerId: customerId ?? this.customerId,
      vehicleId: vehicleId ?? this.vehicleId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<int>(scheduledAt.value);
    }
    if (estimatedDurationMinutes.present) {
      map['estimated_duration_minutes'] = Variable<int>(
        estimatedDurationMinutes.value,
      );
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
    return (StringBuffer('AppointmentsCompanion(')
          ..write('id: $id, ')
          ..write('branchId: $branchId, ')
          ..write('customerId: $customerId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('estimatedDurationMinutes: $estimatedDurationMinutes, ')
          ..write('reason: $reason, ')
          ..write('status: $status, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PartsTable extends Parts with TableInfo<$PartsTable, PartEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
    'sku',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _basePriceMeta = const VerificationMeta(
    'basePrice',
  );
  @override
  late final GeneratedColumn<String> basePrice = GeneratedColumn<String>(
    'base_price',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalStockMeta = const VerificationMeta(
    'totalStock',
  );
  @override
  late final GeneratedColumn<String> totalStock = GeneratedColumn<String>(
    'total_stock',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minimumStockMeta = const VerificationMeta(
    'minimumStock',
  );
  @override
  late final GeneratedColumn<String> minimumStock = GeneratedColumn<String>(
    'minimum_stock',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitOfMeasureMeta = const VerificationMeta(
    'unitOfMeasure',
  );
  @override
  late final GeneratedColumn<String> unitOfMeasure = GeneratedColumn<String>(
    'unit_of_measure',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    sku,
    category,
    basePrice,
    totalStock,
    minimumStock,
    unitOfMeasure,
    status,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parts';
  @override
  VerificationContext validateIntegrity(
    Insertable<PartEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
        _skuMeta,
        sku.isAcceptableOrUnknown(data['sku']!, _skuMeta),
      );
    } else if (isInserting) {
      context.missing(_skuMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('base_price')) {
      context.handle(
        _basePriceMeta,
        basePrice.isAcceptableOrUnknown(data['base_price']!, _basePriceMeta),
      );
    } else if (isInserting) {
      context.missing(_basePriceMeta);
    }
    if (data.containsKey('total_stock')) {
      context.handle(
        _totalStockMeta,
        totalStock.isAcceptableOrUnknown(data['total_stock']!, _totalStockMeta),
      );
    } else if (isInserting) {
      context.missing(_totalStockMeta);
    }
    if (data.containsKey('minimum_stock')) {
      context.handle(
        _minimumStockMeta,
        minimumStock.isAcceptableOrUnknown(
          data['minimum_stock']!,
          _minimumStockMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_minimumStockMeta);
    }
    if (data.containsKey('unit_of_measure')) {
      context.handle(
        _unitOfMeasureMeta,
        unitOfMeasure.isAcceptableOrUnknown(
          data['unit_of_measure']!,
          _unitOfMeasureMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitOfMeasureMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PartEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PartEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      basePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_price'],
      )!,
      totalStock: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}total_stock'],
      )!,
      minimumStock: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}minimum_stock'],
      )!,
      unitOfMeasure: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_of_measure'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $PartsTable createAlias(String alias) {
    return $PartsTable(attachedDatabase, alias);
  }
}

class PartEntity extends DataClass implements Insertable<PartEntity> {
  final String id;
  final String name;
  final String sku;
  final String category;
  final String basePrice;
  final String totalStock;
  final String minimumStock;
  final String unitOfMeasure;
  final String status;
  final int syncedAt;
  const PartEntity({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.basePrice,
    required this.totalStock,
    required this.minimumStock,
    required this.unitOfMeasure,
    required this.status,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['sku'] = Variable<String>(sku);
    map['category'] = Variable<String>(category);
    map['base_price'] = Variable<String>(basePrice);
    map['total_stock'] = Variable<String>(totalStock);
    map['minimum_stock'] = Variable<String>(minimumStock);
    map['unit_of_measure'] = Variable<String>(unitOfMeasure);
    map['status'] = Variable<String>(status);
    map['synced_at'] = Variable<int>(syncedAt);
    return map;
  }

  PartsCompanion toCompanion(bool nullToAbsent) {
    return PartsCompanion(
      id: Value(id),
      name: Value(name),
      sku: Value(sku),
      category: Value(category),
      basePrice: Value(basePrice),
      totalStock: Value(totalStock),
      minimumStock: Value(minimumStock),
      unitOfMeasure: Value(unitOfMeasure),
      status: Value(status),
      syncedAt: Value(syncedAt),
    );
  }

  factory PartEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PartEntity(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sku: serializer.fromJson<String>(json['sku']),
      category: serializer.fromJson<String>(json['category']),
      basePrice: serializer.fromJson<String>(json['basePrice']),
      totalStock: serializer.fromJson<String>(json['totalStock']),
      minimumStock: serializer.fromJson<String>(json['minimumStock']),
      unitOfMeasure: serializer.fromJson<String>(json['unitOfMeasure']),
      status: serializer.fromJson<String>(json['status']),
      syncedAt: serializer.fromJson<int>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sku': serializer.toJson<String>(sku),
      'category': serializer.toJson<String>(category),
      'basePrice': serializer.toJson<String>(basePrice),
      'totalStock': serializer.toJson<String>(totalStock),
      'minimumStock': serializer.toJson<String>(minimumStock),
      'unitOfMeasure': serializer.toJson<String>(unitOfMeasure),
      'status': serializer.toJson<String>(status),
      'syncedAt': serializer.toJson<int>(syncedAt),
    };
  }

  PartEntity copyWith({
    String? id,
    String? name,
    String? sku,
    String? category,
    String? basePrice,
    String? totalStock,
    String? minimumStock,
    String? unitOfMeasure,
    String? status,
    int? syncedAt,
  }) => PartEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    sku: sku ?? this.sku,
    category: category ?? this.category,
    basePrice: basePrice ?? this.basePrice,
    totalStock: totalStock ?? this.totalStock,
    minimumStock: minimumStock ?? this.minimumStock,
    unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
    status: status ?? this.status,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  PartEntity copyWithCompanion(PartsCompanion data) {
    return PartEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sku: data.sku.present ? data.sku.value : this.sku,
      category: data.category.present ? data.category.value : this.category,
      basePrice: data.basePrice.present ? data.basePrice.value : this.basePrice,
      totalStock: data.totalStock.present
          ? data.totalStock.value
          : this.totalStock,
      minimumStock: data.minimumStock.present
          ? data.minimumStock.value
          : this.minimumStock,
      unitOfMeasure: data.unitOfMeasure.present
          ? data.unitOfMeasure.value
          : this.unitOfMeasure,
      status: data.status.present ? data.status.value : this.status,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PartEntity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('category: $category, ')
          ..write('basePrice: $basePrice, ')
          ..write('totalStock: $totalStock, ')
          ..write('minimumStock: $minimumStock, ')
          ..write('unitOfMeasure: $unitOfMeasure, ')
          ..write('status: $status, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    sku,
    category,
    basePrice,
    totalStock,
    minimumStock,
    unitOfMeasure,
    status,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartEntity &&
          other.id == this.id &&
          other.name == this.name &&
          other.sku == this.sku &&
          other.category == this.category &&
          other.basePrice == this.basePrice &&
          other.totalStock == this.totalStock &&
          other.minimumStock == this.minimumStock &&
          other.unitOfMeasure == this.unitOfMeasure &&
          other.status == this.status &&
          other.syncedAt == this.syncedAt);
}

class PartsCompanion extends UpdateCompanion<PartEntity> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> sku;
  final Value<String> category;
  final Value<String> basePrice;
  final Value<String> totalStock;
  final Value<String> minimumStock;
  final Value<String> unitOfMeasure;
  final Value<String> status;
  final Value<int> syncedAt;
  final Value<int> rowid;
  const PartsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sku = const Value.absent(),
    this.category = const Value.absent(),
    this.basePrice = const Value.absent(),
    this.totalStock = const Value.absent(),
    this.minimumStock = const Value.absent(),
    this.unitOfMeasure = const Value.absent(),
    this.status = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PartsCompanion.insert({
    required String id,
    required String name,
    required String sku,
    required String category,
    required String basePrice,
    required String totalStock,
    required String minimumStock,
    required String unitOfMeasure,
    required String status,
    required int syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       sku = Value(sku),
       category = Value(category),
       basePrice = Value(basePrice),
       totalStock = Value(totalStock),
       minimumStock = Value(minimumStock),
       unitOfMeasure = Value(unitOfMeasure),
       status = Value(status),
       syncedAt = Value(syncedAt);
  static Insertable<PartEntity> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? sku,
    Expression<String>? category,
    Expression<String>? basePrice,
    Expression<String>? totalStock,
    Expression<String>? minimumStock,
    Expression<String>? unitOfMeasure,
    Expression<String>? status,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sku != null) 'sku': sku,
      if (category != null) 'category': category,
      if (basePrice != null) 'base_price': basePrice,
      if (totalStock != null) 'total_stock': totalStock,
      if (minimumStock != null) 'minimum_stock': minimumStock,
      if (unitOfMeasure != null) 'unit_of_measure': unitOfMeasure,
      if (status != null) 'status': status,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PartsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? sku,
    Value<String>? category,
    Value<String>? basePrice,
    Value<String>? totalStock,
    Value<String>? minimumStock,
    Value<String>? unitOfMeasure,
    Value<String>? status,
    Value<int>? syncedAt,
    Value<int>? rowid,
  }) {
    return PartsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      basePrice: basePrice ?? this.basePrice,
      totalStock: totalStock ?? this.totalStock,
      minimumStock: minimumStock ?? this.minimumStock,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      status: status ?? this.status,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (basePrice.present) {
      map['base_price'] = Variable<String>(basePrice.value);
    }
    if (totalStock.present) {
      map['total_stock'] = Variable<String>(totalStock.value);
    }
    if (minimumStock.present) {
      map['minimum_stock'] = Variable<String>(minimumStock.value);
    }
    if (unitOfMeasure.present) {
      map['unit_of_measure'] = Variable<String>(unitOfMeasure.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
    return (StringBuffer('PartsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('category: $category, ')
          ..write('basePrice: $basePrice, ')
          ..write('totalStock: $totalStock, ')
          ..write('minimumStock: $minimumStock, ')
          ..write('unitOfMeasure: $unitOfMeasure, ')
          ..write('status: $status, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BatchesTable extends Batches with TableInfo<$BatchesTable, BatchEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchNumberMeta = const VerificationMeta(
    'batchNumber',
  );
  @override
  late final GeneratedColumn<String> batchNumber = GeneratedColumn<String>(
    'batch_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remainingQtyMeta = const VerificationMeta(
    'remainingQty',
  );
  @override
  late final GeneratedColumn<String> remainingQty = GeneratedColumn<String>(
    'remaining_qty',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitCostMeta = const VerificationMeta(
    'unitCost',
  );
  @override
  late final GeneratedColumn<String> unitCost = GeneratedColumn<String>(
    'unit_cost',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arrivalDateMeta = const VerificationMeta(
    'arrivalDate',
  );
  @override
  late final GeneratedColumn<int> arrivalDate = GeneratedColumn<int>(
    'arrival_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    batchNumber,
    remainingQty,
    unitCost,
    arrivalDate,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<BatchEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('batch_number')) {
      context.handle(
        _batchNumberMeta,
        batchNumber.isAcceptableOrUnknown(
          data['batch_number']!,
          _batchNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_batchNumberMeta);
    }
    if (data.containsKey('remaining_qty')) {
      context.handle(
        _remainingQtyMeta,
        remainingQty.isAcceptableOrUnknown(
          data['remaining_qty']!,
          _remainingQtyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remainingQtyMeta);
    }
    if (data.containsKey('unit_cost')) {
      context.handle(
        _unitCostMeta,
        unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta),
      );
    } else if (isInserting) {
      context.missing(_unitCostMeta);
    }
    if (data.containsKey('arrival_date')) {
      context.handle(
        _arrivalDateMeta,
        arrivalDate.isAcceptableOrUnknown(
          data['arrival_date']!,
          _arrivalDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_arrivalDateMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BatchEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BatchEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      batchNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_number'],
      )!,
      remainingQty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remaining_qty'],
      )!,
      unitCost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_cost'],
      )!,
      arrivalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}arrival_date'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $BatchesTable createAlias(String alias) {
    return $BatchesTable(attachedDatabase, alias);
  }
}

class BatchEntity extends DataClass implements Insertable<BatchEntity> {
  final String id;
  final String itemId;
  final String batchNumber;
  final String remainingQty;
  final String unitCost;
  final int arrivalDate;
  final int syncedAt;
  const BatchEntity({
    required this.id,
    required this.itemId,
    required this.batchNumber,
    required this.remainingQty,
    required this.unitCost,
    required this.arrivalDate,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['batch_number'] = Variable<String>(batchNumber);
    map['remaining_qty'] = Variable<String>(remainingQty);
    map['unit_cost'] = Variable<String>(unitCost);
    map['arrival_date'] = Variable<int>(arrivalDate);
    map['synced_at'] = Variable<int>(syncedAt);
    return map;
  }

  BatchesCompanion toCompanion(bool nullToAbsent) {
    return BatchesCompanion(
      id: Value(id),
      itemId: Value(itemId),
      batchNumber: Value(batchNumber),
      remainingQty: Value(remainingQty),
      unitCost: Value(unitCost),
      arrivalDate: Value(arrivalDate),
      syncedAt: Value(syncedAt),
    );
  }

  factory BatchEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BatchEntity(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      batchNumber: serializer.fromJson<String>(json['batchNumber']),
      remainingQty: serializer.fromJson<String>(json['remainingQty']),
      unitCost: serializer.fromJson<String>(json['unitCost']),
      arrivalDate: serializer.fromJson<int>(json['arrivalDate']),
      syncedAt: serializer.fromJson<int>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'batchNumber': serializer.toJson<String>(batchNumber),
      'remainingQty': serializer.toJson<String>(remainingQty),
      'unitCost': serializer.toJson<String>(unitCost),
      'arrivalDate': serializer.toJson<int>(arrivalDate),
      'syncedAt': serializer.toJson<int>(syncedAt),
    };
  }

  BatchEntity copyWith({
    String? id,
    String? itemId,
    String? batchNumber,
    String? remainingQty,
    String? unitCost,
    int? arrivalDate,
    int? syncedAt,
  }) => BatchEntity(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    batchNumber: batchNumber ?? this.batchNumber,
    remainingQty: remainingQty ?? this.remainingQty,
    unitCost: unitCost ?? this.unitCost,
    arrivalDate: arrivalDate ?? this.arrivalDate,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  BatchEntity copyWithCompanion(BatchesCompanion data) {
    return BatchEntity(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      batchNumber: data.batchNumber.present
          ? data.batchNumber.value
          : this.batchNumber,
      remainingQty: data.remainingQty.present
          ? data.remainingQty.value
          : this.remainingQty,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      arrivalDate: data.arrivalDate.present
          ? data.arrivalDate.value
          : this.arrivalDate,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BatchEntity(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('remainingQty: $remainingQty, ')
          ..write('unitCost: $unitCost, ')
          ..write('arrivalDate: $arrivalDate, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemId,
    batchNumber,
    remainingQty,
    unitCost,
    arrivalDate,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BatchEntity &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.batchNumber == this.batchNumber &&
          other.remainingQty == this.remainingQty &&
          other.unitCost == this.unitCost &&
          other.arrivalDate == this.arrivalDate &&
          other.syncedAt == this.syncedAt);
}

class BatchesCompanion extends UpdateCompanion<BatchEntity> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String> batchNumber;
  final Value<String> remainingQty;
  final Value<String> unitCost;
  final Value<int> arrivalDate;
  final Value<int> syncedAt;
  final Value<int> rowid;
  const BatchesCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.batchNumber = const Value.absent(),
    this.remainingQty = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.arrivalDate = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BatchesCompanion.insert({
    required String id,
    required String itemId,
    required String batchNumber,
    required String remainingQty,
    required String unitCost,
    required int arrivalDate,
    required int syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemId = Value(itemId),
       batchNumber = Value(batchNumber),
       remainingQty = Value(remainingQty),
       unitCost = Value(unitCost),
       arrivalDate = Value(arrivalDate),
       syncedAt = Value(syncedAt);
  static Insertable<BatchEntity> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? batchNumber,
    Expression<String>? remainingQty,
    Expression<String>? unitCost,
    Expression<int>? arrivalDate,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (batchNumber != null) 'batch_number': batchNumber,
      if (remainingQty != null) 'remaining_qty': remainingQty,
      if (unitCost != null) 'unit_cost': unitCost,
      if (arrivalDate != null) 'arrival_date': arrivalDate,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BatchesCompanion copyWith({
    Value<String>? id,
    Value<String>? itemId,
    Value<String>? batchNumber,
    Value<String>? remainingQty,
    Value<String>? unitCost,
    Value<int>? arrivalDate,
    Value<int>? syncedAt,
    Value<int>? rowid,
  }) {
    return BatchesCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      batchNumber: batchNumber ?? this.batchNumber,
      remainingQty: remainingQty ?? this.remainingQty,
      unitCost: unitCost ?? this.unitCost,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (batchNumber.present) {
      map['batch_number'] = Variable<String>(batchNumber.value);
    }
    if (remainingQty.present) {
      map['remaining_qty'] = Variable<String>(remainingQty.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<String>(unitCost.value);
    }
    if (arrivalDate.present) {
      map['arrival_date'] = Variable<int>(arrivalDate.value);
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
    return (StringBuffer('BatchesCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('remainingQty: $remainingQty, ')
          ..write('unitCost: $unitCost, ')
          ..write('arrivalDate: $arrivalDate, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VouchersTable extends Vouchers
    with TableInfo<$VouchersTable, VoucherEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VouchersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workOrderIdMeta = const VerificationMeta(
    'workOrderId',
  );
  @override
  late final GeneratedColumn<String> workOrderId = GeneratedColumn<String>(
    'work_order_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voucherTypeMeta = const VerificationMeta(
    'voucherType',
  );
  @override
  late final GeneratedColumn<String> voucherType = GeneratedColumn<String>(
    'voucher_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serieMeta = const VerificationMeta('serie');
  @override
  late final GeneratedColumn<String> serie = GeneratedColumn<String>(
    'serie',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<String> totalAmount = GeneratedColumn<String>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidAmountMeta = const VerificationMeta(
    'paidAmount',
  );
  @override
  late final GeneratedColumn<String> paidAmount = GeneratedColumn<String>(
    'paid_amount',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pendingBalanceMeta = const VerificationMeta(
    'pendingBalance',
  );
  @override
  late final GeneratedColumn<String> pendingBalance = GeneratedColumn<String>(
    'pending_balance',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentStatusMeta = const VerificationMeta(
    'paymentStatus',
  );
  @override
  late final GeneratedColumn<String> paymentStatus = GeneratedColumn<String>(
    'payment_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pdfUrlMeta = const VerificationMeta('pdfUrl');
  @override
  late final GeneratedColumn<String> pdfUrl = GeneratedColumn<String>(
    'pdf_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workOrderId,
    voucherType,
    serie,
    number,
    totalAmount,
    paidAmount,
    pendingBalance,
    paymentStatus,
    status,
    pdfUrl,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vouchers';
  @override
  VerificationContext validateIntegrity(
    Insertable<VoucherEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('work_order_id')) {
      context.handle(
        _workOrderIdMeta,
        workOrderId.isAcceptableOrUnknown(
          data['work_order_id']!,
          _workOrderIdMeta,
        ),
      );
    }
    if (data.containsKey('voucher_type')) {
      context.handle(
        _voucherTypeMeta,
        voucherType.isAcceptableOrUnknown(
          data['voucher_type']!,
          _voucherTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_voucherTypeMeta);
    }
    if (data.containsKey('serie')) {
      context.handle(
        _serieMeta,
        serie.isAcceptableOrUnknown(data['serie']!, _serieMeta),
      );
    } else if (isInserting) {
      context.missing(_serieMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('paid_amount')) {
      context.handle(
        _paidAmountMeta,
        paidAmount.isAcceptableOrUnknown(data['paid_amount']!, _paidAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_paidAmountMeta);
    }
    if (data.containsKey('pending_balance')) {
      context.handle(
        _pendingBalanceMeta,
        pendingBalance.isAcceptableOrUnknown(
          data['pending_balance']!,
          _pendingBalanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pendingBalanceMeta);
    }
    if (data.containsKey('payment_status')) {
      context.handle(
        _paymentStatusMeta,
        paymentStatus.isAcceptableOrUnknown(
          data['payment_status']!,
          _paymentStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentStatusMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('pdf_url')) {
      context.handle(
        _pdfUrlMeta,
        pdfUrl.isAcceptableOrUnknown(data['pdf_url']!, _pdfUrlMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VoucherEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VoucherEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workOrderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_order_id'],
      ),
      voucherType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voucher_type'],
      )!,
      serie: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serie'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}total_amount'],
      )!,
      paidAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paid_amount'],
      )!,
      pendingBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pending_balance'],
      )!,
      paymentStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_status'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      pdfUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pdf_url'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $VouchersTable createAlias(String alias) {
    return $VouchersTable(attachedDatabase, alias);
  }
}

class VoucherEntity extends DataClass implements Insertable<VoucherEntity> {
  final String id;
  final String? workOrderId;
  final String voucherType;
  final String serie;
  final int number;
  final String totalAmount;
  final String paidAmount;
  final String pendingBalance;
  final String paymentStatus;
  final String status;
  final String? pdfUrl;
  final int syncedAt;
  const VoucherEntity({
    required this.id,
    this.workOrderId,
    required this.voucherType,
    required this.serie,
    required this.number,
    required this.totalAmount,
    required this.paidAmount,
    required this.pendingBalance,
    required this.paymentStatus,
    required this.status,
    this.pdfUrl,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || workOrderId != null) {
      map['work_order_id'] = Variable<String>(workOrderId);
    }
    map['voucher_type'] = Variable<String>(voucherType);
    map['serie'] = Variable<String>(serie);
    map['number'] = Variable<int>(number);
    map['total_amount'] = Variable<String>(totalAmount);
    map['paid_amount'] = Variable<String>(paidAmount);
    map['pending_balance'] = Variable<String>(pendingBalance);
    map['payment_status'] = Variable<String>(paymentStatus);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || pdfUrl != null) {
      map['pdf_url'] = Variable<String>(pdfUrl);
    }
    map['synced_at'] = Variable<int>(syncedAt);
    return map;
  }

  VouchersCompanion toCompanion(bool nullToAbsent) {
    return VouchersCompanion(
      id: Value(id),
      workOrderId: workOrderId == null && nullToAbsent
          ? const Value.absent()
          : Value(workOrderId),
      voucherType: Value(voucherType),
      serie: Value(serie),
      number: Value(number),
      totalAmount: Value(totalAmount),
      paidAmount: Value(paidAmount),
      pendingBalance: Value(pendingBalance),
      paymentStatus: Value(paymentStatus),
      status: Value(status),
      pdfUrl: pdfUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(pdfUrl),
      syncedAt: Value(syncedAt),
    );
  }

  factory VoucherEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VoucherEntity(
      id: serializer.fromJson<String>(json['id']),
      workOrderId: serializer.fromJson<String?>(json['workOrderId']),
      voucherType: serializer.fromJson<String>(json['voucherType']),
      serie: serializer.fromJson<String>(json['serie']),
      number: serializer.fromJson<int>(json['number']),
      totalAmount: serializer.fromJson<String>(json['totalAmount']),
      paidAmount: serializer.fromJson<String>(json['paidAmount']),
      pendingBalance: serializer.fromJson<String>(json['pendingBalance']),
      paymentStatus: serializer.fromJson<String>(json['paymentStatus']),
      status: serializer.fromJson<String>(json['status']),
      pdfUrl: serializer.fromJson<String?>(json['pdfUrl']),
      syncedAt: serializer.fromJson<int>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workOrderId': serializer.toJson<String?>(workOrderId),
      'voucherType': serializer.toJson<String>(voucherType),
      'serie': serializer.toJson<String>(serie),
      'number': serializer.toJson<int>(number),
      'totalAmount': serializer.toJson<String>(totalAmount),
      'paidAmount': serializer.toJson<String>(paidAmount),
      'pendingBalance': serializer.toJson<String>(pendingBalance),
      'paymentStatus': serializer.toJson<String>(paymentStatus),
      'status': serializer.toJson<String>(status),
      'pdfUrl': serializer.toJson<String?>(pdfUrl),
      'syncedAt': serializer.toJson<int>(syncedAt),
    };
  }

  VoucherEntity copyWith({
    String? id,
    Value<String?> workOrderId = const Value.absent(),
    String? voucherType,
    String? serie,
    int? number,
    String? totalAmount,
    String? paidAmount,
    String? pendingBalance,
    String? paymentStatus,
    String? status,
    Value<String?> pdfUrl = const Value.absent(),
    int? syncedAt,
  }) => VoucherEntity(
    id: id ?? this.id,
    workOrderId: workOrderId.present ? workOrderId.value : this.workOrderId,
    voucherType: voucherType ?? this.voucherType,
    serie: serie ?? this.serie,
    number: number ?? this.number,
    totalAmount: totalAmount ?? this.totalAmount,
    paidAmount: paidAmount ?? this.paidAmount,
    pendingBalance: pendingBalance ?? this.pendingBalance,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    status: status ?? this.status,
    pdfUrl: pdfUrl.present ? pdfUrl.value : this.pdfUrl,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  VoucherEntity copyWithCompanion(VouchersCompanion data) {
    return VoucherEntity(
      id: data.id.present ? data.id.value : this.id,
      workOrderId: data.workOrderId.present
          ? data.workOrderId.value
          : this.workOrderId,
      voucherType: data.voucherType.present
          ? data.voucherType.value
          : this.voucherType,
      serie: data.serie.present ? data.serie.value : this.serie,
      number: data.number.present ? data.number.value : this.number,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      paidAmount: data.paidAmount.present
          ? data.paidAmount.value
          : this.paidAmount,
      pendingBalance: data.pendingBalance.present
          ? data.pendingBalance.value
          : this.pendingBalance,
      paymentStatus: data.paymentStatus.present
          ? data.paymentStatus.value
          : this.paymentStatus,
      status: data.status.present ? data.status.value : this.status,
      pdfUrl: data.pdfUrl.present ? data.pdfUrl.value : this.pdfUrl,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VoucherEntity(')
          ..write('id: $id, ')
          ..write('workOrderId: $workOrderId, ')
          ..write('voucherType: $voucherType, ')
          ..write('serie: $serie, ')
          ..write('number: $number, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('pendingBalance: $pendingBalance, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('status: $status, ')
          ..write('pdfUrl: $pdfUrl, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workOrderId,
    voucherType,
    serie,
    number,
    totalAmount,
    paidAmount,
    pendingBalance,
    paymentStatus,
    status,
    pdfUrl,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VoucherEntity &&
          other.id == this.id &&
          other.workOrderId == this.workOrderId &&
          other.voucherType == this.voucherType &&
          other.serie == this.serie &&
          other.number == this.number &&
          other.totalAmount == this.totalAmount &&
          other.paidAmount == this.paidAmount &&
          other.pendingBalance == this.pendingBalance &&
          other.paymentStatus == this.paymentStatus &&
          other.status == this.status &&
          other.pdfUrl == this.pdfUrl &&
          other.syncedAt == this.syncedAt);
}

class VouchersCompanion extends UpdateCompanion<VoucherEntity> {
  final Value<String> id;
  final Value<String?> workOrderId;
  final Value<String> voucherType;
  final Value<String> serie;
  final Value<int> number;
  final Value<String> totalAmount;
  final Value<String> paidAmount;
  final Value<String> pendingBalance;
  final Value<String> paymentStatus;
  final Value<String> status;
  final Value<String?> pdfUrl;
  final Value<int> syncedAt;
  final Value<int> rowid;
  const VouchersCompanion({
    this.id = const Value.absent(),
    this.workOrderId = const Value.absent(),
    this.voucherType = const Value.absent(),
    this.serie = const Value.absent(),
    this.number = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.pendingBalance = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.status = const Value.absent(),
    this.pdfUrl = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VouchersCompanion.insert({
    required String id,
    this.workOrderId = const Value.absent(),
    required String voucherType,
    required String serie,
    required int number,
    required String totalAmount,
    required String paidAmount,
    required String pendingBalance,
    required String paymentStatus,
    required String status,
    this.pdfUrl = const Value.absent(),
    required int syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       voucherType = Value(voucherType),
       serie = Value(serie),
       number = Value(number),
       totalAmount = Value(totalAmount),
       paidAmount = Value(paidAmount),
       pendingBalance = Value(pendingBalance),
       paymentStatus = Value(paymentStatus),
       status = Value(status),
       syncedAt = Value(syncedAt);
  static Insertable<VoucherEntity> custom({
    Expression<String>? id,
    Expression<String>? workOrderId,
    Expression<String>? voucherType,
    Expression<String>? serie,
    Expression<int>? number,
    Expression<String>? totalAmount,
    Expression<String>? paidAmount,
    Expression<String>? pendingBalance,
    Expression<String>? paymentStatus,
    Expression<String>? status,
    Expression<String>? pdfUrl,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workOrderId != null) 'work_order_id': workOrderId,
      if (voucherType != null) 'voucher_type': voucherType,
      if (serie != null) 'serie': serie,
      if (number != null) 'number': number,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (paidAmount != null) 'paid_amount': paidAmount,
      if (pendingBalance != null) 'pending_balance': pendingBalance,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (status != null) 'status': status,
      if (pdfUrl != null) 'pdf_url': pdfUrl,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VouchersCompanion copyWith({
    Value<String>? id,
    Value<String?>? workOrderId,
    Value<String>? voucherType,
    Value<String>? serie,
    Value<int>? number,
    Value<String>? totalAmount,
    Value<String>? paidAmount,
    Value<String>? pendingBalance,
    Value<String>? paymentStatus,
    Value<String>? status,
    Value<String?>? pdfUrl,
    Value<int>? syncedAt,
    Value<int>? rowid,
  }) {
    return VouchersCompanion(
      id: id ?? this.id,
      workOrderId: workOrderId ?? this.workOrderId,
      voucherType: voucherType ?? this.voucherType,
      serie: serie ?? this.serie,
      number: number ?? this.number,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workOrderId.present) {
      map['work_order_id'] = Variable<String>(workOrderId.value);
    }
    if (voucherType.present) {
      map['voucher_type'] = Variable<String>(voucherType.value);
    }
    if (serie.present) {
      map['serie'] = Variable<String>(serie.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<String>(totalAmount.value);
    }
    if (paidAmount.present) {
      map['paid_amount'] = Variable<String>(paidAmount.value);
    }
    if (pendingBalance.present) {
      map['pending_balance'] = Variable<String>(pendingBalance.value);
    }
    if (paymentStatus.present) {
      map['payment_status'] = Variable<String>(paymentStatus.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (pdfUrl.present) {
      map['pdf_url'] = Variable<String>(pdfUrl.value);
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
    return (StringBuffer('VouchersCompanion(')
          ..write('id: $id, ')
          ..write('workOrderId: $workOrderId, ')
          ..write('voucherType: $voucherType, ')
          ..write('serie: $serie, ')
          ..write('number: $number, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('pendingBalance: $pendingBalance, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('status: $status, ')
          ..write('pdfUrl: $pdfUrl, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TelemetryReadingsTable extends TelemetryReadings
    with TableInfo<$TelemetryReadingsTable, TelemetryReadingEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TelemetryReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _engineTempCelsiusMeta = const VerificationMeta(
    'engineTempCelsius',
  );
  @override
  late final GeneratedColumn<double> engineTempCelsius =
      GeneratedColumn<double>(
        'engine_temp_celsius',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _engineRpmMeta = const VerificationMeta(
    'engineRpm',
  );
  @override
  late final GeneratedColumn<int> engineRpm = GeneratedColumn<int>(
    'engine_rpm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speedKmhMeta = const VerificationMeta(
    'speedKmh',
  );
  @override
  late final GeneratedColumn<int> speedKmh = GeneratedColumn<int>(
    'speed_kmh',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batteryVoltageMeta = const VerificationMeta(
    'batteryVoltage',
  );
  @override
  late final GeneratedColumn<double> batteryVoltage = GeneratedColumn<double>(
    'battery_voltage',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fuelPercentageMeta = const VerificationMeta(
    'fuelPercentage',
  );
  @override
  late final GeneratedColumn<double> fuelPercentage = GeneratedColumn<double>(
    'fuel_percentage',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batchOperationIdMeta = const VerificationMeta(
    'batchOperationId',
  );
  @override
  late final GeneratedColumn<String> batchOperationId = GeneratedColumn<String>(
    'batch_operation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vehicleId,
    timestamp,
    engineTempCelsius,
    engineRpm,
    speedKmh,
    batteryVoltage,
    fuelPercentage,
    latitude,
    longitude,
    batchOperationId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'telemetry_readings';
  @override
  VerificationContext validateIntegrity(
    Insertable<TelemetryReadingEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('engine_temp_celsius')) {
      context.handle(
        _engineTempCelsiusMeta,
        engineTempCelsius.isAcceptableOrUnknown(
          data['engine_temp_celsius']!,
          _engineTempCelsiusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_engineTempCelsiusMeta);
    }
    if (data.containsKey('engine_rpm')) {
      context.handle(
        _engineRpmMeta,
        engineRpm.isAcceptableOrUnknown(data['engine_rpm']!, _engineRpmMeta),
      );
    }
    if (data.containsKey('speed_kmh')) {
      context.handle(
        _speedKmhMeta,
        speedKmh.isAcceptableOrUnknown(data['speed_kmh']!, _speedKmhMeta),
      );
    }
    if (data.containsKey('battery_voltage')) {
      context.handle(
        _batteryVoltageMeta,
        batteryVoltage.isAcceptableOrUnknown(
          data['battery_voltage']!,
          _batteryVoltageMeta,
        ),
      );
    }
    if (data.containsKey('fuel_percentage')) {
      context.handle(
        _fuelPercentageMeta,
        fuelPercentage.isAcceptableOrUnknown(
          data['fuel_percentage']!,
          _fuelPercentageMeta,
        ),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('batch_operation_id')) {
      context.handle(
        _batchOperationIdMeta,
        batchOperationId.isAcceptableOrUnknown(
          data['batch_operation_id']!,
          _batchOperationIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TelemetryReadingEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TelemetryReadingEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp'],
      )!,
      engineTempCelsius: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}engine_temp_celsius'],
      )!,
      engineRpm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}engine_rpm'],
      ),
      speedKmh: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}speed_kmh'],
      ),
      batteryVoltage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}battery_voltage'],
      ),
      fuelPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fuel_percentage'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      batchOperationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_operation_id'],
      ),
    );
  }

  @override
  $TelemetryReadingsTable createAlias(String alias) {
    return $TelemetryReadingsTable(attachedDatabase, alias);
  }
}

class TelemetryReadingEntity extends DataClass
    implements Insertable<TelemetryReadingEntity> {
  final String id;
  final String vehicleId;
  final int timestamp;
  final double engineTempCelsius;
  final int? engineRpm;
  final int? speedKmh;
  final double? batteryVoltage;
  final double? fuelPercentage;
  final double? latitude;
  final double? longitude;
  final String? batchOperationId;
  const TelemetryReadingEntity({
    required this.id,
    required this.vehicleId,
    required this.timestamp,
    required this.engineTempCelsius,
    this.engineRpm,
    this.speedKmh,
    this.batteryVoltage,
    this.fuelPercentage,
    this.latitude,
    this.longitude,
    this.batchOperationId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['timestamp'] = Variable<int>(timestamp);
    map['engine_temp_celsius'] = Variable<double>(engineTempCelsius);
    if (!nullToAbsent || engineRpm != null) {
      map['engine_rpm'] = Variable<int>(engineRpm);
    }
    if (!nullToAbsent || speedKmh != null) {
      map['speed_kmh'] = Variable<int>(speedKmh);
    }
    if (!nullToAbsent || batteryVoltage != null) {
      map['battery_voltage'] = Variable<double>(batteryVoltage);
    }
    if (!nullToAbsent || fuelPercentage != null) {
      map['fuel_percentage'] = Variable<double>(fuelPercentage);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || batchOperationId != null) {
      map['batch_operation_id'] = Variable<String>(batchOperationId);
    }
    return map;
  }

  TelemetryReadingsCompanion toCompanion(bool nullToAbsent) {
    return TelemetryReadingsCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      timestamp: Value(timestamp),
      engineTempCelsius: Value(engineTempCelsius),
      engineRpm: engineRpm == null && nullToAbsent
          ? const Value.absent()
          : Value(engineRpm),
      speedKmh: speedKmh == null && nullToAbsent
          ? const Value.absent()
          : Value(speedKmh),
      batteryVoltage: batteryVoltage == null && nullToAbsent
          ? const Value.absent()
          : Value(batteryVoltage),
      fuelPercentage: fuelPercentage == null && nullToAbsent
          ? const Value.absent()
          : Value(fuelPercentage),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      batchOperationId: batchOperationId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchOperationId),
    );
  }

  factory TelemetryReadingEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TelemetryReadingEntity(
      id: serializer.fromJson<String>(json['id']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      engineTempCelsius: serializer.fromJson<double>(json['engineTempCelsius']),
      engineRpm: serializer.fromJson<int?>(json['engineRpm']),
      speedKmh: serializer.fromJson<int?>(json['speedKmh']),
      batteryVoltage: serializer.fromJson<double?>(json['batteryVoltage']),
      fuelPercentage: serializer.fromJson<double?>(json['fuelPercentage']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      batchOperationId: serializer.fromJson<String?>(json['batchOperationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'timestamp': serializer.toJson<int>(timestamp),
      'engineTempCelsius': serializer.toJson<double>(engineTempCelsius),
      'engineRpm': serializer.toJson<int?>(engineRpm),
      'speedKmh': serializer.toJson<int?>(speedKmh),
      'batteryVoltage': serializer.toJson<double?>(batteryVoltage),
      'fuelPercentage': serializer.toJson<double?>(fuelPercentage),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'batchOperationId': serializer.toJson<String?>(batchOperationId),
    };
  }

  TelemetryReadingEntity copyWith({
    String? id,
    String? vehicleId,
    int? timestamp,
    double? engineTempCelsius,
    Value<int?> engineRpm = const Value.absent(),
    Value<int?> speedKmh = const Value.absent(),
    Value<double?> batteryVoltage = const Value.absent(),
    Value<double?> fuelPercentage = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<String?> batchOperationId = const Value.absent(),
  }) => TelemetryReadingEntity(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    timestamp: timestamp ?? this.timestamp,
    engineTempCelsius: engineTempCelsius ?? this.engineTempCelsius,
    engineRpm: engineRpm.present ? engineRpm.value : this.engineRpm,
    speedKmh: speedKmh.present ? speedKmh.value : this.speedKmh,
    batteryVoltage: batteryVoltage.present
        ? batteryVoltage.value
        : this.batteryVoltage,
    fuelPercentage: fuelPercentage.present
        ? fuelPercentage.value
        : this.fuelPercentage,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    batchOperationId: batchOperationId.present
        ? batchOperationId.value
        : this.batchOperationId,
  );
  TelemetryReadingEntity copyWithCompanion(TelemetryReadingsCompanion data) {
    return TelemetryReadingEntity(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      engineTempCelsius: data.engineTempCelsius.present
          ? data.engineTempCelsius.value
          : this.engineTempCelsius,
      engineRpm: data.engineRpm.present ? data.engineRpm.value : this.engineRpm,
      speedKmh: data.speedKmh.present ? data.speedKmh.value : this.speedKmh,
      batteryVoltage: data.batteryVoltage.present
          ? data.batteryVoltage.value
          : this.batteryVoltage,
      fuelPercentage: data.fuelPercentage.present
          ? data.fuelPercentage.value
          : this.fuelPercentage,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      batchOperationId: data.batchOperationId.present
          ? data.batchOperationId.value
          : this.batchOperationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TelemetryReadingEntity(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('timestamp: $timestamp, ')
          ..write('engineTempCelsius: $engineTempCelsius, ')
          ..write('engineRpm: $engineRpm, ')
          ..write('speedKmh: $speedKmh, ')
          ..write('batteryVoltage: $batteryVoltage, ')
          ..write('fuelPercentage: $fuelPercentage, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('batchOperationId: $batchOperationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vehicleId,
    timestamp,
    engineTempCelsius,
    engineRpm,
    speedKmh,
    batteryVoltage,
    fuelPercentage,
    latitude,
    longitude,
    batchOperationId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TelemetryReadingEntity &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.timestamp == this.timestamp &&
          other.engineTempCelsius == this.engineTempCelsius &&
          other.engineRpm == this.engineRpm &&
          other.speedKmh == this.speedKmh &&
          other.batteryVoltage == this.batteryVoltage &&
          other.fuelPercentage == this.fuelPercentage &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.batchOperationId == this.batchOperationId);
}

class TelemetryReadingsCompanion
    extends UpdateCompanion<TelemetryReadingEntity> {
  final Value<String> id;
  final Value<String> vehicleId;
  final Value<int> timestamp;
  final Value<double> engineTempCelsius;
  final Value<int?> engineRpm;
  final Value<int?> speedKmh;
  final Value<double?> batteryVoltage;
  final Value<double?> fuelPercentage;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> batchOperationId;
  final Value<int> rowid;
  const TelemetryReadingsCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.engineTempCelsius = const Value.absent(),
    this.engineRpm = const Value.absent(),
    this.speedKmh = const Value.absent(),
    this.batteryVoltage = const Value.absent(),
    this.fuelPercentage = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.batchOperationId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TelemetryReadingsCompanion.insert({
    required String id,
    required String vehicleId,
    required int timestamp,
    required double engineTempCelsius,
    this.engineRpm = const Value.absent(),
    this.speedKmh = const Value.absent(),
    this.batteryVoltage = const Value.absent(),
    this.fuelPercentage = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.batchOperationId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vehicleId = Value(vehicleId),
       timestamp = Value(timestamp),
       engineTempCelsius = Value(engineTempCelsius);
  static Insertable<TelemetryReadingEntity> custom({
    Expression<String>? id,
    Expression<String>? vehicleId,
    Expression<int>? timestamp,
    Expression<double>? engineTempCelsius,
    Expression<int>? engineRpm,
    Expression<int>? speedKmh,
    Expression<double>? batteryVoltage,
    Expression<double>? fuelPercentage,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? batchOperationId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (timestamp != null) 'timestamp': timestamp,
      if (engineTempCelsius != null) 'engine_temp_celsius': engineTempCelsius,
      if (engineRpm != null) 'engine_rpm': engineRpm,
      if (speedKmh != null) 'speed_kmh': speedKmh,
      if (batteryVoltage != null) 'battery_voltage': batteryVoltage,
      if (fuelPercentage != null) 'fuel_percentage': fuelPercentage,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (batchOperationId != null) 'batch_operation_id': batchOperationId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TelemetryReadingsCompanion copyWith({
    Value<String>? id,
    Value<String>? vehicleId,
    Value<int>? timestamp,
    Value<double>? engineTempCelsius,
    Value<int?>? engineRpm,
    Value<int?>? speedKmh,
    Value<double?>? batteryVoltage,
    Value<double?>? fuelPercentage,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String?>? batchOperationId,
    Value<int>? rowid,
  }) {
    return TelemetryReadingsCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      timestamp: timestamp ?? this.timestamp,
      engineTempCelsius: engineTempCelsius ?? this.engineTempCelsius,
      engineRpm: engineRpm ?? this.engineRpm,
      speedKmh: speedKmh ?? this.speedKmh,
      batteryVoltage: batteryVoltage ?? this.batteryVoltage,
      fuelPercentage: fuelPercentage ?? this.fuelPercentage,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      batchOperationId: batchOperationId ?? this.batchOperationId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (engineTempCelsius.present) {
      map['engine_temp_celsius'] = Variable<double>(engineTempCelsius.value);
    }
    if (engineRpm.present) {
      map['engine_rpm'] = Variable<int>(engineRpm.value);
    }
    if (speedKmh.present) {
      map['speed_kmh'] = Variable<int>(speedKmh.value);
    }
    if (batteryVoltage.present) {
      map['battery_voltage'] = Variable<double>(batteryVoltage.value);
    }
    if (fuelPercentage.present) {
      map['fuel_percentage'] = Variable<double>(fuelPercentage.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (batchOperationId.present) {
      map['batch_operation_id'] = Variable<String>(batchOperationId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TelemetryReadingsCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('timestamp: $timestamp, ')
          ..write('engineTempCelsius: $engineTempCelsius, ')
          ..write('engineRpm: $engineRpm, ')
          ..write('speedKmh: $speedKmh, ')
          ..write('batteryVoltage: $batteryVoltage, ')
          ..write('fuelPercentage: $fuelPercentage, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('batchOperationId: $batchOperationId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VehicleFaultsTable extends VehicleFaults
    with TableInfo<$VehicleFaultsTable, VehicleFaultEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehicleFaultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dtcCodeMeta = const VerificationMeta(
    'dtcCode',
  );
  @override
  late final GeneratedColumn<String> dtcCode = GeneratedColumn<String>(
    'dtc_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detectedAtMeta = const VerificationMeta(
    'detectedAt',
  );
  @override
  late final GeneratedColumn<int> detectedAt = GeneratedColumn<int>(
    'detected_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isResolvedMeta = const VerificationMeta(
    'isResolved',
  );
  @override
  late final GeneratedColumn<bool> isResolved = GeneratedColumn<bool>(
    'is_resolved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_resolved" IN (0, 1))',
    ),
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<int> resolvedAt = GeneratedColumn<int>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
    id,
    vehicleId,
    dtcCode,
    severity,
    description,
    detectedAt,
    isResolved,
    resolvedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicle_faults';
  @override
  VerificationContext validateIntegrity(
    Insertable<VehicleFaultEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('dtc_code')) {
      context.handle(
        _dtcCodeMeta,
        dtcCode.isAcceptableOrUnknown(data['dtc_code']!, _dtcCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_dtcCodeMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('detected_at')) {
      context.handle(
        _detectedAtMeta,
        detectedAt.isAcceptableOrUnknown(data['detected_at']!, _detectedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_detectedAtMeta);
    }
    if (data.containsKey('is_resolved')) {
      context.handle(
        _isResolvedMeta,
        isResolved.isAcceptableOrUnknown(data['is_resolved']!, _isResolvedMeta),
      );
    } else if (isInserting) {
      context.missing(_isResolvedMeta);
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VehicleFaultEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VehicleFaultEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      dtcCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dtc_code'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      detectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}detected_at'],
      )!,
      isResolved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_resolved'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resolved_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $VehicleFaultsTable createAlias(String alias) {
    return $VehicleFaultsTable(attachedDatabase, alias);
  }
}

class VehicleFaultEntity extends DataClass
    implements Insertable<VehicleFaultEntity> {
  final String id;
  final String vehicleId;
  final String dtcCode;
  final String severity;
  final String description;
  final int detectedAt;
  final bool isResolved;
  final int? resolvedAt;
  final int? syncedAt;
  const VehicleFaultEntity({
    required this.id,
    required this.vehicleId,
    required this.dtcCode,
    required this.severity,
    required this.description,
    required this.detectedAt,
    required this.isResolved,
    this.resolvedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['dtc_code'] = Variable<String>(dtcCode);
    map['severity'] = Variable<String>(severity);
    map['description'] = Variable<String>(description);
    map['detected_at'] = Variable<int>(detectedAt);
    map['is_resolved'] = Variable<bool>(isResolved);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<int>(resolvedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<int>(syncedAt);
    }
    return map;
  }

  VehicleFaultsCompanion toCompanion(bool nullToAbsent) {
    return VehicleFaultsCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      dtcCode: Value(dtcCode),
      severity: Value(severity),
      description: Value(description),
      detectedAt: Value(detectedAt),
      isResolved: Value(isResolved),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory VehicleFaultEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VehicleFaultEntity(
      id: serializer.fromJson<String>(json['id']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      dtcCode: serializer.fromJson<String>(json['dtcCode']),
      severity: serializer.fromJson<String>(json['severity']),
      description: serializer.fromJson<String>(json['description']),
      detectedAt: serializer.fromJson<int>(json['detectedAt']),
      isResolved: serializer.fromJson<bool>(json['isResolved']),
      resolvedAt: serializer.fromJson<int?>(json['resolvedAt']),
      syncedAt: serializer.fromJson<int?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'dtcCode': serializer.toJson<String>(dtcCode),
      'severity': serializer.toJson<String>(severity),
      'description': serializer.toJson<String>(description),
      'detectedAt': serializer.toJson<int>(detectedAt),
      'isResolved': serializer.toJson<bool>(isResolved),
      'resolvedAt': serializer.toJson<int?>(resolvedAt),
      'syncedAt': serializer.toJson<int?>(syncedAt),
    };
  }

  VehicleFaultEntity copyWith({
    String? id,
    String? vehicleId,
    String? dtcCode,
    String? severity,
    String? description,
    int? detectedAt,
    bool? isResolved,
    Value<int?> resolvedAt = const Value.absent(),
    Value<int?> syncedAt = const Value.absent(),
  }) => VehicleFaultEntity(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    dtcCode: dtcCode ?? this.dtcCode,
    severity: severity ?? this.severity,
    description: description ?? this.description,
    detectedAt: detectedAt ?? this.detectedAt,
    isResolved: isResolved ?? this.isResolved,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  VehicleFaultEntity copyWithCompanion(VehicleFaultsCompanion data) {
    return VehicleFaultEntity(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      dtcCode: data.dtcCode.present ? data.dtcCode.value : this.dtcCode,
      severity: data.severity.present ? data.severity.value : this.severity,
      description: data.description.present
          ? data.description.value
          : this.description,
      detectedAt: data.detectedAt.present
          ? data.detectedAt.value
          : this.detectedAt,
      isResolved: data.isResolved.present
          ? data.isResolved.value
          : this.isResolved,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VehicleFaultEntity(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('dtcCode: $dtcCode, ')
          ..write('severity: $severity, ')
          ..write('description: $description, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('isResolved: $isResolved, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vehicleId,
    dtcCode,
    severity,
    description,
    detectedAt,
    isResolved,
    resolvedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VehicleFaultEntity &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.dtcCode == this.dtcCode &&
          other.severity == this.severity &&
          other.description == this.description &&
          other.detectedAt == this.detectedAt &&
          other.isResolved == this.isResolved &&
          other.resolvedAt == this.resolvedAt &&
          other.syncedAt == this.syncedAt);
}

class VehicleFaultsCompanion extends UpdateCompanion<VehicleFaultEntity> {
  final Value<String> id;
  final Value<String> vehicleId;
  final Value<String> dtcCode;
  final Value<String> severity;
  final Value<String> description;
  final Value<int> detectedAt;
  final Value<bool> isResolved;
  final Value<int?> resolvedAt;
  final Value<int?> syncedAt;
  final Value<int> rowid;
  const VehicleFaultsCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.dtcCode = const Value.absent(),
    this.severity = const Value.absent(),
    this.description = const Value.absent(),
    this.detectedAt = const Value.absent(),
    this.isResolved = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VehicleFaultsCompanion.insert({
    required String id,
    required String vehicleId,
    required String dtcCode,
    required String severity,
    required String description,
    required int detectedAt,
    required bool isResolved,
    this.resolvedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vehicleId = Value(vehicleId),
       dtcCode = Value(dtcCode),
       severity = Value(severity),
       description = Value(description),
       detectedAt = Value(detectedAt),
       isResolved = Value(isResolved);
  static Insertable<VehicleFaultEntity> custom({
    Expression<String>? id,
    Expression<String>? vehicleId,
    Expression<String>? dtcCode,
    Expression<String>? severity,
    Expression<String>? description,
    Expression<int>? detectedAt,
    Expression<bool>? isResolved,
    Expression<int>? resolvedAt,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (dtcCode != null) 'dtc_code': dtcCode,
      if (severity != null) 'severity': severity,
      if (description != null) 'description': description,
      if (detectedAt != null) 'detected_at': detectedAt,
      if (isResolved != null) 'is_resolved': isResolved,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VehicleFaultsCompanion copyWith({
    Value<String>? id,
    Value<String>? vehicleId,
    Value<String>? dtcCode,
    Value<String>? severity,
    Value<String>? description,
    Value<int>? detectedAt,
    Value<bool>? isResolved,
    Value<int?>? resolvedAt,
    Value<int?>? syncedAt,
    Value<int>? rowid,
  }) {
    return VehicleFaultsCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      dtcCode: dtcCode ?? this.dtcCode,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      detectedAt: detectedAt ?? this.detectedAt,
      isResolved: isResolved ?? this.isResolved,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (dtcCode.present) {
      map['dtc_code'] = Variable<String>(dtcCode.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (detectedAt.present) {
      map['detected_at'] = Variable<int>(detectedAt.value);
    }
    if (isResolved.present) {
      map['is_resolved'] = Variable<bool>(isResolved.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<int>(resolvedAt.value);
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
    return (StringBuffer('VehicleFaultsCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('dtcCode: $dtcCode, ')
          ..write('severity: $severity, ')
          ..write('description: $description, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('isResolved: $isResolved, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PredictiveAlertsTable extends PredictiveAlerts
    with TableInfo<$PredictiveAlertsTable, PredictiveAlertEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PredictiveAlertsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _alertTypeMeta = const VerificationMeta(
    'alertType',
  );
  @override
  late final GeneratedColumn<String> alertType = GeneratedColumn<String>(
    'alert_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceScoreMeta = const VerificationMeta(
    'confidenceScore',
  );
  @override
  late final GeneratedColumn<double> confidenceScore = GeneratedColumn<double>(
    'confidence_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vehicleId,
    alertType,
    confidenceScore,
    message,
    status,
    createdAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'predictive_alerts';
  @override
  VerificationContext validateIntegrity(
    Insertable<PredictiveAlertEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('alert_type')) {
      context.handle(
        _alertTypeMeta,
        alertType.isAcceptableOrUnknown(data['alert_type']!, _alertTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_alertTypeMeta);
    }
    if (data.containsKey('confidence_score')) {
      context.handle(
        _confidenceScoreMeta,
        confidenceScore.isAcceptableOrUnknown(
          data['confidence_score']!,
          _confidenceScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_confidenceScoreMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PredictiveAlertEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PredictiveAlertEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      alertType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alert_type'],
      )!,
      confidenceScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence_score'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $PredictiveAlertsTable createAlias(String alias) {
    return $PredictiveAlertsTable(attachedDatabase, alias);
  }
}

class PredictiveAlertEntity extends DataClass
    implements Insertable<PredictiveAlertEntity> {
  final String id;
  final String vehicleId;
  final String alertType;
  final double confidenceScore;
  final String message;
  final String status;
  final int createdAt;
  final int syncedAt;
  const PredictiveAlertEntity({
    required this.id,
    required this.vehicleId,
    required this.alertType,
    required this.confidenceScore,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['alert_type'] = Variable<String>(alertType);
    map['confidence_score'] = Variable<double>(confidenceScore);
    map['message'] = Variable<String>(message);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<int>(createdAt);
    map['synced_at'] = Variable<int>(syncedAt);
    return map;
  }

  PredictiveAlertsCompanion toCompanion(bool nullToAbsent) {
    return PredictiveAlertsCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      alertType: Value(alertType),
      confidenceScore: Value(confidenceScore),
      message: Value(message),
      status: Value(status),
      createdAt: Value(createdAt),
      syncedAt: Value(syncedAt),
    );
  }

  factory PredictiveAlertEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PredictiveAlertEntity(
      id: serializer.fromJson<String>(json['id']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      alertType: serializer.fromJson<String>(json['alertType']),
      confidenceScore: serializer.fromJson<double>(json['confidenceScore']),
      message: serializer.fromJson<String>(json['message']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      syncedAt: serializer.fromJson<int>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'alertType': serializer.toJson<String>(alertType),
      'confidenceScore': serializer.toJson<double>(confidenceScore),
      'message': serializer.toJson<String>(message),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<int>(createdAt),
      'syncedAt': serializer.toJson<int>(syncedAt),
    };
  }

  PredictiveAlertEntity copyWith({
    String? id,
    String? vehicleId,
    String? alertType,
    double? confidenceScore,
    String? message,
    String? status,
    int? createdAt,
    int? syncedAt,
  }) => PredictiveAlertEntity(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    alertType: alertType ?? this.alertType,
    confidenceScore: confidenceScore ?? this.confidenceScore,
    message: message ?? this.message,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  PredictiveAlertEntity copyWithCompanion(PredictiveAlertsCompanion data) {
    return PredictiveAlertEntity(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      alertType: data.alertType.present ? data.alertType.value : this.alertType,
      confidenceScore: data.confidenceScore.present
          ? data.confidenceScore.value
          : this.confidenceScore,
      message: data.message.present ? data.message.value : this.message,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PredictiveAlertEntity(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('alertType: $alertType, ')
          ..write('confidenceScore: $confidenceScore, ')
          ..write('message: $message, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vehicleId,
    alertType,
    confidenceScore,
    message,
    status,
    createdAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PredictiveAlertEntity &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.alertType == this.alertType &&
          other.confidenceScore == this.confidenceScore &&
          other.message == this.message &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.syncedAt == this.syncedAt);
}

class PredictiveAlertsCompanion extends UpdateCompanion<PredictiveAlertEntity> {
  final Value<String> id;
  final Value<String> vehicleId;
  final Value<String> alertType;
  final Value<double> confidenceScore;
  final Value<String> message;
  final Value<String> status;
  final Value<int> createdAt;
  final Value<int> syncedAt;
  final Value<int> rowid;
  const PredictiveAlertsCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.alertType = const Value.absent(),
    this.confidenceScore = const Value.absent(),
    this.message = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PredictiveAlertsCompanion.insert({
    required String id,
    required String vehicleId,
    required String alertType,
    required double confidenceScore,
    required String message,
    required String status,
    required int createdAt,
    required int syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vehicleId = Value(vehicleId),
       alertType = Value(alertType),
       confidenceScore = Value(confidenceScore),
       message = Value(message),
       status = Value(status),
       createdAt = Value(createdAt),
       syncedAt = Value(syncedAt);
  static Insertable<PredictiveAlertEntity> custom({
    Expression<String>? id,
    Expression<String>? vehicleId,
    Expression<String>? alertType,
    Expression<double>? confidenceScore,
    Expression<String>? message,
    Expression<String>? status,
    Expression<int>? createdAt,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (alertType != null) 'alert_type': alertType,
      if (confidenceScore != null) 'confidence_score': confidenceScore,
      if (message != null) 'message': message,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PredictiveAlertsCompanion copyWith({
    Value<String>? id,
    Value<String>? vehicleId,
    Value<String>? alertType,
    Value<double>? confidenceScore,
    Value<String>? message,
    Value<String>? status,
    Value<int>? createdAt,
    Value<int>? syncedAt,
    Value<int>? rowid,
  }) {
    return PredictiveAlertsCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      alertType: alertType ?? this.alertType,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (alertType.present) {
      map['alert_type'] = Variable<String>(alertType.value);
    }
    if (confidenceScore.present) {
      map['confidence_score'] = Variable<double>(confidenceScore.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
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
    return (StringBuffer('PredictiveAlertsCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('alertType: $alertType, ')
          ..write('confidenceScore: $confidenceScore, ')
          ..write('message: $message, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppLocksTable extends AppLocks
    with TableInfo<$AppLocksTable, AppLockEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppLocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<int> expiresAt = GeneratedColumn<int>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [name, owner, expiresAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_locks';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppLockEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  AppLockEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppLockEntity(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expires_at'],
      )!,
    );
  }

  @override
  $AppLocksTable createAlias(String alias) {
    return $AppLocksTable(attachedDatabase, alias);
  }
}

class AppLockEntity extends DataClass implements Insertable<AppLockEntity> {
  final String name;
  final String owner;
  final int expiresAt;
  const AppLockEntity({
    required this.name,
    required this.owner,
    required this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['owner'] = Variable<String>(owner);
    map['expires_at'] = Variable<int>(expiresAt);
    return map;
  }

  AppLocksCompanion toCompanion(bool nullToAbsent) {
    return AppLocksCompanion(
      name: Value(name),
      owner: Value(owner),
      expiresAt: Value(expiresAt),
    );
  }

  factory AppLockEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppLockEntity(
      name: serializer.fromJson<String>(json['name']),
      owner: serializer.fromJson<String>(json['owner']),
      expiresAt: serializer.fromJson<int>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'owner': serializer.toJson<String>(owner),
      'expiresAt': serializer.toJson<int>(expiresAt),
    };
  }

  AppLockEntity copyWith({String? name, String? owner, int? expiresAt}) =>
      AppLockEntity(
        name: name ?? this.name,
        owner: owner ?? this.owner,
        expiresAt: expiresAt ?? this.expiresAt,
      );
  AppLockEntity copyWithCompanion(AppLocksCompanion data) {
    return AppLockEntity(
      name: data.name.present ? data.name.value : this.name,
      owner: data.owner.present ? data.owner.value : this.owner,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppLockEntity(')
          ..write('name: $name, ')
          ..write('owner: $owner, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, owner, expiresAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppLockEntity &&
          other.name == this.name &&
          other.owner == this.owner &&
          other.expiresAt == this.expiresAt);
}

class AppLocksCompanion extends UpdateCompanion<AppLockEntity> {
  final Value<String> name;
  final Value<String> owner;
  final Value<int> expiresAt;
  final Value<int> rowid;
  const AppLocksCompanion({
    this.name = const Value.absent(),
    this.owner = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppLocksCompanion.insert({
    required String name,
    required String owner,
    required int expiresAt,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       owner = Value(owner),
       expiresAt = Value(expiresAt);
  static Insertable<AppLockEntity> custom({
    Expression<String>? name,
    Expression<String>? owner,
    Expression<int>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (owner != null) 'owner': owner,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppLocksCompanion copyWith({
    Value<String>? name,
    Value<String>? owner,
    Value<int>? expiresAt,
    Value<int>? rowid,
  }) {
    return AppLocksCompanion(
      name: name ?? this.name,
      owner: owner ?? this.owner,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<int>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppLocksCompanion(')
          ..write('name: $name, ')
          ..write('owner: $owner, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PendingOperationsTable pendingOperations =
      $PendingOperationsTable(this);
  late final $PendingUploadsTable pendingUploads = $PendingUploadsTable(this);
  late final $CacheMetadataTable cacheMetadata = $CacheMetadataTable(this);
  late final $AttendancesTable attendances = $AttendancesTable(this);
  late final $ShiftsTable shifts = $ShiftsTable(this);
  late final $BranchesTable branches = $BranchesTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $WorkOrdersTable workOrders = $WorkOrdersTable(this);
  late final $BaysTable bays = $BaysTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $VehiclesTable vehicles = $VehiclesTable(this);
  late final $AppointmentsTable appointments = $AppointmentsTable(this);
  late final $PartsTable parts = $PartsTable(this);
  late final $BatchesTable batches = $BatchesTable(this);
  late final $VouchersTable vouchers = $VouchersTable(this);
  late final $TelemetryReadingsTable telemetryReadings =
      $TelemetryReadingsTable(this);
  late final $VehicleFaultsTable vehicleFaults = $VehicleFaultsTable(this);
  late final $PredictiveAlertsTable predictiveAlerts = $PredictiveAlertsTable(
    this,
  );
  late final $AppLocksTable appLocks = $AppLocksTable(this);
  late final Index idxPendingOperationsDedupeKey = Index(
    'idx_pending_operations_dedupe_key',
    'CREATE UNIQUE INDEX idx_pending_operations_dedupe_key ON pending_operations (dedupe_key)',
  );
  late final Index idxPendingOperationsStatusNextAttemptAt = Index(
    'idx_pending_operations_status_next_attempt_at',
    'CREATE INDEX idx_pending_operations_status_next_attempt_at ON pending_operations (status, next_attempt_at)',
  );
  late final Index idxPendingOperationsUserId = Index(
    'idx_pending_operations_user_id',
    'CREATE INDEX idx_pending_operations_user_id ON pending_operations (user_id)',
  );
  late final Index idxAttendancesMembershipIdClockIn = Index(
    'idx_attendances_membership_id_clock_in',
    'CREATE INDEX idx_attendances_membership_id_clock_in ON attendances (membership_id, clock_in)',
  );
  late final Index idxTasksWorkOrderId = Index(
    'idx_tasks_work_order_id',
    'CREATE INDEX idx_tasks_work_order_id ON tasks (work_order_id)',
  );
  late final Index idxWorkOrdersBranchIdStatus = Index(
    'idx_work_orders_branch_id_status',
    'CREATE INDEX idx_work_orders_branch_id_status ON work_orders (branch_id, status)',
  );
  late final Index idxBaysBranchId = Index(
    'idx_bays_branch_id',
    'CREATE INDEX idx_bays_branch_id ON bays (branch_id)',
  );
  late final Index idxCustomersTaxId = Index(
    'idx_customers_tax_id',
    'CREATE INDEX idx_customers_tax_id ON customers (tax_id)',
  );
  late final Index idxVehiclesPlate = Index(
    'idx_vehicles_plate',
    'CREATE UNIQUE INDEX idx_vehicles_plate ON vehicles (plate)',
  );
  late final Index idxAppointmentsBranchIdScheduledAt = Index(
    'idx_appointments_branch_id_scheduled_at',
    'CREATE INDEX idx_appointments_branch_id_scheduled_at ON appointments (branch_id, scheduled_at)',
  );
  late final Index idxPartsSku = Index(
    'idx_parts_sku',
    'CREATE INDEX idx_parts_sku ON parts (sku)',
  );
  late final Index idxPartsCategory = Index(
    'idx_parts_category',
    'CREATE INDEX idx_parts_category ON parts (category)',
  );
  late final Index idxBatchesItemId = Index(
    'idx_batches_item_id',
    'CREATE INDEX idx_batches_item_id ON batches (item_id)',
  );
  late final Index idxVouchersWorkOrderId = Index(
    'idx_vouchers_work_order_id',
    'CREATE INDEX idx_vouchers_work_order_id ON vouchers (work_order_id)',
  );
  late final Index idxTelemetryReadingsVehicleIdTimestamp = Index(
    'idx_telemetry_readings_vehicle_id_timestamp',
    'CREATE UNIQUE INDEX idx_telemetry_readings_vehicle_id_timestamp ON telemetry_readings (vehicle_id, timestamp)',
  );
  late final Index idxVehicleFaultsVehicleIdDtcCode = Index(
    'idx_vehicle_faults_vehicle_id_dtc_code',
    'CREATE INDEX idx_vehicle_faults_vehicle_id_dtc_code ON vehicle_faults (vehicle_id, dtc_code)',
  );
  late final Index idxPredictiveAlertsVehicleIdCreatedAt = Index(
    'idx_predictive_alerts_vehicle_id_created_at',
    'CREATE INDEX idx_predictive_alerts_vehicle_id_created_at ON predictive_alerts (vehicle_id, created_at)',
  );
  late final PendingOperationDao pendingOperationDao = PendingOperationDao(
    this as AppDatabase,
  );
  late final PendingUploadDao pendingUploadDao = PendingUploadDao(
    this as AppDatabase,
  );
  late final CacheMetadataDao cacheMetadataDao = CacheMetadataDao(
    this as AppDatabase,
  );
  late final CacheMaintenanceDao cacheMaintenanceDao = CacheMaintenanceDao(
    this as AppDatabase,
  );
  late final AttendanceDao attendanceDao = AttendanceDao(this as AppDatabase);
  late final ShiftDao shiftDao = ShiftDao(this as AppDatabase);
  late final BranchDao branchDao = BranchDao(this as AppDatabase);
  late final TaskDao taskDao = TaskDao(this as AppDatabase);
  late final VehicleDao vehicleDao = VehicleDao(this as AppDatabase);
  late final BayDao bayDao = BayDao(this as AppDatabase);
  late final CustomerDao customerDao = CustomerDao(this as AppDatabase);
  late final AppointmentDao appointmentDao = AppointmentDao(
    this as AppDatabase,
  );
  late final WorkOrderDao workOrderDao = WorkOrderDao(this as AppDatabase);
  late final PartDao partDao = PartDao(this as AppDatabase);
  late final BatchDao batchDao = BatchDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    pendingOperations,
    pendingUploads,
    cacheMetadata,
    attendances,
    shifts,
    branches,
    tasks,
    workOrders,
    bays,
    customers,
    vehicles,
    appointments,
    parts,
    batches,
    vouchers,
    telemetryReadings,
    vehicleFaults,
    predictiveAlerts,
    appLocks,
    idxPendingOperationsDedupeKey,
    idxPendingOperationsStatusNextAttemptAt,
    idxPendingOperationsUserId,
    idxAttendancesMembershipIdClockIn,
    idxTasksWorkOrderId,
    idxWorkOrdersBranchIdStatus,
    idxBaysBranchId,
    idxCustomersTaxId,
    idxVehiclesPlate,
    idxAppointmentsBranchIdScheduledAt,
    idxPartsSku,
    idxPartsCategory,
    idxBatchesItemId,
    idxVouchersWorkOrderId,
    idxTelemetryReadingsVehicleIdTimestamp,
    idxVehicleFaultsVehicleIdDtcCode,
    idxPredictiveAlertsVehicleIdCreatedAt,
  ];
}

typedef $$PendingOperationsTableCreateCompanionBuilder =
    PendingOperationsCompanion Function({
      required String id,
      required String type,
      required String payload,
      required String dedupeKey,
      required String userId,
      required String tenantId,
      Value<String> status,
      Value<int> attempts,
      required int nextAttemptAt,
      Value<int?> lastHttpStatus,
      Value<String?> lastErrorCode,
      Value<String?> lastErrorMessage,
      required int createdAt,
      Value<String?> dependsOn,
      Value<int> rowid,
    });
typedef $$PendingOperationsTableUpdateCompanionBuilder =
    PendingOperationsCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<String> payload,
      Value<String> dedupeKey,
      Value<String> userId,
      Value<String> tenantId,
      Value<String> status,
      Value<int> attempts,
      Value<int> nextAttemptAt,
      Value<int?> lastHttpStatus,
      Value<String?> lastErrorCode,
      Value<String?> lastErrorMessage,
      Value<int> createdAt,
      Value<String?> dependsOn,
      Value<int> rowid,
    });

class $$PendingOperationsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingOperationsTable> {
  $$PendingOperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dedupeKey => $composableBuilder(
    column: $table.dedupeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastHttpStatus => $composableBuilder(
    column: $table.lastHttpStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorMessage => $composableBuilder(
    column: $table.lastErrorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dependsOn => $composableBuilder(
    column: $table.dependsOn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingOperationsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingOperationsTable> {
  $$PendingOperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dedupeKey => $composableBuilder(
    column: $table.dedupeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastHttpStatus => $composableBuilder(
    column: $table.lastHttpStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorMessage => $composableBuilder(
    column: $table.lastErrorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dependsOn => $composableBuilder(
    column: $table.dependsOn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingOperationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingOperationsTable> {
  $$PendingOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get dedupeKey =>
      $composableBuilder(column: $table.dedupeKey, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastHttpStatus => $composableBuilder(
    column: $table.lastHttpStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastErrorMessage => $composableBuilder(
    column: $table.lastErrorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get dependsOn =>
      $composableBuilder(column: $table.dependsOn, builder: (column) => column);
}

class $$PendingOperationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingOperationsTable,
          PendingOperationEntity,
          $$PendingOperationsTableFilterComposer,
          $$PendingOperationsTableOrderingComposer,
          $$PendingOperationsTableAnnotationComposer,
          $$PendingOperationsTableCreateCompanionBuilder,
          $$PendingOperationsTableUpdateCompanionBuilder,
          (
            PendingOperationEntity,
            BaseReferences<
              _$AppDatabase,
              $PendingOperationsTable,
              PendingOperationEntity
            >,
          ),
          PendingOperationEntity,
          PrefetchHooks Function()
        > {
  $$PendingOperationsTableTableManager(
    _$AppDatabase db,
    $PendingOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingOperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingOperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingOperationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> dedupeKey = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> nextAttemptAt = const Value.absent(),
                Value<int?> lastHttpStatus = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<String?> lastErrorMessage = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String?> dependsOn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingOperationsCompanion(
                id: id,
                type: type,
                payload: payload,
                dedupeKey: dedupeKey,
                userId: userId,
                tenantId: tenantId,
                status: status,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                lastHttpStatus: lastHttpStatus,
                lastErrorCode: lastErrorCode,
                lastErrorMessage: lastErrorMessage,
                createdAt: createdAt,
                dependsOn: dependsOn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required String payload,
                required String dedupeKey,
                required String userId,
                required String tenantId,
                Value<String> status = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                required int nextAttemptAt,
                Value<int?> lastHttpStatus = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<String?> lastErrorMessage = const Value.absent(),
                required int createdAt,
                Value<String?> dependsOn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingOperationsCompanion.insert(
                id: id,
                type: type,
                payload: payload,
                dedupeKey: dedupeKey,
                userId: userId,
                tenantId: tenantId,
                status: status,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                lastHttpStatus: lastHttpStatus,
                lastErrorCode: lastErrorCode,
                lastErrorMessage: lastErrorMessage,
                createdAt: createdAt,
                dependsOn: dependsOn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PendingOperationsTable, PendingOperationEntity>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $PendingOperationsTable,
                    PendingOperationEntity
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingOperationsTable,
      PendingOperationEntity,
      $$PendingOperationsTableFilterComposer,
      $$PendingOperationsTableOrderingComposer,
      $$PendingOperationsTableAnnotationComposer,
      $$PendingOperationsTableCreateCompanionBuilder,
      $$PendingOperationsTableUpdateCompanionBuilder,
      (
        PendingOperationEntity,
        BaseReferences<
          _$AppDatabase,
          $PendingOperationsTable,
          PendingOperationEntity
        >,
      ),
      PendingOperationEntity,
      PrefetchHooks Function()
    >;
typedef $$PendingUploadsTableCreateCompanionBuilder =
    PendingUploadsCompanion Function({
      required String id,
      required String localFilePath,
      required String storagePath,
      required String target,
      Value<String?> publicUrl,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$PendingUploadsTableUpdateCompanionBuilder =
    PendingUploadsCompanion Function({
      Value<String> id,
      Value<String> localFilePath,
      Value<String> storagePath,
      Value<String> target,
      Value<String?> publicUrl,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$PendingUploadsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingUploadsTable> {
  $$PendingUploadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicUrl => $composableBuilder(
    column: $table.publicUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingUploadsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingUploadsTable> {
  $$PendingUploadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicUrl => $composableBuilder(
    column: $table.publicUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingUploadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingUploadsTable> {
  $$PendingUploadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<String> get publicUrl =>
      $composableBuilder(column: $table.publicUrl, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PendingUploadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingUploadsTable,
          PendingUploadEntity,
          $$PendingUploadsTableFilterComposer,
          $$PendingUploadsTableOrderingComposer,
          $$PendingUploadsTableAnnotationComposer,
          $$PendingUploadsTableCreateCompanionBuilder,
          $$PendingUploadsTableUpdateCompanionBuilder,
          (
            PendingUploadEntity,
            BaseReferences<
              _$AppDatabase,
              $PendingUploadsTable,
              PendingUploadEntity
            >,
          ),
          PendingUploadEntity,
          PrefetchHooks Function()
        > {
  $$PendingUploadsTableTableManager(
    _$AppDatabase db,
    $PendingUploadsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingUploadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingUploadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingUploadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> localFilePath = const Value.absent(),
                Value<String> storagePath = const Value.absent(),
                Value<String> target = const Value.absent(),
                Value<String?> publicUrl = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingUploadsCompanion(
                id: id,
                localFilePath: localFilePath,
                storagePath: storagePath,
                target: target,
                publicUrl: publicUrl,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String localFilePath,
                required String storagePath,
                required String target,
                Value<String?> publicUrl = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PendingUploadsCompanion.insert(
                id: id,
                localFilePath: localFilePath,
                storagePath: storagePath,
                target: target,
                publicUrl: publicUrl,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PendingUploadsTable, PendingUploadEntity>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PendingUploadsTable,
                    PendingUploadEntity
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingUploadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingUploadsTable,
      PendingUploadEntity,
      $$PendingUploadsTableFilterComposer,
      $$PendingUploadsTableOrderingComposer,
      $$PendingUploadsTableAnnotationComposer,
      $$PendingUploadsTableCreateCompanionBuilder,
      $$PendingUploadsTableUpdateCompanionBuilder,
      (
        PendingUploadEntity,
        BaseReferences<
          _$AppDatabase,
          $PendingUploadsTable,
          PendingUploadEntity
        >,
      ),
      PendingUploadEntity,
      PrefetchHooks Function()
    >;
typedef $$CacheMetadataTableCreateCompanionBuilder =
    CacheMetadataCompanion Function({
      required String scope,
      required int lastSyncedAt,
      required int recordCount,
      Value<int> rowid,
    });
typedef $$CacheMetadataTableUpdateCompanionBuilder =
    CacheMetadataCompanion Function({
      Value<String> scope,
      Value<int> lastSyncedAt,
      Value<int> recordCount,
      Value<int> rowid,
    });

class $$CacheMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $CacheMetadataTable> {
  $$CacheMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordCount => $composableBuilder(
    column: $table.recordCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CacheMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $CacheMetadataTable> {
  $$CacheMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordCount => $composableBuilder(
    column: $table.recordCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CacheMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $CacheMetadataTable> {
  $$CacheMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recordCount => $composableBuilder(
    column: $table.recordCount,
    builder: (column) => column,
  );
}

class $$CacheMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CacheMetadataTable,
          CacheMetadataEntity,
          $$CacheMetadataTableFilterComposer,
          $$CacheMetadataTableOrderingComposer,
          $$CacheMetadataTableAnnotationComposer,
          $$CacheMetadataTableCreateCompanionBuilder,
          $$CacheMetadataTableUpdateCompanionBuilder,
          (
            CacheMetadataEntity,
            BaseReferences<
              _$AppDatabase,
              $CacheMetadataTable,
              CacheMetadataEntity
            >,
          ),
          CacheMetadataEntity,
          PrefetchHooks Function()
        > {
  $$CacheMetadataTableTableManager(_$AppDatabase db, $CacheMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CacheMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> scope = const Value.absent(),
                Value<int> lastSyncedAt = const Value.absent(),
                Value<int> recordCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheMetadataCompanion(
                scope: scope,
                lastSyncedAt: lastSyncedAt,
                recordCount: recordCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String scope,
                required int lastSyncedAt,
                required int recordCount,
                Value<int> rowid = const Value.absent(),
              }) => CacheMetadataCompanion.insert(
                scope: scope,
                lastSyncedAt: lastSyncedAt,
                recordCount: recordCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CacheMetadataTable, CacheMetadataEntity>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CacheMetadataTable,
                    CacheMetadataEntity
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CacheMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CacheMetadataTable,
      CacheMetadataEntity,
      $$CacheMetadataTableFilterComposer,
      $$CacheMetadataTableOrderingComposer,
      $$CacheMetadataTableAnnotationComposer,
      $$CacheMetadataTableCreateCompanionBuilder,
      $$CacheMetadataTableUpdateCompanionBuilder,
      (
        CacheMetadataEntity,
        BaseReferences<_$AppDatabase, $CacheMetadataTable, CacheMetadataEntity>,
      ),
      CacheMetadataEntity,
      PrefetchHooks Function()
    >;
typedef $$AttendancesTableCreateCompanionBuilder =
    AttendancesCompanion Function({
      required String id,
      required String branchId,
      required String membershipId,
      required String shiftId,
      required int clockIn,
      Value<int?> clockOut,
      required String status,
      required double latitude,
      required double longitude,
      required double distanceToBranchMeters,
      Value<int?> workedMinutes,
      Value<int?> regularMinutes,
      Value<int?> overtimeMinutes,
      Value<String?> justificationReason,
      Value<String?> justificationStatus,
      required int syncedAt,
      Value<int> rowid,
    });
typedef $$AttendancesTableUpdateCompanionBuilder =
    AttendancesCompanion Function({
      Value<String> id,
      Value<String> branchId,
      Value<String> membershipId,
      Value<String> shiftId,
      Value<int> clockIn,
      Value<int?> clockOut,
      Value<String> status,
      Value<double> latitude,
      Value<double> longitude,
      Value<double> distanceToBranchMeters,
      Value<int?> workedMinutes,
      Value<int?> regularMinutes,
      Value<int?> overtimeMinutes,
      Value<String?> justificationReason,
      Value<String?> justificationStatus,
      Value<int> syncedAt,
      Value<int> rowid,
    });

class $$AttendancesTableFilterComposer
    extends Composer<_$AppDatabase, $AttendancesTable> {
  $$AttendancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get membershipId => $composableBuilder(
    column: $table.membershipId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clockIn => $composableBuilder(
    column: $table.clockIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clockOut => $composableBuilder(
    column: $table.clockOut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceToBranchMeters => $composableBuilder(
    column: $table.distanceToBranchMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workedMinutes => $composableBuilder(
    column: $table.workedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get regularMinutes => $composableBuilder(
    column: $table.regularMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get overtimeMinutes => $composableBuilder(
    column: $table.overtimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get justificationReason => $composableBuilder(
    column: $table.justificationReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get justificationStatus => $composableBuilder(
    column: $table.justificationStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttendancesTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendancesTable> {
  $$AttendancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get membershipId => $composableBuilder(
    column: $table.membershipId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clockIn => $composableBuilder(
    column: $table.clockIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clockOut => $composableBuilder(
    column: $table.clockOut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceToBranchMeters => $composableBuilder(
    column: $table.distanceToBranchMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workedMinutes => $composableBuilder(
    column: $table.workedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get regularMinutes => $composableBuilder(
    column: $table.regularMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get overtimeMinutes => $composableBuilder(
    column: $table.overtimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get justificationReason => $composableBuilder(
    column: $table.justificationReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get justificationStatus => $composableBuilder(
    column: $table.justificationStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttendancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendancesTable> {
  $$AttendancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get membershipId => $composableBuilder(
    column: $table.membershipId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shiftId =>
      $composableBuilder(column: $table.shiftId, builder: (column) => column);

  GeneratedColumn<int> get clockIn =>
      $composableBuilder(column: $table.clockIn, builder: (column) => column);

  GeneratedColumn<int> get clockOut =>
      $composableBuilder(column: $table.clockOut, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get distanceToBranchMeters => $composableBuilder(
    column: $table.distanceToBranchMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get workedMinutes => $composableBuilder(
    column: $table.workedMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get regularMinutes => $composableBuilder(
    column: $table.regularMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get overtimeMinutes => $composableBuilder(
    column: $table.overtimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get justificationReason => $composableBuilder(
    column: $table.justificationReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get justificationStatus => $composableBuilder(
    column: $table.justificationStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$AttendancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendancesTable,
          AttendanceEntity,
          $$AttendancesTableFilterComposer,
          $$AttendancesTableOrderingComposer,
          $$AttendancesTableAnnotationComposer,
          $$AttendancesTableCreateCompanionBuilder,
          $$AttendancesTableUpdateCompanionBuilder,
          (
            AttendanceEntity,
            BaseReferences<_$AppDatabase, $AttendancesTable, AttendanceEntity>,
          ),
          AttendanceEntity,
          PrefetchHooks Function()
        > {
  $$AttendancesTableTableManager(_$AppDatabase db, $AttendancesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> branchId = const Value.absent(),
                Value<String> membershipId = const Value.absent(),
                Value<String> shiftId = const Value.absent(),
                Value<int> clockIn = const Value.absent(),
                Value<int?> clockOut = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double> distanceToBranchMeters = const Value.absent(),
                Value<int?> workedMinutes = const Value.absent(),
                Value<int?> regularMinutes = const Value.absent(),
                Value<int?> overtimeMinutes = const Value.absent(),
                Value<String?> justificationReason = const Value.absent(),
                Value<String?> justificationStatus = const Value.absent(),
                Value<int> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendancesCompanion(
                id: id,
                branchId: branchId,
                membershipId: membershipId,
                shiftId: shiftId,
                clockIn: clockIn,
                clockOut: clockOut,
                status: status,
                latitude: latitude,
                longitude: longitude,
                distanceToBranchMeters: distanceToBranchMeters,
                workedMinutes: workedMinutes,
                regularMinutes: regularMinutes,
                overtimeMinutes: overtimeMinutes,
                justificationReason: justificationReason,
                justificationStatus: justificationStatus,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String branchId,
                required String membershipId,
                required String shiftId,
                required int clockIn,
                Value<int?> clockOut = const Value.absent(),
                required String status,
                required double latitude,
                required double longitude,
                required double distanceToBranchMeters,
                Value<int?> workedMinutes = const Value.absent(),
                Value<int?> regularMinutes = const Value.absent(),
                Value<int?> overtimeMinutes = const Value.absent(),
                Value<String?> justificationReason = const Value.absent(),
                Value<String?> justificationStatus = const Value.absent(),
                required int syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => AttendancesCompanion.insert(
                id: id,
                branchId: branchId,
                membershipId: membershipId,
                shiftId: shiftId,
                clockIn: clockIn,
                clockOut: clockOut,
                status: status,
                latitude: latitude,
                longitude: longitude,
                distanceToBranchMeters: distanceToBranchMeters,
                workedMinutes: workedMinutes,
                regularMinutes: regularMinutes,
                overtimeMinutes: overtimeMinutes,
                justificationReason: justificationReason,
                justificationStatus: justificationStatus,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttendancesTable, AttendanceEntity>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AttendancesTable,
                    AttendanceEntity
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttendancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendancesTable,
      AttendanceEntity,
      $$AttendancesTableFilterComposer,
      $$AttendancesTableOrderingComposer,
      $$AttendancesTableAnnotationComposer,
      $$AttendancesTableCreateCompanionBuilder,
      $$AttendancesTableUpdateCompanionBuilder,
      (
        AttendanceEntity,
        BaseReferences<_$AppDatabase, $AttendancesTable, AttendanceEntity>,
      ),
      AttendanceEntity,
      PrefetchHooks Function()
    >;
typedef $$ShiftsTableCreateCompanionBuilder = ShiftsCompanion Function({
  required String id,
  required String name,
  required String startTime,
  required String endTime,
  required int gracePeriodMinutes,
  required String workDays,
  required String restDays,
  required bool isActive,
  required int syncedAt,
  Value<int> rowid,
});
typedef $$ShiftsTableUpdateCompanionBuilder = ShiftsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> startTime,
  Value<String> endTime,
  Value<int> gracePeriodMinutes,
  Value<String> workDays,
  Value<String> restDays,
  Value<bool> isActive,
  Value<int> syncedAt,
  Value<int> rowid,
});

class $$ShiftsTableFilterComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gracePeriodMinutes => $composableBuilder(
    column: $table.gracePeriodMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workDays => $composableBuilder(
    column: $table.workDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get restDays => $composableBuilder(
    column: $table.restDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShiftsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gracePeriodMinutes => $composableBuilder(
    column: $table.gracePeriodMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workDays => $composableBuilder(
    column: $table.workDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get restDays => $composableBuilder(
    column: $table.restDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShiftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get gracePeriodMinutes => $composableBuilder(
    column: $table.gracePeriodMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get workDays =>
      $composableBuilder(column: $table.workDays, builder: (column) => column);

  GeneratedColumn<String> get restDays =>
      $composableBuilder(column: $table.restDays, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$ShiftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShiftsTable,
          ShiftEntity,
          $$ShiftsTableFilterComposer,
          $$ShiftsTableOrderingComposer,
          $$ShiftsTableAnnotationComposer,
          $$ShiftsTableCreateCompanionBuilder,
          $$ShiftsTableUpdateCompanionBuilder,
          (
            ShiftEntity,
            BaseReferences<_$AppDatabase, $ShiftsTable, ShiftEntity>,
          ),
          ShiftEntity,
          PrefetchHooks Function()
        > {
  $$ShiftsTableTableManager(_$AppDatabase db, $ShiftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShiftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShiftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShiftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> startTime = const Value.absent(),
                Value<String> endTime = const Value.absent(),
                Value<int> gracePeriodMinutes = const Value.absent(),
                Value<String> workDays = const Value.absent(),
                Value<String> restDays = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShiftsCompanion(
                id: id,
                name: name,
                startTime: startTime,
                endTime: endTime,
                gracePeriodMinutes: gracePeriodMinutes,
                workDays: workDays,
                restDays: restDays,
                isActive: isActive,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String startTime,
                required String endTime,
                required int gracePeriodMinutes,
                required String workDays,
                required String restDays,
                required bool isActive,
                required int syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => ShiftsCompanion.insert(
                id: id,
                name: name,
                startTime: startTime,
                endTime: endTime,
                gracePeriodMinutes: gracePeriodMinutes,
                workDays: workDays,
                restDays: restDays,
                isActive: isActive,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ShiftsTable, ShiftEntity>(table),
                  BaseReferences<_$AppDatabase, $ShiftsTable, ShiftEntity>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShiftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShiftsTable,
      ShiftEntity,
      $$ShiftsTableFilterComposer,
      $$ShiftsTableOrderingComposer,
      $$ShiftsTableAnnotationComposer,
      $$ShiftsTableCreateCompanionBuilder,
      $$ShiftsTableUpdateCompanionBuilder,
      (ShiftEntity, BaseReferences<_$AppDatabase, $ShiftsTable, ShiftEntity>),
      ShiftEntity,
      PrefetchHooks Function()
    >;
typedef $$BranchesTableCreateCompanionBuilder = BranchesCompanion Function({
  required String id,
  required String name,
  required double latitude,
  required double longitude,
  required double geofenceRadiusMeters,
  required bool isActive,
  required int syncedAt,
  Value<int> rowid,
});
typedef $$BranchesTableUpdateCompanionBuilder = BranchesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<double> latitude,
  Value<double> longitude,
  Value<double> geofenceRadiusMeters,
  Value<bool> isActive,
  Value<int> syncedAt,
  Value<int> rowid,
});

class $$BranchesTableFilterComposer
    extends Composer<_$AppDatabase, $BranchesTable> {
  $$BranchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get geofenceRadiusMeters => $composableBuilder(
    column: $table.geofenceRadiusMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BranchesTableOrderingComposer
    extends Composer<_$AppDatabase, $BranchesTable> {
  $$BranchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get geofenceRadiusMeters => $composableBuilder(
    column: $table.geofenceRadiusMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BranchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BranchesTable> {
  $$BranchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get geofenceRadiusMeters => $composableBuilder(
    column: $table.geofenceRadiusMeters,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$BranchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BranchesTable,
          BranchEntity,
          $$BranchesTableFilterComposer,
          $$BranchesTableOrderingComposer,
          $$BranchesTableAnnotationComposer,
          $$BranchesTableCreateCompanionBuilder,
          $$BranchesTableUpdateCompanionBuilder,
          (
            BranchEntity,
            BaseReferences<_$AppDatabase, $BranchesTable, BranchEntity>,
          ),
          BranchEntity,
          PrefetchHooks Function()
        > {
  $$BranchesTableTableManager(_$AppDatabase db, $BranchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BranchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BranchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BranchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double> geofenceRadiusMeters = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BranchesCompanion(
                id: id,
                name: name,
                latitude: latitude,
                longitude: longitude,
                geofenceRadiusMeters: geofenceRadiusMeters,
                isActive: isActive,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required double latitude,
                required double longitude,
                required double geofenceRadiusMeters,
                required bool isActive,
                required int syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => BranchesCompanion.insert(
                id: id,
                name: name,
                latitude: latitude,
                longitude: longitude,
                geofenceRadiusMeters: geofenceRadiusMeters,
                isActive: isActive,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BranchesTable, BranchEntity>(table),
                  BaseReferences<_$AppDatabase, $BranchesTable, BranchEntity>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BranchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BranchesTable,
      BranchEntity,
      $$BranchesTableFilterComposer,
      $$BranchesTableOrderingComposer,
      $$BranchesTableAnnotationComposer,
      $$BranchesTableCreateCompanionBuilder,
      $$BranchesTableUpdateCompanionBuilder,
      (
        BranchEntity,
        BaseReferences<_$AppDatabase, $BranchesTable, BranchEntity>,
      ),
      BranchEntity,
      PrefetchHooks Function()
    >;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required String workOrderId,
  Value<int?> workOrderNumber,
  Value<String?> workOrderStatus,
  required String vehicleId,
  Value<String?> branchId,
  Value<String?> bayId,
  Value<String?> serviceName,
  Value<String?> mechanicId,
  required String status,
  required String description,
  Value<String?> estimatedHours,
  Value<String?> holdReason,
  Value<String?> missingItemDescription,
  Value<String?> pendingSuspensionReason,
  Value<int?> startedAt,
  required int totalPausedSeconds,
  required int syncedAt,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> workOrderId,
  Value<int?> workOrderNumber,
  Value<String?> workOrderStatus,
  Value<String> vehicleId,
  Value<String?> branchId,
  Value<String?> bayId,
  Value<String?> serviceName,
  Value<String?> mechanicId,
  Value<String> status,
  Value<String> description,
  Value<String?> estimatedHours,
  Value<String?> holdReason,
  Value<String?> missingItemDescription,
  Value<String?> pendingSuspensionReason,
  Value<int?> startedAt,
  Value<int> totalPausedSeconds,
  Value<int> syncedAt,
  Value<int> rowid,
});

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workOrderId => $composableBuilder(
    column: $table.workOrderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workOrderNumber => $composableBuilder(
    column: $table.workOrderNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workOrderStatus => $composableBuilder(
    column: $table.workOrderStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bayId => $composableBuilder(
    column: $table.bayId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceName => $composableBuilder(
    column: $table.serviceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mechanicId => $composableBuilder(
    column: $table.mechanicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estimatedHours => $composableBuilder(
    column: $table.estimatedHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get holdReason => $composableBuilder(
    column: $table.holdReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get missingItemDescription => $composableBuilder(
    column: $table.missingItemDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pendingSuspensionReason => $composableBuilder(
    column: $table.pendingSuspensionReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPausedSeconds => $composableBuilder(
    column: $table.totalPausedSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workOrderId => $composableBuilder(
    column: $table.workOrderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workOrderNumber => $composableBuilder(
    column: $table.workOrderNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workOrderStatus => $composableBuilder(
    column: $table.workOrderStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bayId => $composableBuilder(
    column: $table.bayId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceName => $composableBuilder(
    column: $table.serviceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mechanicId => $composableBuilder(
    column: $table.mechanicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estimatedHours => $composableBuilder(
    column: $table.estimatedHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get holdReason => $composableBuilder(
    column: $table.holdReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get missingItemDescription => $composableBuilder(
    column: $table.missingItemDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pendingSuspensionReason => $composableBuilder(
    column: $table.pendingSuspensionReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPausedSeconds => $composableBuilder(
    column: $table.totalPausedSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workOrderId => $composableBuilder(
    column: $table.workOrderId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get workOrderNumber => $composableBuilder(
    column: $table.workOrderNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get workOrderStatus => $composableBuilder(
    column: $table.workOrderStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get bayId =>
      $composableBuilder(column: $table.bayId, builder: (column) => column);

  GeneratedColumn<String> get serviceName => $composableBuilder(
    column: $table.serviceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mechanicId => $composableBuilder(
    column: $table.mechanicId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estimatedHours => $composableBuilder(
    column: $table.estimatedHours,
    builder: (column) => column,
  );

  GeneratedColumn<String> get holdReason => $composableBuilder(
    column: $table.holdReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get missingItemDescription => $composableBuilder(
    column: $table.missingItemDescription,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pendingSuspensionReason => $composableBuilder(
    column: $table.pendingSuspensionReason,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get totalPausedSeconds => $composableBuilder(
    column: $table.totalPausedSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          TaskEntity,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (TaskEntity, BaseReferences<_$AppDatabase, $TasksTable, TaskEntity>),
          TaskEntity,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workOrderId = const Value.absent(),
                Value<int?> workOrderNumber = const Value.absent(),
                Value<String?> workOrderStatus = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<String?> branchId = const Value.absent(),
                Value<String?> bayId = const Value.absent(),
                Value<String?> serviceName = const Value.absent(),
                Value<String?> mechanicId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> estimatedHours = const Value.absent(),
                Value<String?> holdReason = const Value.absent(),
                Value<String?> missingItemDescription = const Value.absent(),
                Value<String?> pendingSuspensionReason = const Value.absent(),
                Value<int?> startedAt = const Value.absent(),
                Value<int> totalPausedSeconds = const Value.absent(),
                Value<int> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                workOrderId: workOrderId,
                workOrderNumber: workOrderNumber,
                workOrderStatus: workOrderStatus,
                vehicleId: vehicleId,
                branchId: branchId,
                bayId: bayId,
                serviceName: serviceName,
                mechanicId: mechanicId,
                status: status,
                description: description,
                estimatedHours: estimatedHours,
                holdReason: holdReason,
                missingItemDescription: missingItemDescription,
                pendingSuspensionReason: pendingSuspensionReason,
                startedAt: startedAt,
                totalPausedSeconds: totalPausedSeconds,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workOrderId,
                Value<int?> workOrderNumber = const Value.absent(),
                Value<String?> workOrderStatus = const Value.absent(),
                required String vehicleId,
                Value<String?> branchId = const Value.absent(),
                Value<String?> bayId = const Value.absent(),
                Value<String?> serviceName = const Value.absent(),
                Value<String?> mechanicId = const Value.absent(),
                required String status,
                required String description,
                Value<String?> estimatedHours = const Value.absent(),
                Value<String?> holdReason = const Value.absent(),
                Value<String?> missingItemDescription = const Value.absent(),
                Value<String?> pendingSuspensionReason = const Value.absent(),
                Value<int?> startedAt = const Value.absent(),
                required int totalPausedSeconds,
                required int syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                workOrderId: workOrderId,
                workOrderNumber: workOrderNumber,
                workOrderStatus: workOrderStatus,
                vehicleId: vehicleId,
                branchId: branchId,
                bayId: bayId,
                serviceName: serviceName,
                mechanicId: mechanicId,
                status: status,
                description: description,
                estimatedHours: estimatedHours,
                holdReason: holdReason,
                missingItemDescription: missingItemDescription,
                pendingSuspensionReason: pendingSuspensionReason,
                startedAt: startedAt,
                totalPausedSeconds: totalPausedSeconds,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasksTable, TaskEntity>(table),
                  BaseReferences<_$AppDatabase, $TasksTable, TaskEntity>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      TaskEntity,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (TaskEntity, BaseReferences<_$AppDatabase, $TasksTable, TaskEntity>),
      TaskEntity,
      PrefetchHooks Function()
    >;
typedef $$WorkOrdersTableCreateCompanionBuilder = WorkOrdersCompanion Function({
  required String id,
  Value<int?> internalNumber,
  required String branchId,
  required String vehicleId,
  required String customerId,
  Value<String?> currentBayId,
  Value<String?> bayName,
  required String status,
  Value<String?> diagnosticSummary,
  Value<int?> mileageIn,
  Value<String?> subtotal,
  Value<String?> taxAmount,
  required String totalAmount,
  required String currency,
  required int syncedAt,
  Value<int> rowid,
});
typedef $$WorkOrdersTableUpdateCompanionBuilder = WorkOrdersCompanion Function({
  Value<String> id,
  Value<int?> internalNumber,
  Value<String> branchId,
  Value<String> vehicleId,
  Value<String> customerId,
  Value<String?> currentBayId,
  Value<String?> bayName,
  Value<String> status,
  Value<String?> diagnosticSummary,
  Value<int?> mileageIn,
  Value<String?> subtotal,
  Value<String?> taxAmount,
  Value<String> totalAmount,
  Value<String> currency,
  Value<int> syncedAt,
  Value<int> rowid,
});

class $$WorkOrdersTableFilterComposer
    extends Composer<_$AppDatabase, $WorkOrdersTable> {
  $$WorkOrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get internalNumber => $composableBuilder(
    column: $table.internalNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentBayId => $composableBuilder(
    column: $table.currentBayId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bayName => $composableBuilder(
    column: $table.bayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diagnosticSummary => $composableBuilder(
    column: $table.diagnosticSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mileageIn => $composableBuilder(
    column: $table.mileageIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxAmount => $composableBuilder(
    column: $table.taxAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkOrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkOrdersTable> {
  $$WorkOrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get internalNumber => $composableBuilder(
    column: $table.internalNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentBayId => $composableBuilder(
    column: $table.currentBayId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bayName => $composableBuilder(
    column: $table.bayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diagnosticSummary => $composableBuilder(
    column: $table.diagnosticSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mileageIn => $composableBuilder(
    column: $table.mileageIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxAmount => $composableBuilder(
    column: $table.taxAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkOrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkOrdersTable> {
  $$WorkOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get internalNumber => $composableBuilder(
    column: $table.internalNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentBayId => $composableBuilder(
    column: $table.currentBayId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bayName =>
      $composableBuilder(column: $table.bayName, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get diagnosticSummary => $composableBuilder(
    column: $table.diagnosticSummary,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mileageIn =>
      $composableBuilder(column: $table.mileageIn, builder: (column) => column);

  GeneratedColumn<String> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<String> get taxAmount =>
      $composableBuilder(column: $table.taxAmount, builder: (column) => column);

  GeneratedColumn<String> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$WorkOrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkOrdersTable,
          WorkOrderEntity,
          $$WorkOrdersTableFilterComposer,
          $$WorkOrdersTableOrderingComposer,
          $$WorkOrdersTableAnnotationComposer,
          $$WorkOrdersTableCreateCompanionBuilder,
          $$WorkOrdersTableUpdateCompanionBuilder,
          (
            WorkOrderEntity,
            BaseReferences<_$AppDatabase, $WorkOrdersTable, WorkOrderEntity>,
          ),
          WorkOrderEntity,
          PrefetchHooks Function()
        > {
  $$WorkOrdersTableTableManager(_$AppDatabase db, $WorkOrdersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkOrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int?> internalNumber = const Value.absent(),
                Value<String> branchId = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String?> currentBayId = const Value.absent(),
                Value<String?> bayName = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> diagnosticSummary = const Value.absent(),
                Value<int?> mileageIn = const Value.absent(),
                Value<String?> subtotal = const Value.absent(),
                Value<String?> taxAmount = const Value.absent(),
                Value<String> totalAmount = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkOrdersCompanion(
                id: id,
                internalNumber: internalNumber,
                branchId: branchId,
                vehicleId: vehicleId,
                customerId: customerId,
                currentBayId: currentBayId,
                bayName: bayName,
                status: status,
                diagnosticSummary: diagnosticSummary,
                mileageIn: mileageIn,
                subtotal: subtotal,
                taxAmount: taxAmount,
                totalAmount: totalAmount,
                currency: currency,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int?> internalNumber = const Value.absent(),
                required String branchId,
                required String vehicleId,
                required String customerId,
                Value<String?> currentBayId = const Value.absent(),
                Value<String?> bayName = const Value.absent(),
                required String status,
                Value<String?> diagnosticSummary = const Value.absent(),
                Value<int?> mileageIn = const Value.absent(),
                Value<String?> subtotal = const Value.absent(),
                Value<String?> taxAmount = const Value.absent(),
                required String totalAmount,
                required String currency,
                required int syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => WorkOrdersCompanion.insert(
                id: id,
                internalNumber: internalNumber,
                branchId: branchId,
                vehicleId: vehicleId,
                customerId: customerId,
                currentBayId: currentBayId,
                bayName: bayName,
                status: status,
                diagnosticSummary: diagnosticSummary,
                mileageIn: mileageIn,
                subtotal: subtotal,
                taxAmount: taxAmount,
                totalAmount: totalAmount,
                currency: currency,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkOrdersTable, WorkOrderEntity>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WorkOrdersTable,
                    WorkOrderEntity
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkOrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkOrdersTable,
      WorkOrderEntity,
      $$WorkOrdersTableFilterComposer,
      $$WorkOrdersTableOrderingComposer,
      $$WorkOrdersTableAnnotationComposer,
      $$WorkOrdersTableCreateCompanionBuilder,
      $$WorkOrdersTableUpdateCompanionBuilder,
      (
        WorkOrderEntity,
        BaseReferences<_$AppDatabase, $WorkOrdersTable, WorkOrderEntity>,
      ),
      WorkOrderEntity,
      PrefetchHooks Function()
    >;
typedef $$BaysTableCreateCompanionBuilder = BaysCompanion Function({
  required String id,
  required String branchId,
  required String name,
  required String bayType,
  required String status,
  Value<String?> currentWorkOrderId,
  required int syncedAt,
  Value<int> rowid,
});
typedef $$BaysTableUpdateCompanionBuilder = BaysCompanion Function({
  Value<String> id,
  Value<String> branchId,
  Value<String> name,
  Value<String> bayType,
  Value<String> status,
  Value<String?> currentWorkOrderId,
  Value<int> syncedAt,
  Value<int> rowid,
});

class $$BaysTableFilterComposer extends Composer<_$AppDatabase, $BaysTable> {
  $$BaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bayType => $composableBuilder(
    column: $table.bayType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentWorkOrderId => $composableBuilder(
    column: $table.currentWorkOrderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BaysTableOrderingComposer extends Composer<_$AppDatabase, $BaysTable> {
  $$BaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bayType => $composableBuilder(
    column: $table.bayType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentWorkOrderId => $composableBuilder(
    column: $table.currentWorkOrderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $BaysTable> {
  $$BaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get bayType =>
      $composableBuilder(column: $table.bayType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get currentWorkOrderId => $composableBuilder(
    column: $table.currentWorkOrderId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$BaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BaysTable,
          BayEntity,
          $$BaysTableFilterComposer,
          $$BaysTableOrderingComposer,
          $$BaysTableAnnotationComposer,
          $$BaysTableCreateCompanionBuilder,
          $$BaysTableUpdateCompanionBuilder,
          (BayEntity, BaseReferences<_$AppDatabase, $BaysTable, BayEntity>),
          BayEntity,
          PrefetchHooks Function()
        > {
  $$BaysTableTableManager(_$AppDatabase db, $BaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> branchId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> bayType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> currentWorkOrderId = const Value.absent(),
                Value<int> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BaysCompanion(
                id: id,
                branchId: branchId,
                name: name,
                bayType: bayType,
                status: status,
                currentWorkOrderId: currentWorkOrderId,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String branchId,
                required String name,
                required String bayType,
                required String status,
                Value<String?> currentWorkOrderId = const Value.absent(),
                required int syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => BaysCompanion.insert(
                id: id,
                branchId: branchId,
                name: name,
                bayType: bayType,
                status: status,
                currentWorkOrderId: currentWorkOrderId,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BaysTable, BayEntity>(table),
                  BaseReferences<_$AppDatabase, $BaysTable, BayEntity>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BaysTable,
      BayEntity,
      $$BaysTableFilterComposer,
      $$BaysTableOrderingComposer,
      $$BaysTableAnnotationComposer,
      $$BaysTableCreateCompanionBuilder,
      $$BaysTableUpdateCompanionBuilder,
      (BayEntity, BaseReferences<_$AppDatabase, $BaysTable, BayEntity>),
      BayEntity,
      PrefetchHooks Function()
    >;
typedef $$CustomersTableCreateCompanionBuilder = CustomersCompanion Function({
  required String id,
  required String type,
  required String displayName,
  Value<String?> taxId,
  Value<String?> email,
  Value<String?> phone,
  required String status,
  required int syncedAt,
  Value<int> rowid,
});
typedef $$CustomersTableUpdateCompanionBuilder = CustomersCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<String> displayName,
  Value<String?> taxId,
  Value<String?> email,
  Value<String?> phone,
  Value<String> status,
  Value<int> syncedAt,
  Value<int> rowid,
});

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxId => $composableBuilder(
    column: $table.taxId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxId => $composableBuilder(
    column: $table.taxId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get taxId =>
      $composableBuilder(column: $table.taxId, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          CustomerEntity,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (
            CustomerEntity,
            BaseReferences<_$AppDatabase, $CustomersTable, CustomerEntity>,
          ),
          CustomerEntity,
          PrefetchHooks Function()
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> taxId = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                type: type,
                displayName: displayName,
                taxId: taxId,
                email: email,
                phone: phone,
                status: status,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required String displayName,
                Value<String?> taxId = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                required String status,
                required int syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion.insert(
                id: id,
                type: type,
                displayName: displayName,
                taxId: taxId,
                email: email,
                phone: phone,
                status: status,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomersTable, CustomerEntity>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CustomersTable,
                    CustomerEntity
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      CustomerEntity,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (
        CustomerEntity,
        BaseReferences<_$AppDatabase, $CustomersTable, CustomerEntity>,
      ),
      CustomerEntity,
      PrefetchHooks Function()
    >;
typedef $$VehiclesTableCreateCompanionBuilder = VehiclesCompanion Function({
  required String id,
  required String plate,
  Value<String?> vin,
  required String brand,
  required String model,
  Value<int?> year,
  Value<String?> engineType,
  Value<String?> currentOwnerId,
  Value<int?> currentMileage,
  required int syncedAt,
  Value<int> rowid,
});
typedef $$VehiclesTableUpdateCompanionBuilder = VehiclesCompanion Function({
  Value<String> id,
  Value<String> plate,
  Value<String?> vin,
  Value<String> brand,
  Value<String> model,
  Value<int?> year,
  Value<String?> engineType,
  Value<String?> currentOwnerId,
  Value<int?> currentMileage,
  Value<int> syncedAt,
  Value<int> rowid,
});

class $$VehiclesTableFilterComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plate => $composableBuilder(
    column: $table.plate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vin => $composableBuilder(
    column: $table.vin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get engineType => $composableBuilder(
    column: $table.engineType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentOwnerId => $composableBuilder(
    column: $table.currentOwnerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentMileage => $composableBuilder(
    column: $table.currentMileage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VehiclesTableOrderingComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plate => $composableBuilder(
    column: $table.plate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vin => $composableBuilder(
    column: $table.vin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get engineType => $composableBuilder(
    column: $table.engineType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentOwnerId => $composableBuilder(
    column: $table.currentOwnerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentMileage => $composableBuilder(
    column: $table.currentMileage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VehiclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get plate =>
      $composableBuilder(column: $table.plate, builder: (column) => column);

  GeneratedColumn<String> get vin =>
      $composableBuilder(column: $table.vin, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get engineType => $composableBuilder(
    column: $table.engineType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentOwnerId => $composableBuilder(
    column: $table.currentOwnerId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentMileage => $composableBuilder(
    column: $table.currentMileage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$VehiclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehiclesTable,
          VehicleEntity,
          $$VehiclesTableFilterComposer,
          $$VehiclesTableOrderingComposer,
          $$VehiclesTableAnnotationComposer,
          $$VehiclesTableCreateCompanionBuilder,
          $$VehiclesTableUpdateCompanionBuilder,
          (
            VehicleEntity,
            BaseReferences<_$AppDatabase, $VehiclesTable, VehicleEntity>,
          ),
          VehicleEntity,
          PrefetchHooks Function()
        > {
  $$VehiclesTableTableManager(_$AppDatabase db, $VehiclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> plate = const Value.absent(),
                Value<String?> vin = const Value.absent(),
                Value<String> brand = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> engineType = const Value.absent(),
                Value<String?> currentOwnerId = const Value.absent(),
                Value<int?> currentMileage = const Value.absent(),
                Value<int> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehiclesCompanion(
                id: id,
                plate: plate,
                vin: vin,
                brand: brand,
                model: model,
                year: year,
                engineType: engineType,
                currentOwnerId: currentOwnerId,
                currentMileage: currentMileage,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String plate,
                Value<String?> vin = const Value.absent(),
                required String brand,
                required String model,
                Value<int?> year = const Value.absent(),
                Value<String?> engineType = const Value.absent(),
                Value<String?> currentOwnerId = const Value.absent(),
                Value<int?> currentMileage = const Value.absent(),
                required int syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => VehiclesCompanion.insert(
                id: id,
                plate: plate,
                vin: vin,
                brand: brand,
                model: model,
                year: year,
                engineType: engineType,
                currentOwnerId: currentOwnerId,
                currentMileage: currentMileage,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VehiclesTable, VehicleEntity>(table),
                  BaseReferences<_$AppDatabase, $VehiclesTable, VehicleEntity>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VehiclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehiclesTable,
      VehicleEntity,
      $$VehiclesTableFilterComposer,
      $$VehiclesTableOrderingComposer,
      $$VehiclesTableAnnotationComposer,
      $$VehiclesTableCreateCompanionBuilder,
      $$VehiclesTableUpdateCompanionBuilder,
      (
        VehicleEntity,
        BaseReferences<_$AppDatabase, $VehiclesTable, VehicleEntity>,
      ),
      VehicleEntity,
      PrefetchHooks Function()
    >;
typedef $$AppointmentsTableCreateCompanionBuilder =
    AppointmentsCompanion Function({
      required String id,
      required String branchId,
      required String customerId,
      required String vehicleId,
      required int scheduledAt,
      Value<int?> estimatedDurationMinutes,
      Value<String?> reason,
      required String status,
      required int syncedAt,
      Value<int> rowid,
    });
typedef $$AppointmentsTableUpdateCompanionBuilder =
    AppointmentsCompanion Function({
      Value<String> id,
      Value<String> branchId,
      Value<String> customerId,
      Value<String> vehicleId,
      Value<int> scheduledAt,
      Value<int?> estimatedDurationMinutes,
      Value<String?> reason,
      Value<String> status,
      Value<int> syncedAt,
      Value<int> rowid,
    });

class $$AppointmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedDurationMinutes => $composableBuilder(
    column: $table.estimatedDurationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppointmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedDurationMinutes => $composableBuilder(
    column: $table.estimatedDurationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppointmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

  GeneratedColumn<int> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedDurationMinutes => $composableBuilder(
    column: $table.estimatedDurationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$AppointmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppointmentsTable,
          AppointmentEntity,
          $$AppointmentsTableFilterComposer,
          $$AppointmentsTableOrderingComposer,
          $$AppointmentsTableAnnotationComposer,
          $$AppointmentsTableCreateCompanionBuilder,
          $$AppointmentsTableUpdateCompanionBuilder,
          (
            AppointmentEntity,
            BaseReferences<
              _$AppDatabase,
              $AppointmentsTable,
              AppointmentEntity
            >,
          ),
          AppointmentEntity,
          PrefetchHooks Function()
        > {
  $$AppointmentsTableTableManager(_$AppDatabase db, $AppointmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppointmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppointmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppointmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> branchId = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<int> scheduledAt = const Value.absent(),
                Value<int?> estimatedDurationMinutes = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppointmentsCompanion(
                id: id,
                branchId: branchId,
                customerId: customerId,
                vehicleId: vehicleId,
                scheduledAt: scheduledAt,
                estimatedDurationMinutes: estimatedDurationMinutes,
                reason: reason,
                status: status,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String branchId,
                required String customerId,
                required String vehicleId,
                required int scheduledAt,
                Value<int?> estimatedDurationMinutes = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                required String status,
                required int syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppointmentsCompanion.insert(
                id: id,
                branchId: branchId,
                customerId: customerId,
                vehicleId: vehicleId,
                scheduledAt: scheduledAt,
                estimatedDurationMinutes: estimatedDurationMinutes,
                reason: reason,
                status: status,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppointmentsTable, AppointmentEntity>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AppointmentsTable,
                    AppointmentEntity
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppointmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppointmentsTable,
      AppointmentEntity,
      $$AppointmentsTableFilterComposer,
      $$AppointmentsTableOrderingComposer,
      $$AppointmentsTableAnnotationComposer,
      $$AppointmentsTableCreateCompanionBuilder,
      $$AppointmentsTableUpdateCompanionBuilder,
      (
        AppointmentEntity,
        BaseReferences<_$AppDatabase, $AppointmentsTable, AppointmentEntity>,
      ),
      AppointmentEntity,
      PrefetchHooks Function()
    >;
typedef $$PartsTableCreateCompanionBuilder = PartsCompanion Function({
  required String id,
  required String name,
  required String sku,
  required String category,
  required String basePrice,
  required String totalStock,
  required String minimumStock,
  required String unitOfMeasure,
  required String status,
  required int syncedAt,
  Value<int> rowid,
});
typedef $$PartsTableUpdateCompanionBuilder = PartsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> sku,
  Value<String> category,
  Value<String> basePrice,
  Value<String> totalStock,
  Value<String> minimumStock,
  Value<String> unitOfMeasure,
  Value<String> status,
  Value<int> syncedAt,
  Value<int> rowid,
});

class $$PartsTableFilterComposer extends Composer<_$AppDatabase, $PartsTable> {
  $$PartsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get basePrice => $composableBuilder(
    column: $table.basePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get totalStock => $composableBuilder(
    column: $table.totalStock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get minimumStock => $composableBuilder(
    column: $table.minimumStock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitOfMeasure => $composableBuilder(
    column: $table.unitOfMeasure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PartsTableOrderingComposer
    extends Composer<_$AppDatabase, $PartsTable> {
  $$PartsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get basePrice => $composableBuilder(
    column: $table.basePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get totalStock => $composableBuilder(
    column: $table.totalStock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get minimumStock => $composableBuilder(
    column: $table.minimumStock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitOfMeasure => $composableBuilder(
    column: $table.unitOfMeasure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PartsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartsTable> {
  $$PartsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get basePrice =>
      $composableBuilder(column: $table.basePrice, builder: (column) => column);

  GeneratedColumn<String> get totalStock => $composableBuilder(
    column: $table.totalStock,
    builder: (column) => column,
  );

  GeneratedColumn<String> get minimumStock => $composableBuilder(
    column: $table.minimumStock,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitOfMeasure => $composableBuilder(
    column: $table.unitOfMeasure,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$PartsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartsTable,
          PartEntity,
          $$PartsTableFilterComposer,
          $$PartsTableOrderingComposer,
          $$PartsTableAnnotationComposer,
          $$PartsTableCreateCompanionBuilder,
          $$PartsTableUpdateCompanionBuilder,
          (PartEntity, BaseReferences<_$AppDatabase, $PartsTable, PartEntity>),
          PartEntity,
          PrefetchHooks Function()
        > {
  $$PartsTableTableManager(_$AppDatabase db, $PartsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> sku = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> basePrice = const Value.absent(),
                Value<String> totalStock = const Value.absent(),
                Value<String> minimumStock = const Value.absent(),
                Value<String> unitOfMeasure = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartsCompanion(
                id: id,
                name: name,
                sku: sku,
                category: category,
                basePrice: basePrice,
                totalStock: totalStock,
                minimumStock: minimumStock,
                unitOfMeasure: unitOfMeasure,
                status: status,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String sku,
                required String category,
                required String basePrice,
                required String totalStock,
                required String minimumStock,
                required String unitOfMeasure,
                required String status,
                required int syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => PartsCompanion.insert(
                id: id,
                name: name,
                sku: sku,
                category: category,
                basePrice: basePrice,
                totalStock: totalStock,
                minimumStock: minimumStock,
                unitOfMeasure: unitOfMeasure,
                status: status,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PartsTable, PartEntity>(table),
                  BaseReferences<_$AppDatabase, $PartsTable, PartEntity>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PartsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartsTable,
      PartEntity,
      $$PartsTableFilterComposer,
      $$PartsTableOrderingComposer,
      $$PartsTableAnnotationComposer,
      $$PartsTableCreateCompanionBuilder,
      $$PartsTableUpdateCompanionBuilder,
      (PartEntity, BaseReferences<_$AppDatabase, $PartsTable, PartEntity>),
      PartEntity,
      PrefetchHooks Function()
    >;
typedef $$BatchesTableCreateCompanionBuilder = BatchesCompanion Function({
  required String id,
  required String itemId,
  required String batchNumber,
  required String remainingQty,
  required String unitCost,
  required int arrivalDate,
  required int syncedAt,
  Value<int> rowid,
});
typedef $$BatchesTableUpdateCompanionBuilder = BatchesCompanion Function({
  Value<String> id,
  Value<String> itemId,
  Value<String> batchNumber,
  Value<String> remainingQty,
  Value<String> unitCost,
  Value<int> arrivalDate,
  Value<int> syncedAt,
  Value<int> rowid,
});

class $$BatchesTableFilterComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remainingQty => $composableBuilder(
    column: $table.remainingQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get arrivalDate => $composableBuilder(
    column: $table.arrivalDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remainingQty => $composableBuilder(
    column: $table.remainingQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get arrivalDate => $composableBuilder(
    column: $table.arrivalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remainingQty => $composableBuilder(
    column: $table.remainingQty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<int> get arrivalDate => $composableBuilder(
    column: $table.arrivalDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$BatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BatchesTable,
          BatchEntity,
          $$BatchesTableFilterComposer,
          $$BatchesTableOrderingComposer,
          $$BatchesTableAnnotationComposer,
          $$BatchesTableCreateCompanionBuilder,
          $$BatchesTableUpdateCompanionBuilder,
          (
            BatchEntity,
            BaseReferences<_$AppDatabase, $BatchesTable, BatchEntity>,
          ),
          BatchEntity,
          PrefetchHooks Function()
        > {
  $$BatchesTableTableManager(_$AppDatabase db, $BatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> batchNumber = const Value.absent(),
                Value<String> remainingQty = const Value.absent(),
                Value<String> unitCost = const Value.absent(),
                Value<int> arrivalDate = const Value.absent(),
                Value<int> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BatchesCompanion(
                id: id,
                itemId: itemId,
                batchNumber: batchNumber,
                remainingQty: remainingQty,
                unitCost: unitCost,
                arrivalDate: arrivalDate,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String itemId,
                required String batchNumber,
                required String remainingQty,
                required String unitCost,
                required int arrivalDate,
                required int syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => BatchesCompanion.insert(
                id: id,
                itemId: itemId,
                batchNumber: batchNumber,
                remainingQty: remainingQty,
                unitCost: unitCost,
                arrivalDate: arrivalDate,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BatchesTable, BatchEntity>(table),
                  BaseReferences<_$AppDatabase, $BatchesTable, BatchEntity>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BatchesTable,
      BatchEntity,
      $$BatchesTableFilterComposer,
      $$BatchesTableOrderingComposer,
      $$BatchesTableAnnotationComposer,
      $$BatchesTableCreateCompanionBuilder,
      $$BatchesTableUpdateCompanionBuilder,
      (BatchEntity, BaseReferences<_$AppDatabase, $BatchesTable, BatchEntity>),
      BatchEntity,
      PrefetchHooks Function()
    >;
typedef $$VouchersTableCreateCompanionBuilder = VouchersCompanion Function({
  required String id,
  Value<String?> workOrderId,
  required String voucherType,
  required String serie,
  required int number,
  required String totalAmount,
  required String paidAmount,
  required String pendingBalance,
  required String paymentStatus,
  required String status,
  Value<String?> pdfUrl,
  required int syncedAt,
  Value<int> rowid,
});
typedef $$VouchersTableUpdateCompanionBuilder = VouchersCompanion Function({
  Value<String> id,
  Value<String?> workOrderId,
  Value<String> voucherType,
  Value<String> serie,
  Value<int> number,
  Value<String> totalAmount,
  Value<String> paidAmount,
  Value<String> pendingBalance,
  Value<String> paymentStatus,
  Value<String> status,
  Value<String?> pdfUrl,
  Value<int> syncedAt,
  Value<int> rowid,
});

class $$VouchersTableFilterComposer
    extends Composer<_$AppDatabase, $VouchersTable> {
  $$VouchersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workOrderId => $composableBuilder(
    column: $table.workOrderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voucherType => $composableBuilder(
    column: $table.voucherType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serie => $composableBuilder(
    column: $table.serie,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pendingBalance => $composableBuilder(
    column: $table.pendingBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pdfUrl => $composableBuilder(
    column: $table.pdfUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VouchersTableOrderingComposer
    extends Composer<_$AppDatabase, $VouchersTable> {
  $$VouchersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workOrderId => $composableBuilder(
    column: $table.workOrderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voucherType => $composableBuilder(
    column: $table.voucherType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serie => $composableBuilder(
    column: $table.serie,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pendingBalance => $composableBuilder(
    column: $table.pendingBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pdfUrl => $composableBuilder(
    column: $table.pdfUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VouchersTableAnnotationComposer
    extends Composer<_$AppDatabase, $VouchersTable> {
  $$VouchersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workOrderId => $composableBuilder(
    column: $table.workOrderId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get voucherType => $composableBuilder(
    column: $table.voucherType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serie =>
      $composableBuilder(column: $table.serie, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pendingBalance => $composableBuilder(
    column: $table.pendingBalance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get pdfUrl =>
      $composableBuilder(column: $table.pdfUrl, builder: (column) => column);

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$VouchersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VouchersTable,
          VoucherEntity,
          $$VouchersTableFilterComposer,
          $$VouchersTableOrderingComposer,
          $$VouchersTableAnnotationComposer,
          $$VouchersTableCreateCompanionBuilder,
          $$VouchersTableUpdateCompanionBuilder,
          (
            VoucherEntity,
            BaseReferences<_$AppDatabase, $VouchersTable, VoucherEntity>,
          ),
          VoucherEntity,
          PrefetchHooks Function()
        > {
  $$VouchersTableTableManager(_$AppDatabase db, $VouchersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VouchersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VouchersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VouchersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> workOrderId = const Value.absent(),
                Value<String> voucherType = const Value.absent(),
                Value<String> serie = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<String> totalAmount = const Value.absent(),
                Value<String> paidAmount = const Value.absent(),
                Value<String> pendingBalance = const Value.absent(),
                Value<String> paymentStatus = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> pdfUrl = const Value.absent(),
                Value<int> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VouchersCompanion(
                id: id,
                workOrderId: workOrderId,
                voucherType: voucherType,
                serie: serie,
                number: number,
                totalAmount: totalAmount,
                paidAmount: paidAmount,
                pendingBalance: pendingBalance,
                paymentStatus: paymentStatus,
                status: status,
                pdfUrl: pdfUrl,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> workOrderId = const Value.absent(),
                required String voucherType,
                required String serie,
                required int number,
                required String totalAmount,
                required String paidAmount,
                required String pendingBalance,
                required String paymentStatus,
                required String status,
                Value<String?> pdfUrl = const Value.absent(),
                required int syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => VouchersCompanion.insert(
                id: id,
                workOrderId: workOrderId,
                voucherType: voucherType,
                serie: serie,
                number: number,
                totalAmount: totalAmount,
                paidAmount: paidAmount,
                pendingBalance: pendingBalance,
                paymentStatus: paymentStatus,
                status: status,
                pdfUrl: pdfUrl,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VouchersTable, VoucherEntity>(table),
                  BaseReferences<_$AppDatabase, $VouchersTable, VoucherEntity>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VouchersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VouchersTable,
      VoucherEntity,
      $$VouchersTableFilterComposer,
      $$VouchersTableOrderingComposer,
      $$VouchersTableAnnotationComposer,
      $$VouchersTableCreateCompanionBuilder,
      $$VouchersTableUpdateCompanionBuilder,
      (
        VoucherEntity,
        BaseReferences<_$AppDatabase, $VouchersTable, VoucherEntity>,
      ),
      VoucherEntity,
      PrefetchHooks Function()
    >;
typedef $$TelemetryReadingsTableCreateCompanionBuilder =
    TelemetryReadingsCompanion Function({
      required String id,
      required String vehicleId,
      required int timestamp,
      required double engineTempCelsius,
      Value<int?> engineRpm,
      Value<int?> speedKmh,
      Value<double?> batteryVoltage,
      Value<double?> fuelPercentage,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> batchOperationId,
      Value<int> rowid,
    });
typedef $$TelemetryReadingsTableUpdateCompanionBuilder =
    TelemetryReadingsCompanion Function({
      Value<String> id,
      Value<String> vehicleId,
      Value<int> timestamp,
      Value<double> engineTempCelsius,
      Value<int?> engineRpm,
      Value<int?> speedKmh,
      Value<double?> batteryVoltage,
      Value<double?> fuelPercentage,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> batchOperationId,
      Value<int> rowid,
    });

class $$TelemetryReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $TelemetryReadingsTable> {
  $$TelemetryReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get engineTempCelsius => $composableBuilder(
    column: $table.engineTempCelsius,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get engineRpm => $composableBuilder(
    column: $table.engineRpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speedKmh => $composableBuilder(
    column: $table.speedKmh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get batteryVoltage => $composableBuilder(
    column: $table.batteryVoltage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fuelPercentage => $composableBuilder(
    column: $table.fuelPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchOperationId => $composableBuilder(
    column: $table.batchOperationId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TelemetryReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $TelemetryReadingsTable> {
  $$TelemetryReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get engineTempCelsius => $composableBuilder(
    column: $table.engineTempCelsius,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get engineRpm => $composableBuilder(
    column: $table.engineRpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speedKmh => $composableBuilder(
    column: $table.speedKmh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get batteryVoltage => $composableBuilder(
    column: $table.batteryVoltage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fuelPercentage => $composableBuilder(
    column: $table.fuelPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchOperationId => $composableBuilder(
    column: $table.batchOperationId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TelemetryReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TelemetryReadingsTable> {
  $$TelemetryReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<double> get engineTempCelsius => $composableBuilder(
    column: $table.engineTempCelsius,
    builder: (column) => column,
  );

  GeneratedColumn<int> get engineRpm =>
      $composableBuilder(column: $table.engineRpm, builder: (column) => column);

  GeneratedColumn<int> get speedKmh =>
      $composableBuilder(column: $table.speedKmh, builder: (column) => column);

  GeneratedColumn<double> get batteryVoltage => $composableBuilder(
    column: $table.batteryVoltage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fuelPercentage => $composableBuilder(
    column: $table.fuelPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get batchOperationId => $composableBuilder(
    column: $table.batchOperationId,
    builder: (column) => column,
  );
}

class $$TelemetryReadingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TelemetryReadingsTable,
          TelemetryReadingEntity,
          $$TelemetryReadingsTableFilterComposer,
          $$TelemetryReadingsTableOrderingComposer,
          $$TelemetryReadingsTableAnnotationComposer,
          $$TelemetryReadingsTableCreateCompanionBuilder,
          $$TelemetryReadingsTableUpdateCompanionBuilder,
          (
            TelemetryReadingEntity,
            BaseReferences<
              _$AppDatabase,
              $TelemetryReadingsTable,
              TelemetryReadingEntity
            >,
          ),
          TelemetryReadingEntity,
          PrefetchHooks Function()
        > {
  $$TelemetryReadingsTableTableManager(
    _$AppDatabase db,
    $TelemetryReadingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TelemetryReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TelemetryReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TelemetryReadingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<int> timestamp = const Value.absent(),
                Value<double> engineTempCelsius = const Value.absent(),
                Value<int?> engineRpm = const Value.absent(),
                Value<int?> speedKmh = const Value.absent(),
                Value<double?> batteryVoltage = const Value.absent(),
                Value<double?> fuelPercentage = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> batchOperationId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TelemetryReadingsCompanion(
                id: id,
                vehicleId: vehicleId,
                timestamp: timestamp,
                engineTempCelsius: engineTempCelsius,
                engineRpm: engineRpm,
                speedKmh: speedKmh,
                batteryVoltage: batteryVoltage,
                fuelPercentage: fuelPercentage,
                latitude: latitude,
                longitude: longitude,
                batchOperationId: batchOperationId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String vehicleId,
                required int timestamp,
                required double engineTempCelsius,
                Value<int?> engineRpm = const Value.absent(),
                Value<int?> speedKmh = const Value.absent(),
                Value<double?> batteryVoltage = const Value.absent(),
                Value<double?> fuelPercentage = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> batchOperationId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TelemetryReadingsCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                timestamp: timestamp,
                engineTempCelsius: engineTempCelsius,
                engineRpm: engineRpm,
                speedKmh: speedKmh,
                batteryVoltage: batteryVoltage,
                fuelPercentage: fuelPercentage,
                latitude: latitude,
                longitude: longitude,
                batchOperationId: batchOperationId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TelemetryReadingsTable, TelemetryReadingEntity>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $TelemetryReadingsTable,
                    TelemetryReadingEntity
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TelemetryReadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TelemetryReadingsTable,
      TelemetryReadingEntity,
      $$TelemetryReadingsTableFilterComposer,
      $$TelemetryReadingsTableOrderingComposer,
      $$TelemetryReadingsTableAnnotationComposer,
      $$TelemetryReadingsTableCreateCompanionBuilder,
      $$TelemetryReadingsTableUpdateCompanionBuilder,
      (
        TelemetryReadingEntity,
        BaseReferences<
          _$AppDatabase,
          $TelemetryReadingsTable,
          TelemetryReadingEntity
        >,
      ),
      TelemetryReadingEntity,
      PrefetchHooks Function()
    >;
typedef $$VehicleFaultsTableCreateCompanionBuilder =
    VehicleFaultsCompanion Function({
      required String id,
      required String vehicleId,
      required String dtcCode,
      required String severity,
      required String description,
      required int detectedAt,
      required bool isResolved,
      Value<int?> resolvedAt,
      Value<int?> syncedAt,
      Value<int> rowid,
    });
typedef $$VehicleFaultsTableUpdateCompanionBuilder =
    VehicleFaultsCompanion Function({
      Value<String> id,
      Value<String> vehicleId,
      Value<String> dtcCode,
      Value<String> severity,
      Value<String> description,
      Value<int> detectedAt,
      Value<bool> isResolved,
      Value<int?> resolvedAt,
      Value<int?> syncedAt,
      Value<int> rowid,
    });

class $$VehicleFaultsTableFilterComposer
    extends Composer<_$AppDatabase, $VehicleFaultsTable> {
  $$VehicleFaultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dtcCode => $composableBuilder(
    column: $table.dtcCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isResolved => $composableBuilder(
    column: $table.isResolved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VehicleFaultsTableOrderingComposer
    extends Composer<_$AppDatabase, $VehicleFaultsTable> {
  $$VehicleFaultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dtcCode => $composableBuilder(
    column: $table.dtcCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isResolved => $composableBuilder(
    column: $table.isResolved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VehicleFaultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehicleFaultsTable> {
  $$VehicleFaultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

  GeneratedColumn<String> get dtcCode =>
      $composableBuilder(column: $table.dtcCode, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isResolved => $composableBuilder(
    column: $table.isResolved,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$VehicleFaultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehicleFaultsTable,
          VehicleFaultEntity,
          $$VehicleFaultsTableFilterComposer,
          $$VehicleFaultsTableOrderingComposer,
          $$VehicleFaultsTableAnnotationComposer,
          $$VehicleFaultsTableCreateCompanionBuilder,
          $$VehicleFaultsTableUpdateCompanionBuilder,
          (
            VehicleFaultEntity,
            BaseReferences<
              _$AppDatabase,
              $VehicleFaultsTable,
              VehicleFaultEntity
            >,
          ),
          VehicleFaultEntity,
          PrefetchHooks Function()
        > {
  $$VehicleFaultsTableTableManager(_$AppDatabase db, $VehicleFaultsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehicleFaultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehicleFaultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehicleFaultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<String> dtcCode = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> detectedAt = const Value.absent(),
                Value<bool> isResolved = const Value.absent(),
                Value<int?> resolvedAt = const Value.absent(),
                Value<int?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehicleFaultsCompanion(
                id: id,
                vehicleId: vehicleId,
                dtcCode: dtcCode,
                severity: severity,
                description: description,
                detectedAt: detectedAt,
                isResolved: isResolved,
                resolvedAt: resolvedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String vehicleId,
                required String dtcCode,
                required String severity,
                required String description,
                required int detectedAt,
                required bool isResolved,
                Value<int?> resolvedAt = const Value.absent(),
                Value<int?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehicleFaultsCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                dtcCode: dtcCode,
                severity: severity,
                description: description,
                detectedAt: detectedAt,
                isResolved: isResolved,
                resolvedAt: resolvedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VehicleFaultsTable, VehicleFaultEntity>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $VehicleFaultsTable,
                    VehicleFaultEntity
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VehicleFaultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehicleFaultsTable,
      VehicleFaultEntity,
      $$VehicleFaultsTableFilterComposer,
      $$VehicleFaultsTableOrderingComposer,
      $$VehicleFaultsTableAnnotationComposer,
      $$VehicleFaultsTableCreateCompanionBuilder,
      $$VehicleFaultsTableUpdateCompanionBuilder,
      (
        VehicleFaultEntity,
        BaseReferences<_$AppDatabase, $VehicleFaultsTable, VehicleFaultEntity>,
      ),
      VehicleFaultEntity,
      PrefetchHooks Function()
    >;
typedef $$PredictiveAlertsTableCreateCompanionBuilder =
    PredictiveAlertsCompanion Function({
      required String id,
      required String vehicleId,
      required String alertType,
      required double confidenceScore,
      required String message,
      required String status,
      required int createdAt,
      required int syncedAt,
      Value<int> rowid,
    });
typedef $$PredictiveAlertsTableUpdateCompanionBuilder =
    PredictiveAlertsCompanion Function({
      Value<String> id,
      Value<String> vehicleId,
      Value<String> alertType,
      Value<double> confidenceScore,
      Value<String> message,
      Value<String> status,
      Value<int> createdAt,
      Value<int> syncedAt,
      Value<int> rowid,
    });

class $$PredictiveAlertsTableFilterComposer
    extends Composer<_$AppDatabase, $PredictiveAlertsTable> {
  $$PredictiveAlertsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alertType => $composableBuilder(
    column: $table.alertType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PredictiveAlertsTableOrderingComposer
    extends Composer<_$AppDatabase, $PredictiveAlertsTable> {
  $$PredictiveAlertsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alertType => $composableBuilder(
    column: $table.alertType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PredictiveAlertsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PredictiveAlertsTable> {
  $$PredictiveAlertsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

  GeneratedColumn<String> get alertType =>
      $composableBuilder(column: $table.alertType, builder: (column) => column);

  GeneratedColumn<double> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$PredictiveAlertsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PredictiveAlertsTable,
          PredictiveAlertEntity,
          $$PredictiveAlertsTableFilterComposer,
          $$PredictiveAlertsTableOrderingComposer,
          $$PredictiveAlertsTableAnnotationComposer,
          $$PredictiveAlertsTableCreateCompanionBuilder,
          $$PredictiveAlertsTableUpdateCompanionBuilder,
          (
            PredictiveAlertEntity,
            BaseReferences<
              _$AppDatabase,
              $PredictiveAlertsTable,
              PredictiveAlertEntity
            >,
          ),
          PredictiveAlertEntity,
          PrefetchHooks Function()
        > {
  $$PredictiveAlertsTableTableManager(
    _$AppDatabase db,
    $PredictiveAlertsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PredictiveAlertsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PredictiveAlertsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PredictiveAlertsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<String> alertType = const Value.absent(),
                Value<double> confidenceScore = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PredictiveAlertsCompanion(
                id: id,
                vehicleId: vehicleId,
                alertType: alertType,
                confidenceScore: confidenceScore,
                message: message,
                status: status,
                createdAt: createdAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String vehicleId,
                required String alertType,
                required double confidenceScore,
                required String message,
                required String status,
                required int createdAt,
                required int syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => PredictiveAlertsCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                alertType: alertType,
                confidenceScore: confidenceScore,
                message: message,
                status: status,
                createdAt: createdAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PredictiveAlertsTable, PredictiveAlertEntity>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $PredictiveAlertsTable,
                    PredictiveAlertEntity
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PredictiveAlertsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PredictiveAlertsTable,
      PredictiveAlertEntity,
      $$PredictiveAlertsTableFilterComposer,
      $$PredictiveAlertsTableOrderingComposer,
      $$PredictiveAlertsTableAnnotationComposer,
      $$PredictiveAlertsTableCreateCompanionBuilder,
      $$PredictiveAlertsTableUpdateCompanionBuilder,
      (
        PredictiveAlertEntity,
        BaseReferences<
          _$AppDatabase,
          $PredictiveAlertsTable,
          PredictiveAlertEntity
        >,
      ),
      PredictiveAlertEntity,
      PrefetchHooks Function()
    >;
typedef $$AppLocksTableCreateCompanionBuilder = AppLocksCompanion Function({
  required String name,
  required String owner,
  required int expiresAt,
  Value<int> rowid,
});
typedef $$AppLocksTableUpdateCompanionBuilder = AppLocksCompanion Function({
  Value<String> name,
  Value<String> owner,
  Value<int> expiresAt,
  Value<int> rowid,
});

class $$AppLocksTableFilterComposer
    extends Composer<_$AppDatabase, $AppLocksTable> {
  $$AppLocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppLocksTableOrderingComposer
    extends Composer<_$AppDatabase, $AppLocksTable> {
  $$AppLocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppLocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppLocksTable> {
  $$AppLocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  GeneratedColumn<int> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$AppLocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppLocksTable,
          AppLockEntity,
          $$AppLocksTableFilterComposer,
          $$AppLocksTableOrderingComposer,
          $$AppLocksTableAnnotationComposer,
          $$AppLocksTableCreateCompanionBuilder,
          $$AppLocksTableUpdateCompanionBuilder,
          (
            AppLockEntity,
            BaseReferences<_$AppDatabase, $AppLocksTable, AppLockEntity>,
          ),
          AppLockEntity,
          PrefetchHooks Function()
        > {
  $$AppLocksTableTableManager(_$AppDatabase db, $AppLocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppLocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppLocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppLocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<String> owner = const Value.absent(),
                Value<int> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppLocksCompanion(
                name: name,
                owner: owner,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                required String owner,
                required int expiresAt,
                Value<int> rowid = const Value.absent(),
              }) => AppLocksCompanion.insert(
                name: name,
                owner: owner,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppLocksTable, AppLockEntity>(table),
                  BaseReferences<_$AppDatabase, $AppLocksTable, AppLockEntity>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppLocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppLocksTable,
      AppLockEntity,
      $$AppLocksTableFilterComposer,
      $$AppLocksTableOrderingComposer,
      $$AppLocksTableAnnotationComposer,
      $$AppLocksTableCreateCompanionBuilder,
      $$AppLocksTableUpdateCompanionBuilder,
      (
        AppLockEntity,
        BaseReferences<_$AppDatabase, $AppLocksTable, AppLockEntity>,
      ),
      AppLockEntity,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PendingOperationsTableTableManager get pendingOperations =>
      $$PendingOperationsTableTableManager(_db, _db.pendingOperations);
  $$PendingUploadsTableTableManager get pendingUploads =>
      $$PendingUploadsTableTableManager(_db, _db.pendingUploads);
  $$CacheMetadataTableTableManager get cacheMetadata =>
      $$CacheMetadataTableTableManager(_db, _db.cacheMetadata);
  $$AttendancesTableTableManager get attendances =>
      $$AttendancesTableTableManager(_db, _db.attendances);
  $$ShiftsTableTableManager get shifts =>
      $$ShiftsTableTableManager(_db, _db.shifts);
  $$BranchesTableTableManager get branches =>
      $$BranchesTableTableManager(_db, _db.branches);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$WorkOrdersTableTableManager get workOrders =>
      $$WorkOrdersTableTableManager(_db, _db.workOrders);
  $$BaysTableTableManager get bays => $$BaysTableTableManager(_db, _db.bays);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db, _db.vehicles);
  $$AppointmentsTableTableManager get appointments =>
      $$AppointmentsTableTableManager(_db, _db.appointments);
  $$PartsTableTableManager get parts =>
      $$PartsTableTableManager(_db, _db.parts);
  $$BatchesTableTableManager get batches =>
      $$BatchesTableTableManager(_db, _db.batches);
  $$VouchersTableTableManager get vouchers =>
      $$VouchersTableTableManager(_db, _db.vouchers);
  $$TelemetryReadingsTableTableManager get telemetryReadings =>
      $$TelemetryReadingsTableTableManager(_db, _db.telemetryReadings);
  $$VehicleFaultsTableTableManager get vehicleFaults =>
      $$VehicleFaultsTableTableManager(_db, _db.vehicleFaults);
  $$PredictiveAlertsTableTableManager get predictiveAlerts =>
      $$PredictiveAlertsTableTableManager(_db, _db.predictiveAlerts);
  $$AppLocksTableTableManager get appLocks =>
      $$AppLocksTableTableManager(_db, _db.appLocks);
}
