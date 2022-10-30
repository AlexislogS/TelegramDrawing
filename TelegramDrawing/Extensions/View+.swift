//
//  View+.swift
//  TelegramDrawing
//
//  Created by Alex Yatsenko on 30.10.2022.
//

import SwiftUI

extension View {
    func snapshot() -> UIImage {
      let controller = UIHostingController(rootView: self)
      let view = controller.view
      
      let targetSize = controller.view.intrinsicContentSize
      view?.bounds = CGRect(origin: .zero, size: targetSize)
      view?.backgroundColor = .black
      
      let renderer = UIGraphicsImageRenderer(size: targetSize)
      
      return renderer.image { _ in
        view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
      }
    }
}
