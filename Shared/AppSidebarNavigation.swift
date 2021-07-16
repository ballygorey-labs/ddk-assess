//
//  AppSidebarNavigation.swift
//  Diadochokinetic Assess
//
//  Created by Collin Dunphy on 9/24/20.
//

import SwiftUI

struct AppSidebarNavigation: View {

    @EnvironmentObject var model : DDKModel
    @EnvironmentObject var store : Store
    
    @State private var sidebarSelection : Set<NavigationItem> = [.assess]
    @State private var showSettingsModal : Bool = false

    var body: some View {
        NavigationView {
            #if os(macOS)
            /// Brings support to macOS, setting a limit on the extent to which it can expand/contract. Also adds a 'toggle to open/close the sidebar.
            HistoryScreen()
                .frame(minWidth: 100, idealWidth: 150, maxHeight: .infinity)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        sidebarToggleButton
                    }
                }
            #else
            HistoryScreen()
                .toolbar {
                    ToolbarItem(placement: ToolbarItemPlacement.bottomBar) {
                        if store.isSupporter {
                            Text("💜 DDK Supporter")
                        }
                    }
                }
                .sheet(isPresented: $showSettingsModal) {
                    SettingsModal()
                }
            #endif
            
            
            /// Applies a conditional modifier to devices not on macOS, setting the NavBar Display Mode to '.inline'
            #if os(macOS)
            AssessScreen()
            #else
            AssessScreen()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: ToolbarItemPlacement.navigationBarLeading) {
                        Button {
                            showSettingsModal = true
                        } label: {
                            Image(systemName: "gearshape")
                        }
                    }
                }
            #endif
        }
    }
    
    /// macOS Sidebar Toggle
    #if os(macOS)
    var sidebarToggleButton : some View {
        Button(action: toggleSidebar) {
            Image(systemName: "sidebar.left")
                .font(.title)
        }
    }
    
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
    #endif
    
    
    struct SettingsModal : View {
        @EnvironmentObject var model : DDKModel
        @EnvironmentObject var store : Store
        
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
            NavigationView {
                SettingsScreen()
                    .environmentObject(model)
                    .environmentObject(store)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        Button(
                            "Done",
                            action: { presentationMode.wrappedValue.dismiss() }
                        )
                    }
            }
        }
    }
}
