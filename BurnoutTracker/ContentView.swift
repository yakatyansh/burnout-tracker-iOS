import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("HealthKit Integration")
                .font(.title)
                .padding()

            Button("Request HealthKit Access") {
                HealthKitManager.shared.requestAuthorization { success, error in
                    if success {
                        print("✅ HealthKit access granted")
                    } else {
                        print("❌ HealthKit access denied: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
            .padding()
        }
    }
}
