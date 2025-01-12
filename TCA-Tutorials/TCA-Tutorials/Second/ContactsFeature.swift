//
//  ContactsFeature.swift
//  TCA-Tutorials
//
//  Created by 김민준 on 1/12/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture

// MARK: - Entity

struct Contact: Equatable, Identifiable {
    let id: UUID
    var name: String
}

// MARK: - Reducer

@Reducer
struct ContactsFeature {
    
    @ObservableState
    struct State: Equatable {
        
        /// @Presents 매크로로 옵셔널 값을 유지(hold)함으로써 Feature의 State를 통합합니다.
        ///
        /// nil 값은 addContactFeature 기능이 제공되지 않는 것이고,
        /// 값이 있으면 제공됨을 나타낸다.
        @Presents var addContact: AddContactFeature.State?
        var contacts: IdentifiedArrayOf<Contact> = []
    }
    
    enum Action {
        case addButtonTapped
        
        /// Feature의 Action을 함께 통합
        /// 이를 통해 부모는 자식 기능에서 전송된 모든 동작을 관찰할 수 있게 됨.
        case addContact(PresentationAction<AddContactFeature.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.addContact = AddContactFeature.State(
                    contact: .init(id: .init(), name: "")
                )
                return .none
                
                /// AddContact의 contact값 빼오기
            case let .addContact(.presented(.delegate(.saveContact(contact)))):
                state.contacts.append(contact)
                return .none
                
            case .addContact:
                return .none
            }
        }
        /// ifLet Reducer 연산자를 활용해 Reducer를 통합
        ///
        /// 부모 State의 옵셔널 속성에 대해 작동하는 자식 Reducer를
        /// 부모 도메인에 내장한다.
        ///
        /// 자식 Action이 시스템에 들어오면 자식 Reducer를 실행하고,
        /// 모든 Action에서 부모 Reducer를 실행하는 새로운 Reducer가 생성됨.
        ///
        /// 또한 자식 Feature가 해제될 때 효과 취소를 자동으로 처리하고, 그 외 많은 작업을 처리함.
        .ifLet(\.$addContact, action: \.addContact) {
            AddContactFeature()
        }
    }
}

// MARK: - View

struct ContactsView: View {
    
    /// Store의 Binding을 만들어줌.
    @Bindable var store: StoreOf<ContactsFeature>
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.contacts) { contact in
                    Text(contact.name)
                }
            }
            .navigationTitle("Contacts")
            .toolbar {
                Button {
                    store.send(.addButtonTapped)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        /// addContact의 상태가 nil이 아니면
        /// AddContactFeature 도메인에만 Scope를 맞춘 새 Store가 생기고, 전달된다.
        .sheet(item: $store.scope(state: \.addContact, action: \.addContact)) { addContactStore in
            NavigationStack {
                AddContactView(store: addContactStore)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let store = Store(initialState: ContactsFeature.State(contacts: [
        Contact(id: .init(), name: "Blob"),
        Contact(id: .init(), name: "Blob Jr"),
        Contact(id: .init(), name: "Blob Sr")
    ])) {
        ContactsFeature()
    }
    
    return ContactsView(store: store)
}
