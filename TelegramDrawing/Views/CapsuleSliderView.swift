//
//  CapsuleSliderView.swift
//  TelegramDrawing
//
//  Created by Alex Yatsenko on 29.10.2022.
//

import SwiftUI

struct SliderShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: rect.minX, y: rect.midY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    path.closeSubpath()
    return path
  }
}

struct CapsuleSliderView: View {
  
  @Binding var color: Color
  @Binding var sliderProgress: CGFloat
  @Binding var lastDragValue: CGFloat
  @Binding var sliderOffset: CGFloat
  @Binding var isDefaultValueSet: Bool
  
  private let maxSliderWidth: CGFloat = UIScreen.main.bounds.width * 0.7

  var body: some View {
    ZStack(alignment: .leading) {
      SliderShape()
        .stroke(style: StrokeStyle(lineWidth: 4.0, lineCap: .round))
        .foregroundColor(color)
      SliderShape()
        .foregroundColor(color)
      Circle()
        .foregroundColor(.white)
        .frame(width: 24, height: 24)
        .offset(x: sliderOffset)
        .gesture(DragGesture()
          .onChanged({ value in
            let translation = value.translation
            setOffset(translation: translation.width)
          })
            .onEnded({ value in
              let max = maxSliderWidth - 24
              sliderOffset = sliderOffset > max ? max : sliderOffset
              sliderOffset = sliderOffset >= 0 ? sliderOffset : 0
              lastDragValue = sliderOffset
            }))
        .onAppear {
          if !isDefaultValueSet {
            isDefaultValueSet = true
            setOffset(translation: maxSliderWidth * sliderProgress)
            lastDragValue = sliderOffset
          }
        }
    }
    .frame(width: maxSliderWidth, height: 24)
    .cornerRadius(35)
  }
  
  private func setOffset(translation: CGFloat) {
    sliderOffset = translation + lastDragValue
    let max = maxSliderWidth - 24
    sliderOffset = sliderOffset > max ? max : sliderOffset
    sliderOffset = sliderOffset >= 0 ? sliderOffset : 0
    let progress = sliderOffset / max
    sliderProgress = progress <= 1 ? progress : 1
  }
}

struct CapsuleSliderView_Previews: PreviewProvider {
  static var previews: some View {
    CapsuleSliderView(color: .constant(.cyan), sliderProgress: .constant(0), lastDragValue: .constant(0), sliderOffset: .constant(0), isDefaultValueSet: .constant(false))
  }
}
