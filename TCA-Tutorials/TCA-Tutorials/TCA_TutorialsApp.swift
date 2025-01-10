//
//  TCA_TutorialsApp.swift
//  TCA-Tutorials
//
//  Created by 김민준 on 1/10/25.
//

import SwiftUI
import ComposableArchitecture

@main
struct TCA_TutorialsApp: App {
    
    /// 애플리케이션을 구동하는 Store는 한 번만 만들어야 하기 때문에
    /// 대부분의 어플리케이션의 경우 Scene의 Root에서 직접 만들거나
    /// 타입 프로퍼티를 이용해 제공하는 방법을 활용할 수 있다.
    static let store = Store(initialState: CounterFeature.State()) {
        CounterFeature()
        /// Reducer가 처리하는 모든 작업을 콘솔에 프린트하고
        /// 작업을 처리한 후 상태가 어떻게 변경되었는지 프린트한다.
        /// 또한 상태 차이를 컴팩트하게 출력하기 위해 변경되지 않은 경우
        /// 중첩된 상태를 표시하지 않고, 변경되지 않은 컬렉션의 요소를 표시하지 않는다.
            ._printChanges()
    }
    
    var body: some Scene {
        WindowGroup {
            CounterView(store: TCA_TutorialsApp.store)
        }
    }
}
