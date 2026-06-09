import SwiftUI

struct DreamShopView: View {
    @StateObject var kitService = DreamKitService.shared
    @StateObject var subService = SubscriptionService.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var previewingKit: DreamKit?
    @State private var selectedKit: DreamKit?
    @State private var showingPurchaseSuccess = false
    @State private var showingSubscriptionSuccess = false
    
    var body: some View {
        ZStack {
            // Background
            Color.dreamBackground
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
                    Text("The Dream Shop")
                        .font(.custom(DreamTheme.boldFontName, size: 28))
                        .foregroundColor(.gold)
                    Spacer()
                    Image(systemName: "chevron.down").opacity(0)
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Builder Plan Promotion
                        BuilderPlanCard(
                            isPurchased: subService.currentLevel == .builder,
                            isPurchasing: subService.isPurchasing
                        ) {
                            subService.purchaseBuilderPlan()
                        }
                        
                        VStack(spacing: 24) {
                    HStack {
                        Text("CURATED DREAM KITS")
                            .font(.custom(DreamTheme.boldFontName, size: 24))
                            .foregroundColor(.gold)
                            .kerning(1.5)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Text("Enhance your vision with curated dream kits. Each kit unlocks cinematic assets and specialized textures.")
                        .font(.custom(DreamTheme.italicFontName, size: 18))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                            
                            ForEach(kitService.availableKits) { kit in
                                KitCard(kit: kit) {
                                    previewingKit = kit
                                }
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            
            if let kit = previewingKit {
                KitPreviewView(kit: kit, isPresented: Binding(
                    get: { previewingKit != nil },
                    set: { if !$0 { previewingKit = nil } }
                ), onPurchase: {
                    selectedKit = kit
                    previewingKit = nil
                })
                .transition(.move(edge: .bottom))
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showingPurchaseSuccess = false
                        }
                    }
                }
            }
            
            if showingPurchaseSuccess || showingSubscriptionSuccess {
                SuccessToast(message: showingSubscriptionSuccess ? "Builder Plan Active" : "Dream Unlocked")
            }
        }
        .onChange(of: subService.currentLevel) { level in
            if level == .builder {
                withAnimation {
                    showingSubscriptionSuccess = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showingSubscriptionSuccess = false
                    }
                }
            }
        }
    }
}

struct BuilderPlanCard: View {
    let isPurchased: Bool
    let isPurchasing: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gold, lineWidth: 2)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0.1, green: 0.09, blue: 0.15), Color.dreamBackground]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .cornerRadius(20)
                    )
                
                VStack(spacing: 20) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("THE BUILDER PLAN")
                                .font(.custom(DreamTheme.boldFontName, size: 28))
                                .foregroundColor(.gold)
                            
                            Text("Become a Gathering Leader")
                                .font(.custom(DreamTheme.italicFontName, size: 18))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 0) {
                            Text("$4.99")
                                .font(.custom(DreamTheme.boldFontName, size: 42))
                                .foregroundColor(.gold)
                            Text("PER MONTH")
                                .font(.custom(DreamTheme.boldFontName, size: 12))
                                .foregroundColor(Color.sapphire)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        BenefitRow(text: "• Host unlimited gatherings")
                        BenefitRow(text: "• Exclusive luxury asset libraries")
                        BenefitRow(text: "• High-resolution board exports")
                    }
                    
                    Button(action: action) {
                        HStack {
                            if isPurchasing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .dreamBackground))
                                    .padding(.trailing, 8)
                            }
                            Text(isPurchased ? "ACTIVE MEMBER" : (isPurchasing ? "ACTIVATING..." : "UPGRADE NOW"))
                                .font(.custom(DreamTheme.boldFontName, size: 18))
                        }
                        .foregroundColor(.dreamBackground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(isPurchased ? Color.gold.opacity(0.5) : Color.gold)
                        .cornerRadius(25)
                    }
                    .disabled(isPurchased || isPurchasing)
                }
                .padding(30)
            }
        }
        .padding(.horizontal)
    }
}

struct BenefitRow: View {
    let text: String
    var body: some View {
        HStack(spacing: 12) {
            Text(text)
                .font(.custom(DreamTheme.fontName, size: 14))
                .foregroundColor(Color.sapphire)
            Spacer()
        }
    }
}

struct SuccessToast: View {
    let message: String
    var body: some View {
        VStack {
            Spacer()
            Text(message)
                .font(.custom(DreamTheme.boldFontName, size: 24))
                .foregroundColor(.black)
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(Color.gold)
                .cornerRadius(30)
                .shadow(color: .gold.opacity(0.3), radius: 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            Spacer().frame(height: 50)
        }
    }
}

struct KitCard: View {
    let kit: DreamKit
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(red: 0.08, green: 0.07, blue: 0.13))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.sapphire.opacity(0.3), lineWidth: 0.5)
                        )
                    
                    VStack(spacing: 0) {
                        // Kit cover image placeholder
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(red: 0.15, green: 0.13, blue: 0.17))
                            
                            Text(kit.coverImageName.components(separatedBy: "/").first?.capitalized ?? "Dream")
                                .font(.custom(DreamTheme.italicFontName, size: 24))
                                .foregroundColor(.gold)
                                .opacity(0.4)
                        }
                        .padding(20)
                        .frame(height: 180)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(kit.name)
                                .font(.custom(DreamTheme.boldFontName, size: 20))
                                .foregroundColor(.white)
                            
                            Text(kit.description)
                                .font(.custom(DreamTheme.fontName, size: 14))
                                .foregroundColor(Color.sapphire.opacity(0.8))
                                .lineLimit(1)
                            
                            HStack {
                                Text(kit.price)
                                    .font(.custom(DreamTheme.boldFontName, size: 24))
                                    .foregroundColor(.gold)
                                
                                Spacer()
                                
                                if kit.isPurchased {
                                    Text("UNLOCKED")
                                        .font(.custom(DreamTheme.boldFontName, size: 12))
                                        .foregroundColor(.gold)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.gold.opacity(0.1))
                                        .cornerRadius(20)
                                } else {
                                    Text("UNLOCK")
                                        .font(.custom(DreamTheme.boldFontName, size: 12))
                                        .foregroundColor(.gold)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 10)
                                        .background(Color.gold.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.gold, lineWidth: 1)
                                        )
                                        .cornerRadius(20)
                                }
                            }
                            .padding(.top, 10)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
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
                    .font(.custom(DreamTheme.boldFontName, size: 28))
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

struct KitPreviewView: View {
    let kit: DreamKit
    @Binding var isPresented: Bool
    let onPurchase: () -> Void
    @State private var currentAssetIndex = 0
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Asset Carousel
                TabView(selection: $currentAssetIndex) {
                    ForEach(0..<kit.assets.count, id: \.self) { index in
                        ZStack {
                            Rectangle()
                                .fill(LinearGradient(gradient: Gradient(colors: [Color(red: 0.1, green: 0.1, blue: 0.12), .black]), startPoint: .top, endPoint: .bottom))
                            
                            VStack {
                                Spacer()
                                if kit.assets[index].hasSuffix(".m4a") {
                                    VStack(spacing: 20) {
                                        Image(systemName: "waveform")
                                            .font(.system(size: 80))
                                            .foregroundColor(.gold)
                                        Text("Soundscape Preview")
                                            .font(.custom(DreamTheme.boldFontName, size: 24))
                                            .foregroundColor(.white)
                                        Text(kit.assets[index].replacingOccurrences(of: ".m4a", with: ""))
                                            .font(.custom(DreamTheme.italicFontName, size: 18))
                                            .foregroundColor(.secondary)
                                        
                                        Button(action: { /* Play sound mock */ }) {
                                            HStack {
                                                Image(systemName: "play.fill")
                                                Text("Listen")
                                            }
                                            .padding()
                                            .background(Color.gold.opacity(0.2))
                                            .cornerRadius(30)
                                            .foregroundColor(.gold)
                                        }
                                    }
                                } else {
                                    VStack {
                                        Image(systemName: "photo")
                                            .font(.system(size: 60))
                                            .foregroundColor(.gold.opacity(0.3))
                                        Text("Preview: \(kit.assets[index])")
                                            .font(.custom(DreamTheme.italicFontName, size: 18))
                                            .foregroundColor(.gold.opacity(0.6))
                                    }
                                }
                                Spacer()
                            }
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(maxHeight: .infinity)
                
                // Bottom Info
                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(kit.name)
                                .font(.custom(DreamTheme.boldFontName, size: 32))
                                .foregroundColor(.white)
                            Text("Asset \(currentAssetIndex + 1) of \(kit.assets.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(kit.price)
                            .font(.custom(DreamTheme.boldFontName, size: 24))
                            .foregroundColor(.gold)
                    }
                    .padding(.horizontal)
                    
                    Text(kit.description)
                        .font(.custom(DreamTheme.italicFontName, size: 18))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal)
                    
                    HStack(spacing: 16) {
                        Button(action: { isPresented = false }) {
                            Text("Close")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        Button(action: onPurchase) {
                            Text(kit.isPurchased ? "Unlocked" : "Purchase Kit")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gold)
                                .cornerRadius(12)
                        }
                        .disabled(kit.isPurchased)
                    }
                    .padding()
                }
                .padding(.vertical, 30)
                .background(
                    LinearGradient(gradient: Gradient(colors: [.black, Color(red: 0.05, green: 0.05, blue: 0.08)]), startPoint: .top, endPoint: .bottom)
                )
            }
            
            // Dismiss button top right
            VStack {
                HStack {
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.5))
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}
