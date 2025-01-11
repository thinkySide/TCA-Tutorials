//
//  CounterFeatureTests.swift
//  Tests
//
//  Created by 김민준 on 1/11/25.
//

import ComposableArchitecture
import Testing

@testable import TCA_Tutorials

/// TCA의 테스트 도구는 비동기성을 활용하므로 사전에 테스트 메서드를 비동기로 만들 것이다.
/// 이 도구들이 주요 액터와 분리되어 있으므로 테스트 모음을 @MainActor로 만들 것.
@MainActor
struct CounterFeatureTests {
    
    /// 간단한 State를 변화하는 순수 함수 테스트
    @Test
    func basics() async {
        
        /// TestStore는 작업이 시스템에 전송될 때 기능의 동작이 어떻게 변경되는지 쉽게 확인할 수 있는 도구.
        /// 일반적인 Store를 만드는 방법과 동일하다.
        ///
        /// TestStore에 작업을 보낼때마다 해당 작업이 전송된 후 상태가 어떻게 변경되는지 정확히 설명해야 함.
        /// (안그러면 테스트 통과하지 못하게 되는 것)
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        }
        
        /// 각 액션을 보낸 후 State가 어떻게 바뀌었는지 얘기해줘야함.
        /// 후행 클로저 안에서 Action이 전송되기 전 State의 변경 가능한 버전을 받게 되고,
        /// 이를 직접 상태를 변경해줌으로써 테스트를 하는 것.
        await store.send(.incrementButtonTapped) {
            $0.count = 1
        }
        
        await store.send(.decrementButtonTapped) {
            $0.count = 0
        }
    }
    
    /// Effect 테스트(타이머)
    @Test
    func timer() async {
        
        /// 시간을 제어할 수 있도록 만드는 테스트 시계
        let clock = TestClock()
        
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        } withDependencies: { dependencyValues in
            /// 종속성을 재정의.
            dependencyValues.continuousClock = clock
        }
        
        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerRunning = true
            
            /// 여기까지만 해서 테스트를 돌려보면 Effect가 아직 실행중이라는 메시지로 테스트를 실패하게 됨.
            /// TestStore는 Effect를 포함해 전체 기능이 시간이 지남에 따라 어떻게 변화하는지 확실하게 얘기해줘야함.
        }
        
        /// 타이머 작업을 수신 후 count State가 1 증가할 것으로 예상하는 코드
        /// Action 열겨헝을 별도로 구분하기 위해 Key-Path 구문 사용
        ///
        /// TestStore는 액션을 일정 시간만 기다렸다 반환이 없으면 실패를 뱉게 되는데,
        /// 이 액션을 수신하기 위해 더 많은 시간을 기다리도록 만들 수 있는 것이 timeout 인자값.
        /// 명시적으로 n초 이상 기다리게 할 수 있다.
        /// 하지만 이는 테스트 시간을 더 길게 사용하게 만듬...
        /// 그래서 clock을 사용하는 것!
        /// 이러면 이제 테스트가 즉시 통과할 수 있게 된다.
        await clock.advance(by: .seconds(1)) /// advance: TestClock의 내부 시간을 지속 시간만큼 앞당기는 것.
        await store.receive(\.timerTick) {
            $0.count = 1
        }
        
        /// 이렇게 Effect를 종료하는 것까지 해줘야함.
        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerRunning = false
        }
    }
    
    @Test
    func numberFact() async {
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        } withDependencies: {
            /// 의존성을 재정의 함으로써, 서버 요청의 값을 하드 코딩된 문자열로 갈아끼워줄 수 있음.
            /// 이는 비동기 요청 또한 없기 때문에 아래에서도 서버 값을 기다려줄 필요가 없다.
            $0.numberFact.fetch = { "\($0) is a good number." }
        }
        
        await store.send(.factButtonTapped) {
            $0.isLoading = true
        }
        
        /// timeout 없이도 바로 테스트 결과 예측 가능!
        await store.receive(\.factResponse) {
            $0.isLoading = false
            $0.fact = "0 is a good number."
        }
    }
}
