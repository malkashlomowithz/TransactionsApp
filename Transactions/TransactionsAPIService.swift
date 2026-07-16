//
//  TransactionsAPIService.swift
//  Transactions
//
//  Created by Malky Shlomowitz on 15/07/2026.
//

import Alamofire
import Foundation

struct TransactionsAPIService: TransactionsAPIServiceProtocol {

    private let baseURL = URL(string: "https://transactionsbackend-production.up.railway.app/transactions")!

    func fetchTransactions(after cursor: String?) async throws -> TransactionsPage {
        var parameters: [String: String] = [:]
        if let cursor {
            parameters["cursor"] = cursor
        }

        return try await AF.request(baseURL, parameters: parameters)
            .serializingDecodable(TransactionsPage.self, decoder: JSONDecoder.transactionsAPI)
            .value
    }

    func fetchTransaction(id: String) async throws -> Transaction {
        try await AF.request(baseURL.appendingPathComponent(id))
            .serializingDecodable(Transaction.self, decoder: JSONDecoder.transactionsAPI)
            .value
    }

    func updateTransaction(id: String, _ update: TransactionUpdate) async throws -> Transaction {
        try await AF.request(
            baseURL.appendingPathComponent(id),
            method: .put,
            parameters: update,
            encoder: JSONParameterEncoder.default
        )
        .serializingDecodable(Transaction.self, decoder: JSONDecoder.transactionsAPI)
        .value
    }
}
