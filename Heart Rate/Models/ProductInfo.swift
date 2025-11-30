import Foundation
import StoreKit

struct ProductInfo: Identifiable, Equatable {
    let id: String
    let title: String
    let priceString: String
    let periodSuffix: String
    let trialText: String?
    let storeKitProduct: Product

    init(from sk: Product) {
        id = sk.id
        storeKitProduct = sk
        priceString = sk.displayPrice

        var tmpTitle = sk.displayName
        var tmpSuffix = ""

        if let sub = sk.subscription {
            let period = sub.subscriptionPeriod

            switch period.unit {
            case .week:
                tmpTitle = "1 week"
                tmpSuffix = "/week"

            case .month:
                tmpTitle = "1 month"
                tmpSuffix = "/month"

            case .year:
                tmpTitle = "1 year"
                tmpSuffix = "/year"

            default:
                tmpTitle = sk.displayName
                tmpSuffix = ""
            }

            if let intro = sub.introductoryOffer,
               intro.paymentMode == .freeTrial {

                let p = intro.period
                let unit: String

                switch p.unit {
                case .day: unit = p.value == 1 ? "day" : "days"
                case .week: unit = p.value == 1 ? "week" : "weeks"
                case .month: unit = p.value == 1 ? "month" : "months"
                case .year: unit = p.value == 1 ? "year" : "years"
                @unknown default: unit = "days"
                }

                trialText = "\(p.value) \(unit) free trial"
            } else {
                trialText = nil
            }
        } else {
            trialText = nil
        }

        title = tmpTitle
        periodSuffix = tmpSuffix
    }
}
