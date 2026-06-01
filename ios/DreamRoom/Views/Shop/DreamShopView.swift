import SwiftUI

struct DreamShopView: View {
    @StateObject var kitService = DreamKitService.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedKit: DreamKit?
    @State private var showingPurchaseSuccess = false
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.05, green: 0.05, blue: 0.08)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.down")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("Dream Shop")
                        .font(.custom("CormorantGaramond-Bold", size: 28))
                        .foregroundColor(.gold)
                    Spacer()
                    // Dummy space for balance
                    Image(systemName: "chevron.down").opacity(0)
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Text("Enhance your vision with curated dream kits. Each kit unlocks cinematic assets and specialized textures.")
                            .font(.custom("CormorantGaramond-MediumItalic", size: 18))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        ForEach(kitService.availableKits) { kit in
                            KitCard(kit: kit) {
                                selectedKit = kit
                            }
                        }
                    }
                    .padding()
                }
            }
            
            if let kit = selectedKit {
                PurchaseModal(kit: kit, isPresented: Binding(
                    get: { selectedKit != nil },
                    set: { if !$0 { selectedKit = nil } }
                )) {
                    kitService.purchaseKit(kitId: kit.id)
                    selectedKit = nil
                    withAnimation {
                        showingPurchaseSuccess = true
                    }
                    // Dismiss success after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showingPurchaseSuccess = false
                        }
                    }
                }
            }
            
            if showingPurchaseSuccess {
                VStack {
                    Spacer()
                    Text("Dream Unlocked")
                        .font(.custom("CormorantGaramond-Bold", size: 24))
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.gold)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    Spacer().frame(height: 50)
                }
            }
        }
    }
}

struct KitCard: View {
    let kit: DreamKit
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                ZStack(alignment: .bottomTrailing) {
                    // Placeholder for kit cover image
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(colors: [.gray.opacity(0.3), .black.opacity(0.6)]), startPoint: .top, endPoint: .bottom))
                        .aspectRatio(16/9, contentMode: .fit)
                        .cornerRadius(12)
                    
                    if kit.isPurchased {
                        Text("UNLOCKED")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(8)
                            .background(Color.gold)
                            .foregroundColor(.black)
                            .cornerRadius(4)
                            .padding(12)
                    } else {
                        Text(kit.price)
                            .font(.system(size: 14, weight: .bold))
                            .padding(8)
                            .background(Color.black.opacity(0.8))
                            .foregroundColor(.gold)
                            .cornerRadius(4)
                            .padding(12)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(kit.name)
                        .font(.custom("CormorantGaramond-Bold", size: 22))
                        .foregroundColor(.white)
                    
                    Text(kit.description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

struct PurchaseModal: View {
    let kit: DreamKit
    @Binding var isPresented: Bool
    let onConfirm: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture { isPresented = false }
            
            VStack(spacing: 24) {
                Text("Unlock Dream")
                    .font(.custom("CormorantGaramond-Bold", size: 28))
                    .foregroundColor(.gold)
                
                Text("Confirm your purchase of '\(kit.name)' to immediately unlock its premium assets for your vision boards.")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    Button(action: onConfirm) {
                        Text(kit.isPurchased ? "Re-download" : "Unlock for \(kit.price)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gold)
                            .cornerRadius(12)
                    }
                    
                    Button(action: { isPresented = false }) {
                        Text("Cancel")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(32)
            .background(Color(red: 0.1, green: 0.1, blue: 0.15))
            .cornerRadius(24)
            .padding(24)
            .shadow(color: .gold.opacity(0.2), radius: 20)
        }
    }
}
