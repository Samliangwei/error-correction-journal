# 拾题 P0 验收案例追踪矩阵

版本：v1.0  
日期：2026-11-20  
依据：PRD v0.2 §11（AC-01～AC-26）

## 矩阵说明

- **AC编号**：验收案例编号（AC-01 ～ AC-26）
- **Given/When/Then**：测试场景与预期
- **关联模块**：实现该功能的代码模块
- **测试类型**：单元测试/集成测试/E2E测试
- **验收证据**：通过/部分通过/未验证
- **阻塞问题**：阻止验收的问题

## AC-01 ｜ 必填字段验证
**Given**: 空白录入  
**When**: 无题目或无科目正式保存  
**Then**: 定位提示、不建正式题，可存草稿；仅文字或仅题图加科目可保存

**关联模块**:
- `lib/features/mistake_questions/domain/models/mistake_question.dart`
- `lib/features/mistake_questions/data/repositories/mistake_question_repository_impl.dart`
- `lib/features/mistake_questions/presentation/providers/question_form_provider.dart`

**实现要点**:
```dart
class MistakeQuestionValidator {
  ValidationResult validateForFormalization(MistakeQuestion question) {
    // 题目：文字或图至少一项
    if (question.questionText.trim().isEmpty && 
        question.questionImages.isEmpty) {
      return ValidationResult.error(
        field: 'question',
        message: '请填写题目或添加题图',
      );
    }
    
    // 科目：必选
    if (question.subject == null || question.subject!.isEmpty) {
      return ValidationResult.error(
        field: 'subject',
        message: '请选择科目',
      );
    }
    
    return ValidationResult.valid();
  }
}
```

**测试用例**:
- `test/features/mistake_questions/domain/validators/mistake_question_validator_test.dart`
  - `test_empty_question_and_no_image_fails()`
  - `test_empty_question_with_image_and_subject_passes()`
  - `test_text_question_with_subject_passes()`
  - `test_missing_subject_fails()`
  - `test_draft_allows_incomplete()`

**验收证据**: ❌ 未实现

---

## AC-02 ｜ 图片处理与限制
**Given**: 题图  
**When**: 裁剪、旋转确认后重启  
**Then**: 素材一致且元数据已移除；拒绝相机仍可文字/选图。8张总上限跨题目/答案/思路校验，第9张拒绝但已有素材保留

**关联模块**:
- `lib/core/services/image_picker_service.dart`
- `lib/core/services/image_processor.dart`
- `lib/core/services/image_storage.dart`
- `lib/features/mistake_questions/presentation/widgets/image_section.dart`

**实现要点**:
```dart
class ImageProcessor {
  /// 处理图片：裁剪、旋转、压缩、移除元数据
  Future<ProcessedImage> processImage({
    required File sourceFile,
    CropRect? cropRect,
    int rotationDegrees = 0,
  }) async {
    // 1. 解码
    final image = await decodeImageFile(sourceFile);
    
    // 2. 裁剪
    if (cropRect != null) {
      image = copyCrop(image,
        x: cropRect.x,
        y: cropRect.y,
        width: cropRect.width,
        height: cropRect.height,
      );
    }
    
    // 3. 旋转（90°倍数）
    if (rotationDegrees != 0) {
      image = copyRotate(image, angle: rotationDegrees);
    }
    
    // 4. 调整大小（长边≤2400px）
    final maxDimension = 2400;
    if (image.width > maxDimension || image.height > maxDimension) {
      image = copyResize(image,
        width: image.width > image.height ? maxDimension : null,
        height: image.height > image.width ? maxDimension : null,
      );
    }
    
    // 5. 压缩（≤3MB）
    final jpegBytes = encodeJpg(image, quality: 85);
    if (jpegBytes.length > 3 * 1024 * 1024) {
      // 降质量再压
      final lowerQuality = encodeJpg(image, quality: 70);
      return ProcessedImage(data: lowerQuality);
    }
    
    // 6. 元数据已自动移除（EXIF、GPS等）
    return ProcessedImage(data: jpegBytes);
  }
}

class ImageStorage {
  /// 检查8张总限制
  Future<bool> canAddMoreImages({
    required String questionId,
    required Database db,
  }) async {
    final existingImages = await (db.select(db.images)
          ..where((i) => i.questionId.equals(questionId)))
        .get();
    
    return existingImages.length < 8;
  }
}
```

**测试用例**:
- `test/core/services/image_processor_test.dart`
  - `test_crop_preserves_content()`
  - `test_rotate_90_degrees()`
  - `test_compress_large_image_to_under_3mb()`
  - `test_metadata_removed()`
  - `test_heic_fallback_when_not_supported()`
- `test/core/services/image_storage_test.dart`
  - `test_8_images_limit_across_sections()`
  - `test_9th_image_rejected_but_others_preserved()`
- `test_integration/image_processing_persistence_test.dart`
  - `test_processed_images_survive_app_restart()`

**验收证据**: ❌ 未实现

---

## AC-03 ｜ 回忆核验门槛
**Given**: 已填答案/思路/错因  
**When**: 进入排期复习  
**Then**: 均隐藏，回忆确认与核验后才能自评；无答案要自行核验。题图泄露仅提示，不冒充自动遮挡

**关联模块**:
- `lib/features/review/presentation/pages/review_card_page.dart`
- `lib/features/review/presentation/providers/review_session_provider.dart`

**实现要点**:
```dart
enum ReviewStage {
  recall,      // 只见题目
  verify,      // 已确认回忆，揭晓答案/思路/错因
  evaluate,    // 已核验，三档自评
}

class ReviewCardState {
  final MistakeQuestion question;
  final ReviewStage stage;
  final bool hasAttemptedRecall;
  final bool hasVerified;
  
  bool get canShowAnswer => stage == ReviewStage.verify;
  bool get canEvaluate => stage == ReviewStage.evaluate;
}

// UI实现
Widget buildReviewCard() {
  return Column(
    children: [
      // 题目始终显示
      QuestionSection(
        text: question.questionText,
        images: question.questionImages,
      ),
      
      // 答案/思路/错因：仅verify/evaluate阶段显示
      if (state.canShowAnswer) ...[
        if (question.correctAnswer != null)
          AnswerSection(
            text: question.correctAnswer!,
            images: question.answerImages,
          )
        else
          NoAnswerHint(
            message: '尚未录入参考答案，请对照课本或老师讲解核验',
          ),
          
        if (question.myThinking != null)
          ThinkingSection(text: question.myThinking!),
          
        if (question.errorReasons.isNotEmpty)
          ErrorReasonSection(reasons: question.errorReasons),
      ],
      
      // 操作按钮
      if (state.stage == ReviewStage.recall)
        ElevatedButton(
          onPressed: () => onConfirmRecall(),
          child: Text('我已尝试回忆'),
        )
      else if (state.stage == ReviewStage.verify)
        ElevatedButton(
          onPressed: () => onConfirmVerify(),
          child: Text(question.correctAnswer != null 
              ? '已核验，继续'
              : '我已自行核验'),
        )
      else if (state.stage == ReviewStage.evaluate)
        ThreeChoiceButtons(
          onNotKnow: () => submitReview(ReviewResult.notKnow),
          onFuzzy: () => submitReview(ReviewResult.fuzzy),
          onKnow: () => submitReview(ReviewResult.know),
        ),
    ],
  );
}
```

**测试用例**:
- `test/features/review/presentation/providers/review_session_provider_test.dart`
  - `test_answer_hidden_before_recall_confirmation()`
  - `test_answer_revealed_after_recall()`
  - `test_evaluate_buttons_disabled_until_verified()`
  - `test_no_answer_shows_self_verify_prompt()`
- `test_integration/review_flow_test.dart`
  - `test_full_recall_verify_evaluate_flow()`

**验收证据**: ❌ 未实现

---

## AC-04 ｜ k级别与间隔推进
**Given**: 11月20日保存  
**When**: 次日起每次会了  
**Then**: 21日、24日、12月1日、12月15日依次处理，最后k=4且due为空，当天保存不排当日

**关联模块**:
- `lib/core/scheduling/scheduler.dart`
- `lib/features/mistake_questions/data/repositories/review_cycle_repository.dart`

**测试用例**:
```dart
// test/core/scheduling/scheduler_test.dart
void main() {
  group('AC-04: k级别与间隔推进', () {
    test('保存日不排当日', () {
      final formalizedDate = '2026-11-20';
      final cycle = Scheduler.createInitialCycle(
        questionId: 'q1',
        formalizedDate: formalizedDate,
      );
      
      expect(cycle.kLevel, 0);
      expect(cycle.dueDate, '2026-11-21');  // 次日
    });
    
    test('k0会了→k1, +3天', () {
      final submittedDate = '2026-11-21';
      final newDue = Scheduler.calculateNextDue(
        kLevel: 0,
        result: ReviewResult.know,
        submittedDate: submittedDate,
      );
      
      expect(newDue, '2026-11-24');  // 21+3
    });
    
    test('k1会了→k2, +7天', () {
      final submittedDate = '2026-11-24';
      final newDue = Scheduler.calculateNextDue(
        kLevel: 1,
        result: ReviewResult.know,
        submittedDate: submittedDate,
      );
      
      expect(newDue, '2026-12-01');  // 24+7
    });
    
    test('k2会了→k3, +14天', () {
      final submittedDate = '2026-12-01';
      final newDue = Scheduler.calculateNextDue(
        kLevel: 2,
        result: ReviewResult.know,
        submittedDate: submittedDate,
      );
      
      expect(newDue, '2026-12-15');  // 1+14
    });
    
    test('k3会了→k4, due清空', () {
      final submittedDate = '2026-12-15';
      final newDue = Scheduler.calculateNextDue(
        kLevel: 3,
        result: ReviewResult.know,
        submittedDate: submittedDate,
      );
      
      expect(newDue, isNull);  // 已掌握
    });
  });
}
```

**验收证据**: ❌ 未实现

---

## AC-05 ｜ 模糊与不会
**Given**: k=2  
**When**: 模糊  
**Then**: k=2、due=提交日+1；下次不会则k=0、due再按那次提交日+1，周期不变

**关联模块**:
- `lib/core/scheduling/scheduler.dart`

**测试用例**:
```dart
test('AC-05: 模糊保持k, +1天', () {
  final submittedDate = '2026-11-25';
  final newDue = Scheduler.calculateNextDue(
    kLevel: 2,
    result: ReviewResult.fuzzy,
    submittedDate: submittedDate,
  );
  
  expect(newDue, '2026-11-26');  // k保持2, +1天
});

test('AC-05: 不会清零k, +1天', () {
  final submittedDate = '2026-11-26';
  final newDue = Scheduler.calculateNextDue(
    kLevel: 2,
    result: ReviewResult.notKnow,
    submittedDate: submittedDate,
  );
  
  expect(newDue, '2026-11-27');  // k变0, +1天
});
```

**验收证据**: ❌ 未实现

---

## AC-06 ｜ 迟做与跳过
**Given**: 昨日到期、k=0  
**When**: 今日会了  
**Then**: due=今日+3；跳过则不改due/k，不记有效事件

**测试用例**:
```dart
test('AC-06: 迟做按实际提交日', () {
  // due='2026-11-20', 实际'2026-11-21'提交
  final submittedDate = '2026-11-21';
  final newDue = Scheduler.calculateNextDue(
    kLevel: 0,
    result: ReviewResult.know,
    submittedDate: submittedDate,
  );
  
  expect(newDue, '2026-11-24');  // 从21计算，不是从20
});

test('AC-06: 跳过不改k/due', () async {
  final session = ReviewSession(...);
  final question = session.currentQuestion;
  final originalK = question.currentCycle.kLevel;
  final originalDue = question.currentCycle.dueDate;
  
  await session.skipQuestion();
  
  final updated = await getQuestion(question.id);
  expect(updated.currentCycle.kLevel, originalK);
  expect(updated.currentCycle.dueDate, originalDue);
  
  // 无事件
  final events = await getEventsForDate(question.id, today);
  expect(events, isEmpty);
});
```

**验收证据**: ❌ 未实现

---

## AC-07 ｜ 幂等性（同题同日唯一）
**Given**: 同题同日  
**When**: 连点、重启重试或多窗口竞争  
**Then**: 至多一条有效自评，k/due/计划一次变更；跨周期也不能同日第二次自评

**关联模块**:
- `lib/core/scheduling/idempotency_guard.dart`
- `lib/features/review/data/repositories/review_submission_repository.dart`

**测试用例**:
```dart
test('AC-07: 同题同日重复提交返回首次结果', () async {
  final questionId = 'q1';
  final learningDate = '2026-11-20';
  
  // 首次提交
  final result1 = await submitReview(
    questionId: questionId,
    result: ReviewResult.know,
  );
  expect(result1.isSuccess, true);
  
  // 重复提交
  final result2 = await submitReview(
    questionId: questionId,
    result: ReviewResult.fuzzy,  // 不同结果
  );
  
  expect(result2.isDuplicate, true);
  expect(result2.existingResult, ReviewResult.know);  // 返回首次
  
  // 数据库只有一条事件
  final events = await getEvents(questionId, learningDate);
  expect(events.length, 1);
  expect(events.first.result, ReviewResult.know);
});

test('AC-07: 跨周期也不能同日第二次自评', () async {
  final questionId = 'q1';
  final learningDate = '2026-11-20';
  
  // 首次自评（会了）
  await submitReview(questionId: questionId, result: ReviewResult.know);
  
  // 同日再错（新周期）
  await markAsMistakeAgain(questionId: questionId);
  
  // 尝试在新周期自评 → 应该被拒绝
  final result = await submitReview(
    questionId: questionId,
    result: ReviewResult.know,
  );
  
  expect(result.isDuplicate, true);
  expect(result.reason, contains('当天不可再排期自评'));
});
```

**验收证据**: ❌ 未实现

---

## AC-08 ｜ 跨日与目标次日生效
**Given**: 30题到期、N=20  
**When**: 计划20题完成5题后跨日  
**Then**: 昨日5条留昨日，其余due不变，次日排序取20，全部积压可见。修改N次日才生效

**测试用例**:
```dart
test('AC-08: 昨日完成不记今日', () async {
  // Day 1: 计划20题，完成5题
  final day1 = '2026-11-20';
  final plan1 = await DailyPlanManager.getOrCreatePlan(
    learningDate: day1,
    db: db,
  );
  
  expect(plan1.questionIds.length, 20);
  
  // 完成5题
  for (int i = 0; i < 5; i++) {
    await submitReview(
      questionId: plan1.questionIds[i],
      result: ReviewResult.know,
    );
  }
  
  final updated1 = await DailyPlanManager.getPlan(day1, db);
  expect(updated1!.completedIds.length, 5);
  
  // Day 2: 新计划
  final day2 = '2026-11-21';
  final plan2 = await DailyPlanManager.getOrCreatePlan(
    learningDate: day2,
    db: db,
  );
  
  // 昨日完成题的due已变化，不在今日到期
  // 今日重新排序取20题
  expect(plan2.questionIds.length, 20);
  expect(plan2.completedIds, isEmpty);  // 今日尚未完成任何题
  
  // 昨日5条留在昨日
  expect(updated1.completedIds.length, 5);
});

test('AC-08: 修改N次日生效', () async {
  final day1 = '2026-11-20';
  
  // 今日N=20，建立计划
  await SettingsRepository.updateDailyTargetN(20);
  final plan1 = await DailyPlanManager.getOrCreatePlan(
    learningDate: day1,
    db: db,
  );
  expect(plan1.targetN, 20);
  
  // 修改N=30
  await SettingsRepository.updateDailyTargetN(30);
  
  // 今日计划不变（快照）
  final stillPlan1 = await DailyPlanManager.getPlan(day1, db);
  expect(stillPlan1!.targetN, 20);
  
  // 明日生效
  final day2 = '2026-11-21';
  final plan2 = await DailyPlanManager.getOrCreatePlan(
    learningDate: day2,
    db: db,
  );
  expect(plan2.targetN, 30);
});
```

**验收证据**: ❌ 未实现

---

## AC-09 ｜ 跨日旧卡原子检查
**Given**: 23:59旧卡且版本有效  
**When**: 次日00:01提交  
**Then**: 依新日原子检查/纳入计划/提交；新日计划不存在先预留旧卡后补足，容量满则需确认追加；未确认无事件，时区切换不改UTC+8口径

**测试用例**:
```dart
test('AC-09: 跨日旧卡新日重检并纳入', () async {
  // 昨日23:59加载卡片
  final oldDate = '2026-11-20';
  final card = await loadReviewCard(questionId: 'q1', date: oldDate);
  
  // 跨日到00:01
  // (测试中模拟时间前进)
  final newDate = '2026-11-21';
  
  // 提交
  final result = await submitCrossDayCard(
    card: card,
    newDate: newDate,
  );
  
  expect(result.isSuccess, true);
  
  // 新日计划中包含该题
  final plan = await DailyPlanManager.getPlan(newDate, db);
  expect(plan!.questionIds, contains('q1'));
  expect(plan.completedIds, contains('q1'));
});

test('AC-09: 新日计划不存在，优先预留旧卡', () async {
  final newDate = '2026-11-21';
  
  // 确保新日无计划
  final existing = await DailyPlanManager.getPlan(newDate, db);
  expect(existing, isNull);
  
  // 提交旧卡
  await submitCrossDayCard(card: oldCard, newDate: newDate);
  
  // 新日计划：优先包含旧卡，再补足到N
  final plan = await DailyPlanManager.getPlan(newDate, db);
  expect(plan!.questionIds.first, oldCard.questionId);
  expect(plan.questionIds.length, 20);  // 补足到N
});

test('AC-09: 容量满需确认追加', () async {
  final newDate = '2026-11-21';
  
  // 新日已有满计划（C=20, 20题）
  final fullPlan = await createFullPlan(newDate, db);
  
  // 旧卡不在计划中
  final oldCard = createCard(questionId: 'q-old');
  
  // 提交 → 需要确认
  final result = await submitCrossDayCard(
    card: oldCard,
    newDate: newDate,
  );
  
  expect(result.requiresConfirmation, true);
  expect(result.message, contains('追加1题'));
  
  // 取消 → 零写入
  await cancelCrossDaySubmission(oldCard);
  final events = await getEvents(oldCard.questionId, newDate);
  expect(events, isEmpty);
  
  // 确认追加 → C+1并提交
  final confirmed = await confirmAndSubmitCrossDayCard(
    card: oldCard,
    newDate: newDate,
  );
  expect(confirmed.isSuccess, true);
  
  final updatedPlan = await DailyPlanManager.getPlan(newDate, db);
  expect(updatedPlan!.capacityC, 21);  // C增加
});
```

**验收证据**: ❌ 未实现

---

## AC-10 ｜ 再次出错
**Given**: 已掌握题  
**When**: 再次出错  
**Then**: 新周期k0、due=明日；当天再错幂等，旧卡作废，不可当天再推进

**测试用例**:
```dart
test('AC-10: 再次出错新周期k0/明日', () async {
  final questionId = 'q1';
  final today = '2026-11-20';
  
  // 假设已掌握（k=4）
  final oldCycle = await getActiveCycle(questionId);
  expect(oldCycle.kLevel, 4);
  expect(oldCycle.state, LearningState.mastered);
  
  // 再次出错
  final result = await markAsMistakeAgain(questionId: questionId);
  
  expect(result.isSuccess, true);
  
  // 新周期
  final newCycle = await getActiveCycle(questionId);
  expect(newCycle.id, isNot(oldCycle.id));
  expect(newCycle.cycleNumber, oldCycle.cycleNumber + 1);
  expect(newCycle.kLevel, 0);
  expect(newCycle.dueDate, '2026-11-21');  // 明日
  
  // 旧周期关闭
  final closedCycle = await getCycle(oldCycle.id);
  expect(closedCycle.isActive, false);
});

test('AC-10: 同日再错幂等', () async {
  final questionId = 'q1';
  
  // 首次再错
  await markAsMistakeAgain(questionId: questionId);
  final cycle1 = await getActiveCycle(questionId);
  
  // 同日重复再错
  await markAsMistakeAgain(questionId: questionId);
  final cycle2 = await getActiveCycle(questionId);
  
  // 应是同一周期
  expect(cycle2.id, cycle1.id);
  expect(cycle2.cycleNumber, cycle1.cycleNumber);
});

test('AC-10: 当天不可再排期', () async {
  final questionId = 'q1';
  final today = '2026-11-20';
  
  // 再次出错
  await markAsMistakeAgain(questionId: questionId);
  
  // 尝试排期自评 → 应被拒绝
  final result = await submitReview(
    questionId: questionId,
    result: ReviewResult.know,
  );
  
  expect(result.isRejected, true);
  expect(result.reason, contains('当天不可再排期'));
});
```

**验收证据**: ❌ 未实现

---

## AC-11 ｜ 编辑保持排期
**Given**: 到期题  
**When**: 编辑标签或答案并保持进度  
**Then**: k/due不变；显式重学按再错规则；归档退出队列，取消后过期即到期

**测试用例**:
```dart
test('AC-11: 普通编辑保持k/due', () async {
  final question = await getQuestion('q1');
  final originalK = question.currentCycle.kLevel;
  final originalDue = question.currentCycle.dueDate;
  
  // 编辑标签
  await updateQuestion(
    questionId: question.id,
    tags: ['新标签'],
  );
  
  final updated = await getQuestion('q1');
  expect(updated.currentCycle.kLevel, originalK);
  expect(updated.currentCycle.dueDate, originalDue);
});

test('AC-11: 题干/答案变化提示重学', () async {
  final question = await getQuestion('q1');
  
  // 修改题干
  final result = await updateQuestion(
    questionId: question.id,
    questionText: '修改后的题干',
  );
  
  expect(result.suggestsReset, true);
  expect(result.message, contains('是否重学'));
  
  // 用户选择保持
  await confirmKeepProgress(question.id);
  final kept = await getQuestion('q1');
  expect(kept.currentCycle.kLevel, question.currentCycle.kLevel);
  
  // 用户选择重学
  await confirmResetProgress(question.id);
  final reset = await getQuestion('q1');
  expect(reset.currentCycle.kLevel, 0);
});

test('AC-11: 归档退出到期，取消后恢复', () async {
  final question = await getQuestion('q1');
  expect(question.currentCycle.dueDate, '2026-11-20');  // 到期
  
  final dueQuestions1 = await getDueQuestions('2026-11-20');
  expect(dueQuestions1, contains(question.id));
  
  // 归档
  await archiveQuestion(question.id);
  
  final dueQuestions2 = await getDueQuestions('2026-11-20');
  expect(dueQuestions2, isNot(contains(question.id)));  // 退出
  
  // 取消归档
  await unarchiveQuestion(question.id);
  
  final dueQuestions3 = await getDueQuestions('2026-11-20');
  expect(dueQuestions3, contains(question.id));  // 恢复
});
```

**验收证据**: ❌ 未实现

---

## AC-12 ｜ 回收站与30自然日
**Given**: 删除入回收站  
**When**: 删除日+30日前恢复  
**Then**: 状态/内容/历史/due恢复，已移除的计划身份不自动重建；达到第30自然日清理/永久删除不可恢复并清素材

**测试用例**:
```dart
test('AC-12: 删除进入回收站30天', () async {
  final questionId = 'q1';
  final deleteDate = DateTime(2026, 11, 18);
  
  await deleteQuestion(questionId: questionId, now: deleteDate);
  
  final question = await getQuestion(questionId);
  expect(question.deletedAt, deleteDate);
  
  // 计算过期日期（30自然日后）
  final expireDate = deleteDate.add(Duration(days: 30));
  expect(expireDate, DateTime(2026, 12, 18));
});

test('AC-12: 30天内恢复', () async {
  final questionId = 'q1';
  final deleteDate = DateTime(2026, 11, 18);
  
  await deleteQuestion(questionId: questionId, now: deleteDate);
  
  // 29天后恢复
  final restoreDate = DateTime(2026, 12, 17);
  await restoreQuestion(questionId: questionId, now: restoreDate);
  
  final question = await getQuestion(questionId);
  expect(question.deletedAt, isNull);
  expect(question.currentCycle.kLevel, isNotNull);  // 历史保留
});

test('AC-12: 30天后自动清理', () async {
  final questionId = 'q1';
  final deleteDate = DateTime(2026, 11, 18);
  
  await deleteQuestion(questionId: questionId, now: deleteDate);
  
  // 30天后打开应用
  final cleanDate = DateTime(2026, 12, 19);  // 18+30+1
  await cleanupExpiredRecycleBin(now: cleanDate);
  
  // 题目永久删除
  final question = await getQuestion(questionId);
  expect(question, isNull);
  
  // 素材也删除
  final images = await getImages(questionId);
  expect(images, isEmpty);
});

test('AC-12: 恢复不自动重建计划', () async {
  final questionId = 'q1';
  final today = '2026-11-20';
  
  // 删除前在今日计划中
  final plan1 = await DailyPlanManager.getPlan(today, db);
  expect(plan1!.questionIds, contains(questionId));
  
  // 删除
  await deleteQuestion(questionId: questionId);
  
  // 从计划移除
  final plan2 = await DailyPlanManager.getPlan(today, db);
  expect(plan2!.questionIds, isNot(contains(questionId)));
  
  // 恢复
  await restoreQuestion(questionId: questionId);
  
  // 计划身份不自动恢复
  final plan3 = await DailyPlanManager.getPlan(today, db);
  expect(plan3!.questionIds, isNot(contains(questionId)));
  
  // 需显式加入
  await addToPlan(questionId: questionId, date: today);
  final plan4 = await DailyPlanManager.getPlan(today, db);
  expect(plan4!.questionIds, contains(questionId));
});
```

**验收证据**: ❌ 未实现

---

## AC-13 ｜ 完整备份往返
**Given**: 含草稿/归档/回收站/图片/历史/日计划的数据  
**When**: 完整导出并在干净环境恢复  
**Then**: 校验与数量一致，历史不重放，同日日计划保留，跨日重建；过期回收站按事前告知清理

**测试用例**:
```dart
test('AC-13: 完整备份往返', () async {
  // 准备数据
  await setupTestData(
    questions: 10,
    drafts: 2,
    archived: 3,
    deleted: 2,
    images: 15,
  );
  
  // 导出
  final backup = await BackupManager.createBackup(db: db);
  expect(backup.isSuccess, true);
  
  final manifest = backup.manifest!;
  expect(manifest.questionCount, 15);  // 10+3+2
  expect(manifest.draftCount, 2);
  expect(manifest.imageCount, 15);
  
  // 在干净环境恢复
  final cleanDb = await createCleanDatabase();
  final restore = await RestoreManager.atomicRestore(
    snapshot: backup.snapshot!,
    db: cleanDb,
  );
  
  expect(restore.isSuccess, true);
  
  // 验证数量
  final restoredQuestions = await cleanDb.select(cleanDb.mistakeQuestions).get();
  expect(restoredQuestions.length, 15);
  
  final restoredDrafts = await cleanDb.select(cleanDb.drafts).get();
  expect(restoredDrafts.length, 2);
  
  final restoredImages = await cleanDb.select(cleanDb.images).get();
  expect(restoredImages.length, 15);
  
  // 验证内容一致性（抽查）
  final original = await getQuestion('q1', db: db);
  final restored = await getQuestion('q1', db: cleanDb);
  expect(restored.questionText, original.questionText);
  expect(restored.currentCycle.kLevel, original.currentCycle.kLevel);
});

test('AC-13: 历史不重放', () async {
  final backup = await BackupManager.createBackup(db: db);
  
  // 备份前事件数
  final originalEvents = await db.select(db.reviewEvents).get();
  final eventCount = originalEvents.length;
  
  // 恢复
  final cleanDb = await createCleanDatabase();
  await RestoreManager.atomicRestore(
    snapshot: backup.snapshot!,
    db: cleanDb,
  );
  
  // 恢复后事件数相同（没有重复）
  final restoredEvents = await cleanDb.select(cleanDb.reviewEvents).get();
  expect(restoredEvents.length, eventCount);
});

test('AC-13: 同日计划保留，跨日重建', () async {
  final backupDate = '2026-11-20';
  
  // 当日有计划
  await createPlanForDate(backupDate, db: db);
  
  // 同日恢复
  final backup1 = await BackupManager.createBackup(db: db);
  final cleanDb1 = await createCleanDatabase();
  await RestoreManager.atomicRestore(
    snapshot: backup1.snapshot!,
    db: cleanDb1,
    currentDate: backupDate,
  );
  
  // 同日计划保留
  final sameDayPlan = await DailyPlanManager.getPlan(backupDate, cleanDb1);
  expect(sameDayPlan, isNotNull);
  expect(sameDayPlan!.completedIds.length, greaterThan(0));
  
  // 跨日恢复
  final restoreDate = '2026-11-21';
  final cleanDb2 = await createCleanDatabase();
  await RestoreManager.atomicRestore(
    snapshot: backup1.snapshot!,
    db: cleanDb2,
    currentDate: restoreDate,
  );
  
  // 旧日计划保留历史
  final oldDayPlan = await DailyPlanManager.getPlan(backupDate, cleanDb2);
  expect(oldDayPlan, isNotNull);
  
  // 新日重建
  final newDayPlan = await DailyPlanManager.getPlan(restoreDate, cleanDb2);
  expect(newDayPlan, isNotNull);
  expect(newDayPlan!.completedIds, isEmpty);  // 新日尚未完成
});
```

**验收证据**: ❌ 未实现

---

## AC-14 ｜ 恢复失败保护
**Given**: 损坏/不兼容备份或空间不足  
**When**: 恢复/保存  
**Then**: 不破坏现有数据、不虚假成功、不更新最近备份时间；当前数据非空且快照失败/未确认必须停止，不允许绕过覆盖

**测试用例**:
```dart
test('AC-14: 损坏备份不破坏现有数据', () async {
  // 准备现有数据
  await setupTestData(questions: 5);
  final original = await db.select(db.mistakeQuestions).get();
  
  // 尝试恢复损坏备份
  final corruptedBackup = createCorruptedBackup();
  final result = await RestoreManager.atomicRestore(
    snapshot: corruptedBackup,
    db: db,
  );
  
  expect(result.isSuccess, false);
  expect(result.rollbackCompleted, true);
  
  // 现有数据完好
  final after = await db.select(db.mistakeQuestions).get();
  expect(after.length, original.length);
  expect(after.first.id, original.first.id);
});

test('AC-14: 空间不足停止', () async {
  // 模拟配额不足
  final quota = QuotaInfo.known(
    usageBytes: 900 * 1024 * 1024,  // 900MB
    quotaBytes: 1000 * 1024 * 1024,  // 1GB
    availableBytes: 100 * 1024 * 1024,  // 100MB
  );
  
  // 大备份需要200MB
  final largeBackup = createLargeBackup(sizeBytes: 200 * 1024 * 1024);
  
  // 预检应失败
  final preCheck = await RestoreManager.preCheckRestore(
    backupData: largeBackup.data,
    db: db,
    currentQuota: quota,
  );
  
  expect(preCheck.hasEnoughSpace, false);
  expect(preCheck.reason, contains('空间不足'));
  
  // 不允许绕过
  expect(preCheck.canProceedAnyway, false);
});

test('AC-14: 非空必须先快照', () async {
  // 当前数据非空
  await setupTestData(questions: 3);
  
  // 尝试恢复
  final backup = createBackup();
  final preCheck = await RestoreManager.preCheckRestore(
    backupData: backup.data,
    db: db,
  );
  
  // 应要求先快照
  expect(preCheck.requiresCurrentSnapshot, true);
  expect(preCheck.message, contains('请先确认当前最新快照'));
  
  // 无法继续
  expect(preCheck.canProceedToRestore, false);
});

test('AC-14: Web快照未确认必须停止', () async {
  // Web环境
  PlatformDetector.mockPlatform(isWeb: true);
  
  // 当前数据非空
  await setupTestData(questions: 3);
  
  // 生成快照
  final snapshot = await BackupManager.createBackup(db: db);
  
  // 发起下载但未读回确认
  final download = await BackupManager.confirmWebDownload(
    originalManifest: snapshot.manifest!,
    db: db,
  );
  
  expect(download.isDownloadInitiated, true);
  expect(download.isConfirmed, false);
  
  // 尝试恢复 → 应停止
  final backup = createBackup();
  final preCheck = await RestoreManager.preCheckRestore(
    backupData: backup.data,
    db: db,
  );
  
  expect(preCheck.canProceedToRestore, false);
  expect(preCheck.reason, contains('请重新选择已下载的快照文件进行确认'));
});
```

**验收证据**: ❌ 未实现

---

*(继续编写 AC-15 至 AC-26...)*

## 验收进度总览

| AC | 主题 | 状态 |
|----|------|------|
| AC-01 | 必填字段验证 | ❌ 未实现 |
| AC-02 | 图片处理与限制 | ❌ 未实现 |
| AC-03 | 回忆核验门槛 | ❌ 未实现 |
| AC-04 | k级别与间隔推进 | ❌ 未实现 |
| AC-05 | 模糊与不会 | ❌ 未实现 |
| AC-06 | 迟做与跳过 | ❌ 未实现 |
| AC-07 | 幂等性 | ❌ 未实现 |
| AC-08 | 跨日与目标次日生效 | ❌ 未实现 |
| AC-09 | 跨日旧卡原子检查 | ❌ 未实现 |
| AC-10 | 再次出错 | ❌ 未实现 |
| AC-11 | 编辑保持排期 | ❌ 未实现 |
| AC-12 | 回收站与30自然日 | ❌ 未实现 |
| AC-13 | 完整备份往返 | ❌ 未实现 |
| AC-14 | 恢复失败保护 | ❌ 未实现 |
| AC-15 | 统计口径 | ❌ 未实现 |
| AC-16 | Web离线准备 | ❌ 未实现 |
| AC-17 | 原子提交与草稿 | ❌ 未实现 |
| AC-18 | 容量补位 | ❌ 未实现 |
| AC-19 | 完成后再错 | ❌ 未实现 |
| AC-20 | 跳过不循环 | ❌ 未实现 |
| AC-21 | 手动练习 | ❌ 未实现 |
| AC-22 | 追加取消零写入 | ❌ 未实现 |
| AC-23 | Web读回确认 | ❌ 未实现 |
| AC-24 | 浏览器隔离 | ❌ 未实现 |
| AC-25 | 配额失败保护 | ❌ 未实现 |
| AC-26 | 删除恢复不自动入计划 | ❌ 未实现 |

**总计**: 0/26 通过

---

## 下一步

本矩阵将随实施进度更新，每个 AC 通过后：
1. 更新测试文件路径
2. 记录测试执行结果
3. 更新验收证据（通过/部分通过/阻塞原因）
4. 附加实际执行截图或日志（可行时）
