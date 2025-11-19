import Foundation   // 🧩 네트워크, 비동기 처리 등에 필요한 기본 프레임워크 임포트

// @MainActor : 이 클래스 안의 모든 공개 메서드는 메인 스레드(UI 스레드)에서 실행된다는 의미
@MainActor
class MealViewModel: ObservableObject {  // 🧠 ObservableObject : SwiftUI View에서 감시(구독)할 수 있는 상태 객체
    
    // 🍽 현재 불러온 메뉴(없을 수도 있어서 옵셔널)
    @Published var meal: Meal? = nil
    
    // 🇰🇷 번역된 조리 설명 (없으면 영어 설명 사용)
    @Published var translatedInstructions: String? = nil
    
    // ⏳ API 호출 중인지 표시 (로딩 인디케이터용)
    @Published var isLoading: Bool = false
    
    // ⚠️ 에러가 발생했을 때 사용자에게 보여줄 메시지
    @Published var errorMessage: String? = nil
    
    // ⭐ 랜덤 메뉴를 불러오는 비동기 함수
    func loadRandomMeal() async {
        // 1) 호출 시작 → 로딩 상태 on, 에러/번역 초기화
        isLoading = true
        errorMessage = nil
        translatedInstructions = nil
        
        do {
            // 2) TheMealDB에서 랜덤 메뉴 1개 받아오기
            //    MealAPI의 fetchRandomMeal은 static 함수이므로
            //    인스턴스가 아니라 타입 이름으로 호출해야 함 (MealAPI.fetchRandomMeal)
            let result = try await MealAPI.fetchRandomMeal()
            
            // 3) 받아온 결과를 화면용 상태에 반영
            self.meal = result
            
            // 4) 조리 설명이 있을 경우에만 번역 시도
            if let original = result.strInstructions {
                do {
                    // TranslationAPI의 시그니처 : translateToKorean(_ text: String)
                    // → 외부 인자 레이블이 없으므로 (text:)를 쓰지 않고 그냥 값만 전달
                    let translated = try await TranslationAPI.translateToKorean(original)
                    self.translatedInstructions = translated

                } catch {
                    // 번역이 실패해도 앱이 죽지 않도록, 로그만 찍고 영어로 fallback
                    print("번역 오류:", error)
                    self.translatedInstructions = nil
                }
            }
            
        } catch {
            // 6) API 호출 자체가 실패한 경우
            print("API 오류:", error)
            self.errorMessage = "메뉴를 불러오는데 실패했습니다."
        }
        
        // 7) 모든 작업 종료 → 로딩 상태 off
        isLoading = false
    }
}
