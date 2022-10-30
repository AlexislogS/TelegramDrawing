//
//  MainScreen.swift
//  TelegramDrawing
//
//  Created by Alex Yatsenko on 29.10.2022.
//

import SwiftUI

struct MainScreen: View {
  
  @State private var currentLine = Line(color: .cyan)
  @State private var lines = [Line]()
  @State private var colorOpacity = 1.0
  @State private var image: UIImage?
  @State private var color: Color = .cyan
  @State private var showOpacitySlider = false
  @State private var sliderProgress: CGFloat = 0.3
  @State private var lastDragValue: CGFloat = 0
  @State private var brushOffset: CGFloat = 0
  @State private var isBrushDefaultValueSet = false
  @State private var sliderOffset: CGFloat = 0
  @State private var selectedBrush = 0
  @State private var isDrawing = false
  @State private var isSliderDefaultValueSet = false
  @State private var inputType = 0
  @State private var text = ""
  @State private var location: CGPoint = .zero
  @State private var degree = 0.0
  @State private var scale: CGFloat = 1.0
  @State private var lastScale: CGFloat = 1.0
  @State private var justLaunched = true
  @FocusState private var isTextFocused: Bool
  @GestureState private var fingerLocation: CGPoint? = nil
  @GestureState private var startLocation: CGPoint? = nil
  
  private let sliderMaxLineWidth: CGFloat = 20
  private let brushes = ["brush", "pen", "pencil"]
  
  var body: some View {
    if let image = image {
      NavigationView {
        VStack {
          canvas(image: image)
          if showOpacitySlider {
            VStack {
              BrushView(tip: "tip" + brushes[selectedBrush], base: brushes[selectedBrush], color: $color, isBrushDefaultValueSet: $isBrushDefaultValueSet, brushProgress: $sliderProgress, brushOffset: $brushOffset)
                .scaleEffect(0.2)
                .frame(height: 90)
                .clipped()
              HStack(spacing: 20) {
                Button {
                  withAnimation(.easeOut) {
                    showOpacitySlider = false
                  }
                } label: {
                  Image("back")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(30)
                }.padding(-30)
                CapsuleSliderView(color: $color, sliderProgress: $sliderProgress, lastDragValue: $lastDragValue, sliderOffset: $sliderOffset, isDefaultValueSet: $isSliderDefaultValueSet)
                  .onChange(of: sliderProgress) { newValue in
                    let lineWidth = max(newValue, 0.01) * sliderMaxLineWidth
                    currentLine.lineWidth = lineWidth
                  }
              }
            }
            .padding(.bottom, 50)
            .frame(height: 150)
          } else {
            VStack(spacing: 5) {
              HStack(spacing: -16) {
                ColorPicker("", selection: $color)
                  .onChange(of: color) { newValue in
                    currentLine.color = newValue
                  }
                ForEach(brushes.indices, id: \.self) { index in
                  BrushView(tip: "tip" + brushes[index], base: brushes[index],
                            color: $color, isBrushDefaultValueSet: $isBrushDefaultValueSet, brushProgress: $sliderProgress, brushOffset: $brushOffset)
                    .scaleEffect(0.15)
                    .onTapGesture {
                      selectedBrush = index
                      withAnimation(.easeIn) {
                        showOpacitySlider = true
                      }
                    }
                }
              }
              .frame(height: 80)
              .fixedSize()
              HStack(spacing: 10) {
                Button {
                  self.image = nil
                } label: {
                  Image("cancel")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(30)
                }.padding(-30)
                Picker("", selection: $inputType) {
                  Text("Draw").tag(0)
                  Text("Text").tag(1)
                }
                .pickerStyle(.segmented)
                .frame(width: 300, height: 44)
                .shadow(radius: 5)
                Button {
                  let image = canvas(image: image).snapshot()
                  UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                } label: {
                  Image("download")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(30)
                }.padding(-30)
              }
            }
            .padding(.bottom, 25)
            .frame(height: 150)
          }
        }
        .padding(.bottom)
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button(action: {
              if inputType == 0, !lines.isEmpty {
                lines.removeLast()
              } else {
                resetText()
              }
            }, label: {
              Image("undo")
                .resizable()
                .frame(width: 24, height: 24)
            })
            .disabled(lines.isEmpty && text.isEmpty)
            .opacity(lines.isEmpty && text.isEmpty ? 0.5 : 1)
          }
          ToolbarItem(placement: .navigationBarTrailing) {
            Button("Clear All") {
              resetText()
              lines.removeAll()
            }
            .disabled(lines.isEmpty && text.isEmpty)
            .opacity(lines.isEmpty && text.isEmpty ? 0.5 : 1)
            .foregroundColor(.white)
          }
        }
        .background(Color.black)
      }
    } else {
      ImagePickView(image: $image)
    }
  }
  
  private func canvas(image: UIImage) -> some View {
    ZStack {
      Canvas { context, size in
        for line in lines {
          var path = Path()
          path.addLines(line.points)
          context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
        }
      }
      .onAppear {
        if justLaunched {
          justLaunched = false
          resetText()
        }
      }
      .background(Image(uiImage: image)
        .resizable()
        .aspectRatio(contentMode: .fit))
      .gesture(DragGesture()
        .onChanged({ value in
          if inputType == 0 {
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
          }
        })
          .onEnded({ value in
            if inputType == 0 {
              isDrawing = false
            } else {
              isTextFocused = true
            }
          }).simultaneously(with: rotationGesture.simultaneously(with: scaleGesture))
      )
      if !text.isEmpty || inputType == 1 {
        textEditor
          .foregroundColor(.white)
          .focused($isTextFocused)
          .disabled(inputType == 0)
          .padding()
          .background(RoundedRectangle(cornerRadius: 12)
            .strokeBorder(style: StrokeStyle(lineWidth: inputType == 0 ? 0 : 4, dash: [10]))
            .foregroundColor(.white))
          .position(location)
          .scaleEffect(scale)
          .rotationEffect(Angle.degrees(degree))
          .gesture(simpleDrag.simultaneously(with: fingerDrag))
          .padding(.horizontal)
      }
    }
    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.7)
  }
  
  private var textEditor: some View {
    if #available(iOS 16.0, *) {
      return TextField("Title", text: $text,  axis: .vertical).lineLimit(1...10)
    } else {
      return TextEditor(text: $text).frame(height: 44)
    }
  }
  
  private var simpleDrag: some Gesture {
    DragGesture()
      .onChanged { value in
        var newLocation = startLocation ?? location
        newLocation.x += value.translation.width
        newLocation.y += value.translation.height
        self.location = newLocation
      }.updating($startLocation) { (value, startLocation, transaction) in
        startLocation = startLocation ?? location
      }
  }
    
  private var fingerDrag: some Gesture {
        DragGesture()
            .updating($fingerLocation) { (value, fingerLocation, transaction) in
                fingerLocation = value.location
            }
    }
  
  private var scaleGesture: some Gesture {
    MagnificationGesture()
      .onChanged { val in
        if inputType == 1 {
          let delta = val / self.lastScale
          self.lastScale = val
          if delta > 0.94 {
            let newScale = self.scale * delta
            self.scale = min(max(newScale, 0.4), 1.2)
          }
        }
      }
      .onEnded { _ in
        if inputType == 1 {
          self.lastScale = 1.0
        }
      }
  }
  
  private var rotationGesture: some Gesture {
    RotationGesture()
      .onChanged({ angle in
        if inputType == 1 {
          self.degree = angle.degrees
        }
      })
  }
  
  private var defaultLocation: CGPoint {
    CGPoint(x: UIScreen.main.bounds.width / 2 - 15, y: UIScreen.main.bounds.height / 2 - 100)
  }
  
  private func resetText() {
    text = ""
    location = CGPoint(x: UIScreen.main.bounds.width / 2 - 15, y: UIScreen.main.bounds.height / 2 - 100)
    degree = 0
    scale = 1
    lastScale = 1
  }
}

struct MainScreen_Previews: PreviewProvider {
  static var previews: some View {
    MainScreen()
  }
}
