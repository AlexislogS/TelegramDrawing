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
  
  @Binding var color: Color
  @Binding var isBrushDefaultValueSet: Bool
  @Binding var brushProgress: CGFloat
  @Binding var brushOffset: CGFloat
  
  private let maxBrushHeight: CGFloat = 84
  
  var body: some View {
    ZStack {
      Image(tip)
        .colorMultiply(color)
      Image(base)
      ZStack(alignment: .top) {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
          .fill(.clear)
          .frame(width: 102, height: 84)
        RoundedRectangle(cornerRadius: 6, style: .continuous)
          .fill(color)
          .frame(width: 102, height: brushOffset)
      }
    }
    .onAppear {
      if !isBrushDefaultValueSet {
        isBrushDefaultValueSet = true
        setOffset(translation: maxBrushHeight * 0.3)
      }
    }
    .onChange(of: brushProgress) { newValue in
      setOffset(translation: maxBrushHeight * newValue)
    }
  }
  
  private func setOffset(translation: CGFloat) {
    brushOffset = translation
    let max = maxBrushHeight
    brushOffset = brushOffset > max ? max : brushOffset
    brushOffset = brushOffset >= 0 ? brushOffset : 0
  }
}

struct BrushView_Previews: PreviewProvider {
  static var previews: some View {
    BrushView(tip: "tipneon", base: "brush", color: .constant(.cyan), isBrushDefaultValueSet: .constant(false), brushProgress: .constant(0), brushOffset: .constant(0))
  }
}
