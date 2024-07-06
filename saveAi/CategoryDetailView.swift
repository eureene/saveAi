import SwiftUI

struct CategoryDetailView: View {
    let category: String
    let products: [String: (Double, Int)]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(products.keys.sorted(), id: \.self) { product in
                    HStack {
                        Text("\(product) * \(products[product]!.1)")
                        Spacer()
                        Text("$\(products[product]!.0, specifier: "%.2f")")
                    }
                }
            }
            .navigationBarTitle(category)
        }
    }
}
