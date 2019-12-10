//
//  UntimedTapView.swift
//  Diadochokinetic Assess
//
//  Created by Collin on 12/1/19.
//  Copyright © 2019 Ballygorey Apps. All rights reserved.
//

import SwiftUI

struct UntimedTapView: View {
    @EnvironmentObject var timerSession : TimerSession
    var body: some View {
        ZStack {
          Color("background").edgesIgnoringSafeArea(.top)
        VStack {
            ZStack {

                Rectangle()
                    .frame(width: Screen.width * 0.8, height: Screen.height * 0.3)
                .foregroundColor(Color("RectangleBackground"))
                    .cornerRadius(15)
                VStack {
                    Text("\(timerSession.unTimedTaps) \(timerSession.unTimedTaps == 1 ? "tap" : "taps")")
                        .font(.custom("Nunito-Bold", size: 50))
                        .padding(.bottom)
                    Text(timerSession.getUntimedTimeString())
                        .font(.custom("Nunito-SemiBold", size: 22))
                }.frame(width: Screen.width * 0.8, height: 175)
                Handle().offset(CGSize(width: 0, height: 15))
            }.frame(width: Screen.width, height: Screen.height*0.3)//.padding(.bottom)
            
            HStack {
            
                Button(action: {
                    self.timerSession.stopUntimed()
                }) {
                    resetButton
                }
                Spacer()
                Button(action: {
                    self.timerSession.finishAndLogUntimed()
                }) {
                    logButton
                }
            }.frame(height: Screen.width*0.25).padding([.leading, .trailing], Screen.width * 0.09) 
            
            
            TapButton(timed: false).environmentObject(timerSession).padding(.top, -10)
            }
        }
    }
}

struct UntimedTapView_Previews: PreviewProvider {
    static var previews: some View {
        UntimedTapView()
    }
}
