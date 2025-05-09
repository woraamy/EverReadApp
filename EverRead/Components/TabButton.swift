import SwiftUI

struct TabButton<T: Hashable & Equatable>: View {
    let label: String
    let tab:T
    @Binding var selectedTab:T

    var isSelected: Bool {
        selectedTab == tab
    }

    var body: some View {
        Button(action: {
            selectedTab = tab
        }) {
            VStack {
                Text(label)
                    .font(.body)
            }
            .padding(25)
            .frame(height: 35)
            .background(isSelected ? Color.white : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
