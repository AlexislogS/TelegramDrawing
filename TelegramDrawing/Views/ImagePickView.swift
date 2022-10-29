//
//  ImagePickView.swift
//  TelegramDrawing
//
//  Created by Alex Yatsenko on 29.10.2022.
//

import SwiftUI
import PhotosUI

struct ImagePickView: View {
  
  @Binding var image: UIImage?
  @State private var selectedItems = [PhotosPickerItem]()
  
  var body: some View {
    PhotosPicker(selection: $selectedItems, maxSelectionCount: 1, matching: .images) {
      Text("Choose photo")
        .foregroundColor(.white)
        .padding()
        .frame(width: 300)
        .background(Color.cyan)
        .cornerRadius(15)
    }.onChange(of: selectedItems) { newValue in
      getImage(from: newValue.first)
    }
  }
  
  private func getImage(from item: PhotosPickerItem?) {
    guard let item = item else { return }
    item.loadTransferable(type: Data.self) { result in
      switch result {
      case .success(let data):
        if let data = data, let image = UIImage(data: data) {
          self.image = image
        }
      case .failure(let error):
        print("Image error", error.localizedDescription)
        getImage(from: item)
      }
    }
  }
}

struct ImagePickView_Previews: PreviewProvider {
  static var previews: some View {
    ImagePickView(image: .constant(nil))
  }
}
