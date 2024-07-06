import SwiftUI

struct DashboardView: View {
    @Binding var showModal: Bool
    @Binding var selectedCategory: String?
    @Binding var showAddIncome: Bool
    @Binding var categoriesData: [String: Double]
    @Binding var revenue: Double
    @Binding var balance: Double
    @Binding var depense: Double
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Text("BALANCE TOTAL")
                        .font(.headline)
                        .padding(.bottom, 5)
                    Text("$\(balance, specifier: "%.2f")")
                        .font(.largeTitle)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 1)
                .padding(.horizontal, 6)
                
                HStack {
                    VStack {
                        HStack {
                            Circle()
                                .fill(Color.green.opacity(0.2))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Image(systemName: "arrow.down")
                                        .foregroundColor(.green)
                                ).padding(.leading, 5).padding(.top, 5)
                            Spacer()
                            Text("BUDGET")
                                .font(.headline)
                                .padding(.trailing, 5)
                        }
                        Text("$\(revenue, specifier: "%.2f")")
                            .font(.title)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 1)
                    .padding(.horizontal, 6)
                    
                    VStack {
                        HStack {
                            Circle()
                                .fill(Color.red.opacity(0.2))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Image(systemName: "arrow.up")
                                        .foregroundColor(.red)
                                ).padding(.leading, 5).padding(.top, 5)
                            Spacer()
                            Text("DEPENSE")
                                .font(.headline)
                                .padding(.trailing, 5)
                        }
                        Text("$\(depense, specifier: "%.2f")")
                            .font(.title)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 1)
                    .padding(.horizontal, 6)
                }
                .padding(.vertical)
                
                List {
                    ForEach(categoriesData.keys.sorted(), id: \.self) { category in
                        Section(header: Text(category)) {
                            Button(action: {
                                selectedCategory = category
                                showModal.toggle()
                            }) {
                                HStack {
                                    Text(category)
                                    Spacer()
                                    Text("$\(categoriesData[category]!, specifier: "%.2f")")
                                }
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .navigationBarTitle("Dashboard")
                
                HStack {
                    Spacer()
                    Button(action: {
                        showAddIncome = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                            .font(.system(size: 56))
                            .foregroundColor(.blue)
                            .shadow(radius: 5)
                    }
                }
                .padding(.bottom)
                .padding(.trailing)
            }
        }
    }
}
