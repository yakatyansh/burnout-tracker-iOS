import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @ObservedObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            // Background Blur Effect
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack {
                Text("Welcome to Burnout Tracker")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .padding()
                        .background(GlassBackgroundView())
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        
                    SecureField("Password", text: $password)
                        .padding()
                        .background(GlassBackgroundView())
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
                .padding()
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Button(action: {
                    authManager.signInWithEmail(email: email, password: password) { result in
                        switch result {
                        case .success(_):
                            print("✅ Signed in successfully")
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                        }
                    }
                }) {
                    Text("Sign In")
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding()
                
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.white)
                    Button("Sign Up") {
                        authManager.signUpWithEmail(email: email, password: password) { result in
                            switch result {
                            case .success(_):
                                print("✅ Account created successfully")
                            case .failure(let error):
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                    .foregroundColor(.blue)
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                    .padding()
                
                GoogleSignInButton(action: {
                    authManager.signInWithGoogle()
                })
                .frame(height: 50)
                .cornerRadius(12)
                .padding()
            }
            .padding()
        }
    }
}

// Glassmorphic Background Effect
struct GlassBackgroundView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white.opacity(0.2))
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            .blur(radius: 2)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(authManager: AuthManager())
    }
}
