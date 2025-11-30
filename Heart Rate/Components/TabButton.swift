import SwiftUI

struct TabButton: View {
    let imageName: String
    let text: String
    let isActive: Bool
    let activeGradient: LinearGradient?
    let inactiveColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                
                let icon = Image(imageName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()

                if isActive && activeGradient != nil {
                    icon
                        .frame(width: 38, height: 38)
                        .foregroundStyle(activeGradient!)
                    
                } else if isActive {
                    icon
                        .frame(width: 33, height: 33)
                        .foregroundColor(Color(hex: "EF4874"))
                        
                } else {
                    icon
                        .frame(width: 33, height: 33)
                        .foregroundColor(inactiveColor)
                }

                Text(text)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isActive ? Color(hex: "EF4874") : inactiveColor)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
