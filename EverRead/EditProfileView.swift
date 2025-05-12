import SwiftUI

struct EditProfileView: View {
    @State private var selectedTab: Tab = .Activity
    @EnvironmentObject var session: UserSession
    @StateObject private var dataManager = DataManager()
    @AppStorage("authToken") var token = ""

    @State private var bioText = ""
    @State private var nameText = ""
    @State private var selectedImage: UIImage?
    @State private var isShowingPicker = false
    @State private var StatusMessage: String?
    @State private var showUploadAlert = false

    private let apiService = ProfileEditAPIService()

    var body: some View {
        let user = dataManager.user

        ZStack {
            Color.softWhitePink.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack {
                        Text("Edit profile")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.bottom, 5)
                        Divider()

                        ProfileCard(
                            name: user?.username ?? "username",
                            bookRead: String(user?.book_read ?? 0),
                            reading: String(user?.reading ?? 0),
                            review: String(user?.review ?? 0),
                            follower: "432",
                            following: "87",
                            profile: user?.profile_img ?? "",
                            bio: user?.bio ?? ""
                        )

                        Divider()
                    }

                    VStack(alignment: .leading, spacing: 15) {
                        // MARK: Profile Image Upload Section
                        Text("Upload profile image").font(.headline)

                        Button("Pick & Upload Image") {
                            isShowingPicker = true
                        }.padding(8).frame(width: 350).background(Color.redPink).cornerRadius(16)
                        // MARK: Name and Bio Update Section
                        Text("Change your name").font(.headline).padding(.top)
                        TextField("Your new name", text: $nameText)
                            .padding(6)
                            .background(Color.white)
                            .border(Color.gray.opacity(0.3))
                            .cornerRadius(5)

                        Text("Change your Bio").font(.headline).padding(.top)
                        TextEditor(text: $bioText)
                            .frame(height: 100)
                            .border(Color.gray.opacity(0.3))
                            .cornerRadius(5)
                            .overlay(
                                bioText.isEmpty ? Text("Sharing your biography")
                                    .foregroundColor(.gray.opacity(0.6))
                                    .padding(8)
                                    .allowsHitTesting(false) : nil,
                                alignment: .topLeading
                            )

                        Button("Submit Changes") {
                            editProfileText(username: nameText, bio: bioText, token: token)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(nameText.isEmpty && bioText.isEmpty)
                    }
                    .frame(width: 350)
                }
            }
            .foregroundColor(.darkPinkBrown)
            .onAppear {
                dataManager.fetchUser()
            }
            .sheet(isPresented: $isShowingPicker) {
                ImagePicker(
                    image: $selectedImage,
                    userToken: token,
                    uploadHandler: { image, token, completion in
                        apiService.uploadProfileImage(image: image, userToken: token) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(_):
                                    StatusMessage = "Profile image uploaded successfully!"
                                    dataManager.fetchUser()
                                case .failure(let error):
                                    StatusMessage = "Upload failed: \(error.localizedDescription)"
                                }
                                showUploadAlert = true
                            }
                            completion(result)
                        }
                    }
                )
            }
            .alert(isPresented: $showUploadAlert) {
                Alert(title: Text("Change Status"), message: Text(StatusMessage ?? ""), dismissButton: .default(Text("OK")))
            }
        }
    }
    func editProfileText(username: String, bio: String, token: String){
        apiService.SubmitProfileEdit(username: username, bio: bio, token: token){ result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    StatusMessage = "Update change successfully!"
                    dataManager.fetchUser()
                case .failure(let error):
                    StatusMessage = "Update failed: \(error.localizedDescription)"
                }
                showUploadAlert = true
            }
            }
        }}

#Preview {
    EditProfileView().environmentObject(UserSession())
}
