//
//  CounterFeature.swift
//  TCA-Tutorials
//
//  Created by 김민준 on 1/11/25.
//

import ComposableArchitecture
import Foundation

/// Reducer 매크로? : Reducer 프로토콜에 맞게 타입을 확장해줌.
@Reducer
struct CounterFeature {
    
    /// 상태를 보관하는 State
    /// 기능을 관찰해야 하는 경우 ObservableState 매크로 추가해 줘야 함. (보통 그럼)
    /// Observable 프로토콜을 준수하게 됨.
    /// ObservableState는 @Observable의 TCA 버전으로 struct에 맞게 조정되어 있다고 함.
    @ObservableState
    struct State {
        var count = 0
        var fact: String?
        var isLoading = false
        var isTimerRunning = false
    }
    
    /// Feature에서 수행할 모든 작업을 보관하는 Action
    /// Action 케이스의 이름은 논리를 나타내는 것보다
    /// UI에서 수행하는 작업 그대로 나타내는 것을 권장함.
    enum Action {
        case decrementButtonTapped
        case factButtonTapped
        case factResponse(String)
        case incrementButtonTapped
        case timerTick
        case toggleTimerButtonTapped
    }
    
    /// Effect 취소
    enum CancelID {
        case timer
    }
    
    /// Reducer를 준수하려면 body 계산 속성을 꼭 구현해줘야 한다.
    var body: some ReducerOf<Self> {
        
        /// state는 inout으로 제공되기 때문에 직접 mutation을 수행할 수 있다.
        Reduce { state, action in
            switch action {
                
                /// 실행될 효과를 나타내는 Effect 값을 반환해야 하지만
                /// 이 경우에는 아무것도 실행할 필요가 없기 때문에 .none 반환
            case .decrementButtonTapped:
                state.count -= 1
                state.fact = nil
                return .none
                
            case .factButtonTapped:
                state.fact = nil
                state.isLoading = true
                
                /// 사이드 이펙트를 실행하는데 적합한 TCA의 도구, Effect
                ///
                /// Effect를 구성하는 기본 방법은 run 타입 함수를 사용하는 것.
                /// 이를 통해 원하는 모든 종류의 작업을 수행할 수 있는 비동기 컨텍스트와 작업을
                /// 시스템으로 다시 보내기 위한 핸들(send)를 제공합니다.
                return .run { [count = state.count] send in
                    let (data, _) = try await URLSession.shared
                        .data(from: URL(string: "http://numbersapi.com/\(count)")!)
                    let fact = String(decoding: data, as: UTF8.self)
                    
                    /// 이렇게 직접 내부 속성을 업데이트 할 수 없다.
                    /// sendable 클로저가 inout state를 캡처할 수 없기 때문에
                    /// 컴파일러에서 엄격하게 적용하는 것.
                    /// 이는 순수한 State의 변형과 지저분하고 복잡한 Effect를 분리하는 방법을 보여줌.
                    // state.fact = fact
                    
                    /// 이렇게 새로운 Action을 fact를 담아 보내줘야 함.
                    await send(.factResponse(fact))
                }
                
                /// Effect에서 Reducer로 정보를 다시 공급하기 위한 Action
            case let .factResponse(fact):
                state.fact = fact
                state.isLoading = false
                return .none
                
            case .incrementButtonTapped:
                state.count += 1
                state.fact = nil
                return .none
                
            case .timerTick:
                state.count += 1
                state.fact = nil
                return .none
                
            case .toggleTimerButtonTapped:
                state.isTimerRunning.toggle()
                if state.isTimerRunning {
                    return .run { send in
                        /// 1초마다 타이머 틱 작동
                        while true {
                            try await Task.sleep(for: .seconds(1))
                            await send(.timerTick)
                        }
                    }
                    /// Effect를 취소 가능하게 표시하게 해주는 것.
                    .cancellable(id: CancelID.timer)
                } else {
                    /// Effect를 취소 하는 방법
                    return .cancel(id: CancelID.timer)
                }
            }
        }
    }
}
