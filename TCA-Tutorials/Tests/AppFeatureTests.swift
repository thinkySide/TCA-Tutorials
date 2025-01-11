//
//  AppFeatureTests.swift
//  Tests
//
//  Created by 김민준 on 1/11/25.
//

import ComposableArchitecture
import Testing

@testable import TCA_Tutorials

@MainActor
struct AppFeatureTests {
    
    @Test
    func incrementInFirstTab() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }
        
        /// 여러 레이어의 기능을 통해 작업을 전송할 때 Key-Path 구문을 사용하기.
        await store.send(\.tab1.incrementButtonTapped) {
            $0.tab1.count = 1
        }
    }
}
