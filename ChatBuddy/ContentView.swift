import SwiftUI
import ChatBuddy

struct ContentView: View {
    var body: some View {
        ChatBuddyView(viewModel: ChatBuddyViewModel())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
