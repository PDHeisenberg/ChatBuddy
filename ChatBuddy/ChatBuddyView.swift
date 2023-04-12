import SwiftUI
import Speech
import Alamofire
import AVFoundation

class ChatBuddyViewModel: ObservableObject {
    @Published var userInput = ""
    @Published var aiResponse = ""
    @Published var messages: [ChatMessage] = []
    @Published var isRecording = false
    
    private let audioEngine = AVAudioEngine()
    
    func sendUserInput() {
        guard !userInput.isEmpty else { return }
        
        let queryMessage = ChatMessage(text: userInput, type: .userQuery)
        messages.append(queryMessage)
        self.objectWillChange.send()
        
        OpenAIAPI.generateResponse(prompt: userInput) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    let aiMessage = ChatMessage(text: response, type: .aiResponse)
                    self.messages.append(aiMessage)
                    self.objectWillChange.send()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    let aiMessage = ChatMessage(text: "Error: \(error.localizedDescription)", type: queryMessage.type)
                    self.messages.append(aiMessage)
                    self.objectWillChange.send()
                }
            }
        }
    }
    
    

    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let request = SFSpeechAudioBufferRecognitionRequest()

        var pauseTimer: Timer?

        audioSession.requestRecordPermission { [weak self] allowed in
            guard let self = self else { return }

            if allowed {
                let inputNode = self.audioEngine.inputNode

                request.shouldReportPartialResults = true
                let recognitionTask = SFSpeechRecognizer()?.recognitionTask(with: request, resultHandler: { result, error in
                    if let result = result {
                        DispatchQueue.main.async {
                            self.userInput = result.bestTranscription.formattedString

                            // Invalidate and restart the pause timer
                            pauseTimer?.invalidate()
                            pauseTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { _ in
                                self.stopRecording()
                            })
                        }
                    }
                })

                let recordingFormat = inputNode.outputFormat(forBus: 0)
                inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
                    request.append(buffer)
                }

                self.audioEngine.prepare()
                try? self.audioEngine.start()
                self.isRecording = true
            } else {
                print("Permission not granted")
            }
        }
    }


    func stopRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.requestRecordPermission { [weak self] allowed in
            guard let self = self else { return }

            if allowed {
                let inputNode = self.audioEngine.inputNode
                inputNode.removeTap(onBus: 0)
                self.audioEngine.stop()
                try? audioSession.setActive(false, options: .notifyOthersOnDeactivation)
                self.isRecording = false

                // Automatically send the recorded user input
                self.sendUserInput()
                self.userInput = ""
            } else {
                print("Permission not granted")
            }
        }
    }
}

struct ChatBuddyView: View {
    @ObservedObject var viewModel: ChatBuddyViewModel
    
    init(viewModel: ChatBuddyViewModel) {
        self.viewModel = viewModel
        viewModel.startRecording()
    }
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.messages) { message in
                        ChatMessageView(message: message)
                    }
                    
                }.padding(.horizontal, 24)
                    .padding(.top, 72)
            }
            Spacer()
            Button {
                if viewModel.isRecording {
                    viewModel.stopRecording()
                } else {
                    viewModel.startRecording()
                }
            } label: {
                Image(systemName: viewModel.isRecording ? "stop.fill" : "mic.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)
                    .padding()
                    .frame(width: 60, height: 60)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(30)
            }
            
            TextField("Type your message", text: $viewModel.userInput, onCommit: {
                viewModel.sendUserInput()
                viewModel.userInput = ""
            })
            .frame(height: 48)
            .padding(.horizontal, 24)
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.gray, lineWidth: 1))
            .padding(.horizontal, 32)
            .padding(.top,48)
            .padding(.bottom, 32)
            
        }.edgesIgnoringSafeArea(.all)
    }
}

struct ChatBuddyView_Previews: PreviewProvider {
    static var previews: some View {
        ChatBuddyView(viewModel: ChatBuddyViewModel())
    }
}


