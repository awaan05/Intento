//
//import SwiftUI
//
//struct CapsuleTransformButton: View {
//    @State private var isAnimating = false
//    @State private var width: CGFloat = 200
//
//    var body: some View {
//        Button(action: {
//            withAnimation(.spring()) {
//                isAnimating = true
//                width = 300
//            }
//            withAnimation(.linear(duration: 5)) {
//                width = 0
//            }
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                withAnimation(.spring()) {
//                    width = 200
//                    isAnimating = false
//                }
//            }
//        }) {
//            Capsule()
//                .fill(Color.black)
//                .frame(width: width, height: 50)
//        }
//    }
//}
//
//#Preview {
//    CapsuleTransformButton()
//}
//
