//
//  AboutDDK.swift
//  AboutDDK
//
//  Created by Collin Dunphy on 7/23/21.
//

import SwiftUI
import StoreKit

struct AboutDDK: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @ScaledMetric(wrappedValue: 35, relativeTo: .title3) var imageIconSize : CGFloat

    
    var body: some View {
        ScrollView {
            VStack {
                
                // App Information
                VStack {
                    Text("DDK")
                        .font(.system(size: 100, weight: .regular, design: .rounded))
                    Text("Version \(getAppCurrentVersionNumber())".capitalized)
                        .font(.system(.callout, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                // Description
                VStack {
                    Text("A simple, intuitive diagnostic tool that's designed by and built for Speech Language Pathologists (SLPs).")
                        .padding(.bottom, 4)
                    
                    Text("Made with love. ❤️")
                        .font(.headline)
                }
                .padding(.vertical)
                
                // Contact + People Ackknolegments
                VStack {
                    Divider()
                    
                    HStack {
                        Text("Collin Dunphy")
                        Spacer()
                        
                        // Contact Logos + Links
                        HStack {
                            Link(destination: URL(string: "https://www.instagram.com/collindunphy/")!) {
                                Image("instagram_logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: imageIconSize)
                            }
                            .padding(.trailing, 8)
                            
                            Link(destination: URL(string: "https://www.github.com/cpdunphy")!) {
                                Image("github_logo")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(colorScheme == .light ? .black : .white)
                                    .scaledToFit()
                                    .frame(width: imageIconSize)
                            }
                            
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Made in partnership with\n")
                            .foregroundColor(.secondary)
                        + Text("Kelly Lundis M.S. CCC-SLP")
                        
                    }.padding(.top)
                    
                    Text("&copy; 2025 Collin Dunphy")
                        .foregroundColor(.secondary)
                        .padding(.top)
                    
                }.padding(.vertical)
                
                
                
            }
            .multilineTextAlignment(.center)
            .scenePadding()
        }
        .navigationTitle("About")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
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
        return "\(getAppCurrentVersionNumber())"
    }
}

struct AboutDDK_Previews: PreviewProvider {
    static var previews: some View {
        AboutDDK()
    }
}
