//
//  TransactionDecodingTests.swift
//  TransactionsTests
//

import Foundation
import Testing
@testable import Transactions

@Suite("Transactions API decoding")
struct TransactionDecodingTests {

    private func transactionJSON(date: String = "2026-07-14T13:42:09.687+00:00") -> String {
        """
        {
            "_id": "abc123",
            "transactionId": "6F9B4F3E-8C2A-4D6B-9E1F-2A3B4C5D6E7F",
            "description": "Coffee",
            "amount": 12.5,
            "transferType": "payment",
            "cardLastFour": "4242",
            "createdAt": "\(date)",
            "updatedAt": "\(date)"
        }
        """
    }

    @Test func decodesTransactionWithFractionalSecondDates() throws {
        let dateString = "2026-07-14T13:42:09.687+00:00"
        let data = Data(transactionJSON(date: dateString).utf8)

        let transaction = try JSONDecoder.transactionsAPI.decode(Transaction.self, from: data)

        #expect(transaction.id == "abc123")
        #expect(transaction.description == "Coffee")
        #expect(transaction.amount == 12.5)
        #expect(transaction.transferType == .payment)
        #expect(transaction.cardLastFour == "4242")

        let expectedDate = try Date(
            dateString,
            strategy: Date.ISO8601FormatStyle(includingFractionalSeconds: true)
        )
        #expect(transaction.createdAt == expectedDate)
    }

    @Test func decodesTransactionWithWholeSecondDates() throws {
        let dateString = "2026-07-14T13:42:09Z"
        let data = Data(transactionJSON(date: dateString).utf8)

        let transaction = try JSONDecoder.transactionsAPI.decode(Transaction.self, from: data)

        let expectedDate = try Date(dateString, strategy: .iso8601)
        #expect(transaction.createdAt == expectedDate)
    }

    @Test func decodesPage() throws {
        let data = Data("""
        {
            "items": [\(transactionJSON())],
            "nextCursor": "cursor-1",
            "hasMore": true
        }
        """.utf8)

        let page = try JSONDecoder.transactionsAPI.decode(TransactionsPage.self, from: data)

        #expect(page.items.map(\.id) == ["abc123"])
        #expect(page.nextCursor == "cursor-1")
        #expect(page.hasMore)
    }
}
