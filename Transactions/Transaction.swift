//
//  Transaction.swift
//  Transactions
//
//  Created by Malky Shlomowitz on 15/07/2026.
//

import Foundation
import DesignSystem

/// The kind of transaction. Raw values match the backend's `TRANSFER_TYPES`
/// strings, so the type decodes directly from API payloads.
nonisolated enum TransferType: String, Codable, CaseIterable, Sendable {
    case deposit
    case withdrawal
    case transfer
    case payment

    /// The SF Symbol shown in the transaction cell's icon circle.
    var systemImage: String {
        switch self {
        case .deposit: "arrow.down"
        case .withdrawal: "arrow.up"
        case .transfer: "arrow.left.arrow.right"
        case .payment: "creditcard.fill"
        }
    }
}

/// A transaction as returned by the API.
nonisolated struct Transaction: Codable, Identifiable, Sendable {

    let id: String
    let transactionId: UUID
    let description: String
    let amount: Decimal
    let transferType: TransferType
    let cardLastFour: String
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case transactionId
        case description
        case amount
        case transferType
        case cardLastFour
        case createdAt
        case updatedAt
    }
}

extension Transaction {

    /// The API returns all amounts in GBP.
    // TODO: Replace this hardcoded value with a `currencyCode` field decoded from the DB once the API provides it.
    static let currencyCode = "GBP"

    var amountString: String {
        amount.formatted(.currency(code: Self.currencyCode))
    }

    var dateString: String {
        createdAt.formatted(date: .abbreviated, time: .omitted)
    }
}

extension DSTransactionCell {

    init(transaction: Transaction) {
        self.init(
            transaction.description,
            subtitle: transaction.dateString,
            amount: transaction.amount,
            currencyCode: Transaction.currencyCode,
            systemImage: transaction.transferType.systemImage
        )
    }
}

extension JSONDecoder {

    /// A decoder configured for the transactions API, which sends ISO 8601
    /// dates with fractional seconds (e.g. `2026-07-14T13:42:09.687+00:00`).
    static var transactionsAPI: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let string = try decoder.singleValueContainer().decode(String.self)
            do {
                return try Date(string, strategy: Date.ISO8601FormatStyle(includingFractionalSeconds: true))
            } catch {
                return try Date(string, strategy: .iso8601)
            }
        }
        return decoder
    }
}
