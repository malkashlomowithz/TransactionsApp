//
//  TransactionDetailViewModelTests.swift
//  TransactionsTests
//

import Foundation
import Testing
@testable import Transactions

@Suite("TransactionDetailViewModel")
@MainActor
struct TransactionDetailViewModelTests {

    private let service = MockTransactionsService()

    private func makeViewModel(
        onUpdate: @escaping (Transaction) -> Void = { _ in }
    ) -> TransactionDetailViewModel {
        TransactionDetailViewModel(transactionId: "txn-1", service: service, onUpdate: onUpdate)
    }

    @Test func loadPopulatesTransactionAndEditableFields() async {
        service.transactionResult = .success(.make(
            id: "txn-1",
            description: "Coffee",
            amount: 4.5,
            transferType: .payment,
            cardLastFour: "4242"
        ))
        let viewModel = makeViewModel()

        await viewModel.load()

        #expect(viewModel.transaction?.id == "txn-1")
        #expect(viewModel.editedDescription == "Coffee")
        #expect(viewModel.editedTransferType == .payment)
        #expect(service.requestedTransactionIds == ["txn-1"])
        #expect(!viewModel.isLoading)
    }

    @Test func loadFailureSurfacesError() async {
        service.transactionResult = .failure(StubError())
        let viewModel = makeViewModel()

        await viewModel.load()

        #expect(viewModel.transaction == nil)
        #expect(viewModel.errorMessage == "Something went wrong")
        #expect(!viewModel.isLoading)
    }

    @Test func hasChangesTracksEdits() async {
        service.transactionResult = .success(.make(description: "Coffee"))
        let viewModel = makeViewModel()
        await viewModel.load()

        #expect(!viewModel.hasChanges)

        viewModel.editedDescription = "Espresso"
        #expect(viewModel.hasChanges)

        viewModel.editedDescription = "Coffee"
        #expect(!viewModel.hasChanges)
    }

    @Test func saveSendsEditedFieldsAndNotifiesOnUpdate() async throws {
        service.transactionResult = .success(.make(id: "txn-1", description: "Coffee", amount: 4.5))
        service.updateResult = .success(.make(id: "txn-1", description: "Lunch", amount: 20))

        var updatedTransactions: [Transaction] = []
        let viewModel = makeViewModel { updatedTransactions.append($0) }
        await viewModel.load()

        viewModel.editedDescription = "Lunch"
        viewModel.editedTransferType = .transfer
        await viewModel.save()

        let received = try #require(service.receivedUpdates.first)
        #expect(received.id == "txn-1")
        #expect(received.update.description == "Lunch")
        #expect(received.update.transferType == .transfer)
        #expect(received.update.amount == nil)
        #expect(received.update.cardLastFour == nil)

        #expect(viewModel.didSaveSuccessfully)
        #expect(viewModel.transaction?.description == "Lunch")
        #expect(updatedTransactions.map(\.id) == ["txn-1"])
        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.isSaving)
    }

    @Test func saveFailureSurfacesError() async {
        service.transactionResult = .success(.make())
        service.updateResult = .failure(StubError())
        let viewModel = makeViewModel()
        await viewModel.load()
        viewModel.editedDescription = "Changed"

        await viewModel.save()

        #expect(viewModel.errorMessage == "Something went wrong")
        #expect(!viewModel.didSaveSuccessfully)
        #expect(!viewModel.isSaving)
    }

    @Test func dismissSavedConfirmationClearsFlag() async {
        service.transactionResult = .success(.make())
        service.updateResult = .success(.make())
        let viewModel = makeViewModel()
        await viewModel.load()
        await viewModel.save()
        #expect(viewModel.didSaveSuccessfully)

        viewModel.dismissSavedConfirmation()

        #expect(!viewModel.didSaveSuccessfully)
    }
}
