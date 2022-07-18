//
//  OnboardingOptions.swift
//  Diadochokinetic Assess
//
//  Created by Collin Dunphy on 3/11/22.
//

import SwiftUI
import StoreKit

struct OnboardingOptions: View {
    
    @EnvironmentObject var store : Store
    
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedOption: Product?
    
    @Binding var errorTitle : String
    @Binding var isShowingError : Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    
                    // Options
                    ForEach(store.subscriptions) { product in
                        Button {
                            
                            withAnimation(.easeOut(duration: 0.15)) {
                                selectedOption = product
                            }
                            
                            print(product)
                            
                        } label: {
                            ProductOption(option: product, selection: $selectedOption)
                                .padding()
#if !os(macOS)
                                .background(
                                    Color(.secondarySystemGroupedBackground)
                                )
#endif
                                .cornerRadius(10.0)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10.0)
                                        .strokeBorder(
                                            selectedOption == product ? Color.accentColor : .clear,
                                            lineWidth: 1
                                        )
                                )
                                .shadow(color: .black.opacity(0.25), radius: 7, x: -2, y: 4)
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom)
                        
                    }
                    
                    // Checkout
                    checkoutButton
                    
                    // Reedeem Promo Code Button
                    redeemPromoCodeButton
                        .padding(.vertical, 6)
                    
                    
                    // Terms of Serivce & Privacy Policy
                    Text("[Terms of Service](https://ballygorey.com) and [Privacy Policy](https://ballygorey.com)")
                        .font(.subheadline)
                    
                }
                
                .scenePadding()
#if !os(macOS)
                .navigationBarTitleDisplayMode(.inline)
#endif
                .interactiveDismissDisabled()
                .onAppear(perform: setDefaultProductSelection)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel, action: { dismiss() })
                    }
                }
            }
#if !os(macOS)
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
#endif
        }
    }
    
    
    // Checkout Button
    var checkoutButton : some View {
        Button {
            guard let product : Product = selectedOption else { return }
            
            Task {
                await buy(product: product)
            }
        } label: {
            Text("Continue to Checkout \(Image(systemName: "chevron.forward"))")
                .padding(4)
        }
        #if !os(macOS)
        .buttonBorderShape(.capsule)
        #endif
        .buttonStyle(.borderedProminent)
    }
    
    var redeemPromoCodeButton : some View {
        Button(
            "Redeem Code",
            action: {
#if os(iOS)
                SKPaymentQueue.default().presentCodeRedemptionSheet()
#endif
            }
        )
    }
    
    func setDefaultProductSelection() {
        //TODO: Set the default product to the one that makes me the most money 🤑
    }
    
    
    func buy(product: Product) async {
        do {
            if try await store.purchase(product) != nil {
                //withAnimation {
                //isPurchased = true
                //}
            }
        } catch StoreError.failedVerification {
            errorTitle = "Your purchase could not be verified by the App Store."
            isShowingError = true
        } catch {
            print("Failed purchase for \(product.id): \(error)")
        }
    }
}

//struct OnboardingOptions_Previews: PreviewProvider {
//    static var previews: some View {
//        OnboardingOptions()
//    }
//}
