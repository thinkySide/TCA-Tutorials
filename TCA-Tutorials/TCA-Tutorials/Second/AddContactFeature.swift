//
//  AddContactFeature.swift
//  TCA-Tutorials
//
//  Created by 김민준 on 1/12/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct AddContactFeature {
    
    @ObservableState
    struct State: Equatable {
        var contact: Contact
    }
    
    enum Action {
        case cancelButtonTapped
        case delegate(Delegate)
        case saveButtonTapped
        case setName(String)
        
        /// 자식 Feature가 부모에게 원하는 작업을 직접 알릴 수 있게 만들기
        /// 자식 피처가 직접 부모가 무엇을 하길 원하는지 정확히 설명할 수 있음!
        ///
        /// CasePathable: Delegate 작업이 수신되었을 때 추가로 assert 하기 위함.
        @CasePathable
        enum Delegate: Equatable {
            case saveContact(Contact)
        }
    }
    
    /// 자식이 부모와 직접 연결하지 않고도 스스로를 해제할 수 있게 함.
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .cancelButtonTapped:
                return .run { _ in
                    await self.dismiss()
                }
                
            case .delegate:
                return .none
                
            case .saveButtonTapped:
                return .run { [contact = state.contact] send in
                    /// 자식 기능이 부모 기능과 통신하기를 원할 때마다
                    /// 즉시 동기적으로 Delegate 작업을 보내는 Effect 반환
                    await send(.delegate(.saveContact(contact)))
                    await self.dismiss()
                }
                
            case let .setName(name):
                state.contact.name = name
                return .none
            }
        }
    }
}

// MARK: - View

struct AddContactView: View {
    
    @Bindable var store: StoreOf<AddContactFeature>
    
    var body: some View {
        Form {
            /// 바인딩 될 때 전송하려는 작업을 설명하기
            TextField("Name", text: $store.contact.name.sending(\.setName))
            
            Button("Save") {
                store.send(.saveButtonTapped)
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Cancel") {
                    store.send(.cancelButtonTapped)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let store = Store(
        initialState: AddContactFeature.State(
            contact: Contact(
                id: .init(),
                name: "Blob"
            )
        ),
        reducer: {
            AddContactFeature()
        }
    )
    
    return NavigationStack {
        AddContactView(store: store)
    }
}
