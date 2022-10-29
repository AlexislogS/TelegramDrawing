//
//  BrushView.swift
//  TelegramDrawing
//
//  Created by Alex Yatsenko on 29.10.2022.
//

import SwiftUI

struct BrushView: View {
  
  let tip: String
  let base: String
  
  var body: some View {
    ZStack {
      Image(tip)
        .colorMultiply(.cyan)
      Image(base)
      RoundedRectangle(cornerRadius: 6, style: .continuous)
        .fill(.cyan)
        .frame(width: 102, height: 84)
        .offset(x: 0, y: -24)
    }
  }
}

struct BrushView_Previews: PreviewProvider {
  static var previews: some View {
    BrushView(tip: "neon", base: "brush")
  }
}
