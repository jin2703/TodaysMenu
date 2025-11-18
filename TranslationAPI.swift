import Foundation

// 🌐 OpenAI 번역용 간단 모델

// OpenAI 응답 JSON 구조 (chat/completions 형태 기준)
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

// 🧠 번역 관련 API 서비스
struct TranslationAPI {
    
    // ⚠️ 실제 발급받은 OpenAI API 키를 여기에 넣기 (과제라면 상수로 두고, 실서비스면 분리)
    static let apiKey = "YOUR_OPENAI_API_KEY"
    
    // 🇰🇷 영어 → 한국어 번역 함수
    static func translateToKorean(_ text: String) async throws -> String {
        
        // 1) OpenAI Chat Completions 엔드포인트 URL
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw URLError(.badURL)
        }
        
        // 2) HTTP 요청 객체 만들기
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // 3) 헤더 설정 (인증 + JSON 형식)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // 4) 요청 바디(프롬프트) 구성
        //    system: 번역 스타일 지시
        //    user: 실제 번역할 텍스트
        let body: [String: Any] = [
            "model": "gpt-4.1-mini",   // 번역용으로 가볍고 빠른 모델
            "messages": [
                [
                    "role": "system",
                    "content": "당신은 영어를 한국어로 자연스럽게 번역하는 번역가입니다. 설명문을 짧고 자연스럽게 한글로 번역하세요."
                ],
                [
                    "role": "user",
                    "content": text
                ]
            ]
        ]
        
        // 5) 딕셔너리를 JSON 데이터로 변환
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        // 6) 실제 네트워크 요청 전송
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // 7) 응답 JSON을 파싱
        let decoded = try JSONDecoder().decode(OpenAIChatResponse.self, from: data)
        
        // 8) 첫 번째 응답의 message.content를 번역문으로 사용
        if let content = decoded.choices.first?.message.content {
            return content.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            // 응답은 받았는데 내용이 없을 때
            throw NSError(domain: "TranslationAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "번역 결과가 비어 있습니다."])
        }
    }
}
