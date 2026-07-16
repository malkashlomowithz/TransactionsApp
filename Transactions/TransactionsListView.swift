//
//  TransactionsListView.swift
//  Transactions
//
//  Created by Malky Shlomowitz on 15/07/2026.
//

import DesignSystem
import SwiftUI

struct TransactionsListView: View {

    let service: any TransactionsAPIServiceProtocol
    @State private var viewModel: TransactionsListViewModel

    init(service: any TransactionsAPIServiceProtocol) {
        self.service = service
        _viewModel = State(initialValue: TransactionsListViewModel(service: service))
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                List {
                    ForEach(viewModel.transactions) { transaction in
                        NavigationLink(value: transaction.id) {
                            DSTransactionCell(transaction: transaction)
                        }
                        .id(transaction.id)
                        .listRowSeparator(.hidden)
                        .listRowBackground(DSColors.lightGrey)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .onAppear {
                            if transaction.id == viewModel.transactions.last?.id {
                                Task { await viewModel.loadNextPage() }
                            }
                        }
                    }

                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(DSColors.lightGrey)
                .navigationTitle("Transactions")
                .navigationDestination(for: String.self) { transactionId in
                    TransactionDetailView(transactionId: transactionId, service: service) { transaction in
                        viewModel.update(transaction)
                    }
                }
                .task {
                    await viewModel.loadInitialPage()
                }
                .overlay {
                    if let errorMessage = viewModel.errorMessage, viewModel.transactions.isEmpty {
                        ContentUnavailableView(errorMessage, systemImage: "wifi.slash")
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    if !viewModel.transactions.isEmpty {
                        Button {
                            guard let firstId = viewModel.transactions.first?.id else { return }
                            withAnimation {
                                proxy.scrollTo(firstId, anchor: .top)
                            }
                        } label: {
                            Image(systemName: "chevron.up")
                                .frame(width: 60, height: 60)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.dsIconGrey)
                        .padding(13)
                    }
                }
            }
        }
    }
}

#Preview {
    TransactionsListView(service: TransactionsAPIService())
}
