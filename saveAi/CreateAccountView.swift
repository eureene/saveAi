//
//  CreateAccountView.swift
//  saveAi
//
//  Created by Mohamet amine Ndiaye on 05/06/2024.
//

import SwiftUI
import FirebaseAuth

struct CreateAccountView: View {
    @Binding var showCreateAccountView: Bool // Add a binding to control the sheet

    @State private var email = ""
    @State private var password = ""
    @State private var repeatPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            Spacer()
            VStack{
                // Profile Image
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.gray)
                
            }.padding(.bottom, 50)
            
            // Create Account Form
            VStack(alignment: .leading, spacing: 15) {
                Text("Creer compte")
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
                
                SecureField("Repeter mot de passe", text: $repeatPassword)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5.0)
                
                Button(action: {
                    // Handle create account action
                    showCreateAccountView = false // Dismiss the sheet after creating an account
                    if password == repeatPassword {
                        Auth.auth().createUser(withEmail: email, password: password) { _, error in
                            if let error = error {
                                showError = true
                                errorMessage = error.localizedDescription
                            } else {
                                // Navigate to the login view or perform any other action
                            }
                        }
                    } else {
                        showError = true
                        errorMessage = "Passwords do not match."
                    }
                }) {
                    Text("Creer compte")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(5.0)
                }.padding(.top, 10)
            }
            .padding(.horizontal, 30)

            Spacer()
            
        }
        .background(Color.gray.opacity(0.2))
        .edgesIgnoringSafeArea(.all)
    }
}

