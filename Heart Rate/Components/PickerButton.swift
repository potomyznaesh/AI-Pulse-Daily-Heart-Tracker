import SwiftUI

struct PickerButton: View {
    let title: String
    let isSelected: Bool
    let gradient: LinearGradient
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(isSelected ? .white : .black)
                .padding(.horizontal, 25)
                .padding(.vertical, 12)
                .background {
                    if isSelected { Capsule().fill(gradient) }
                    else { Capsule().fill(Color.clear) }
                }
        }
    }
}
