import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewModel()
    @State private var isEditing = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.gold.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "person.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.gold)
                }
                .padding(.top, 40)
                
                if isEditing {
                    TextField("Name", text: $viewModel.userProfile.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    TextEditor(text: $viewModel.userProfile.bio)
                        .frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                        .padding(.horizontal)
                } else {
                    Text(viewModel.userProfile.name)
                        .font(.custom("CormorantGaramond-Bold", size: 28))
                    
                    Text(viewModel.userProfile.bio)
                        .font(.custom("CormorantGaramond-Italic", size: 18))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isEditing.toggle()
                    }
                }) {
                    Text(isEditing ? "Save Profile" : "Edit Profile")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gold)
                        .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Your Soul")
            .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
        }
    }
}

struct PrivacySettingsView: View {
    @Binding var settings: BoardSettings
    
    var body: some View {
        List {
            Section(header: Text("Board Privacy")) {
                ForEach(BoardPrivacy.allCases, id: \.self) { privacy in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(privacy.rawValue)
                                .font(.headline)
                            Text(privacy.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if settings.privacy == privacy {
                            Image(systemName: "checkmark")
                                .foregroundColor(.gold)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        settings.privacy = privacy
                    }
                }
            }
        }
        .navigationTitle("Privacy Settings")
    }
}
