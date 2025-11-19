import SwiftUI   // 🧩 SwiftUI 프레임워크 (화면을 선언형으로 만들 때 사용)

// 📱 앱 메인 화면 View
struct ContentView: View {
    // 🧠 화면에서 사용할 ViewModel (메뉴 데이터 + 로딩 상태 관리)
    @StateObject private var vm = MealViewModel()
    
    // 🔽 "자세히 보기" sheet 표시 여부 상태값
    @State private var isShowingDetail: Bool = false
    
    var body: some View {
        // 🔁 세로 방향으로 스크롤 가능한 컨테이너
        ScrollView {
            VStack(spacing: 24) {
                
                // 🍽 앱 제목
                Text("오늘 뭐 먹지?")
                    .font(.largeTitle)                 // 큰 제목 폰트
                    .bold()                            // 굵게
                    .padding(.top, 24)                 // 상단 여백
                    .frame(maxWidth: .infinity, alignment: .center)
                
                // ⚙️ 상태에 따라 다른 화면 표시
                if vm.isLoading {
                    // 1️⃣ 로딩 중일 때
                    ProgressView("메뉴 추천 중...")
                        .padding(.top, 40)
                } else if let meal = vm.meal {
                    // 2️⃣ 정상적으로 받아온 메뉴가 있을 때
                    
                    // 🖼 음식 이미지
                    if let thumb = meal.strMealThumb,
                       let url = URL(string: thumb) {
                        
                        AsyncImage(url: url) { image in
                            image
                                .resizable()           // 리사이즈 가능하게
                                .scaledToFit()         // 비율 유지하며 화면에 맞추기
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(height: 260)            // 이미지 높이
                        .clipShape(
                            RoundedRectangle(cornerRadius: 24)  // 둥근 모서리 카드 형태
                        )
                        .shadow(radius: 8)             // 살짝 그림자
                    }
                    
                    // 🍜 메뉴 이름
                    Text(meal.strMeal)
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // #카테고리 표시
                    if let category = meal.strCategory {
                        Text("# \(category)")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    
                    // 📄 조리 설명 (요약본: 일부만 보여주기)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("조리 방법")
                            .font(.headline)
                        
                        Text(
                            vm.translatedInstructions        // 번역된 한글이 있으면 우선 사용
                            ?? meal.strInstructions          // 없다면 원문 영어 사용
                            ?? "설명이 없습니다."
                        )
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(5)                       // 메인 화면에서는 최대 5줄까지만
                        
                        // 🔍 전체 레시피를 보고 싶을 때 열리는 버튼
                        Button {
                            isShowingDetail = true          // sheet 표시 상태를 true로 변경
                        } label: {
                            Text("자세히 보기")
                                .font(.subheadline)
                                .underline()
                        }
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                } else if let error = vm.errorMessage {
                    // 3️⃣ 에러가 발생했을 때
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    // 4️⃣ 아직 아무 데이터도 없을 때 (최초 진입 직후 잠깐)
                    Text("아직 메뉴가 없습니다.\n아래 버튼을 눌러 메뉴를 추천받아보세요!")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.top, 40)
                }
                
                // 🔘 "다시 추천" 버튼 – 새로운 랜덤 메뉴 요청
                Button {
                    Task {
                        await vm.loadRandomMeal()         // 비동기로 API 호출
                    }
                } label: {
                    Text(vm.isLoading ? "불러오는 중..." : "다시 추천")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.isLoading)                   // 로딩 중에는 중복 클릭 방지
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
        .scrollIndicators(.hidden)                        // 스크롤바 숨기기 (깔끔하게)
        .task {
            // ⭐ 화면이 처음 나타날 때 자동으로 한 번 메뉴를 불러오기
            await vm.loadRandomMeal()
        }
        // 🪟 "자세히 보기" sheet – 전체 레시피 전용 화면
        .sheet(isPresented: $isShowingDetail) {
            if let meal = vm.meal {
                MealDetailSheet(
                    title: meal.strMeal,
                    fullText: vm.translatedInstructions
                        ?? meal.strInstructions
                        ?? "설명이 없습니다."
                )
            }
        }
    }
}

// 📄 하단에서 올라오는 상세 레시피 sheet View
struct MealDetailSheet: View {
    let title: String          // 메뉴 이름
    let fullText: String       // 전체 조리 설명 (한글 번역 or 영어)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(title)
                        .font(.title2)
                        .bold()
                        .padding(.top, 8)
                    
                    Text(fullText)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                }
                .padding()
            }
            .navigationTitle("레시피 상세")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// 🔍 Xcode Canvas 미리보기
#Preview {
    ContentView()
}
