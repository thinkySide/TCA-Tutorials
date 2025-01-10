//
//  ContentView.swift
//  TCA-Tutorials
//
//  Created by 김민준 on 1/10/25.
//

import SwiftUI
import ComposableArchitecture

struct CounterView: View {
    
    /// Reducer에 대한 Store
    /// Store는 기능의 런타임을 나타낸다.
    /// 즉, 상태를 업데이트하기 위해 작업을 처리할 수 있는 객체.
    /// 효과를 실행하고 해당 효과에서 시스템으로 데이터를 다시 공급.
    ///
    /// store는 let으로 선언되어도 된다.
    /// store의 데이터 관찰은 ObservableState 매크로를 통해 자동으로 수행됨.
    let store: StoreOf<CounterFeature>
    
    var body: some View {
        VStack {
            /// Dynamic 멤버 조회를 통해 store에서 State 속성을 직접 읽을 수 있음.
            Text("\(store.count)")
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)
            HStack {
                Button("-") {
                    /// send 함수를 통해 store에 작업을 전송할 수 있음.
                    store.send(.decrementButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)
                
                Button("+") {
                    store.send(.incrementButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    
    /// Store는 기능을 시작할 초기 State와
    /// 기능을 구동하는 Reducer 후행 클로저로 구성할 수 있다.
    ///
    /// TCA의 장점
    /// 모든 기능의 논리와 동작이 Reducer에 포함되어 있기 때문에
    /// 완전히 다른 Reducer로 미리보기를 실행해
    /// 실행 방식을 변경할 수 있다.
    CounterView(
        store: Store(initialState: CounterFeature.State()) {
            /// Reducer를 주석 처리 하면
            /// Store에 상태 변형이나 효과를 수행하지 않는 Reducer가 제공된다.
            /// 이를 통해 로직이나 동작에 대해 걱정하지 않고 기능의 디자인을 미리 볼 수도 있음!
            CounterFeature()
        }
    )
}
