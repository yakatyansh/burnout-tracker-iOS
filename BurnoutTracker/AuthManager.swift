import SwiftUI
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import FirebaseCore

class AuthManager: ObservableObject {
    @Published var isSignedIn = false
    
    init() {
        self.isSignedIn = Auth.auth().currentUser != nil
    }
    
    // Email & Password Sign Up
    func signUpWithEmail(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let user = authResult?.user {
                DispatchQueue.main.async {
                    self.isSignedIn = true
                }
                completion(.success(user))
            }
        }
    }

    // Email & Password Sign In
    func signInWithEmail(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let user = authResult?.user {
                DispatchQueue.main.async {
                    self.isSignedIn = true
                }
                completion(.success(user))
            }
        }
    }

    // Google Sign-In Function
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let rootViewController = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.windows.first?.rootViewController })
            .first else {
            print("❌ Error: No root view controller found")
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            if let error = error {
                print("❌ Google Sign-In failed: \(error.localizedDescription)")
                return
            }

            guard let user = signInResult?.user, let idToken = user.idToken?.tokenString else {
                print("❌ Error retrieving user or token")
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print("❌ Firebase Sign-In failed: \(error.localizedDescription)")
                    return
                }

                DispatchQueue.main.async {
                    self.isSignedIn = true
                }
                print("✅ Google Sign-In successful: \(result?.user.displayName ?? "No Name")")
            }
        }
    }

    // Logout function
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            DispatchQueue.main.async {
                self.isSignedIn = false
            }
        } catch {
            print("❌ Error signing out: \(error.localizedDescription)")
        }
    }
}
