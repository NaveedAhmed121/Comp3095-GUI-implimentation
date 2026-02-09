import SwiftUI

struct AddItemView: View {
    @Binding var items: [ShoppingItem]
    let item: ShoppingItem?
    @Environment(\.dismiss) var dismiss
    
    @State private var itemName: String = ""
    @State private var itemPrice: String = ""
    @State private var itemQuantity: String = "1"
    @State private var selectedCategory: String = "Food"
    @State private var isTaxable: Bool = true
    @State private var itemNotes: String = ""
    
    let categories = ["Food", "Medication", "Cleaning", "Other"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Item Details") {
                    TextField("Item Name", text: $itemName)
                        .textInputAutocapitalization(.words)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Price ($)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        TextField("0.00", text: $itemPrice)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Quantity")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 12) {
                            Button(action: { decreaseQuantity() }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                            }
                            
                            TextField("1", text: $itemQuantity)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                                .frame(maxWidth: 80)
                                .multilineTextAlignment(.center)
                            
                            Button(action: { increaseQuantity() }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Category")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                
                Section("Tax Information") {
                    Toggle("This item is taxable", isOn: $isTaxable)
                        .tint(.blue)
                    
                    if isTaxable {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.blue)
                            
                            Text("HST (13%) will be applied to taxable items")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $itemNotes)
                        .frame(height: 80)
                        .font(.system(size: 14, weight: .regular))
                }
                
                Section("Summary") {
                    let price = Double(itemPrice) ?? 0.0
                    let quantity = Int(itemQuantity) ?? 1
                    let subtotal = price * Double(quantity)
                    let tax = isTaxable ? subtotal * 0.13 : 0
                    let total = subtotal + tax
                    
                    HStack {
                        Text("Subtotal")
                        Spacer()
                        Text("$\(String(format: "%.2f", subtotal))")
                            .fontWeight(.semibold)
                    }
                    
                    if isTaxable {
                        HStack {
                            Text("Tax (13%)")
                            Spacer()
                            Text("$\(String(format: "%.2f", tax))")
                                .fontWeight(.semibold)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Total")
                            .fontWeight(.bold)
                        Spacer()
                        Text("$\(String(format: "%.2f", total))")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle(item == nil ? "Add Item" : "Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(itemName.isEmpty || itemPrice.isEmpty)
                }
            }
            .onAppear {
                if let item = item {
                    itemName = item.name
                    itemPrice = String(item.price)
                    itemQuantity = String(item.quantity)
                    selectedCategory = item.category
                    isTaxable = item.isTaxable
                    itemNotes = item.notes
                }
            }
        }
    }
    
    private func saveItem() {
        let price = Double(itemPrice) ?? 0.0
        let quantity = Int(itemQuantity) ?? 1
        
        if let existingItem = item {
            if let index = items.firstIndex(where: { $0.id == existingItem.id }) {
                items[index] = ShoppingItem(
                    id: existingItem.id,
                    name: itemName,
                    price: price,
                    quantity: quantity,
                    category: selectedCategory,
                    isTaxable: isTaxable,
                    notes: itemNotes
                )
            }
        } else {
            let newItem = ShoppingItem(
                id: UUID(),
                name: itemName,
                price: price,
                quantity: quantity,
                category: selectedCategory,
                isTaxable: isTaxable,
                notes: itemNotes
            )
            items.append(newItem)
        }
        
        dismiss()
    }
    
    private func increaseQuantity() {
        if let quantity = Int(itemQuantity) {
            itemQuantity = String(quantity + 1)
        }
    }
    
    private func decreaseQuantity() {
        if let quantity = Int(itemQuantity), quantity > 1 {
            itemQuantity = String(quantity - 1)
        }
    }
}

#Preview {
    AddItemView(items: .constant([]), item: nil)
}
