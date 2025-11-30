
import SwiftUI

struct InsightArticle: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let imageName: String
    
    let heroImageName: String
    let articleText: String
    let sourceURL: String
}