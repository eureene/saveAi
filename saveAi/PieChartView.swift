import SwiftUI

struct PieChartView: View {
    var categoriesData: [String: Double]
    @State private var categoriesColors: [String: Color] = [:]
    
    var body: some View {
        VStack {
            // Custom Pie Chart
            ZStack {
                ForEach(generatePieSlices(), id: \.startAngle) { slice in
                    PieSliceView(startAngle: slice.startAngle, endAngle: slice.endAngle, color: slice.color)
                }
            }
            .frame(width: 250, height: 250)  // Frame size
            
            // Legend
            VStack(alignment: .leading) {
                ForEach(Array(categoriesData.keys.sorted()), id: \.self) { category in
                    HStack {
                        Color(categoriesColors[category] ?? .gray)
                            .frame(width: 20, height: 20)
                        Text(category)
                    }
                }
            }
            .padding()

            // Month Selector
            HStack {
                Spacer()
      
                Spacer()
            }
            .padding(.top, 20)

            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            categoriesColors = generateColors(for: categoriesData.keys.sorted())
        }
    }
    
    private func generatePieSlices() -> [PieSliceData] {
        let total = categoriesData.values.reduce(0, +)
        var startAngle = Angle(degrees: 0)
        var slices: [PieSliceData] = []
        
        for (category, value) in categoriesData {
            let endAngle = startAngle + Angle(degrees: (value / total) * 360)
            slices.append(PieSliceData(startAngle: startAngle, endAngle: endAngle, color: categoriesColors[category] ?? .gray))
            startAngle = endAngle
        }
        
        return slices
    }
    
    private func generateColors(for categories: [String]) -> [String: Color] {
        var colors: [String: Color] = [:]
        let predefinedColors: [Color] = [.red, .blue, .green, .orange, .yellow, .purple, .pink, .cyan, .mint, .teal, .brown]
        
        for (index, category) in categories.enumerated() {
            colors[category] = predefinedColors[index % predefinedColors.count]
        }
        
        return colors
    }
}

struct PieSliceData {
    var startAngle: Angle
    var endAngle: Angle
    var color: Color
}

struct PieSliceView: View {
    var startAngle: Angle
    var endAngle: Angle
    var color: Color

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let center = CGPoint(x: width / 2, y: height / 2)
                path.move(to: center)

                path.addArc(center: center, radius: width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            }
            .fill(color)
        }
    }
}

struct PieChartView_Previews: PreviewProvider {
    static var previews: some View {
        PieChartView(categoriesData: ["Fruits & Légumes": 100, "Produits laitiers": 200, "Boulangerie": 150])
    }
}
