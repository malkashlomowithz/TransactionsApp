//
//  TransactionDetailView.swift
//  Transactions
//
//  Created by Malky Shlomowitz on 15/07/2026.
//

import DesignSystem
import SwiftUI

struct TransactionDetailView: View {

    private enum Field {
        case description
    }

    @State private var viewModel: TransactionDetailViewModel
    @FocusState private var focusedField: Field?

    init(
        transactionId: String,
        service: any TransactionsAPIServiceProtocol,
        onUpdate: @escaping (Transaction) -> Void = { _ in }
    ) {
        _viewModel = State(initialValue: TransactionDetailViewModel(
            transactionId: transactionId,
            service: service,
            onUpdate: onUpdate
        ))
    }

    var body: some View {
        ScrollView {
            Group {
                if viewModel.transaction != nil {
                    form
                } else if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 80)
                } else if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView(errorMessage, systemImage: "wifi.slash")
                }
            }
            .frame(maxWidth: .infinity)
        }
        .background(DSColors.lightGrey)
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Transaction")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button {
                    focusedField = nil
                } label: {
                    Label("Done", systemImage: "checkmark")
                }
            }
        }
        .task {
            await viewModel.load()
        }
        .overlay {
            if viewModel.didSaveSuccessfully {
                DSSuccessBadge(label: "Saved")
                    .transition(.scale.combined(with: .opacity))
                    .task {
                        try? await Task.sleep(for: .seconds(2))
                        viewModel.dismissSavedConfirmation()
                    }
            }
        }
        .animation(.bouncy, value: viewModel.didSaveSuccessfully)
    }

    private var form: some View {
        VStack(alignment: .leading, spacing: 20) {
            DSFieldRow(caption: "Description", editable: true) {
                TextField("Description", text: $viewModel.editedDescription)
                    .focused($focusedField, equals: .description)
                    .dsTextStyle(DSFonts.heading2Medium)
                    .foregroundStyle(DSColors.darkGrey)
            }

            DSDetailRow(
                caption: "Amount",
                title: viewModel.transaction?.amountString ?? ""
            )

            DSFieldRow(caption: "Type", editable: true) {
                Picker("Type", selection: $viewModel.editedTransferType) {
                    ForEach(TransferType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }

            DSDetailRow(
                caption: "Card",
                title: "****  ****  ****  " + (viewModel.transaction?.cardLastFour ?? "")
            )

            DSDetailRow(
                caption: "Last updated",
                title: viewModel.transaction?.updatedAt.formatted(date: .abbreviated, time: .shortened) ?? ""
            )

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .dsTextStyle(DSFonts.caption)
                    .foregroundStyle(.red)
            }

            Button("Save Changes") {
                Task { await viewModel.save() }
            }
            .buttonStyle(.dsPrimary)
            .disabled(viewModel.isSaving || !viewModel.hasChanges)
        }
        .padding(24)
    }

}

#Preview {
    NavigationStack {
        TransactionDetailView(transactionId: "preview", service: TransactionsAPIService())
    }
}
