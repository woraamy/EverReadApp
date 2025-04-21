import SwiftUI

struct DetailTabButton: View {
    let label: String
    let detail_tab: DetailTab
    @Binding var selectedTab: DetailTab

    var isSelected: Bool {
        selectedTab == detail_tab
    }

    var body: some View {
        Button(action: {
            selectedTab = detail_tab
        }) {
            VStack {
                Text(label)
                    .font(.body)
            }
            .padding(20)
            .frame(width: 170, height: 35)
            .background(isSelected ? Color.white : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

