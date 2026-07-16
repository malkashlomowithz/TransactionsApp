//
//  TransactionsAPIServiceProtocol.swift
//  Transactions
//
//  Created by Malky Shlomowitz on 15/07/2026.
//

import Foundation

/// Abstraction over the transactions API so consumers can be tested
/// with a mock implementation.
protocol TransactionsAPIServiceProtocol: Sendable {

    /// Fetches a page of transactions. Pass `nil` to fetch the first page;
    /// pass the previous page's `nextCursor` to fetch the one after it.
    func fetchTransactions(after cursor: String?) async throws -> TransactionsPage

    /// Fetches a single transaction by id.
    func fetchTransaction(id: String) async throws -> Transaction

    /// Updates a transaction's fields and returns the updated value.
    func updateTransaction(id: String, _ update: TransactionUpdate) async throws -> Transaction
}

extension TransactionsAPIServiceProtocol {

    func fetchTransactions() async throws -> TransactionsPage {
        try await fetchTransactions(after: nil)
    }
}

/// The mutable fields of a transaction, as sent to `updateTransaction`.
/// All fields are optional so callers can update just the ones that changed.
nonisolated struct TransactionUpdate: Encodable, Sendable {
    var description: String?
    var amount: Decimal?
    var transferType: TransferType?
    var cardLastFour: String?
    var updatedAt: Date?
}
