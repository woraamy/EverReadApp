import SwiftUI
import UIKit

import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?

    let userToken: String
    let uploadHandler: (UIImage, String, @escaping (Result<Data, ProfileEditAPIService.APIError>) -> Void) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage

                // ⬇️ Call the upload handler
                parent.uploadHandler(uiImage, parent.userToken) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let data):
                            print("Upload successful: \(String(data: data, encoding: .utf8) ?? "No response body")")
                        case .failure(let error):
                            print("Upload failed: \(error.localizedDescription)")
                        }
                    }
                }
            }

            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
