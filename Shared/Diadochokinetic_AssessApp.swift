//
//  Diadochokinetic_AssessApp.swift
//  Shared
//
//  Created by Collin Dunphy on 9/23/20.
//

import SwiftUI

@main
struct Diadochokinetic_AssessApp: App {
    
    /// Initial declaration and initiation of 'DDKModel'
    @StateObject private var ddk : DDKModel = DDKModel()
    
    
    /// Initial declaration and initiation of 'HeartRateAssessment'
    @StateObject private var timed : TimedAssessment = TimedAssessment()
    
    /// Initial declaration and initiation of 'HeartRateAssessment'
    @StateObject private var count : CountingAssessment = CountingAssessment()
    
    /// Initial declaration and initiation of 'HeartRateAssessment'
    @StateObject private var heartRate : HeartRateAssessment = HeartRateAssessment()
    
    
    /// Initial declaration and initiation of 'Store'
    @StateObject private var store : Store = Store()
        
    @ViewBuilder
    var contents : some View {
        if store.userAuthenticationStatus == .subscribed {
            ContentView()
        } else {
            #if os(macOS)
                ContentView()
            #else
            Onboarding()
            #endif
        }
    }
    
    var body: some Scene {
        WindowGroup {
            contents
                .environmentObject(ddk)
                .environmentObject(store)
                .environmentObject(timed)
                .environmentObject(count)
                .environmentObject(heartRate)
        }
    }
}
