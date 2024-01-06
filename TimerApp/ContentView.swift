//
//  ContentView.swift
//  TimerApp
//
//  Created by Shwetangi Gurav on 05/01/24.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    @ObservedObject private var viewModel = TimerViewModel(timeInterval: 60)
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .opacity(0.3)
                    .foregroundColor(.gray)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(viewModel.timeRemaining / 60))
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.blue)
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.linear(duration: 0.01))
                
                Text(String(viewModel.formattedTimeText))
                    .font(.largeTitle)
            }
            .padding()
            
            Button(action: {
                viewModel.startPauseTimer()
            }) {
                Text(viewModel.isRunning ? "Pause" : "Start")
            }
            .padding()
            
            Button(action: {
                viewModel.stopTimer()
            }) {
                Text("Stop")
            }
            .padding()
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        }.onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
