//
//  CounterFeature.swift
//  TCA-Tutorials
//
//  Created by 김민준 on 1/11/25.
//

import ComposableArchitecture

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
    }
    
    /// Feature에서 수행할 모든 작업을 보관하는 Action
    /// Action 케이스의 이름은 논리를 나타내는 것보다
    /// UI에서 수행하는 작업 그대로 나타내는 것을 권장함.
    enum Action {
        case decrementButtonTapped
        case incrementButtonTapped
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
                return .none
                
            case .incrementButtonTapped:
                state.count += 1
                return .none
            }
        }
    }
}
