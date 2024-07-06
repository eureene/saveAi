import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthenticationViewModel()
    @State private var selectedTab = 0
    @State private var showCamera = false
    @State private var image: UIImage? = nil
    @State private var showModal = false
    @State private var selectedCategory: String? = nil
    @State private var showAddIncome = false
    @State private var categoriesData: [String: Double] = [:]
    @State private var productsData: [String: [String: (Double, Int)]] = [:]
    @State private var revenue: Double = 0.0
    @State private var balance: Double = 0.0
    @State private var depense: Double = 0.0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            LoginView(authViewModel: authViewModel, categoriesData: $categoriesData)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }.tag(0)
            
            CameraTab(showCamera: $showCamera, image: $image, selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "camera.fill")
                    Text("Camera")
                }.tag(1)
            
            DashboardView(showModal: $showModal, selectedCategory: $selectedCategory, showAddIncome: $showAddIncome, categoriesData: $categoriesData, revenue: $revenue, balance: $balance, depense: $depense)
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Cart")
                }.tag(2)
            
            profile()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }.tag(3)
            
        }
        .onChange(of: authViewModel.isLoggedIn) { isLoggedIn in
            selectedTab = isLoggedIn ? 0 : 1
        }
        .onChange(of: selectedTab) { tab in
            if tab == 2 || tab == 4 {
                fetchData()
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(image: $image, isShown: $showCamera)
        }
        .sheet(isPresented: $showModal) {
            if let category = selectedCategory {
                CategoryDetailView(category: category, products: productsData[category] ?? [:])
            }
        }
        .sheet(isPresented: $showAddIncome) {
            AddIncomeView(revenue: $revenue, balance: $balance, showAddIncome: $showAddIncome)
        }
        .onAppear {
            loadPersistedData()
            fetchData()
        }
    }
    
    func loadPersistedData() {
        if let savedRevenue = UserDefaults.standard.value(forKey: "revenue") as? Double {
            revenue = savedRevenue
        }
        if let savedBalance = UserDefaults.standard.value(forKey: "balance") as? Double {
            balance = savedBalance
        }
    }
    
    func fetchData() {
        guard let url = URL(string: "http://37.27.16.160:3600/k7Idp7qLsAVtL9MIBJcQJccylev1") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let fetchedData = try JSONDecoder().decode([Product].self, from: data)
                    processFetchedData(fetchedData)
                } catch {
                    print("Error decoding data: \(error)")
                }
            }
        }.resume()
    }
    
    func processFetchedData(_ data: [Product]) {
        var tempCategoriesData: [String: Double] = [:]
        var tempProductsData: [String: [String: (Double, Int)]] = [:]
        var totalDepense: Double = 0.0
        
        for product in data {
            let category = product.category
            let price = product.price
            
            totalDepense += price
            
            if tempCategoriesData[category] != nil {
                tempCategoriesData[category]! += price
            } else {
                tempCategoriesData[category] = price
            }
            
            if tempProductsData[category] != nil {
                if let productData = tempProductsData[category]![product.item] {
                    tempProductsData[category]![product.item] = (productData.0 + price, productData.1 + 1)
                } else {
                    tempProductsData[category]![product.item] = (price, 1)
                }
            } else {
                tempProductsData[category] = [product.item: (price, 1)]
            }
        }
        
        DispatchQueue.main.async {
            self.categoriesData = tempCategoriesData
            self.productsData = tempProductsData
            self.depense = totalDepense
            self.balance = self.revenue - self.depense
        }
    }
}


#Preview {
    ContentView()
}
