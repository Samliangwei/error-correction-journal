# 拾题 P0 数据安全设计

版本：v1.0  
日期：2026-11-20  
依据：PRD v0.2 §06-08

## 1. 调度安全（§06）

### 1.1 时区固定 UTC+8
```dart
class TimeUtils {
  static const String fixedTimeZone = 'Asia/Shanghai'; // UTC+8
  
  /// 获取当前学习日期（格式：2026-11-20）
  static String getCurrentLearningDate() {
    final now = DateTime.now().toUtc().add(Duration(hours: 8));
    return DateFormat('yyyy-MM-dd').format(now);
  }
  
  /// 学习日期转DateTime（当日00:00 UTC+8）
  static DateTime learningDateToDateTime(String date) {
    final local = DateTime.parse('${date}T00:00:00');
    return local.subtract(Duration(hours: 8)).toUtc();
  }
  
  /// 检查设备日期是否回拨
  static Future<DateCheckResult> checkDeviceDate() async {
    final lastKnownDate = await getLastKnownLearningDate();
    final currentDate = getCurrentLearningDate();
    
    if (currentDate < lastKnownDate) {
      return DateCheckResult.rollback;  // 回拨，暂停排期写入
    }
    
    final daysDiff = _dateDifference(lastKnownDate, currentDate);
    if (daysDiff > 7) {
      return DateCheckResult.largeJump;  // 大幅前跳，需确认
    }
    
    return DateCheckResult.normal;
  }
}
```

**安全要点**：
- 设备旅行不随系统时区漂移
- 事件存绝对时刻（UTC）+ 学习日期（UTC+8字符串）
- 回拨到上次有效学习日前 → 暂停排期写入，仍可查看/草稿
- 前跳>7日 → 需确认设备日期
- 离线不声称验证真实时间

### 1.2 k级别推进与间隔计算
```dart
class Scheduler {
  /// 计算下次due日期
  static String? calculateNextDue(
    int kLevel,
    ReviewResult result,
    String submittedDate,
  ) {
    if (result == ReviewResult.notKnow) {
      // 不会 → k0, +1天
      return _addDays(submittedDate, 1);
    } else if (result == ReviewResult.fuzzy) {
      // 模糊 → k保持, +1天
      return _addDays(submittedDate, 1);
    } else if (result == ReviewResult.know) {
      // 会了 → k递进
      final newK = kLevel + 1;
      if (newK == 1) return _addDays(submittedDate, 3);
      if (newK == 2) return _addDays(submittedDate, 7);
      if (newK == 3) return _addDays(submittedDate, 14);
      if (newK >= 4) return null;  // 已掌握，清空due
    }
    throw ArgumentError('Invalid result');
  }
  
  /// 从保存日创建首次排期
  static ReviewCycle createInitialCycle(
    String questionId,
    String formalizedDate,
  ) {
    return ReviewCycle(
      id: Uuid().v4(),
      questionId: questionId,
      cycleNumber: 1,
      kLevel: 0,
      state: LearningState.pendingReview,
      dueDate: _addDays(formalizedDate, 1),  // 次日首复习
      startedAt: DateTime.now(),
      isActive: true,
    );
  }
}
```

**安全要点**：
- k0→k1→k2→k3→k4 严格递进
- 间隔：3/7/14天，固定不调整
- 迟做按实际提交日计算新due，不以原due
- 需同周期跨间隔完成4次"会了"才k4

### 1.3 幂等性守护
```dart
class IdempotencyGuard {
  /// 检查今日是否已有有效自评
  static Future<IdempotencyResult> checkReviewIdempotency({
    required String questionId,
    required String learningDate,
    required String cycleId,
    required Database db,
  }) async {
    // 查询题+日的有效事件
    final events = await (db.select(db.reviewEvents)
          ..where((e) => 
              e.questionId.equals(questionId) &
              e.learningDate.equals(learningDate)))
        .get();
    
    if (events.isEmpty) {
      return IdempotencyResult.allowed();
    }
    
    // 已有有效自评，返回首次结果
    final firstEvent = events.first;
    return IdempotencyResult.duplicate(
      existingEventId: firstEvent.id,
      result: firstEvent.result,
      kLevelAfter: firstEvent.kLevelAfter,
      dueDateAfter: firstEvent.dueDateAfter,
    );
  }
  
  /// 再次出错幂等性检查
  static Future<ResetIdempotencyResult> checkResetIdempotency({
    required String questionId,
    required String learningDate,
    required Database db,
  }) async {
    // 检查今日是否已再错
    final resets = await (db.select(db.reviewCycles)
          ..where((c) =>
              c.questionId.equals(questionId) &
              c.startedAt.day.equals(DateTime.parse(learningDate).day)))
        .get();
    
    if (resets.length > 1) {
      // 同日已有新周期，幂等返回
      return ResetIdempotencyResult.alreadyReset();
    }
    
    return ResetIdempotencyResult.allowed();
  }
}
```

**安全要点**：
- 题UUID + 学习日期 → 唯一有效自评
- 跨周期也不能同日第二次自评
- 再次出错同题+学习日幂等
- 重复请求返回首次结果，不重复计数

### 1.4 跨日旧卡原子检查
```dart
class CrossDayValidator {
  /// 跨日提交前原子检查
  static Future<ValidationResult> validateCrossDayCard({
    required String questionId,
    required String cardCycleId,
    required int cardVersion,
    required String newLearningDate,
    required Database db,
  }) async {
    return await db.transaction(() async {
      // 1. 重检版本
      final question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals(questionId)))
          .getSingleOrNull();
      
      if (question == null) {
        return ValidationResult.questionDeleted();
      }
      
      if (question.version != cardVersion) {
        return ValidationResult.versionChanged(
          reason: '题目已被编辑，请刷新',
        );
      }
      
      // 2. 重检生命周期
      if (question.isArchived) {
        return ValidationResult.lifecycleChanged(
          reason: '题目已归档',
        );
      }
      
      if (question.deletedAt != null) {
        return ValidationResult.lifecycleChanged(
          reason: '题目已删除',
        );
      }
      
      // 3. 重检周期
      final cycle = await (db.select(db.reviewCycles)
            ..where((c) => c.id.equals(cardCycleId)))
          .getSingleOrNull();
      
      if (cycle == null || !cycle.isActive) {
        return ValidationResult.cycleInvalid(
          reason: '复习周期已失效',
        );
      }
      
      // 4. 重检due（是否仍到期）
      final state = await getLearningState(questionId, db);
      if (state == LearningState.mastered) {
        return ValidationResult.alreadyMastered();
      }
      
      if (!_isStillDue(cycle.dueDate, newLearningDate)) {
        return ValidationResult.notDueAnymore();
      }
      
      // 5. 重检当日限制
      final todayIdempotency = await IdempotencyGuard.checkReviewIdempotency(
        questionId: questionId,
        learningDate: newLearningDate,
        cycleId: cardCycleId,
        db: db,
      );
      
      if (todayIdempotency.isDuplicate) {
        return ValidationResult.alreadyReviewedToday(
          existingResult: todayIdempotency.result!,
        );
      }
      
      // 6. 重检容量
      final plan = await DailyPlanManager.getOrCreatePlan(
        learningDate: newLearningDate,
        db: db,
      );
      
      if (plan.completedIds.contains(questionId)) {
        // 多窗口已完成
        return ValidationResult.alreadyCompleted();
      }
      
      final capacityCheck = await _checkCapacity(
        plan: plan,
        questionId: questionId,
        db: db,
      );
      
      return capacityCheck;
    });
  }
}
```

**安全要点**：
- 6重检查：版本/生命周期/周期/due/当日限制/容量
- 原子事务：所有检查在同一事务中
- 新日无计划 → 优先预留旧卡后补足到N
- 新日已有计划有空位 → 即纳入
- 新日容量满且不在计划 → 必须明确确认"追加1题"，取消零写入

## 2. 容量管理安全（§06）

### 2.1 每日计划容量规则
```dart
class DailyPlanManager {
  /// 建立或获取今日计划
  static Future<DailyPlan> getOrCreatePlan({
    required String learningDate,
    required Database db,
  }) async {
    final existing = await _getPlan(learningDate, db);
    if (existing != null) return existing;
    
    // 首次建立：C = N
    final settings = await SettingsRepository.getSettings();
    final targetN = settings.dailyTargetN;
    
    // 按排序取最多N题
    final dueQuestions = await _getDueQuestions(learningDate, db);
    final questionIds = dueQuestions
        .take(targetN)
        .map((q) => q.id)
        .toList();
    
    return DailyPlan(
      id: Uuid().v4(),
      learningDate: learningDate,
      targetN: targetN,
      capacityC: targetN,
      questionIds: questionIds,
      completedIds: [],
      skippedIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  /// 完成一题（不释放容量）
  static Future<void> completeQuestion({
    required String questionId,
    required String learningDate,
    required Database db,
  }) async {
    await db.transaction(() async {
      final plan = await getOrCreatePlan(
        learningDate: learningDate,
        db: db,
      );
      
      if (plan.completedIds.contains(questionId)) {
        // 已完成，幂等返回
        return;
      }
      
      // 已完成不释放容量，分母不变
      await (db.update(db.dailyPlans)
            ..where((p) => p.id.equals(plan.id)))
          .write(DailyPlansCompanion(
            completedIds: Value([...plan.completedIds, questionId]),
            updatedAt: Value(DateTime.now()),
          ));
    });
  }
  
  /// 自动补位（不扩大C）
  static Future<void> autoFillSlot({
    required String learningDate,
    required Database db,
  }) async {
    await db.transaction(() async {
      final plan = await getOrCreatePlan(
        learningDate: learningDate,
        db: db,
      );
      
      final uncompletedCount = plan.questionIds.length - plan.completedIds.length;
      if (uncompletedCount >= plan.capacityC) {
        // 已满，不补位
        return;
      }
      
      // 计算空位数
      final emptySlots = plan.capacityC - plan.questionIds.length;
      if (emptySlots <= 0) return;
      
      // 获取候选题（排除今日已完成/已再错/已删除）
      final candidates = await _getCandidatesForFill(
        learningDate: learningDate,
        excludeIds: plan.questionIds,
        db: db,
      );
      
      // 补足空位，但不超过C
      final toAdd = candidates.take(emptySlots).map((q) => q.id).toList();
      
      await (db.update(db.dailyPlans)
            ..where((p) => p.id.equals(plan.id)))
          .write(DailyPlansCompanion(
            questionIds: Value([...plan.questionIds, ...toAdd]),
            updatedAt: Value(DateTime.now()),
          ));
    });
  }
  
  /// 明确追加（扩大C）
  static Future<AdditionResult> addQuestionsExplicitly({
    required List<String> questionIds,
    required String learningDate,
    required Database db,
  }) async {
    return await db.transaction(() async {
      final plan = await getOrCreatePlan(
        learningDate: learningDate,
        db: db,
      );
      
      final settings = await SettingsRepository.getSettings();
      final maxBatchSize = settings.dailyTargetN;
      
      if (questionIds.length > maxBatchSize) {
        return AdditionResult.batchTooLarge(
          requestedCount: questionIds.length,
          maxBatch: maxBatchSize,
        );
      }
      
      // 过滤已在计划中的题
      final newIds = questionIds
          .where((id) => !plan.questionIds.contains(id))
          .toList();
      
      if (newIds.isEmpty) {
        return AdditionResult.allAlreadyInPlan();
      }
      
      // C 增加实际新增数量
      final newCapacity = plan.capacityC + newIds.length;
      
      await (db.update(db.dailyPlans)
            ..where((p) => p.id.equals(plan.id)))
          .write(DailyPlansCompanion(
            capacityC: Value(newCapacity),
            questionIds: Value([...plan.questionIds, ...newIds]),
            updatedAt: Value(DateTime.now()),
          ));
      
      return AdditionResult.success(
        actualAdded: newIds.length,
        newCapacity: newCapacity,
        newTotal: plan.questionIds.length + newIds.length,
      );
    });
  }
}
```

**安全要点**：
- 目标N：默认20，5-50整数，修改次日生效
- 容量C：初始=N，只因明确追加增大
- 已完成不释放：完成后分母不变
- 自动补位：不超过原C，不纳入今日已完成/再错/删除题
- 追加确认：每批≤N，显示实际增量/C/分母

### 2.2 归档/删除补位规则
```dart
class LifecycleManager {
  /// 归档题（已完成保留，未完成移除并补位）
  static Future<void> archiveQuestion({
    required String questionId,
    required Database db,
  }) async {
    await db.transaction(() async {
      // 标记归档
      await (db.update(db.mistakeQuestions)
            ..where((q) => q.id.equals(questionId)))
          .write(MistakeQuestionsCompanion(
            isArchived: Value(true),
            updatedAt: Value(DateTime.now()),
          ));
      
      // 检查今日计划
      final today = TimeUtils.getCurrentLearningDate();
      final plan = await DailyPlanManager.getPlan(today, db);
      if (plan == null) return;
      
      if (plan.completedIds.contains(questionId)) {
        // 已完成，保留计划身份
        return;
      }
      
      if (plan.questionIds.contains(questionId)) {
        // 未完成，移除并补位
        await _removeFromPlanAndFill(
          questionId: questionId,
          plan: plan,
          db: db,
        );
      }
    });
  }
  
  /// 删除题（无论完成否均移除并补位）
  static Future<void> deleteQuestion({
    required String questionId,
    required Database db,
  }) async {
    await db.transaction(() async {
      final now = DateTime.now();
      
      // 软删除
      await (db.update(db.mistakeQuestions)
            ..where((q) => q.id.equals(questionId)))
          .write(MistakeQuestionsCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
          ));
      
      // 从今日计划移除（分子分母都移除）
      final today = TimeUtils.getCurrentLearningDate();
      final plan = await DailyPlanManager.getPlan(today, db);
      if (plan == null) return;
      
      if (plan.questionIds.contains(questionId)) {
        await _removeFromPlanAndFill(
          questionId: questionId,
          plan: plan,
          removeFromCompleted: true,  // 删除时也移除已完成
          db: db,
        );
      }
    });
  }
  
  /// 从计划移除并补位（C不变）
  static Future<void> _removeFromPlanAndFill({
    required String questionId,
    required DailyPlan plan,
    bool removeFromCompleted = false,
    required Database db,
  }) async {
    final newQuestionIds = plan.questionIds.where((id) => id != questionId).toList();
    final newCompletedIds = removeFromCompleted
        ? plan.completedIds.where((id) => id != questionId).toList()
        : plan.completedIds;
    
    // 补位但不超过原C
    final emptySlots = plan.capacityC - newQuestionIds.length;
    if (emptySlots > 0) {
      final candidates = await _getCandidatesForFill(
        learningDate: plan.learningDate,
        excludeIds: newQuestionIds,
        db: db,
      );
      
      final toAdd = candidates.take(emptySlots).map((q) => q.id).toList();
      newQuestionIds.addAll(toAdd);
    }
    
    await (db.update(db.dailyPlans)
          ..where((p) => p.id.equals(plan.id)))
        .write(DailyPlansCompanion(
          questionIds: Value(newQuestionIds),
          completedIds: Value(newCompletedIds),
          updatedAt: Value(DateTime.now()),
        ));
  }
}
```

**安全要点**：
- 归档已完成 → 保留计划
- 归档未完成 → 移除并补位
- 删除无论完成否 → 分子分母都移除并补位
- 补位不超过原C，不暗中扩大容量

## 3. 事务一致性（§06）

### 3.1 复习提交原子操作
```dart
class ReviewSubmissionService {
  /// 原子提交复习结果
  static Future<SubmissionResult> submitReview({
    required String questionId,
    required String cardCycleId,
    required int cardVersion,
    required ReviewResult result,
    required Database db,
  }) async {
    final learningDate = TimeUtils.getCurrentLearningDate();
    
    return await db.transaction(() async {
      // 1. 跨日原子检查（6重）
      final validation = await CrossDayValidator.validateCrossDayCard(
        questionId: questionId,
        cardCycleId: cardCycleId,
        cardVersion: cardVersion,
        newLearningDate: learningDate,
        db: db,
      );
      
      if (!validation.isValid) {
        return SubmissionResult.validationFailed(validation.reason);
      }
      
      // 2. 原子写入：事件 + k/due/状态 + 计划
      final cycle = await _getCycle(cardCycleId, db);
      final newK = _calculateNewK(cycle.kLevel, result);
      final newDue = Scheduler.calculateNextDue(
        cycle.kLevel,
        result,
        learningDate,
      );
      final newState = _calculateNewState(newK);
      
      // 2.1 写入事件
      final event = ReviewEvent(
        id: Uuid().v4(),
        questionId: questionId,
        cycleId: cardCycleId,
        eventTime: DateTime.now(),
        learningDate: learningDate,
        result: result,
        kLevelBefore: cycle.kLevel,
        kLevelAfter: newK,
        dueDateAfter: newDue,
      );
      await db.into(db.reviewEvents).insert(event);
      
      // 2.2 更新周期
      await (db.update(db.reviewCycles)
            ..where((c) => c.id.equals(cardCycleId)))
          .write(ReviewCyclesCompanion(
            kLevel: Value(newK),
            state: Value(newState),
            dueDate: Value(newDue),
            completedAt: Value(newK >= 4 ? DateTime.now() : null),
            updatedAt: Value(DateTime.now()),
          ));
      
      // 2.3 更新计划（完成）
      await DailyPlanManager.completeQuestion(
        questionId: questionId,
        learningDate: learningDate,
        db: db,
      );
      
      return SubmissionResult.success(
        newK: newK,
        newDue: newDue,
        newState: newState,
      );
    });
    // 事务全部成功或全部失败，不能部分成功
  }
}
```

**安全要点**：
- 单一事务：事件+k/due/状态+计划原子成功
- 失败回滚：任何错误回滚所有写入
- 不能先显示完成再失败：提交成功后才更新UI

## 4. 备份恢复安全（§07）

### 4.1 完整备份生成
```dart
class BackupManager {
  /// 生成完整备份快照
  static Future<BackupResult> createBackup({
    required Database db,
  }) async {
    try {
      // 1. 一致性快照（在事务中读取）
      final snapshot = await db.transaction(() async {
        final questions = await db.select(db.mistakeQuestions).get();
        final drafts = await db.select(db.drafts).get();
        final cycles = await db.select(db.reviewCycles).get();
        final events = await db.select(db.reviewEvents).get();
        final plans = await db.select(db.dailyPlans).get();
        final images = await db.select(db.images).get();
        final settings = await SettingsRepository.getSettings();
        
        return BackupSnapshot(
          version: '1.0.0',
          timestamp: DateTime.now(),
          timezone: TimeUtils.fixedTimeZone,
          questions: questions,
          drafts: drafts,
          cycles: cycles,
          events: events,
          plans: plans,
          images: images,
          settings: settings,
        );
      });
      
      // 2. 生成备份包
      final backupData = await _generateBackupPackage(snapshot, db);
      
      // 3. 计算校验值
      final checksum = _calculateChecksum(backupData);
      
      // 4. 添加元数据
      final manifest = BackupManifest(
        version: snapshot.version,
        timestamp: snapshot.timestamp,
        questionCount: snapshot.questions.length,
        draftCount: snapshot.drafts.length,
        imageCount: snapshot.images.length,
        checksum: checksum,
      );
      
      final finalPackage = await _packageWithManifest(backupData, manifest);
      
      return BackupResult.success(
        package: finalPackage,
        manifest: manifest,
      );
    } catch (e) {
      return BackupResult.failure(error: e.toString());
    }
  }
  
  /// Web平台下载与读回验证
  static Future<DownloadConfirmResult> confirmWebDownload({
    required BackupManifest originalManifest,
    required Database db,
  }) async {
    try {
      // 1. 触发下载（浏览器API）
      await _triggerBrowserDownload(originalManifest.packageData);
      
      // 此时只是"已生成/已发起下载，尚未确认保存"
      // 不更新最近成功备份时间
      
      return DownloadConfirmResult.downloadInitiated(
        message: '已生成并发起下载，尚未确认保存。\n'
                '请重新选择已下载的文件进行验证。',
      );
    } catch (e) {
      return DownloadConfirmResult.failure(error: e.toString());
    }
  }
  
  /// 读回验证匹配
  static Future<DownloadConfirmResult> verifyDownloadedFile({
    required Uint8List fileData,
    required String originalChecksum,
    required Database db,
  }) async {
    try {
      final checksum = _calculateChecksum(fileData);
      
      if (checksum != originalChecksum) {
        return DownloadConfirmResult.checksumMismatch(
          message: '校验不匹配，请重新选择正确的备份文件',
        );
      }
      
      // 校验匹配，更新最近成功备份时间
      await SettingsRepository.updateLastSuccessfulBackupTime(
        DateTime.now(),
      );
      
      return DownloadConfirmResult.confirmed(
        message: '备份已确认',
      );
    } catch (e) {
      return DownloadConfirmResult.failure(error: e.toString());
    }
  }
}
```

**安全要点**：
- 一致性快照：事务中读取所有数据
- 版本化：包含格式版本、时间戳、校验值
- Web下载不是成功：发起下载不更新成功时间
- 读回验证：重选文件验证匹配才确认成功

### 4.2 恢复预检
```dart
class RestoreManager {
  /// 恢复预检（多层安全）
  static Future<RestorePreCheckResult> preCheckRestore({
    required Uint8List backupData,
    required Database db,
  }) async {
    try {
      // 1. 格式兼容性
      final manifest = await _extractManifest(backupData);
      if (!_isVersionCompatible(manifest.version)) {
        return RestorePreCheckResult.incompatibleVersion(
          version: manifest.version,
        );
      }
      
      // 2. 校验完整性
      final checksum = _calculateChecksum(backupData);
      if (checksum != manifest.checksum) {
        return RestorePreCheckResult.corruptedPackage();
      }
      
      // 3. 解包安全（路径穿越、体积）
      final unpackResult = await _safeUnpack(backupData);
      if (!unpackResult.isS) {
        return RestorePreCheckResult.unpackFailed(
          reason: unpackResult.error,
        );
      }
      
      final snapshot = unpackResult.snapshot!;
      
      // 4. 字段约束
      if (!_validateConstraints(snapshot)) {
        return RestorePreCheckResult.constraintViolation();
      }
      
      // 5. 数量限制
      if (snapshot.drafts.length > 50) {
        return RestorePreCheckResult.exceedsDraftLimit(
          count: snapshot.drafts.length,
        );
      }
      
      final formalCount = snapshot.questions.length;
      if (formalCount > 5000) {
        return RestorePreCheckResult.exceedsFormalLimit(
          count: formalCount,
        );
      }
      
      // 6. 素材校验
      for (final image in snapshot.images) {
        if (!await _verifyImageFile(image)) {
          return RestorePreCheckResult.imageMissing(
            imageId: image.id,
          );
        }
      }
      
      // 7. 配额与临时空间
      final quotaCheck = await _checkQuotaForRestore(snapshot);
      if (!quotaCheck.hasEnoughSpace) {
        return RestorePreCheckResult.insufficientQuota(
          required: quotaCheck.requiredBytes,
          available: quotaCheck.availableBytes,
        );
      }
      
      // 8. 回滚空间预留
      final currentDataSize = await _getCurrentDataSize(db);
      if (!quotaCheck.hasRollbackSpace(currentDataSize)) {
        return RestorePreCheckResult.insufficientRollbackSpace();
      }
      
      // 9. 当前数据非空检查
      final isEmpty = await _isCurrentDataEmpty(db);
      if (!isEmpty) {
        // 非空必须先生成当前快照
        return RestorePreCheckResult.requiresCurrentSnapshot(
          message: '当前数据非空，请先确认当前最新快照',
        );
      }
      
      // 10. 跨日回收站清理预告
      final today = TimeUtils.getCurrentLearningDate();
      final toClean = snapshot.questions
          .where((q) =>
              q.deletedAt != null &&
              _isExpired(q.deletedAt!, today, 30))
          .length;
      
      return RestorePreCheckResult.ready(
        manifest: manifest,
        toCleanCount: toClean,
      );
    } catch (e) {
      return RestorePreCheckResult.failure(error: e.toString());
    }
  }
  
  /// 当前快照生成（恢复前必须）
  static Future<CurrentSnapshotResult> createCurrentSnapshot({
    required Database db,
  }) async {
    // 生成当前数据的备份快照
    final backupResult = await BackupManager.createBackup(db: db);
    if (!backupResult.isSuccess) {
      return CurrentSnapshotResult.failure(
        error: backupResult.error,
      );
    }
    
    // Web环境需读回确认
    if (PlatformDetector.isWeb) {
      final downloadResult = await BackupManager.confirmWebDownload(
        originalManifest: backupResult.manifest!,
        db: db,
      );
      
      if (!downloadResult.isConfirmed) {
        return CurrentSnapshotResult.webNotConfirmed(
          message: '请重新选择已下载的快照文件进行确认',
        );
      }
    }
    
    return CurrentSnapshotResult.success(
      manifest: backupResult.manifest!,
    );
  }
}
```

**安全要点**：
- 10层预检：格式/校验/解包/约束/数量/素材/配额/回滚/非空/清理
- 非空保护：当前数据非空必须先生成并确认最新快照
- 空间不足停止：不允许"仍然覆盖"或先删数据腾空间
- Web读回确认：浏览器环境快照也需读回验证

### 4.3 原子替换与回滚
```dart
class RestoreManager {
  /// 原子替换（失败回滚）
  static Future<RestoreResult> atomicRestore({
    required BackupSnapshot snapshot,
    required Database db,
  }) async {
    // 1. 防并发编辑：检查数据变化
    final currentVersion = await _getCurrentDataVersion(db);
    
    // 2. 在事务中原子替换
    try {
      await db.transaction(() async {
        // 2.1 再次检查版本（防并发）
        final latestVersion = await _getCurrentDataVersion(db);
        if (latestVersion != currentVersion) {
          throw ConcurrentModificationException(
            '数据在恢复期间被修改，请重新确认快照',
          );
        }
        
        // 2.2 清空现有数据（在事务中）
        await _clearAllData(db);
        
        // 2.3 写入备份数据
        await _writeSnapshot(snapshot, db);
        
        // 2.4 恢复计划与标记（同日保留，跨日重建）
        await _restorePlansAndMarks(snapshot, db);
        
        // 2.5 清理过期回收站
        await _cleanExpiredRecycleBin(snapshot, db);
      });
      
      return RestoreResult.success(
        restoredCount: snapshot.questions.length,
      );
    } catch (e) {
      // 事务失败自动回滚到替换前状态
      return RestoreResult.failure(
        error: e.toString(),
        rollbackCompleted: true,
      );
    }
  }
}
```

**安全要点**：
- 单一事务：清空+写入+恢复计划+清理，原子成功
- 并发检测：替换前后检查数据版本，变化则重新确认
- 失败回滚：任何错误回滚至替换前完整状态
- 不先删数据：清空和写入在同一事务中

## 5. 再次出错安全（§06）

### 5.1 再次出错幂等与保留完成
```dart
class MistakeAgainService {
  /// 再次出错（幂等，保留当日完成）
  static Future<MistakeAgainResult> markAsMistakeAgain({
    required String questionId,
    required Database db,
  }) async {
    final learningDate = TimeUtils.getCurrentLearningDate();
    
    return await db.transaction(() async {
      // 1. 检查题目状态
      final question = await _getQuestion(questionId, db);
      if (question == null) {
        return MistakeAgainResult.questionNotFound();
      }
      
      if (question.isArchived) {
        return MistakeAgainResult.questionArchived(
          message: '请先取消归档',
        );
      }
      
      if (question.deletedAt != null) {
        return MistakeAgainResult.questionDeleted();
      }
      
      // 2. 检查今日幂等（同题+学习日）
      final todayReset = await _checkTodayReset(
        questionId,
        learningDate,
        db,
      );
      
      if (todayReset.alreadyReset) {
        // 同日幂等，返回首次结果
        return MistakeAgainResult.alreadyResetToday(
          cycleId: todayReset.newCycleId!,
        );
      }
      
      // 3. 检查当日是否已有有效自评
      final hasReviewedToday = await _hasTodayReview(
        questionId,
        learningDate,
        db,
      );
      
      // 4. 关闭旧周期
      final oldCycle = await _getActiveCycle(questionId, db);
      if (oldCycle != null) {
        await (db.update(db.reviewCycles)
              ..where((c) => c.id.equals(oldCycle.id)))
            .write(ReviewCyclesCompanion(
              isActive: Value(false),
              updatedAt: Value(DateTime.now()),
            ));
      }
      
      // 5. 开启新周期（k0, due=明日）
      final newCycleNumber = (oldCycle?.cycleNumber ?? 0) + 1;
      final newCycle = ReviewCycle(
        id: Uuid().v4(),
        questionId: questionId,
        cycleNumber: newCycleNumber,
        kLevel: 0,
        state: LearningState.reviewing,
        dueDate: TimeUtils.addDays(learningDate, 1),
        startedAt: DateTime.now(),
        isActive: true,
      );
      await db.into(db.reviewCycles).insert(newCycle);
      
      // 6. 处理今日计划
      final plan = await DailyPlanManager.getPlan(learningDate, db);
      if (plan != null && plan.questionIds.contains(questionId)) {
        if (hasReviewedToday && plan.completedIds.contains(questionId)) {
          // 已完成后再错：保留有效自评、完成身份、计划身份
          // 另标"今日再错、明日重学"（在UI层显示）
          // 当天不可再排期自评（幂等守护已阻止）
        } else {
          // 未完成：移出当日计划并补位
          await LifecycleManager._removeFromPlanAndFill(
            questionId: questionId,
            plan: plan,
            db: db,
          );
        }
      }
      
      return MistakeAgainResult.success(
        newCycleId: newCycle.id,
        preservedCompletion: hasReviewedToday,
      );
    });
  }
}
```

**安全要点**：
- 同题+学习日幂等：同日多次触发只执行一次
- 新周期k0/due明日：保留旧历史
- 已完成后再错：保留有效自评、完成身份、计划身份
- 未完成：移出当日计划并补位
- 当天不可再排期：幂等守护阻止

## 6. Web 平台安全（§08）

### 6.1 Drift wasm + IndexedDB 持久化
```dart
// lib/core/database/database_web.dart
import 'package:drift/wasm.dart';
import 'package:drift/web.dart';

Future<QueryExecutor> createWebExecutor(String dbName) async {
  // 1. 使用官方推荐的 sqlite3.wasm + IndexedDB
  return WasmDatabase.open(
    databaseName: dbName,
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.js'),
    // 明确使用 IndexedDB 持久化
    storage: DriftWebStorage.indexedDb(dbName),
  );
}
```

**安全要点**：
- 使用官方 Drift wasm + worker
- IndexedDB 真实持久化
- 不虚假成功：写入失败抛异常

### 6.2 离线资源准备
```dart
// Service Worker 配置
class OfflineReadinessChecker {
  /// 检查离线就绪状态
  static Future<OfflineStatus> checkOfflineReadiness() async {
    if (!PlatformDetector.isWeb) {
      return OfflineStatus.ready(message: '原生平台已就绪');
    }
    
    try {
      // 1. 检查 Service Worker 注册
      final swRegistered = await _isServiceWorkerRegistered();
      if (!swRegistered) {
        return OfflineStatus.notReady(
          message: '离线资源尚未准备，请联网完成首次加载',
        );
      }
      
      // 2. 检查关键资源缓存
      final resourcesCached = await _areResourcesCached([
        '/',
        '/main.dart.js',
        '/sqlite3.wasm',
        '/drift_worker.js',
        '/assets/AssetManifest.json',
      ]);
      
      if (!resourcesCached) {
        return OfflineStatus.notReady(
          message: '资源缓存未完成',
        );
      }
      
      return OfflineStatus.ready(
        message: '本地·离线就绪',
      );
    } catch (e) {
      return OfflineStatus.unknown(
        message: '无法检测离线状态',
      );
    }
  }
}
```

**安全要点**：
- Service Worker + Cache API
- 首次需联网完成资源下载
- 完成后显示"本地·离线就绪"
- 不承诺首次飞行模式可加载

### 6.3 配额探测与失败安全
```dart
class QuotaManager {
  /// 探测可用配额
  static Future<QuotaInfo> checkQuota() async {
    if (!PlatformDetector.isWeb) {
      return QuotaInfo.notApplicable();
    }
    
    try {
      // StorageManager API（仅部分浏览器支持）
      final estimate = await html.window.navigator.storage?.estimate();
      if (estimate != null) {
        final usage = estimate['usage'] as int?;
        final quota = estimate['quota'] as int?;
        
        if (usage != null && quota != null) {
          final available = quota - usage;
          return QuotaInfo.known(
            usageBytes: usage,
            quotaBytes: quota,
            availableBytes: available,
          );
        }
      }
      
      // API 不可用
      return QuotaInfo.unknown(
        message: '浏览器不支持配额检测，将逐次验证写入',
      );
    } catch (e) {
      return QuotaInfo.unknown(
        message: '配额检测失败: ${e.toString()}',
      );
    }
  }
  
  /// 逐次写入校验（配额未知时）
  static Future<WriteResult> safeWrite({
    required Future<void> Function() writeOperation,
  }) async {
    try {
      await writeOperation();
      return WriteResult.success();
    } on DriftRemoteException catch (e) {
      if (_isQuotaExceededError(e)) {
        return WriteResult.quotaExceeded();
      }
      rethrow;
    }
  }
  
  static bool _isQuotaExceededError(DriftRemoteException e) {
    // SQLite SQLITE_FULL (13)
    return e.message.contains('SQLITE_FULL') ||
           e.message.contains('database or disk is full');
  }
}
```

**安全要点**：
- 配额探测：可用时探测，不可用时明确未知
- 失败安全：空间不足停止写入，不静默删数据
- 逐次校验：未知配额时每次写入检查
- 不假承诺：不因题数未到5000就承诺可写

---

## 总结

本文档定义了 7 大数据安全子系统的详细实现规范：

1. **调度安全**：UTC+8固定时区、k级别推进、幂等性、跨日检查
2. **容量管理**：N/C规则、已完成不释放、自动补位、追加确认
3. **事务一致性**：原子操作、失败回滚、版本检查
4. **备份恢复**：完整快照、Web读回验证、10层预检、原子替换
5. **再次出错**：同日幂等、保留完成、新周期
6. **Web平台**：Drift wasm + IndexedDB、离线准备、配额探测
7. **失败安全**：所有异常场景的安全处理

所有实现必须严格遵守本设计，不得弱化安全门槛。
