import SwiftUI   // 📝 SwiftUI와 @MainActor, ObservableObject 등을 사용하기 위해 임포트

// 🧠 ViewModel은 화면(View)에서 사용할 데이터를 관리하는 클래스
//    @MainActor : 이 클래스 안의 코드가 항상 메인 스레드에서 실행되도록 보장 (UI 관련이라 필요)
@MainActor
class MealViewModel: ObservableObject {  // 🧩 ObservableObject : 화면에서 이 객체를 구독하고 변경을 감지할 수 있게 해주는 프로토콜
    
    // 🍽 현재 화면에 보여줄 메뉴 데이터
    // @Published : 값이 바뀌면 SwiftUI가 자동으로 화면을 다시 그리도록 알려주는 속성
    @Published var meal: Meal? = nil
    
    // ⏳ 네트워크 요청 중인지 나타내는 상태
    @Published var isLoading: Bool = false
    
    // ⚠️ 에러가 발생했을 때 사용자에게 보여줄 메시지
    @Published var errorMessage: String? = nil
    
    // 🧱 초기 생성자 (지금은 특별히 하는 일 없음)
    init() {}
    
    // 🌐 랜덤 메뉴를 불러오는 비동기 함수
    //    async : 네트워크처럼 시간이 걸리는 작업을 비동기로 처리
    func loadRandomMeal() async {
        // 요청 시작 → 로딩 상태 켜기
        isLoading = true
        errorMessage = nil   // 이전 에러 메시지 초기화
        
        do {
            // 🔄 MealAPI를 통해 실제 랜덤 메뉴 데이터를 받아옴
            let newMeal = try await MealAPI.fetchRandomMeal()
            
            // ✅ 성공하면 화면에 보여줄 meal 값 업데이트
            self.meal = newMeal
        } catch {
            // ❌ 실패 시 에러 메시지 저장 → 나중에 Text로 보여줄 수 있음
            self.errorMessage = "메뉴를 불러오는데 실패했습니다. 다시 시도해주세요."
            print("MealAPI Error:", error)
        }
        
        // 요청 종료 → 로딩 상태 끄기
        isLoading = false
    }
}
