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
  @State private var sliderProgress: CGFloat = 0.3
  @State private var lastDragValue: CGFloat = 0
  @State private var sliderOffset: CGFloat = 0
  @State private var selectedBrush = 0
  @State private var isDrawing = false
  @State private var isSliderDefaultValueSet = false
  
  private let sliderMaxLineWidth: CGFloat = 20
  private let brushes = ["brush", "pen", "pencil"]
  
  var body: some View {
    if let image = image {
      NavigationView {
        VStack {
          Canvas { context, size in
            for line in lines {
              var path = Path()
              path.addLines(line.points)
              context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
            }
          }
          .background(Image(uiImage: image)
            .resizable())
          .gesture(DragGesture()
            .onChanged({ value in
              let newPoint = value.location
              if isDrawing, var lastLine = lines.popLast() {
                lastLine.points.append(newPoint)
                lines.append(lastLine)
                currentLine = lastLine
              } else {
                isDrawing = true
                let lineWidth = max(sliderProgress, 0.01) * sliderMaxLineWidth
                currentLine = Line(color: color, lineWidth: lineWidth)
                currentLine.points.append(newPoint)
                lines.append(currentLine)
              }
            })
              .onEnded({ value in
                isDrawing = false
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
                CapsuleSliderView(color: $color, sliderProgress: $sliderProgress, lastDragValue: $lastDragValue, sliderOffset: $sliderOffset, isDefaultValueSet: $isSliderDefaultValueSet)
                  .onChange(of: sliderProgress) { newValue in
                    let lineWidth = max(newValue, 0.01) * sliderMaxLineWidth
                    currentLine.lineWidth = lineWidth
                  }
              }
            }
            .frame(height: 60)
          } else {
            HStack(spacing: -16) {
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
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button(action: {
              lines.removeLast()
            }, label: {
              Image("undo")
                .resizable()
                .frame(width: 24, height: 24)
            })
            .disabled(lines.isEmpty)
            .opacity(lines.isEmpty ? 0.5 : 1)
          }
          ToolbarItem(placement: .navigationBarTrailing) {
            Button("Clear All") {
              lines.removeAll()
            }
            .disabled(lines.isEmpty)
            .opacity(lines.isEmpty ? 0.5 : 1)
            .foregroundColor(.white)
          }
        }
        .background(Color.black)
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
