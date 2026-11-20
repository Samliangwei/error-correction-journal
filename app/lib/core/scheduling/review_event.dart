/// 复习事件（记录每次有效自评）
library;

import 'learning_date.dart';
import 'review_result.dart';
import 'review_cycle.dart';

/// 复习事件
class ReviewEvent {
  final String questionId;
  final int cycleNumber; // 关联周期
  final LearningDate learningDate; // 学习日期
  final ReviewResult result;
  final KLevel kLevelBefore;
  final KLevel kLevelAfter;
  final LearningDate? dueDateAfter;

  const ReviewEvent({
    required this.questionId,
    required this.cycleNumber,
    required this.learningDate,
    required this.result,
    required this.kLevelBefore,
    required this.kLevelAfter,
    required this.dueDateAfter,
  });

  @override
  String toString() =>
      'ReviewEvent(q=$questionId, cycle=$cycleNumber, date=$learningDate, '
      'result=$result, k=$kLevelBefore->$kLevelAfter, due=$dueDateAfter)';
}
