//
//  NumberFactClient.swift
//  TCA-Tutorials
//
//  Created by 김민준 on 1/11/25.
//

import ComposableArchitecture
import Foundation

/// 의존성을 추상화하는 인터페이스 모델링.
///
/// 프로토콜이 아닌 구조체를 이용한 인터페이스 모델링이다.
/// 프로토콜은 인터페이스를 추상화하는 가장 인기있는 방법이지만, 유일한 방법은 아니다.
/// 가변 속성이 없는 구조체를 사용한 다음 적합성을 나타내기 위한 구조체의 값을 구성하는 방법임!
struct NumberFactClient {
    
    /// 정수를 가져와 문자열을 반환하는 단일 비동기 함수
    var fetch: (Int) async throws -> String
}

/// 의존성을 등록하기 위한 적합성(프로토콜) 추가
extension NumberFactClient: DependencyKey {
    
    /// DependencyKey의 적합성 liveValue
    /// 이 값은 시뮬레이터와 기기에서 기능을 실행될 때 사용되는 값으로,
    /// 실제 네트워크 요청을 하기에 적합한 곳임.
    static let liveValue = Self(
        fetch: { number in
            let (data, _) = try await URLSession.shared
                .data(from: URL(string: "http://numbersapi.com/\(number)")!)
            return String(decoding: data, as: UTF8.self)
        }
    )
}

/// DependencyValie를 확장해 numberFact를 구문에서 사용할 수 있도록 추가
/// 의존성을 등록하는 것은 SwiftUI의 Environment 값을 등록하는 것과 다르지 않다.
extension DependencyValues {
    var numberFact: NumberFactClient {
        get { self[NumberFactClient.self] }
        set { self[NumberFactClient.self] = newValue }
    }
}
