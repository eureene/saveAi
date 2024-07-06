import SwiftUI
import Firebase
import FirebaseStorage

struct ImageInfo: Identifiable {
    let id: UUID
    let url: URL
    let date: Date
}

struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct CameraTab: View {
    @Binding var showCamera: Bool
    @Binding var image: UIImage?
    @Binding var selectedTab: Int
    @State private var isSaving = false
    @State private var saveError: SaveError?
    @State private var isUploadComplete = false
    @State private var images: [ImageInfo] = []
    @State private var isLoading = true
    @State private var selectedImageURL: IdentifiableURL?

    var body: some View {
        VStack {
            if let image = image {
                VStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                    Button(action: saveImage) {
                        Text("Enregistrer")
                            .font(.title)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(isSaving)
                    .padding()
                    
                    if isSaving {
                        ProgressView("Televersement...")
                            .padding()
                    }
                }
                .padding()
            } else {
                if isUploadComplete {
                    Text("Televersement Complete!")
                        .foregroundColor(.green)
                        .padding()
                }
                
                if isLoading {
                    ProgressView("chargement recus...")
                        .padding()
                } else {
                    ScrollView {
                        ForEach(Array(images.enumerated()), id: \.element.id) { index, imageInfo in
                            VStack(alignment: .leading) {
                                Text("Reçu du \(formattedDate(imageInfo.date))")
                                    .font(.caption)
                                    .padding([.top, .leading])
                                AsyncImage(url: imageInfo.url) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 150)
                                            .clipped()
                                            .onTapGesture {
                                                let tappedIndex = index
                                                if tappedIndex > 0 {
                                                    selectedImageURL = IdentifiableURL(url: images[tappedIndex - 1].url)
                                                }
                                            }
                                    } else if phase.error != nil {
                                        Color.red // Indicates an error.
                                            .frame(height: 150)
                                    } else {
                                        Color.gray // Acts as a placeholder.
                                            .frame(height: 150)
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    showCamera = true
                }) {
                    Text("Prendre photo")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .onAppear(perform: loadImages)
        .alert(item: $saveError) { error in
            Alert(title: Text("Erreur"), message: Text(error.localizedDescription), dismissButton: .default(Text("OK")))
        }
        .sheet(item: $selectedImageURL) { identifiableURL in
            FullImageView(url: identifiableURL.url)
        }
    }

    private func saveImage() {
        guard let image = image, let user = Auth.auth().currentUser else { return }
        isSaving = true
        isUploadComplete = false

        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageName = user.uid + "_" + UUID().uuidString // Using user UID and a unique identifier
        let imageRef = storageRef.child("images/\(imageName).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        imageRef.putData(imageData, metadata: metadata) { metadata, error in
            isSaving = false
            if let error = error {
                saveError = SaveError(id: UUID(), localizedDescription: error.localizedDescription)
                return
            }
            imageRef.downloadURL { url, error in
                guard let url = url else {
                    if let error = error {
                        saveError = SaveError(id: UUID(), localizedDescription: error.localizedDescription)
                    }
                    return
                }
                let imageInfo = ImageInfo(id: UUID(), url: url, date: Date())
                images.insert(imageInfo, at: 0) // Add the new image to the top of the list
                isUploadComplete = true
                
                // Trigger the Node.js server to process the latest image
                let serverURL = URL(string: "http://37.27.16.160:3500/triggerUpload")! // Adjust the URL if necessary
                var request = URLRequest(url: serverURL)
                request.httpMethod = "GET"

                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("Error triggering Node.js server: \(error)")
                        return
                    }
                    print("Successfully triggered Node.js server")
                }.resume()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    isUploadComplete = false
                    selectedTab = 1 // Navigate to the CameraTab view
                    showCamera = false // Dismiss the camera view
                    self.image = nil // Reset the image state
                }
            }
        }
    }
    
    private func loadImages() {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("images")
        
        storageRef.listAll { (result, error) in
            if let error = error {
                print("Error listing images: \(error)")
                self.isLoading = false
                return
            }
            
            guard let result = result else {
                print("No result found")
                self.isLoading = false
                return
            }
            
            var loadedImages: [ImageInfo] = []
            let group = DispatchGroup()
            
            for item in result.items {
                group.enter()
                item.getMetadata { metadata, error in
                    guard let metadata = metadata else {
                        group.leave()
                        return
                    }
                    let date = metadata.timeCreated ?? Date()
                    item.downloadURL { url, error in
                        if let url = url {
                            let imageInfo = ImageInfo(id: UUID(), url: url, date: date)
                            loadedImages.append(imageInfo)
                        }
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.images = loadedImages.sorted(by: { $0.date > $1.date })
                self.isLoading = false
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct FullImageView: View {
    let url: URL
    
    var body: some View {
        VStack {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                } else if phase.error != nil {
                    Color.red // Indicates an error.
                } else {
                    Color.gray // Acts as a placeholder.
                }
            }
            .padding()
        }
    }
}

struct SaveError: Identifiable {
    let id: UUID
    let localizedDescription: String
}
