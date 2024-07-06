import SwiftUI

struct AddIncomeView: View {
    @Binding var revenue: Double
    @Binding var balance: Double
    @Binding var showAddIncome: Bool
    @State private var newIncome: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Ajoute ton budget", text: $newIncome)
                    .keyboardType(.decimalPad)
                    .padding()
                
                Button(action: {
                    if let income = Double(newIncome) {
                        revenue += income
                        balance += income
                        UserDefaults.standard.set(revenue, forKey: "revenue")
                        UserDefaults.standard.set(balance, forKey: "balance")
                        showAddIncome = false
                    }
                }) {
                    Text("Ajoute budget")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("Ajoute Budget", displayMode: .inline)
        }
    }
}
