//
//  ContentView.swift
//  InstagramStoryTutorial
//
//  Created by 조종운 on 2020/05/10.
//  Copyright © 2020 조종운. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @ObservedObject var storyTimer: StoryTimer = StoryTimer(items: 4, interval: 3.0)
    var imageNames: [String] = ["Image1", "Image2", "Image4", "Image5"]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Image(self.imageNames[Int(self.storyTimer.progress)])
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: nil, alignment: .center)
                    .animation(.none)
            }
            
            HStack(alignment: .center, spacing: 4) {
                ForEach(self.imageNames.indices) { x in
                    LodingRectangle(progress: min(max(CGFloat(self.storyTimer.progress) - CGFloat(x), 0.0), 1.0))
                        .frame(width: nil, height: 2, alignment: .leading)
                        .animation(.linear)
                }
            }.padding()
        }
        .onAppear { self.storyTimer.start() }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct LodingRectangle: View {
    var progress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color.white.opacity(0.3))
                    .cornerRadius(5)
                
                Rectangle()
                    .frame(width: geometry.size.width * self.progress, height: nil, alignment: .leading)
                    .foregroundColor(Color.white.opacity(0.9))
                    .cornerRadius(5)
            }
        }
    }
}

class StoryTimer: ObservableObject {
    @Published var progress: Double
    
    private var interval: TimeInterval
    private var max: Int
    private let publisher: Timer.TimerPublisher
    private var cancellable: Cancellable?
    
    init(items: Int, interval: TimeInterval) {
        self.max = items
        self.progress = 0
        self.interval = interval
        self.publisher = Timer.publish(every: 0.1, on: .main, in: .default)
    }
    
    func start() {
        self.cancellable = self.publisher.autoconnect().sink(receiveValue: { _ in
            var newProgress = self.progress + (0.1 / self.interval)
            if Int(newProgress) >= self.max { newProgress = 0 }
            self.progress = newProgress
        })
    }
}

