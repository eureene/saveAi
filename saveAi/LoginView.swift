import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    @State private var showCreateAccountView = false
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var shouldNavigate = false
    @Binding var categoriesData: [String: Double] // Binding to categories data
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                VStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 50)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Connecter")
                        .font(.title)
                        .bold()
                    
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(5.0)
                    
                    SecureField("Mot de passe", text: $password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(5.0)
                    
                    Button(action: {
                        Auth.auth().signIn(withEmail: email, password: password) { _, error in
                            if let error = error {
                                showError = true
                                errorMessage = error.localizedDescription
                            } else {
                                authViewModel.isLoggedIn = true
                                shouldNavigate = true
                            }
                        }
                    }) {
                        Text("Connexion")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(5.0)
                            .padding(.top, 10)
                    }
                    .alert(isPresented: $showError) {
                        Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                    }
                    
                    HStack {
                        Text("Mot de passe oublie")
                            .foregroundColor(.gray)
                            .padding(.leading, 5)
                        Spacer()
                        Button(action: {
                            showCreateAccountView = true
                        }) {
                            Text("Cree compte")
                                .foregroundColor(.blue)
                                .padding(.trailing, 5)
                        }
                    }
                    .padding(.top)
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                NavigationLink(destination: PieChartView(categoriesData: categoriesData)
                                .navigationBarBackButtonHidden(true)
                                .navigationBarHidden(true), isActive: $shouldNavigate) {
                    EmptyView()
                }
            }
            .background(Color.gray.opacity(0.2))
            .edgesIgnoringSafeArea(.all)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showCreateAccountView) {
            CreateAccountView(showCreateAccountView: $showCreateAccountView)
        }
    }
}
