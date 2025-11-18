import Foundation

// API 전체 응답 구조
struct MealResponse: Decodable {
    let meals: [Meal]
}

// 개별 음식 데이터 구조
struct Meal: Decodable {
    let idMeal: String
    let strMeal: String
    let strMealThumb: String?
    let strInstructions: String?
    let strCategory: String?
}
