import SwiftUI

/// Toolbar buttons for sensor rows inside `List`: blue label text, original gray fill, press feedback.
struct SensorToolbarButtonStyle: ButtonStyle {
    /// When true (e.g. Get Data → streaming), slightly stronger blue text.
    var isActive: Bool = false

    private static let labelBlue = Color(red: 0.0, green: 0.48, blue: 1.0)
    private static let labelBlueActive = Color(red: 0.0, green: 0.38, blue: 0.90)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(textColor(isPressed: configuration.isPressed))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color("Light Gray"))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.black.opacity(configuration.isPressed ? 0.08 : 0))
                    }
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }

    private func textColor(isPressed: Bool) -> Color {
        if isPressed {
            return Self.labelBlue.opacity(0.75)
        }
        return isActive ? Self.labelBlueActive : Self.labelBlue
    }
}
