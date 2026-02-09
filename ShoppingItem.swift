import Foundation

struct ShoppingItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var price: Double
    var quantity: Int
    var category: String
    var isTaxable: Bool
    var notes: String = ""
    
    init(id: UUID = UUID(), name: String, price: Double, quantity: Int, category: String, isTaxable: Bool, notes: String = "") {
        self.id = id
        self.name = name
        self.price = price
        self.quantity = quantity
        self.category = category
        self.isTaxable = isTaxable
        self.notes = notes
    }
}
