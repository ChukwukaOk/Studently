import SwiftUI

// MARK: - Splash Screen
struct SplashScreen: View {
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var gradientRotation: Double = 0
    @State private var bubbleOffsets: [CGSize] = Array(repeating: .zero, count: 6)

    var body: some View {
        ZStack {
            // Animated gradient background
            AngularGradient(
                colors: [
                    Color(hex: "6C63FF"),
                    Color(hex: "4ECDC4"),
                    Color(hex: "6C63FF"),
                ],
                center: .center,
                angle: .degrees(gradientRotation)
            )
            .ignoresSafeArea()
            .blur(radius: 60)
            .overlay(Color.black.opacity(0.15))

            // Floating bubbles
            ForEach(0..<6, id: \.self) { i in
                Circle()
                    .fill(.white.opacity(0.06))
                    .frame(width: CGFloat.random(in: 60...140))
                    .offset(bubbleOffsets[i])
            }

            // Logo
            VStack(spacing: 16) {
                // App Icon
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 110, height: 110)
                        .blur(radius: 1)

                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                // Bubble Text Logo
                BubbleText(text: "Studently")
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                Text("Your Money, Your Future")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.7))
                    .opacity(subtitleOpacity)
            }
        }
        .onAppear {
            // Animate bubbles
            for i in 0..<6 {
                let randomX = CGFloat.random(in: -150...150)
                let randomY = CGFloat.random(in: -300...300)
                bubbleOffsets[i] = CGSize(width: randomX - 30, height: randomY - 30)
                withAnimation(.easeInOut(duration: Double.random(in: 3...5)).repeatForever(autoreverses: true).delay(Double(i) * 0.2)) {
                    bubbleOffsets[i] = CGSize(width: randomX + 30, height: randomY + 30)
                }
            }

            // Gradient rotation
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                gradientRotation = 360
            }

            // Logo entrance
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.2)) {
                logoScale = 1.0
                logoOpacity = 1
            }

            withAnimation(.easeOut(duration: 0.5).delay(0.7)) {
                subtitleOpacity = 1
            }
        }
    }
}

// MARK: - Bubble Text (Studently Logo)
struct BubbleText: View {
    let text: String

    var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(text.enumerated()), id: \.offset) { index, char in
                BubbleLetter(letter: String(char), index: index)
            }
        }
    }
}

struct BubbleLetter: View {
    let letter: String
    let index: Int
    @State private var appeared = false

    private var letterColor: Color {
        let colors: [Color] = [
            Color(hex: "FF6B6B"),
            Color(hex: "FECA57"),
            Color(hex: "48DBFB"),
            Color(hex: "FF9FF3"),
            Color(hex: "54A0FF"),
            Color(hex: "5F27CD"),
            Color(hex: "01A3A4"),
            Color(hex: "F368E0"),
            Color(hex: "FF6348"),
        ]
        return colors[index % colors.count]
    }

    var body: some View {
        Text(letter)
            .font(.system(size: 40, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .shadow(color: letterColor.opacity(0.8), radius: 0, x: 2, y: 2)
            .shadow(color: letterColor.opacity(0.4), radius: 8, x: 0, y: 4)
            .scaleEffect(appeared ? 1 : 0)
            .rotationEffect(.degrees(appeared ? 0 : -20))
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5).delay(Double(index) * 0.05 + 0.3)) {
                    appeared = true
                }
            }
    }
}

// MARK: - Account Created Celebration
struct AccountCreatedCelebration: View {
    @State private var ringScale: CGFloat = 0
    @State private var checkScale: CGFloat = 0
    @State private var textOpacity: Double = 0
    @State private var showConfetti = false
    @State private var buttonOpacity: Double = 0
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            AppTheme.primaryGradient
                .ignoresSafeArea()

            // Confetti
            ConfettiView(isActive: showConfetti)

            VStack(spacing: 32) {
                Spacer()

                // Success Ring
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.2), lineWidth: 4)
                        .frame(width: 140, height: 140)

                    Circle()
                        .trim(from: 0, to: ringScale)
                        .stroke(.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(-90))

                    Image(systemName: "checkmark")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundStyle(.white)
                        .scaleEffect(checkScale)
                }

                VStack(spacing: 12) {
                    Text("You're All Set!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Your Studently account is ready.\nLet's start building better\nfinancial habits!")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .opacity(textOpacity)

                Spacer()

                Button {
                    HapticManager.shared.impact(.medium)
                    onContinue()
                } label: {
                    HStack {
                        Text("Let's Go")
                            .font(.headline)
                        Image(systemName: "arrow.right")
                            .font(.headline)
                    }
                    .foregroundStyle(AppTheme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(BounceButtonStyle())
                .opacity(buttonOpacity)
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            // Ring draws in
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                ringScale = 1
            }

            // Checkmark bounces in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5).delay(0.8)) {
                checkScale = 1
            }

            // Confetti burst
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                showConfetti = true
                HapticManager.shared.notification(.success)
            }

            // Text fades in
            withAnimation(.easeOut(duration: 0.5).delay(1.2)) {
                textOpacity = 1
            }

            // Button appears
            withAnimation(.easeOut(duration: 0.4).delay(1.6)) {
                buttonOpacity = 1
            }
        }
    }
}
