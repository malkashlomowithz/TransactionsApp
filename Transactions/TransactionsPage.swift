//
//  TransactionsPage.swift
//  Transactions
//
//  Created by Malky Shlomowitz on 15/07/2026.
//

import Foundation

/// A single page of transactions returned by the transactions API.
nonisolated struct TransactionsPage: Decodable, Sendable {
    let items: [Transaction]
    let nextCursor: String?
    let hasMore: Bool
}
