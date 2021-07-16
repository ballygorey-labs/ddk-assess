//
//  SKStore.swift
//  Diadochokinetic Assess
//
//  Created by Collin Dunphy on 9/23/20.
//

import Foundation
import SwiftUI
import StoreKit

typealias FetchCompletionHandler = (([SKProduct]) -> Void)
typealias PurchaseCompletionHandler = ((SKPaymentTransaction?) -> Void)

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
// MARK: - Store

class Store : NSObject, ObservableObject {
    
    var isSupporter : Bool {
        return !completedPurchases.isEmpty
    }
    
    @Published var productOptions : [SKProduct] = []
    
    private let allProductIdentifiers = Set([Store.donateDonutIdentifier, donateSmoothieIdentifier, donateLunchIdentifier])
    
    
    @AppStorage("completed_purchases") private var completedPurchases : [String] = [] { didSet { print("Setting completed Purchases") } }
    
    private var fetchedProducts : [SKProduct] = []
    private var productsRequest: SKProductsRequest?
    private var fetchCompletionHandler: FetchCompletionHandler?
    private var purchaseCompletionHandler: PurchaseCompletionHandler?
    
    override init() {
        super.init()
        startObservingPaymentQueue()
                
        fetchProducts { [weak self] products in
            guard let self = self else { return }
            self.productOptions = products
            print("\(products)")
//            self.unlockAllRecipesProduct = products.first(where: { $0.productIdentifier == Store.unlockAllRecipesIdentifier })
        }
    }

}

// MARK: - Store API

extension Store {
    static let donateDonutIdentifier: String = "com.Ballygorey.Diadochokinetic_Assess.SupportTheDev"
    static let donateLunchIdentifier = "com.Ballygorey.Diadochokinetic_Assess.SupportTheDev3"
    static let donateSmoothieIdentifier = "com.Ballygorey.Diadochokinetic_Assess.SupportTheDev2"

    
    static func getEmoji(id: String) -> String {
        switch id {
        case Store.donateDonutIdentifier:
            return "🍩"
        case Store.donateSmoothieIdentifier:
            return "🍹"
        case Store.donateLunchIdentifier:
            return "🍔🍟"
        default:
            return ""
        }
    }
    
    func product(for identifier: String) -> SKProduct? {
        return fetchedProducts.first(where: { $0.productIdentifier == identifier })
    }

    func purchaseProduct(_ product: SKProduct) {
        startObservingPaymentQueue()
        buy(product) { [weak self] transaction in
            guard let self = self,
                  let transaction = transaction else {
                return
            }

            // If the purchase was successful and it was for the premium recipes identifiers
            // then publish the unlock change
//            if transaction.payment.productIdentifier == Store.unlockAllRecipesIdentifier,
//               transaction.transactionState == .purchased {
//                self.unlockedAllRecipes = true
//            }
        }
    }
    
    func restoreProducts() {
        print("Restoring products ...")
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: - Private Logic

extension Store {
    private func buy(_ product: SKProduct, completion: @escaping PurchaseCompletionHandler) {
        // Save our completion handler for later
        purchaseCompletionHandler = completion
        
        // Create the payment and add it to the queue
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    private func hasPurchasedIAP(_ identifier: String) -> Bool {
        completedPurchases.contains(identifier)
    }
    
    private func fetchProducts(_ completion: @escaping FetchCompletionHandler) {
        guard self.productsRequest == nil else {
            return
        }
        // Store our completion handler for later
        fetchCompletionHandler = completion
        
        // Create and start this product request
        productsRequest = SKProductsRequest(productIdentifiers: allProductIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
    
    
    private func startObservingPaymentQueue() {
        SKPaymentQueue.default().add(self)
    }
}

// MARK: - SKPAymentTransactionObserver

extension Store: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Starting Payment Queue")
        for transaction in transactions {
            var shouldFinishTransaction = false
            switch transaction.transactionState {
            case .purchased, .restored:
                print("Adding to purchase array")
                completedPurchases.append(transaction.payment.productIdentifier)
                shouldFinishTransaction = true
            case .failed:
                shouldFinishTransaction = true
            case .purchasing, .deferred:
                break
            @unknown default:
                break
            }
            if shouldFinishTransaction {
                SKPaymentQueue.default().finishTransaction(transaction)
                DispatchQueue.main.async {
                    self.purchaseCompletionHandler?(transaction)
                    self.purchaseCompletionHandler = nil
                }
            }
        }
    }
    
//    func paymentQueue(_ queue: SKPaymentQueue, didRevokeEntitlementsForProductIdentifiers productIdentifiers: [String]) {
//        completedPurchases.removeAll(where: { productIdentifiers.contains($0) })
//        DispatchQueue.main.async {
////            if productIdentifiers.contains(Store.unlockAllRecipesIdentifier) {
////                self.unlockedAllRecipes = false
////            }
//        }
//    }
}


// MARK: - SKProductsRequestDelegate

extension Store: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Did Receive Product Response")
        let loadedProducts = response.products
        let invalidProducts = response.invalidProductIdentifiers
        
        guard !loadedProducts.isEmpty else {
            var errorMessage = "Could not find any products."
            if !invalidProducts.isEmpty {
                errorMessage = "Invalid products: \(invalidProducts.joined(separator: ", "))"
            }
            print("\(errorMessage)")
            productsRequest = nil
            return
        }
        
        // Cache these for later use
        fetchedProducts = loadedProducts
    
        // Notify anyone waiting on the product load
        DispatchQueue.main.async {
            self.fetchCompletionHandler?(loadedProducts)
            
            // Clean up
            self.fetchCompletionHandler = nil
            self.productsRequest = nil
        }
    }
}
