# Transactions

An iOS app for browsing and editing bank transactions, built with SwiftUI.

## Features

- **Transaction list** — paginated, infinite-scrolling list of transactions with a jump-to-top button
- **Transaction detail** — view and edit a transaction's description and type, with a save confirmation
- **Live backend** — fetches data from a hosted transactions API

## Architecture

- **SwiftUI + `@Observable`** view models (`TransactionsListViewModel`, `TransactionDetailViewModel`) drive the UI with `async`/`await`
- **`TransactionsAPIServiceProtocol`** abstracts the network layer so views/view models can be tested against `MockTransactionsService` instead of hitting the real API
- **[Alamofire](https://github.com/Alamofire/Alamofire)** handles networking; `TransactionsAPIService` talks to the backend and decodes responses with a custom ISO 8601 `JSONDecoder`
- **[DesignSystem](https://github.com/malkashlomowithz/DesignSystemPackage)** (a remote Swift package) supplies shared UI components (`DSTransactionCell`, `DSFieldRow`, `DSDetailRow`, buttons, colors, fonts, etc.)

## Project structure

```
Transactions/
├── TransactionsApp.swift              # App entry point
├── Transaction.swift                  # Transaction model + decoding
├── TransactionsPage.swift             # Paginated response model
├── TransactionsAPIServiceProtocol.swift
├── TransactionsAPIService.swift       # Alamofire-backed API client
├── TransactionsListView.swift         # List screen
├── TransactionsListViewModel.swift
├── TransactionDetailView.swift        # Detail/edit screen
└── TransactionDetailViewModel.swift

TransactionsTests/                     # Unit tests + mocks/fixtures
```

## Requirements

- Xcode with iOS 26.5+ SDK
- Swift 5

## Getting started

1. Open `Transactions.xcodeproj` in Xcode.
2. Let Swift Package Manager resolve dependencies (Alamofire, DesignSystem).
3. Build and run the `Transactions` scheme on a simulator or device.

## Testing

Run the `TransactionsTests` target from Xcode or via:

```sh
xcodebuild test -project Transactions.xcodeproj -scheme Transactions -destination 'platform=iOS Simulator,name=iPhone 16'
```
