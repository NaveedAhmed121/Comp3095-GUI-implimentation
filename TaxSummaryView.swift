import SwiftUI
import UIKit

struct TaxSummaryView: View {
    let items: [ShoppingItem]
    let taxRate: Double

    @Environment(\.dismiss) private var dismiss
    @State private var adjustedTaxRate: Double

    init(items: [ShoppingItem], taxRate: Double) {
        self.items = items
        self.taxRate = taxRate
        _adjustedTaxRate = State(initialValue: taxRate)
    }

    var subtotal: Double {
        items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }

    var taxableSubtotal: Double {
        items
            .filter { $0.isTaxable }
            .reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }

    var taxAmount: Double {
        taxableSubtotal * adjustedTaxRate
    }

    var total: Double {
        subtotal + taxAmount
    }

    var groupedByCategory: [String: [ShoppingItem]] {
        Dictionary(grouping: items, by: { $0.category })
    }

    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    // Header card
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Order Summary")
                                    .font(.system(size: 24, weight: .bold))

                                Text("\(items.count) item\(items.count == 1 ? "" : "s")")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }

                        Divider()

                        HStack {
                            Text("Tax Rate")
                                .font(.system(size: 14, weight: .semibold))

                            Spacer()

                            VStack(alignment: .trailing, spacing: 6) {
                                Text("\(Int(adjustedTaxRate * 100))%")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.blue)

                                Slider(value: $adjustedTaxRate, in: 0...0.25, step: 0.01)
                                    .frame(width: 140)
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(12)

                    // Items by category
                    if items.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "tray")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)

                            Text("No items to summarize")
                                .font(.system(size: 16, weight: .semibold))

                            Text("Add items to view tax summary.")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(30)
                        .background(Color.white)
                        .cornerRadius(12)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(groupedByCategory.keys.sorted(), id: \.self) { category in
                                if let categoryItems = groupedByCategory[category] {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(category.uppercased())
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.blue)

                                        VStack(spacing: 8) {
                                            ForEach(categoryItems) { item in
                                                HStack {
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(item.name)
                                                            .font(.system(size: 14, weight: .medium))

                                                        Text("Qty: \(item.quantity)")
                                                            .font(.system(size: 12))
                                                            .foregroundColor(.gray)

                                                        if item.isTaxable {
                                                            Text("Taxable")
                                                                .font(.system(size: 11))
                                                                .foregroundColor(.red)
                                                        } else {
                                                            Text("Non-taxable")
                                                                .font(.system(size: 11))
                                                                .foregroundColor(.gray)
                                                        }
                                                    }

                                                    Spacer()

                                                    VStack(alignment: .trailing, spacing: 2) {
                                                        let itemTotal = item.price * Double(item.quantity)
                                                        Text("$\(String(format: "%.2f", itemTotal))")
                                                            .font(.system(size: 14, weight: .semibold))

                                                        if item.isTaxable {
                                                            Text("+ $\(String(format: "%.2f", itemTotal * adjustedTaxRate)) tax")
                                                                .font(.system(size: 11))
                                                                .foregroundColor(.red)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        .padding(10)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(8)

                                        let categorySubtotal = categoryItems.reduce(0) {
                                            $0 + ($1.price * Double($1.quantity))
                                        }

                                        let categoryTax = categoryItems
                                            .filter { $0.isTaxable }
                                            .reduce(0) { $0 + ($1.price * Double($1.quantity)) * adjustedTaxRate }

                                        HStack {
                                            Text("Category Total")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.gray)
                                            Spacer()
                                            Text("$\(String(format: "%.2f", categorySubtotal + categoryTax))")
                                                .font(.system(size: 13, weight: .semibold))
                                        }
                                    }
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }

                    // Totals card
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
                            Text("Tax (\(Int(adjustedTaxRate * 100))%)")
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

                    // Action buttons
                    VStack(spacing: 10) {
                        Button(action: shareReceipt) {
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

                        Button(action: copyReceipt) {
                            HStack(spacing: 8) {
                                Image(systemName: "doc.on.doc")
                                Text("Copy Receipt")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(Color(.systemGray5))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                            .font(.system(size: 14, weight: .semibold))
                        }
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("Summary")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }

    private func receiptText() -> String {
        """
        Shopping List Receipt

        Subtotal: $\(String(format: "%.2f", subtotal))
        Tax (\(Int(adjustedTaxRate * 100))%): $\(String(format: "%.2f", taxAmount))
        Total: $\(String(format: "%.2f", total))
        """
    }

    private func shareReceipt() {
        let activityVC = UIActivityViewController(
            activityItems: [receiptText()],
            applicationActivities: nil
        )

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = scene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }

    private func copyReceipt() {
        UIPasteboard.general.string = receiptText()
    }
}

#Preview {
    NavigationStack {
        TaxSummaryView(
            items: [
                ShoppingItem(name: "Milk", price: 3.99, quantity: 2, category: "Food", isTaxable: true),
                ShoppingItem(name: "Bread", price: 2.50, quantity: 1, category: "Food", isTaxable: false),
                ShoppingItem(name: "Cleaner", price: 5.00, quantity: 1, category: "Cleaning", isTaxable: true)
            ],
            taxRate: 0.13
        )
    }
}