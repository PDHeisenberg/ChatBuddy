import SwiftUI

struct ChatMessageView: View {
    var message: ChatMessage
    
    var body: some View {
        HStack {
            if message.type == .aiResponse {
                Text(message.text)
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(12)
                Spacer()
            } else {
                Spacer()
                Text(message.text)
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }
}

struct ChatMessageView_Previews: PreviewProvider {
static var previews: some View {
VStack {
ChatMessageView(message: ChatMessage(text: "User message", type: .userQuery))
ChatMessageView(message: ChatMessage(text: "AI response", type: .aiResponse))
}
}
}
