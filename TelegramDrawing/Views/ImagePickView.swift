//
//  ImagePickView.swift
//  TelegramDrawing
//
//  Created by Alex Yatsenko on 29.10.2022.
//

import SwiftUI

struct ImagePickView: View {
  
  @Binding var image: UIImage?
  @State private var isLoading = false
  @State private var showImagePicker: Bool = false
  
  var body: some View {
    ZStack {
      Button(action: {
        isLoading = true
        showImagePicker = true
      }, label: {
        Text("Choose photo")
          .foregroundColor(.white)
          .padding()
          .frame(width: 300)
          .background(Color.cyan)
          .cornerRadius(15)
      })
      .sheet(isPresented: $showImagePicker) {
        ImagePicker(sourceType: .photoLibrary) { image in
          self.image = image
          self.isLoading = false
        }
      }
      if isLoading {
        ProgressView()
          .scaleEffect(1.5, anchor: .center)
          .disabled(true)
      }
    }
  }
}

struct ImagePickView_Previews: PreviewProvider {
  static var previews: some View {
    ImagePickView(image: .constant(nil))
  }
}

struct ImagePicker: UIViewControllerRepresentable {
  
  @Environment(\.presentationMode)
  private var presentationMode
  
  let sourceType: UIImagePickerController.SourceType
  let onImagePicked: (UIImage) -> Void
  
  final class Coordinator: NSObject,
                           UINavigationControllerDelegate,
                           UIImagePickerControllerDelegate {
    
    @Binding
    private var presentationMode: PresentationMode
    private let sourceType: UIImagePickerController.SourceType
    private let onImagePicked: (UIImage) -> Void
    
    init(presentationMode: Binding<PresentationMode>,
         sourceType: UIImagePickerController.SourceType,
         onImagePicked: @escaping (UIImage) -> Void) {
      _presentationMode = presentationMode
      self.sourceType = sourceType
      self.onImagePicked = onImagePicked
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
      onImagePicked(uiImage)
      presentationMode.dismiss()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      presentationMode.dismiss()
    }
    
  }
  
  func makeCoordinator() -> Coordinator {
    return Coordinator(presentationMode: presentationMode,
                       sourceType: sourceType,
                       onImagePicked: onImagePicked)
  }
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.sourceType = sourceType
    picker.delegate = context.coordinator
    return picker
  }
  
  func updateUIViewController(_ uiViewController: UIImagePickerController,
                              context: UIViewControllerRepresentableContext<ImagePicker>) {
    
  }
}
