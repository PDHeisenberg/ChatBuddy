import Alamofire
import Foundation

struct OpenAIAPI {
    static let apiKey = "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"
    static let apiUrl = "https://api.openai.com/v1/engines/text-davinci-003/completions"

    static func generateResponse(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        let promptText = "User: \(prompt)\nAI:"
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]

        let parameters: [String: Any] = [
            "prompt": promptText,
            "max_tokens": 50, // Limit the response length
            "n": 1, // Number of completions to generate
            "stop": ["\n"], // Stop the generation when a newline character is encountered
            "temperature": 0.8 // Adjust the temperature to control the randomness of the output
        ]

        AF.request(apiUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any] {
                    print("JSON Response: \(json)")
                    if let choices = json["choices"] as? [[String: Any]],
                       let choice = choices.first,
                       let text = choice["text"] as? String {
                        completion(.success(text))
                    } else {
                        completion(.failure(NSError(domain: "Parsing error", code: 0, userInfo: nil)))
                    }
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
