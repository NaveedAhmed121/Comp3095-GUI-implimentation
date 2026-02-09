import SwiftUI

struct LaunchScreen: View {
    @Binding var isPresented: Bool
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.8),
                    Color.blue.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // APP ICON
                Image(systemName: "cart.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                // APP NAME
                VStack(spacing: 10) {
                    Text("ShopCart")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Smart Shopping Made Simple")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                // TEAM INFO
                VStack(alignment: .center, spacing: 12) {
                    Text("Developed by")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .tracking(0.5)
                    
                    VStack(alignment: .center, spacing: 4) {
                        Text("Naveed Ahmed")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.white)
                        
                        Text("Student ID: 101416034")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("Completed by Naveed")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 30)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                
                Spacer()
                
                // LOADING INDICATOR
                ProgressView()
                    .tint(.white)
                
                Spacer()
                    .frame(height: 40)
            }
            .padding(30)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                opacity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    isPresented = false
                }
            }
        }
    }
}

#Preview {
    LaunchScreen(isPresented: .constant(true))
}
