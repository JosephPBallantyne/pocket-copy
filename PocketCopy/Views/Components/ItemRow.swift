import SwiftUI

struct ItemRow: View {
    let index: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Text("\(index)")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 20, alignment: .trailing)
            
            Text(text.isEmpty ? "" : text)
                .font(.system(size: 13))
                .foregroundColor(text.isEmpty ? Color.secondary.opacity(0.5) : .primary)
                .lineLimit(1)
                .truncationMode(.tail)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}
