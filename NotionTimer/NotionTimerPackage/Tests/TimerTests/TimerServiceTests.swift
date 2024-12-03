import Testing
@testable import Timer

@MainActor
struct TimerServiceTests {
    func service(isManualBreakStartEnabled: Bool = true) -> TimerService {
        return .init(
            isManualBreakStartEnabled: isManualBreakStartEnabled,
            focusTimeSec: 0,
            breakTimeSec: 0
        )
    }
    
    @Test func 集中時かつ手動休憩がtrueのとき_残り時間が0になると追加集中モードに移行すること() {
        let service = service(isManualBreakStartEnabled: true)
        service.remainingTimeSec = 0
        service.tickInFocusMode()
        
        #expect(service.timerMode == .additionalFocusMode)
    }

    @Test func 集中時かつ手動休憩がfalseのとき_残り時間が0になると休憩に移行すること() async throws {
        let service = service(isManualBreakStartEnabled: false)
        service.remainingTimeSec = 0
        service.tickInFocusMode()
        #expect(service.timerMode == .breakMode)
    }
    
    @Test func 休憩時_残り時間が0になると集中に移行すること() async throws {
        let service = service()
        service.remainingTimeSec = 0
        service.tickInBreakMode()
        
        #expect(service.timerMode == .focusMode)
    }
}
