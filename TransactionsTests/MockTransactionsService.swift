//
//  MockTransactionsService.swift
//  TransactionsTests
//

import Foundation
@testable import Transactions

/// A scriptable stand-in for the real API service. Queue up results before
/// exercising a view model, then assert on the recorded calls afterwards.
@MainActor
final class MockTransactionsService: TransactionsAPIServiceProtocol {

    enum MockError: Error {
        case noStubbedResult
    }

    /// Results returned by `fetchTransactions(after:)`, consumed in FIFO order.
    var pageResults: [Result<TransactionsPage, any Error>] = []
    var transactionResult: Result<Transaction, any Error> = .failure(MockError.noStubbedResult)
    var updateResult: Result<Transaction, any Error> = .failure(MockError.noStubbedResult)

    private(set) var requestedCursors: [String?] = []
    private(set) var requestedTransactionIds: [String] = []
    private(set) var receivedUpdates: [(id: String, update: TransactionUpdate)] = []

    func fetchTransactions(after cursor: String?) async throws -> TransactionsPage {
        requestedCursors.append(cursor)
        guard !pageResults.isEmpty else { throw MockError.noStubbedResult }
        return try pageResults.removeFirst().get()
    }

    func fetchTransaction(id: String) async throws -> Transaction {
        requestedTransactionIds.append(id)
        return try transactionResult.get()
    }

    func updateTransaction(id: String, _ update: TransactionUpdate) async throws -> Transaction {
        receivedUpdates.append((id, update))
        return try updateResult.get()
    }
}

/// An error with a predictable message, for asserting error propagation.
struct StubError: LocalizedError {
    var errorDescription: String? { "Something went wrong" }
}
