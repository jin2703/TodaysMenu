import Foundation

// 🧾 OpenAI Chat Completions 응답 모델
struct OpenAIChatResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let role: String
            let content: String
        }
        let index: Int
        let message: Message
    }

    let choices: [Choice]
}

// 🌐 번역 API 래퍼
struct TranslationAPI {
    // ⚠️ 여기에는 "진짜" 키를 넣어서 로컬에서만 사용하고,
    //    깃허브에 올릴 땐 "YOUR_OPENAI_API_KEY" 로 꼭 바꿔줘!
    static let apiKey = "YOUR_OPENAI_API_KEY"

    // 🇰🇷 영어 → 한국어 번역 함수
    static func translateToKorean(_ text: String) async throws -> String {
        // 1) Chat Completions 엔드포인트
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw URLError(.badURL)
        }

        // 2) HTTP 요청 준비
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        // 3) 요청 바디 (프롬프트)
        let body: [String: Any] = [
            "model": "gpt-4.1-mini",   // ✅ 네 계정에서 사용 가능한 chat 모델로 바꿔도 됨
            "messages": [
                [
                    "role": "system",
                    "content": "당신은 영어를 자연스럽게 한국어로 번역하는 번역가입니다. 불필요한 설명 없이 번역된 한글 문장만 출력하세요."
                ],
                [
                    "role": "user",
                    "content": text
                ]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        // 4) 네트워크 요청
        let (data, response) = try await URLSession.shared.data(for: request)

        // 5) HTTP 상태 코드 확인 (디버깅용)
        if let http = response as? HTTPURLResponse {
            print("🌐 OpenAI status code:", http.statusCode)
            if http.statusCode != 200 {
                let bodyString = String(data: data, encoding: .utf8) ?? ""
                print("❌ OpenAI error body:\n\(bodyString)")
                throw NSError(
                    domain: "TranslationAPI",
                    code: http.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "OpenAI 요청 실패 (\(http.statusCode))"]
                )
            }
        }

        // 6) JSON 디코딩
        do {
            let decoded = try JSONDecoder().decode(OpenAIChatResponse.self, from: data)

            guard let content = decoded.choices.first?.message.content else {
                throw NSError(
                    domain: "TranslationAPI",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "응답에 message.content가 없습니다."]
                )
            }

            return content.trimmingCharacters(in: .whitespacesAndNewlines)

        } catch {
            // 디코딩 에러 시 원시 바디도 같이 출력 (디버깅용)
            let bodyString = String(data: data, encoding: .utf8) ?? ""
            print("❌ JSON decode error:", error)
            print("📦 Raw response body:\n\(bodyString)")
            throw error
        }
    }
}
