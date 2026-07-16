//
//  TransactionsListViewModelTests.swift
//  TransactionsTests
//

import Foundation
import Testing
@testable import Transactions

@Suite("TransactionsListViewModel")
@MainActor
struct TransactionsListViewModelTests {

    private let service = MockTransactionsService()
    private let viewModel: TransactionsListViewModel

    init() {
        viewModel = TransactionsListViewModel(service: service)
    }

    @Test func initialPageLoadsWithoutCursor() async {
        service.pageResults = [
            .success(.make(items: [.make(id: "1"), .make(id: "2")], nextCursor: "cursor-1", hasMore: true))
        ]

        await viewModel.loadInitialPage()

        #expect(viewModel.transactions.map(\.id) == ["1", "2"])
        #expect(service.requestedCursors == [nil])
        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.isLoading)
    }

    @Test func initialPageIsNotReloadedWhenTransactionsExist() async {
        service.pageResults = [
            .success(.make(items: [.make(id: "1")], hasMore: true)),
            .success(.make(items: [.make(id: "2")], hasMore: true)),
        ]

        await viewModel.loadInitialPage()
        await viewModel.loadInitialPage()

        #expect(viewModel.transactions.map(\.id) == ["1"])
        #expect(service.requestedCursors.count == 1)
    }

    @Test func nextPageAppendsAndPassesCursor() async {
        service.pageResults = [
            .success(.make(items: [.make(id: "1")], nextCursor: "cursor-1", hasMore: true)),
            .success(.make(items: [.make(id: "2")], nextCursor: nil, hasMore: false)),
        ]

        await viewModel.loadInitialPage()
        await viewModel.loadNextPage()

        #expect(viewModel.transactions.map(\.id) == ["1", "2"])
        #expect(service.requestedCursors == [nil, "cursor-1"])
    }

    @Test func pagingStopsOnLastPage() async {
        service.pageResults = [
            .success(.make(items: [.make(id: "1")], hasMore: false))
        ]

        await viewModel.loadInitialPage()
        await viewModel.loadNextPage()

        #expect(service.requestedCursors.count == 1)
        #expect(viewModel.transactions.map(\.id) == ["1"])
    }

    @Test func failureSurfacesErrorAndAllowsRetry() async {
        service.pageResults = [
            .failure(StubError()),
            .success(.make(items: [.make(id: "1")], hasMore: false)),
        ]

        await viewModel.loadInitialPage()

        #expect(viewModel.errorMessage == "Something went wrong")
        #expect(viewModel.transactions.isEmpty)
        #expect(!viewModel.isLoading)

        await viewModel.loadNextPage()

        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.transactions.map(\.id) == ["1"])
    }

    @Test func updateReplacesMatchingTransaction() async {
        service.pageResults = [
            .success(.make(items: [.make(id: "1", description: "Coffee"), .make(id: "2")], hasMore: false))
        ]
        await viewModel.loadInitialPage()

        viewModel.update(.make(id: "1", description: "Espresso"))

        #expect(viewModel.transactions.first?.description == "Espresso")
        #expect(viewModel.transactions.count == 2)
    }

    @Test func updateIgnoresUnknownTransaction() async {
        service.pageResults = [
            .success(.make(items: [.make(id: "1")], hasMore: false))
        ]
        await viewModel.loadInitialPage()

        viewModel.update(.make(id: "missing"))

        #expect(viewModel.transactions.map(\.id) == ["1"])
    }
}
