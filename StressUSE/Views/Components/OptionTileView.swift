import SwiftUI

struct OptionTileView: View {
    let option: AnswerOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isSelected ? Color.black : Color.white.opacity(0.85))
                        .frame(width: 28, height: 28)

                    Image(systemName: isSelected ? "checkmark" : "circle")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(isSelected ? .white : .black.opacity(0.45))
                }

                Text(option.text)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.black.opacity(0.82))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(isSelected ? Color.white : Color.white.opacity(0.72))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(isSelected ? Color.black : Color.white.opacity(0.6), lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
