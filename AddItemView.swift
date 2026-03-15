import SwiftUI

// COMP3097 - Early Prototype Phase
// Author: Naveed Ahmed - Student ID: 101416034
// Purpose: Add/Edit shopping items with real data persistence

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
    @State private var showDeleteAlert = false
    
    let categories = ["Food", "Medication", "Cleaning", "Other"]
    
    // MARK: - Computed Properties
    
    /// Calculate real-time subtotal for preview
    var subtotal: Double {
        let price = Double(itemPrice) ?? 0.0
        let quantity = Int(itemQuantity) ?? 1
        return price * Double(quantity)
    }
    
    /// Calculate real-time tax for preview
    var taxAmount: Double {
        isTaxable ? subtotal * 0.13 : 0
    }
    
    /// Calculate real-time total for preview
    var total: Double {
        subtotal + taxAmount
    }
    
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
                            Text("$\(String(format: "%.2f", taxAmount))")
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
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
                            .font(.system(size: 16))
                    }
                }
                
                if item != nil {
                    Section {
                        Button(role: .destructive, action: { showDeleteAlert = true }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Delete Item")
                            }
                            .frame(maxWidth: .infinity)
                        }
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
            .alert("Delete Item?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deleteItem()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete \(itemName)?")
            }
        }
    }
    
    // MARK: - Functions
    
    /// Save new item or update existing item
    private func saveItem() {
        let price = Double(itemPrice) ?? 0.0
        let quantity = Int(itemQuantity) ?? 1
        
        if let existingItem = item {
            // EDIT: Update existing item
            if let index = items.firstIndex(where: { $0.id == existingItem.id }) {
                items[index] = ShoppingItem(
                    id: existingItem.id,
                    name: itemName,
                    price: price,
                    quantity: quantity,
                    category: selectedCategory,
                    isTaxable: isTaxable,
                    isCompleted: items[index].isCompleted,
                    notes: itemNotes
                )
            }
        } else {
            // ADD: Create new item
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
    
    /// Delete the current item
    private func deleteItem() {
        if let item = item, let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
        }
        dismiss()
    }
    
    /// Increase quantity by 1
    private func increaseQuantity() {
        if let quantity = Int(itemQuantity) {
            itemQuantity = String(quantity + 1)
        }
    }
    
    /// Decrease quantity by 1 (minimum 1)
    private func decreaseQuantity() {
        if let quantity = Int(itemQuantity), quantity > 1 {
            itemQuantity = String(quantity - 1)
        }
    }
}

#Preview {
    AddItemView(items: .constant([]), item: nil)
}
