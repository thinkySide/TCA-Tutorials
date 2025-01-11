//
//  AppFeature.swift
//  TCA-Tutorials
//
//  Created by 김민준 on 1/11/25.
//

import ComposableArchitecture
import SwiftUI

struct AppView: View {
    
    /// 이렇게 2개의 Store를 만들 수 있겠지만, 이상적이지 않다.
    /// 서로 통신할 수 없는 두개의 고립된 Store가 생겼기 때문.
    /// 나중에 한 탭에서 발생하는 이벤트가 다른 탭에도 영향을 줄 수 있다...
    ///
    /// 이것이 TCA에서 여러 개의 분리된 Store를 갖기 보다,
    /// 기능을 함께 구성(Composable)하고, View를 단일 Store로 구동하는 것을 선호하는 이유.
    /// 이렇게 하면 기능이 서로 통신하기 쉬워지고, 제대로 작동하는지 테스트도 해볼 수 있다.
    // let store1: StoreOf<CounterFeature>
    // let store2: StoreOf<CounterFeature>
    
    /// 이렇게 AppFeature의 단일 Store를 유지하고 자식 Store를 파생시킬 수 있음.
    let store: StoreOf<AppFeature>
    
    var body: some View {
        TabView {
            /// Scrop 메서드를 사용해 tab1 도메인에만 Scope를 맞춘 자식 Store를 파생시킨다.
            /// 이는 Key-Path 구문을 사용해 열거형의 케이스를 선택해 수행됨.
            CounterView(store: store.scope(state: \.tab1, action: \.tab1))
                .tabItem {
                    Text("Counter 1")
                }
            
            CounterView(store: store.scope(state: \.tab2, action: \.tab2))
                .tabItem {
                    Text("Counter 2")
                }
        }
    }
}

#Preview {
    AppView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}

@Reducer
struct AppFeature {
    
    struct State: Equatable {
        var tab1 = CounterFeature.State()
        var tab2 = CounterFeature.State()
    }
    
    enum Action {
        case tab1(CounterFeature.Action)
        case tab2(CounterFeature.Action)
    }
    
    /// body 계산 속성은 ResultBuilder를 활용하고 있기 때문에,
    /// Reducer를 원하는 만큼 나열할 수 있다.
    ///
    /// 작업이 시스템에 들어오면 각 Reducer는 위에서 아래로 실행된다.
    /// 이는 SwiftUI의 View계층을 구성하는데 사용하는 것과 동일.
    var body: some ReducerOf<Self> {
        
        /// 1. 첫 번째 탭에서 실행되는 Counter Feature
        /// CounterFeature를 AppFeature로 구성하려면 Scrope Reducer를 활용할 수 있다.
        /// 부모 기능의 하위 도메인에 Scrop를 맞추고
        /// 해당 하위 도메인에서 자식 Reducer를 실행할 수 있음.
        Scope(state: \.tab1, action: \.tab1) {
            CounterFeature()
        }
        
        /// 2. 두 번째 탭에서 실행되는 Counter Feature
        Scope(state: \.tab2, action: \.tab2) {
            CounterFeature()
        }
        
        /// 3. 핵심 App Feature 로직
        Reduce { state, action in
            return .none
        }
    }
}
