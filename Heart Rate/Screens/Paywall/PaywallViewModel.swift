import SwiftUI
import StoreKit
import Combine

@MainActor
class PaywallViewModel: ObservableObject {
    @Published var selectedProductId: String?
    @Published var products: [ProductInfo] = []
    @AppStorage("isPremiumUser") var isPremiumUser = false
    @Published var isLoading = false
    @Published var purchaseErrorMessage = ""
    @Published var showPurchaseError = false

    private let ids = [
        "com.app.scanapp.opf.week",
        "com.app.scanapp.opf.month",
        "com.app.scanapp.opf.year"
    ]

    var selectedProduct: ProductInfo? {
        products.first(where: { $0.id == selectedProductId })
    }

    var canPurchase: Bool {
        selectedProductId != nil
    }

    init() {
        Task { await fetchProducts() }
    }

    func fetchProducts() async {
        isLoading = true

        do {
            let fetched = try await Product.products(for: ids)
                .map { ProductInfo(from: $0) }

            products = fetched.sorted { a, b in
                func rank(_ p: ProductInfo) -> Int {
                    if p.id.contains(".week") { return 0 }
                    if p.id.contains(".month") { return 1 }
                    if p.id.contains(".year") { return 2 }
                    return 3
                }
                return rank(a) < rank(b)
            }

            selectedProductId = nil

        } catch {
            products = []
        }

        isLoading = false
    }

    func purchaseSelected() async {
        guard let product = selectedProduct else { return }
        isLoading = true

        do {
            let result = try await product.storeKitProduct.purchase()

            switch result {
            case .success(let verification):
                if case .verified(let t) = verification {
                    await t.finish()
                    isPremiumUser = true
                }
            default:
                break
            }

        } catch {
            purchaseErrorMessage = error.localizedDescription
            showPurchaseError = true
        }

        isLoading = false
    }

    func restore() async {
        isLoading = true
        try? await AppStore.sync()

        for await t in Transaction.currentEntitlements {
            if case .verified = t { isPremiumUser = true }
        }

        isLoading = false
    }
}
