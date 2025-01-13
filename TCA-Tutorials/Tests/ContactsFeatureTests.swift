//
//  ContactsFeatureTests.swift
//  Tests
//
//  Created by 김민준 on 1/13/25.
//

import ComposableArchitecture
import Foundation
import Testing

@testable import TCA_Tutorials

@MainActor
struct ContactsFeatureTests {
    
    @Test
    func addFlow() async {
        let store = TestStore(initialState: ContactsFeature.State()) {
            ContactsFeature()
        } withDependencies: {
            /// 0에서 시작해 순차적으로 증가하는 ID
            $0.uuid = .incrementing
        }
        
        await store.send(.addButtonTapped) {
            $0.destination = .addContact(
                AddContactFeature.State(
                    contact: Contact(id: UUID(0), name: "")
                )
            )
        }
        
        // await store.send(\.destination.addContact.setName, "Blob Jr.") {
        // $0.destination?.addContact?.contact.name = "Blob Jr."
        // }
        
        await store.send(\.destination.addContact.saveButtonTapped)
        
        await store.receive(
            \.destination.addContact.delegate.saveContact,
             Contact(id: UUID(0), name: "Blob Jr.")
        ) {
            $0.contacts = [
                Contact(id: UUID(0), name: "Blob Jr.")
            ]
        }
        
        await store.receive(\.destination.dismiss) {
            $0.destination = nil
        }
    }
    
    /// 비철저한 스타일의 테스트
    @Test
    func addFlowNonExhastive() async {
        let store = TestStore(initialState: ContactsFeature.State()) {
            ContactsFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        
        /// TestStore의 완전성 Off
        store.exhaustivity = .off
        
        /// 비철저한 테스트는 상태 변경에 대해 assertion 할 필요가 없음.
        await store.send(.addButtonTapped)
        await store.send(\.destination.addContact.setName, "Blob Jr.")
        await store.send(\.destination.addContact.saveButtonTapped)
        
        /// Effect에서 받은 Action 대기열을 지웁니다.
        await store.skipReceivedActions()
        
        store.assert {
            $0.contacts = [
                Contact(id: UUID(0), name: "Blob Jr.")
            ]
            $0.destination = nil
        }
    }
    
    @Test
    func deleteContact() async {
        let store = TestStore(
            initialState: ContactsFeature.State(
                contacts: [
                    Contact(id: UUID(0), name: "Blob"),
                    Contact(id: UUID(1), name: "Blob Jr."),
                ]
            )
        ) {
            ContactsFeature()
        }
        
        await store.send(.deleteButtonTapped(id: UUID(1))) {
            $0.destination = .alert(.deleteConfirmation(id: UUID(1)))
        }
        
        await store.send(.destination(.presented(.alert(.confirmDeletion(id: UUID(1)))))) {
            $0.contacts.remove(id: UUID(1))
            $0.destination = nil
        }
    }
}
