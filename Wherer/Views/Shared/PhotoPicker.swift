import SwiftUI

struct PhotoPickerPresenter: UIViewControllerRepresentable {
    @Binding var photoSource: PhotoSource?
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard let source = photoSource else { return }
        guard let window = uiViewController.view.window,
              let rootVC = window.rootViewController else { return }

        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        guard !(topVC is UIImagePickerController) else { return }

        let picker = UIImagePickerController()
        picker.modalPresentationStyle = .fullScreen

        if UIImagePickerController.isSourceTypeAvailable(source.sourceType) {
            picker.sourceType = source.sourceType
        } else {
            picker.sourceType = .photoLibrary
        }
        picker.delegate = context.coordinator

        topVC.present(picker, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: PhotoPickerPresenter

        init(_ parent: PhotoPickerPresenter) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true) { [weak self] in
                self?.parent.photoSource = nil
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true) { [weak self] in
                self?.parent.photoSource = nil
            }
        }
    }
}
