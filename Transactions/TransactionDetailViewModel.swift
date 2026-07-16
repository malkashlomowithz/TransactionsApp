//
//  TransactionDetailViewModel.swift
//  Transactions
//
//  Created by Malky Shlomowitz on 15/07/2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class TransactionDetailViewModel {

    private(set) var transaction: Transaction?
    private(set) var isLoading = false
    private(set) var isSaving = false
    private(set) var errorMessage: String?
    private(set) var didSaveSuccessfully = false

    var editedDescription = ""
    var editedTransferType: TransferType = .payment

    private let transactionId: String
    private let service: any TransactionsAPIServiceProtocol
    private let onUpdate: (Transaction) -> Void

    init(
        transactionId: String,
        service: any TransactionsAPIServiceProtocol,
        onUpdate: @escaping (Transaction) -> Void = { _ in }
    ) {
        self.transactionId = transactionId
        self.service = service
        self.onUpdate = onUpdate
    }

    var hasChanges: Bool {
        guard let transaction else { return false }
        return editedDescription != transaction.description
            || editedTransferType != transaction.transferType
    }

    func load() async {
        await perform(tracking: \.isLoading) {
            let transaction = try await self.service.fetchTransaction(id: self.transactionId)
            self.apply(transaction)
        }
    }

    func save() async {
        let update = TransactionUpdate(
            description: editedDescription,
            transferType: editedTransferType
        )

        await perform(tracking: \.isSaving) {
            let transaction = try await self.service.updateTransaction(id: self.transactionId, update)
            self.apply(transaction)
            self.didSaveSuccessfully = true
            self.onUpdate(transaction)
        }
    }

    func dismissSavedConfirmation() {
        didSaveSuccessfully = false
    }

    /// Runs `work` with the given progress flag set and `errorMessage` cleared,
    /// capturing any thrown error's description.
    private func perform(
        tracking progressFlag: ReferenceWritableKeyPath<TransactionDetailViewModel, Bool>,
        _ work: () async throws -> Void
    ) async {
        self[keyPath: progressFlag] = true
        errorMessage = nil
        defer { self[keyPath: progressFlag] = false }

        do {
            try await work()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func apply(_ transaction: Transaction) {
        self.transaction = transaction
        editedDescription = transaction.description
        editedTransferType = transaction.transferType
    }
}
