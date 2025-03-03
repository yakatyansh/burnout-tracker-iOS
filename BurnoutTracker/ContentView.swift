import SwiftUI

struct ContentView: View {
    @StateObject private var healthKitManager = HealthKitManager.shared

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.7)]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 25) {
                // Title
                Text("Health Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(radius: 5)

                // Step Progress
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 20)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(healthKitManager.stepCount / 10000))
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.5))

                    VStack {
                        Text("\(Int(healthKitManager.stepCount))")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                        Text("Steps")
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .frame(width: 150, height: 150)

                // Live Heart Rate
                HealthMetricCard(icon: "heart.fill", title: "Heart Rate", value: "\(Int(healthKitManager.heartRate))", unit: "BPM", color: .red)

                // Calories Burned
                HealthMetricCard(icon: "flame.fill", title: "Calories Burned", value: "\(Int(healthKitManager.caloriesBurned))", unit: "kcal", color: .orange)

                Spacer()

                // Request Health Access
                Button(action: {
                    healthKitManager.requestAuthorization()
                }) {
                    Text("Grant Health Access")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(GlassmorphicBackground())
                        .cornerRadius(15)
                        .shadow(color: .white.opacity(0.2), radius: 10, x: 0, y: 4)
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 30)
            }
            .padding()
        }
        .onAppear {
            healthKitManager.startFetchingData()
        }
    }
}
