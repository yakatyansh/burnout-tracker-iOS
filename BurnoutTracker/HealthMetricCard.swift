import SwiftUI

struct HealthMetricCard: View {
    var icon: String
    var title: String
    var value: String
    var unit: String
    var color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .padding()
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                HStack {
                    Text(value)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(unit)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            Spacer()
        }
        .padding()
        .background(GlassmorphicBackground())
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal, 20)
    }
}
