//
//  FlippableCard.swift
//  NotionTimer
//
//  Created by Taichi on 2024/09/27.
//

import SwiftUI

struct CardFront: View {
    @Binding var degree: Double
    @State private var opacity = 0.0
    private var animation: Animation {
        .linear
        .speed(0.4)
        .repeatForever(autoreverses: true)
    }

    var body: some View {
        ZStack {
            GlassmorphismRoundedRectangle()

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

struct CardBack: View {
    @Binding var degree: Double
    @State private var opacity = 0.0
    private var animation: Animation {
        .linear
        .speed(0.5)
        .repeatForever(autoreverses: true)
    }

    var body: some View {
        ZStack {
            GlassmorphismRoundedRectangle()
        }
        .rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
    }
}

struct FlippableCard: View {
    @State var frontDegree = 0.0
    @State var backDegree = -90.0
    @State var isFlipping = false

    let height: CGFloat = 350
    let durationAndDelay: CGFloat = 0.2

    var body: some View {
        ZStack {
            CardBack(degree: $backDegree)
                .frame(height: height)
            CardFront(degree: $frontDegree)
                .frame(height: height)
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
        FlippableCard()
    }
}
