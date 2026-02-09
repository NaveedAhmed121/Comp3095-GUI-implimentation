import SwiftUI
import UIKit

struct ContentView: View {
    @State private var showLaunchScreen = true
    @State private var shoppingItems: [ShoppingItem] = [
        ShoppingItem(id: UUID(), name: "Milk", price: 3.99, quantity: 2, category: "Food", isTaxable: true),
        ShoppingItem(id: UUID(), name: "Bread", price: 2.50, quantity: 1, category: "Food", isTaxable: false),
        ShoppingItem(id: UUID(), name: "Vitamins", price: 15.99, quantity: 1, category: "Medication", isTaxable: true),
        ShoppingItem(id: UUID(), name: "Cleaner", price: 5.00, quantity: 1, category: "Cleaning", isTaxable: true),
        ShoppingItem(id: UUID(), name: "Notebook", price: 3.50, quantity: 2, category: "Other", isTaxable: false),
    ]
    @State private var selectedCategory = "All"
    @State private var taxRate: Double = 0.13
    
    var filteredItems: [ShoppingItem] {
        if selectedCategory == "All" {
            return shoppingItems
        }
        return shoppingItems.filter { $0.category == selectedCategory }
    }
    
    var categories: [String] {
        var cats = Set(shoppingItems.map { $0.category })
        return ["All"] + cats.sorted()
    }
    
    var body: some View {
        if showLaunchScreen {
            LaunchScreen(isPresented: $showLaunchScreen)
        } else {
            NavigationStack {
                ZStack {
                    Color(.systemGray6)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // HEADER
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Shopping List")
                                    .font(.system(size: 28, weight: .bold))
                                Text("\(filteredItems.count) items")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            
                            NavigationLink(destination: TaxSummaryView(items: filteredItems, taxRate: taxRate)) {
                                VStack(spacing: 2) {
                                    Image(systemName: "chart.bar")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Summary")
                                        .font(.system(size: 10, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                        
                        // CATEGORY FILTER
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(categories, id: \.self) { category in
                                    Button(action: {
                                        selectedCategory = category
                                    }) {
                                        Text(category)
                                            .font(.system(size: 12, weight: .semibold))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.2))
                                            .foregroundColor(selectedCategory == category ? .white : .black)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.bottom, 12)
                        .background(Color(.systemGray6))
                        
                        // ITEMS LIST
                        if filteredItems.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "cart")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                Text("No items yet")
                                    .font(.system(size: 18, weight: .semibold))
                                
                                Text("Add your first item to get started")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(.systemBackground))
                        } else {
                            List {
                                ForEach(filteredItems) { item in
                                    NavigationLink(destination: AddItemView(items: $shoppingItems, item: item)) {
                                        ShoppingItemRow(item: item)
                                    }
                                }
                                .onDelete { indexSet in
            let idsToDelete = indexSet.map { filteredItems[$0].id }
            shoppingItems.removeAll { idsToDelete.contains($0.id) }
                                }
                            }
                            .listStyle(.plain)
                        }
                    }
                    
                    // FLOATING ACTION BUTTON
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            NavigationLink(destination: AddItemView(items: $shoppingItems, item: nil)) {
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                            .padding(20)
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct ShoppingItemRow: View {
    let item: ShoppingItem
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "circle")
                .font(.system(size: 20))
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                        .font(.system(size: 16, weight: .semibold))
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("$\(String(format: "%.2f", item.price))")
                            .font(.system(size: 14, weight: .semibold))
                        
                        Text("Qty: \(item.quantity)")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.gray)
                    }
                }
                
                HStack(spacing: 8) {
                    Text(item.category)
                        .font(.system(size: 11, weight: .semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                    
                    if item.isTaxable {
                        Text("Taxable")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", item.price * Double(item.quantity)))")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ContentView()
}
