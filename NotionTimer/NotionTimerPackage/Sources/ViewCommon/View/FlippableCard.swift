//
//  FlippableCard.swift
//  NotionTimer
//
//  Created by Taichi on 2024/09/27.
//

import SwiftUI

public struct FlippableCard<Content: View>: View {
    let frontContent: Content
    let backContent: Content
    @State var frontDegree = 0.0
    @State var backDegree = -90.0
    @State var isFlipping = false

    let height: CGFloat
    let durationAndDelay: CGFloat = 0.2
    
    public init(
        frontDegree: Double = 0.0,
        backDegree: Double = 90.0,
        isFlipping: Bool = false,
        height: CGFloat = 350,
        @ViewBuilder frontContent: () -> Content,
        @ViewBuilder backContent: () -> Content
    ) {
        self.frontContent = frontContent()
        self.backContent = backContent()
        self.frontDegree = frontDegree
        self.backDegree = backDegree
        self.isFlipping = isFlipping
        self.height = height
    }

    public var body: some View {
        ZStack {
            CardBack(degree: $backDegree) {
                backContent
            }.frame(height: height)
            
            CardFront(degree: $frontDegree) {
                frontContent
            }.frame(height: height)
        }
        .onTapGesture {
            flipCard()
        }
    }

    func flipCard() {
        isFlipping = !isFlipping
        if isFlipping {
            withAnimation(.linear(duration: durationAndDelay)) {
                frontDegree = 90
            }
            withAnimation(.linear(duration: durationAndDelay).delay(durationAndDelay)) {
                backDegree = 0
            }
        } else {
            withAnimation(.linear(duration: durationAndDelay)) {
                backDegree = -90
            }
            withAnimation(.linear(duration: durationAndDelay).delay(durationAndDelay)) {
                frontDegree = 0
            }
        }
    }
}

#Preview {
    ZStack {
        Color(.mint)
        FlippableCard {
            Text("Front")
                .foregroundStyle(.white)
        } backContent: {
            Text("Back")
                .foregroundStyle(.white)
        }
    }
}

struct CardFront<Content: View>: View {
    @Binding var degree: Double
    @State private var opacity = 0.0
    private var animation: Animation {
        .linear
        .speed(0.4)
        .repeatForever(autoreverses: true)
    }
    let content: Content
    
    init(
        degree: Binding<Double>,
        @ViewBuilder content: () -> Content
    ) {
        self._degree = degree
        self.content = content()
    }

    var body: some View {
        ZStack {
            GlassmorphismRoundedRectangle()
            
            content

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("Tap!")
                        .foregroundStyle(.white)
                    Image(systemName: "circle.circle")
                        .foregroundStyle(.white)
                        .opacity(opacity)
                        .onAppear {
                            withAnimation(animation) {
                                opacity = 1.0
                            }
                        }
                }
                .padding()
                .shadow(radius: 5)
            }
        }
        .rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
    }
}

struct CardBack<Content: View>: View {
    @Binding var degree: Double
    @State private var opacity = 0.0
    private var animation: Animation {
        .linear
        .speed(0.5)
        .repeatForever(autoreverses: true)
    }
    let content: Content
    
    init(
        degree: Binding<Double>,
        @ViewBuilder content: () -> Content
    ) {
        self._degree = degree
        self.content = content()
    }

    var body: some View {
        ZStack {
            GlassmorphismRoundedRectangle()
            
            content
        }
        .rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
    }
}
