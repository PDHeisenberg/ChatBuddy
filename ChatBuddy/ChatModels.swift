import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let type: ChatMessageType
}

enum ChatMessageType {
    case userQuery
    case aiResponse
}
