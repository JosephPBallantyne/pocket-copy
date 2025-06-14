import SwiftUI

struct HeaderView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(NSColor.controlBackgroundColor))
                .frame(height: 56)
            
            HStack(spacing: 10) {
                Image(systemName: "doc.on.clipboard.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.accentColor)
                
                Text("Pocket Copy")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .overlay(
            Divider()
                .background(Color(NSColor.separatorColor)),
            alignment: .bottom
        )
    }
}
