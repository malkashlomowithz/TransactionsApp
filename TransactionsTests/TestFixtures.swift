//
//  TestFixtures.swift
//  TransactionsTests
//

import Foundation
@testable import Transactions

extension Transaction {

    /// A fully-populated transaction with sensible defaults, so tests only
    /// spell out the fields they care about.
    static func make(
        id: String = "txn-1",
        description: String = "Coffee",
        amount: Decimal = 4.5,
        transferType: TransferType = .payment,
        cardLastFour: String = "4242",
        createdAt: Date = Date(timeIntervalSince1970: 1_750_000_000),
        updatedAt: Date = Date(timeIntervalSince1970: 1_750_000_000)
    ) -> Transaction {
        Transaction(
            id: id,
            transactionId: UUID(),
            description: description,
            amount: amount,
            transferType: transferType,
            cardLastFour: cardLastFour,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension TransactionsPage {

    static func make(
        items: [Transaction] = [],
        nextCursor: String? = nil,
        hasMore: Bool = false
    ) -> TransactionsPage {
        TransactionsPage(items: items, nextCursor: nextCursor, hasMore: hasMore)
    }
}
