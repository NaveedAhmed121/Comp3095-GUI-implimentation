import Foundation

// COMP3097 - Early Prototype Phase
// Author: Naveed Ahmed - Student ID: 101416034
// Data Model for Shopping Items

struct ShoppingItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var price: Double
    var quantity: Int
    var category: String
    var isTaxable: Bool
    var isCompleted: Bool
    var notes: String
    
    init(
        id: UUID = UUID(),
        name: String,
        price: Double,
        quantity: Int,
        category: String,
        isTaxable: Bool,
        isCompleted: Bool = false,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.quantity = quantity
        self.category = category
        self.isTaxable = isTaxable
        self.isCompleted = isCompleted
        self.notes = notes
    }
    
    /// Calculate the total price for this item (price × quantity)
    var itemTotal: Double {
        price * Double(quantity)
    }
    
    /// Calculate tax amount for this item if taxable
    var taxAmount: Double {
        isTaxable ? itemTotal * 0.13 : 0.0
    }
    
    /// Calculate total including tax
    var totalWithTax: Double {
        itemTotal + taxAmount
    }
}
