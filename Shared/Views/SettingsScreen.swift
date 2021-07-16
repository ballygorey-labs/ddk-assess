//
//  Settings.swift
//  Diadochokinetic Assess
//
//  Created by Collin Dunphy on 9/29/20.
//

import SwiftUI

#if os(iOS)
import MessageUI
#endif

struct SettingsScreen: View {
    
    @EnvironmentObject var model : DDKModel
    @EnvironmentObject var store : Store
    
    @State private var showResetConfirmationAlert : Bool = false
    
    @AppStorage("countdown_length") var countdown : Int = 3
    @AppStorage("show_heartrate_stats") var heartrate : Bool = false
    @AppStorage("default_assessment_style") var defaultAssessmentType : AssessType = .timed
    @AppStorage("show_decimal_timer") var showDecimalOnTimer : Bool = true
    
    #if os(iOS)
    @State private var result: Result<MFMailComposeResult, Error>? = nil
    @State private var isShowingMailView : Bool = false
    #endif
    
    //TODO: This is a mess. Make it feel more uniform.
    
    var body: some View {
        Form {
            Section(header: Text("User preferences")) {
                Picker("Default Assessment Style", selection: $defaultAssessmentType) {
                    ForEach([AssessType.timed, AssessType.count], id: \.self) {
                        Text("\($0.label)")
                            .tag($0)
                    }
                }
                
                Stepper("Countdown Time: \(countdown) \(countdown == 1 ? "second" : "seconds")", value: $countdown, in: 0...60)

                Toggle("Show Decimal on Timer", isOn: $showDecimalOnTimer)
            }
            Section {
                Button {
                    showResetConfirmationAlert = true
                } label: {
                    Label("Reset Preferences", systemImage: "exclamationmark.arrow.circlepath")
                }.foregroundColor(.red)
            }
            
            #if os(iOS)
            Section {
                Button(action: {
                    self.isShowingMailView.toggle()
                }) {
                    FeedbackText()
                }.disabled(!MFMailComposeViewController.canSendMail())
            }
            
            Section(
                header: Text("Support"),
                footer: Button("Restore Purchases", action: store.restoreProducts)
            ) {
                if !store.productOptions.isEmpty {
                    ForEach(store.productOptions.sorted { $0.productIdentifier < $1.productIdentifier }, id: \.self) { product in
                        NavigationLink(destination: SupportTheDev(product: product)) {
                            Text("Buy the developer a \(product.localizedTitle) \(Store.getEmoji(id: product.productIdentifier))")
                                .foregroundColor(.accentColor)
                        }
                    }
                } else {
                    Text("No Support Options Currently Available")
                        .font(.footnote)
                }
            }
            #endif
            
            Section(header: Text(versionDescription())) {}
        }
        .navigationTitle("Settings")
        .alert(isPresented: $showResetConfirmationAlert) {
            resetAlert
        }
        .sheet(isPresented: $isShowingMailView) {
            MailView(result: $result, versionNumber: getAppCurrentVersionNumber())
        }
        
    }
    
    func getAppCurrentVersionNumber() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version: AnyObject? = dictionary["CFBundleShortVersionString"] as AnyObject?
        let build : AnyObject? = dictionary["CFBundleVersion"] as AnyObject?
        let versionStr = version as! String
        let buildStr = build as! String
        return "\(versionStr) (\(buildStr))"
    }
    
    func versionDescription() -> String {
        return "Made with ❤️ \(getAppCurrentVersionNumber())"
    }
    
    var resetAlert: Alert {
        Alert(
            title: Text("Reset Preferences"),
            message: Text("Are you sure you want to reset all preferences?"),
            primaryButton: .cancel(Text("Cancel")),
            secondaryButton: .destructive(Text("Reset"), action: resetPreferences)
        )
    }
    
    func resetPreferences() {
        countdown = 3
        model.currentlySelectedTimerLength = 10
        defaultAssessmentType = .timed
        heartrate = false
        showDecimalOnTimer = true
        model.resetTimed()
        model.resetCount()
    }

}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen()
    }
}


#if os(iOS)
struct FeedbackText :View {
    var disabled = !MFMailComposeViewController.canSendMail()
    var body : some View {
        HStack {
            Image(systemName: "paperplane.fill")
                .imageScale(.large)
                .foregroundColor(disabled ?
                    .secondary : .accentColor)
            
            VStack(alignment: .leading) {
                Text("Submit Feedback")
                Text("Help us improve the app.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }.padding(.leading)
            
        }.padding()
    }
}
#endif



