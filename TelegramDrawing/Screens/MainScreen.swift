//
//  MainScreen.swift
//  TelegramDrawing
//
//  Created by Alex Yatsenko on 29.10.2022.
//

import SwiftUI

struct Line {
  var points = [CGPoint]()
  var color: Color = .red
  var lineWidth = 1.0
}

struct MainScreen: View {
  
  @State private var currentLine = Line(color: .cyan)
  @State private var lines = [Line]()
  @State private var colorOpacity = 1.0
  @State private var image: UIImage?
  @State private var color: Color = .cyan
  @State private var showOpacitySlider = false
  @State private var sliderProgress: CGFloat = 0
  @State private var lastDragValue: CGFloat = 0
  @State private var sliderOffset: CGFloat = 0
  @State private var selectedBrush = 0
  
  private let sliderMaxLineWidth: CGFloat = 20
  private let brushes = ["brush", "pen", "pencil"]
  
  var body: some View {
    if let image = image {
      ZStack {
        Image(uiImage: image)
          .resizable()
          .ignoresSafeArea(.all)
        VStack {
          Canvas { context, size in
            for line in lines {
              var path = Path()
              path.addLines(line.points)
              context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
            }
          }.gesture(DragGesture()
            .onChanged({ value in
              let newPoint = value.location
              currentLine.points.append(newPoint)
              lines.append(currentLine)
            })
              .onEnded({ value in
                let lineWidth = max(sliderProgress, 0.01) * sliderMaxLineWidth
                currentLine = Line(color: color, lineWidth: lineWidth)
              })
          )
          if showOpacitySlider {
            VStack {
              BrushView(tip: "tip" + brushes[selectedBrush], base: brushes[selectedBrush])
                .scaleEffect(0.3)
                .offset(y: -85)
                .frame(height: 20)
                .fixedSize(horizontal: false, vertical: true)
              HStack(spacing: 20) {
                Button {
                  withAnimation(.easeOut) {
                    showOpacitySlider = false
                  }
                } label: {
                  Image("back")
                    .resizable()
                    .frame(width: 24, height: 24)
                }
                CapsuleSliderView(color: $color, sliderProgress: $sliderProgress, lastDragValue: $lastDragValue, sliderOffset: $sliderOffset)
                  .onChange(of: sliderProgress) { newValue in
                    let lineWidth = max(newValue, 0.01) * sliderMaxLineWidth
                    currentLine.lineWidth = lineWidth
                  }
              }
            }
          } else {
            HStack(spacing: -20) {
              ColorPicker("", selection: $color)
                .onChange(of: color) { newValue in
                  currentLine.color = newValue
                }
              ForEach(brushes.indices, id: \.self) { index in
                BrushView(tip: brushes[index], base: brushes[index])
                  .scaleEffect(0.4)
                  .onTapGesture {
                    selectedBrush = index
                    withAnimation(.easeIn) {
                      showOpacitySlider = true
                    }
                  }
              }
            }
            .frame(height: 60)
          }
        }
        .padding(.bottom)
      }
    } else {
      ImagePickView(image: $image)
    }
  }
}

struct MainScreen_Previews: PreviewProvider {
  static var previews: some View {
    MainScreen()
  }
}
