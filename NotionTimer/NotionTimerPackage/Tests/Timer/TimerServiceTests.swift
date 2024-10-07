import Testing
@testable import Timer

@Test func 集中時かつ手動休憩がtrueのとき、残り時間が0になると追加集中モードに移行すること() async throws {}

@Test func 集中時かつ手動休憩がfalseのとき、残り時間が0になると休憩に移行すること() async throws {}

@Test func 休憩時、残り時間が0になると集中に移行すること() async throws {}
