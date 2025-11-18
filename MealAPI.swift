import Foundation

// API 요청 오류 정의(선택적)
enum MealAPIError: Error {
    case invalidURL
    case emptyResponse
    case decodingError
}

// MARK: - MealAPI 서비스
struct MealAPI {
    
    // 랜덤 메뉴 가져오는 함수
    static func fetchRandomMeal() async throws -> Meal {
        
        // API URL
        let urlString = "https://www.themealdb.com/api/json/v1/1/random.php"
        
        // URL 검사
        guard let url = URL(string: urlString) else {
            throw MealAPIError.invalidURL
        }
        
        do {
            // 실제 API 요청
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // JSON 파싱
            let decoded = try JSONDecoder().decode(MealResponse.self, from: data)
            
            // meals 배열이 비어 있을 경우
            guard let meal = decoded.meals.first else {
                throw MealAPIError.emptyResponse
            }
            
            return meal
            
        } catch let error as DecodingError {
            print("Decoding Error:", error)
            throw MealAPIError.decodingError
        } catch {
            print("Other Error:", error)
            throw error
        }
    }
}
