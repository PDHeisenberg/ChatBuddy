import SwiftUI

struct VoiceInputController: UIViewControllerRepresentable {
    var onRecognizedText: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> ViewController {
        let viewController = ViewController()
        viewController.onRecognizedText = onRecognizedText

        // Create the input text view
            viewController.inputTextView = UITextView()
            viewController.inputTextView.layer.borderWidth = 1
            viewController.inputTextView.layer.borderColor = UIColor.gray.cgColor
            viewController.inputTextView.layer.cornerRadius = 5
            viewController.view.addSubview(viewController.inputTextView)
            
            // Add constraints to inputTextView
            viewController.inputTextView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                viewController.inputTextView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 20),
                viewController.inputTextView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -20),
                viewController.inputTextView.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor, constant: 20),
                viewController.inputTextView.heightAnchor.constraint(equalToConstant: 100)
            ])

        // Create the voice input button
        viewController.voiceInputButton = UIButton(type: .system)
        viewController.voiceInputButton.setTitle("Start Recording", for: [])
        viewController.voiceInputButton.addTarget(viewController, action: #selector(viewController.toggleRecording), for: .touchUpInside)

        // Add the button to the view and set constraints
        viewController.view.addSubview(viewController.voiceInputButton)
        viewController.voiceInputButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewController.voiceInputButton.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            viewController.voiceInputButton.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])

        return viewController
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
    }

    class Coordinator: NSObject {
        var parent: VoiceInputController

        init(_ parent: VoiceInputController) {
            self.parent = parent
        }
    }
}
