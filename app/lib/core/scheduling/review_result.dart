/// 复习自评结果
enum ReviewResult {
  /// 不会（k归0，+1天）
  notKnow,

  /// 模糊（k保持，+1天）
  fuzzy,

  /// 会了（k递进，按级别+3/7/14天或清空）
  know,
}
