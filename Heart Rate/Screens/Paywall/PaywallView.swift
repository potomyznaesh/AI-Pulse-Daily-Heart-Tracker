import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var vm = PaywallViewModel()
    @State private var showCloseButton = false

    var body: some View {
        ZStack(alignment: .topTrailing) {

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    Image("img5")
                        .resizable()
                        .scaledToFit()
                        .padding(.bottom, 8)

                    VStack(spacing: 8) {
                        Text("Use all features of")
                            .font(.system(size: 28, weight: .bold))
                        Text("Heart Rate")
                            .font(.system(size: 28, weight: .bold))
                    }

                    VStack(alignment: .leading, spacing: 14) {

                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(Color(red: 1.0, green: 0.11, blue: 0.39))
                                .font(.system(size: 17, weight: .semibold))

                            Text("Save every result and see your progress.")
                                .font(.system(size: 15))
                                .foregroundColor(.black.opacity(0.82))
                        }
                        .padding(.horizontal, 22)

                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "clock")
                                .foregroundColor(Color(red: 1.0, green: 0.11, blue: 0.39))
                                .font(.system(size: 17, weight: .semibold))

                            Text("Access your full history anytime.")
                                .font(.system(size: 15))
                                .foregroundColor(.black.opacity(0.82))
                        }
                        .padding(.horizontal, 22)

                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(Color(red: 1.0, green: 0.11, blue: 0.39))
                                .font(.system(size: 17, weight: .semibold))

                            Text("Get quick AI insights for your BPM.")
                                .font(.system(size: 15))
                                .foregroundColor(.black.opacity(0.82))
                        }
                        .padding(.horizontal, 22)
                    }
                    
                    if vm.isLoading {
                        ProgressView().padding(40)
                    } else {
                        productLayout
                    }

                    Button {
                        Task {
                            await vm.purchaseSelected()
                            if vm.isPremiumUser { dismiss() }
                        }
                    } label: {
                        Text("Continue")
                            .font(.system(size: 21, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                vm.canPurchase
                                    ? AnyShapeStyle(LinearGradient(
                                        colors: [
                                            Color(red: 1.0, green: 0.64, blue: 0.69),
                                            Color(red: 1.0, green: 0.11, blue: 0.39)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    : AnyShapeStyle(Color.gray.opacity(0.25))
                            )
                            .clipShape(Capsule())
                            .shadow(color: vm.canPurchase
                                    ? Color(red: 1.0, green: 0.11, blue: 0.39).opacity(0.3)
                                    : .clear,
                                    radius: 20, y: 8)
                    }
                    .disabled(!vm.canPurchase)
                    .padding(.horizontal, 20)

                    HStack(spacing: 30) {
                        Link("Terms of use", destination: URL(string: "https://google.com")!)
                        Button("Restore") { Task { await vm.restore() } }
                        Link("Privacy policy", destination: URL(string: "https://google.com")!)
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.bottom, 40)
                }
            }

            if showCloseButton {
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 34))
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(.top, 14)
                    .padding(.trailing, 18)
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation(.easeInOut(duration: 0.35)) {
                    showCloseButton = true
                }
            }
        }
        .alert("Error", isPresented: $vm.showPurchaseError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.purchaseErrorMessage)
        }
    }

    var productLayout: some View {
        VStack(spacing: 20) {

            if let top = vm.products.first {
                TrialCard(
                    product: top,
                    isSelected: vm.selectedProductId == top.id
                )
                .onTapGesture {
                    withAnimation { vm.selectedProductId = top.id }
                }
            }

            if vm.products.count > 1 {
                HStack(spacing: 16) {
                    ForEach(vm.products.dropFirst()) { product in
                        SmallCard(
                            product: product,
                            isSelected: vm.selectedProductId == product.id
                        )
                        .onTapGesture {
                            withAnimation { vm.selectedProductId = product.id }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct TrialCard: View {
    let product: ProductInfo
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            Text(product.title)
                .font(.system(size: 17, weight: .semibold))

            if let trial = product.trialText {
                Text(trial)
                    .font(.system(size: 15))
                    .foregroundColor(.black.opacity(0.8))
            }

            Text(product.priceString + product.periodSuffix)
                .font(.system(size: 15))
                .foregroundColor(.black.opacity(0.75))
        }
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 18, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(
                    Color(red: 1.0, green: 0.11, blue: 0.39),
                    lineWidth: isSelected ? 2 : 0
                )
        )
        .padding(.horizontal, 20)
    }
}

struct SmallCard: View {
    let product: ProductInfo
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text(product.title)
                .font(.system(size: 16, weight: .semibold))

            Text(product.priceString + product.periodSuffix)
                .font(.system(size: 15))
                .foregroundColor(.black.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 12, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    Color(red: 1.0, green: 0.11, blue: 0.39),
                    lineWidth: isSelected ? 2 : 0
                )
        )
    }
}

#Preview {
    PaywallView()
}
