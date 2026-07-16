//
//  TransactionsListViewModel.swift
//  Transactions
//
//  Created by Malky Shlomowitz on 15/07/2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class TransactionsListViewModel {

    private(set) var transactions: [Transaction] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private var nextCursor: String?
    private var hasMore = true
    private let service: any TransactionsAPIServiceProtocol

    init(service: any TransactionsAPIServiceProtocol) {
        self.service = service
    }

    func loadInitialPage() async {
        guard transactions.isEmpty else { return }
        await loadNextPage()
    }

    func loadNextPage() async {
        guard !isLoading, hasMore else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let page = try await service.fetchTransactions(after: nextCursor)
            transactions.append(contentsOf: page.items)
            print(transactions.count)
            nextCursor = page.nextCursor
            hasMore = page.hasMore
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func update(_ transaction: Transaction) {
        guard let index = transactions.firstIndex(where: { $0.id == transaction.id }) else { return }
        print(transaction)
        transactions[index] = transaction
    }
}
