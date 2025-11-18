import SwiftUI   // 🧩 SwiftUI 프레임워크 임포트 (화면을 선언형 방식으로 만들 때 사용)

// 📱 메인 화면 View
struct ContentView: View {
    // @StateObject : 이 View 안에서 ViewModel 인스턴스를 "처음 한 번" 만들고 상태를 관리하겠다는 의미
    // private      : 다른 파일이나 View에서 이 변수를 직접 접근하지 못하게 막아줌 (캡슐화)
    @StateObject private var vm = MealViewModel()
    
    // 화면에 그려질 실제 UI를 정의하는 부분
    var body: some View {
        // VStack : 위에서 아래로 뷰를 쌓는 컨테이너 (spacing은 뷰 사이 간격)
        VStack(spacing: 20) {
            
            // 1️⃣ 로딩 중일 때
            if vm.isLoading {
                // ProgressView : 동그라미 도는 로딩 인디케이터
                ProgressView("메뉴 추천 중...")
            }
            
            // 2️⃣ 정상적으로 받아온 메뉴가 있을 때
            else if let meal = vm.meal {
                // 이미지 URL이 존재하면 AsyncImage로 비동기 로딩
                if let thumb = meal.strMealThumb,
                   let url = URL(string: thumb) {
                    
                    // AsyncImage : 네트워크 상의 이미지를 비동기로 불러오는 SwiftUI 컴포넌트
                    AsyncImage(url: url) { image in
                        image
                            .resizable()          // 이미지를 리사이즈 가능하도록
                            .scaledToFit()        // 비율 유지하면서 영역 안에 맞게
                    } placeholder: {
                        // 이미지를 불러오는 동안 보여줄 뷰
                        ProgressView()
                    }
                    .frame(height: 250)          // 이미지 영역 높이 고정
                    .clipShape(                  // 모서리를 둥글게 잘라주는 역할
                        RoundedRectangle(cornerRadius: 16)
                    )
                }
                
                // 음식 이름 텍스트
                Text(meal.strMeal)
                    .font(.title2)               // 글자 크기 스타일
                    .bold()                      // 굵게
                    .multilineTextAlignment(.center)  // 여러 줄일 때 가운데 정렬
                
                // 카테고리가 있으면 해시태그처럼 표시
                if let category = meal.strCategory {
                    Text("# \(category)")
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Capsule())    // 캡슐 모양(알약처럼 둥근)으로 잘라줌
                }
                
                // 조리 설명 텍스트 (strInstructions)
                Text(meal.strInstructions ?? "설명이 없습니다.")
                    .font(.body)
                    .foregroundColor(.secondary) // 약간 흐린 색상
                    .multilineTextAlignment(.leading)
                    .lineLimit(6)                // 최대 6줄까지만 표시
            }
            
            // 3️⃣ 에러 메시지가 있을 때
            else if let error = vm.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            // 4️⃣ 아직 아무 상태도 아닐 때(첫 로딩 전에 잠깐 있을 수 있음)
            else {
                Text("아직 메뉴가 없습니다.\n아래 버튼을 눌러 메뉴를 추천받아보세요!")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            
            // 🔘 "다시 추천" 버튼 – 누르면 새로운 랜덤 메뉴를 가져옴
            Button {
                // Task { } : 버튼을 눌렀을 때 비동기 함수(async)를 호출하기 위한 래퍼
                Task {
                    await vm.loadRandomMeal()  // ViewModel에 랜덤 메뉴 요청
                }
            } label: {
                Text(vm.isLoading ? "불러오는 중..." : "다시 추천")
                    .frame(maxWidth: .infinity) // 버튼을 가로로 넓게
            }
            .buttonStyle(.borderedProminent)   // 기본 파란색 강조 버튼 스타일
            .disabled(vm.isLoading)            // 로딩 중일 때는 중복 클릭 방지
            
        }
        .padding()  // 전체 VStack에 여백 추가
        // .task : View가 화면에 처음 나타날 때 한 번 실행되는 비동기 작업
        .task {
            // 앱이 처음 열리면 자동으로 한 번 메뉴를 불러오기
            await vm.loadRandomMeal()
        }
    }
}

// 미리보기용 코드 (Xcode Canvas에서 사용)
#Preview {
    ContentView()
}
