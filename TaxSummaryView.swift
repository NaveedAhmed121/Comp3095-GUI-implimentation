import SwiftUI
import UIKit

struct TaxSummaryView: View {
    let items: [ShoppingItem]
    let taxRate: Double
    @Environment(\.dismiss) var dismiss
    @State private var adjustedTaxRate: Double
    
    init(items: [ShoppingItem], taxRate: Double) {
        self.items = items
        self.taxRate = taxRate
        _adjustedTaxRate = State(initialValue: taxRate)
    }
    
    var subtotal: Double {
        items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
    
    var taxAmount: Double {
        let taxableTotal = items.filter { $0.isTaxable }
            .reduce(0) { $0 + ($1.price * Double($1.quantity)) }
        return taxableTotal * adjustedTaxRate
    }
    
    var total: Double {
        subtotal + taxAmount
    }
    
    var groupedByCategory: [String: [ShoppingItem]] {
        Dictionary(grouping: items, by: { $0.category })
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // HEADER CARD
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Order Summary")
                                        .font(.system(size: 24, weight: .bold))
                                    
                                    Text("\(items.count) items")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            
                            Divider()
                            
                            // TAX RATE SELECTOR
                            HStack {
                                Text("Tax Rate (HST)")
                                    .font(.system(size: 14, weight: .semibold))
                                
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    Stepper("", value: $adjustedTaxRate, in: 0...0.25, step: 0.01)
                                        .labelsHidden()
                                    
                                    Text("\(String(format: "%.0f", adjustedTaxRate * 100))%")
                                        .font(.system(size: 14, weight: .semibold))
                                        .frame(width: 40)
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        // ITEMS BY CATEGORY
                        VStack(spacing: 12) {
                            ForEach(groupedByCategory.keys.sorted(), id: \.self) { category in
                                if let categoryItems = groupedByCategory[category] {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(category.uppercased())
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.blue)
                                        
                                        VStack(spacing: 6) {
                                            ForEach(categoryItems) { item in
                                                HStack {
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(item.name)
                                                            .font(.system(size: 13, weight: .regular))
                                                        
                                                        Text("Qty: \(item.quantity)")
                                                            .font(.system(size: 11, weight: .regular))
                                                            .foregroundColor(.gray)
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                    VStack(alignment: .trailing, spacing: 2) {
                                                        Text("$\(String(format: "%.2f", item.price * Double(item.quantity)))")
                                                            .font(.system(size: 13, weight: .semibold))
                                                        
                                                        if item.isTaxable {
                                                            Text("+ $\(String(format: "%.2f", item.price * Double(item.quantity) * adjustedTaxRate))")
                                                                .font(.system(size: 10, weight: .regular))
                                                                .foregroundColor(.red)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        .padding(10)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(8)
                                        
                                        // CATEGORY TOTAL
                                        HStack {
                                            Text("Category Total")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.gray)
                                            
                                            Spacer()
                                            
                                            let categoryTotal = categoryItems.reduce(0) { total, item in
                                                let itemTotal = item.price * Double(item.quantity)
                                                return total + (item.isTaxable ? itemTotal * (1 + adjustedTaxRate) : itemTotal)
                                            }
                                            Text("$\(String(format: "%.2f", categoryTotal))")
                                                .font(.system(size: 13, weight: .semibold))
                                        }
                                    }
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                }
                            }
                        }
                        
                        // TOTALS CARD
                        VStack(spacing: 12) {
                            HStack {
                                Text("Subtotal")
                                    .font(.system(size: 14, weight: .semibold))
                                Spacer()
                                Text("$\(String(format: "%.2f", subtotal))")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Tax (\(String(format: "%.0f", adjustedTaxRate * 100))%)")
                                    .font(.system(size: 14, weight: .semibold))
                                Spacer()
                                Text("$\(String(format: "%.2f", taxAmount))")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.red)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Total")
                                    .font(.system(size: 16, weight: .bold))
                                Spacer()
                                Text("$\(String(format: "%.2f", total))")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        // ACTION BUTTONS
                        VStack(spacing: 10) {
                            Button(action: { shareReceipt() }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share Receipt")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .font(.system(size: 14, weight: .semibold))
                            }
                            
                            Button(action: { printReceipt() }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "printer")
                                    Text("Print Receipt")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(Color(.systemGray5))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                                .font(.system(size: 14, weight: .semibold))
                            }
                        }
                        .padding(16)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func shareReceipt() {
        let receiptText = """
        ShopCart Receipt
        
        Subtotal: $\(String(format: "%.2f", subtotal))
        Tax (\(String(format: "%.0f", adjustedTaxRate * 100))%): $\(String(format: "%.2f", taxAmount))
        Total: $\(String(format: "%.2f", total))
        """
        
        let activity = UIActivityViewController(activityItems: [receiptText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(activity, animated: true)
        }
    }
    
    private func printReceipt() {
        UIPasteboard.general.string = """
        ShopCart Receipt
        
        Subtotal: $\(String(format: "%.2f", subtotal))
        Tax (\(String(format: "%.0f", adjustedTaxRate * 100))%): $\(String(format: "%.2f", taxAmount))
        Total: $\(String(format: "%.2f", total))
        """
    }
}

#Preview {
    TaxSummaryView(items: [
        ShoppingItem(id: UUID(), name: "Milk", price: 3.99, quantity: 2, category: "Food", isTaxable: true),
        ShoppingItem(id: UUID(), name: "Vitamins", price: 15.99, quantity: 1, category: "Medication", isTaxable: true),
    ], taxRate: 0.13)
}
