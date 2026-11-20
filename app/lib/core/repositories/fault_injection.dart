/// 故障注入点（仅用于测试）
///
/// 不对用户暴露，仅在测试中使用
class FaultInjection {
  /// 事件写入后故障
  void Function()? afterEventInsert;

  /// 周期更新后故障
  void Function()? afterCycleUpdate;

  /// 计划更新后故障
  void Function()? afterPlanUpdate;

  /// 再错操作写入后故障
  void Function()? afterMistakeAgainInsert;

  /// 初始周期写入后故障（录入事务回滚测试）
  void Function()? afterInitialCycleInsert;

  /// 重置所有故障点
  void reset() {
    afterEventInsert = null;
    afterCycleUpdate = null;
    afterPlanUpdate = null;
    afterMistakeAgainInsert = null;
    afterInitialCycleInsert = null;
  }

  /// 触发事件写入后故障
  void triggerAfterEventInsert() {
    afterEventInsert?.call();
  }

  /// 触发周期更新后故障
  void triggerAfterCycleUpdate() {
    afterCycleUpdate?.call();
  }

  /// 触发计划更新后故障
  void triggerAfterPlanUpdate() {
    afterPlanUpdate?.call();
  }

  /// 触发再错操作写入后故障
  void triggerAfterMistakeAgainInsert() {
    afterMistakeAgainInsert?.call();
  }

  void triggerAfterInitialCycleInsert() {
    afterInitialCycleInsert?.call();
  }
}
