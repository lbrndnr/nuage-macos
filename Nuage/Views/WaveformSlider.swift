//
//  WaveformSlider.swift
//  Nuage
//
//  Created by Laurin Brandner on 12.10.22.
//

import SwiftUI
import SoundCloud

struct WaveformSlider<Value : BinaryFloatingPoint, MinValueLabel: View, MaxValueLabel: View>: View {
    
    var waveform: Waveform?
    
    @Binding private var value: Value
    @State private var updatingValue: Value?
    
    @GestureState private var highlighted = false
    
    private var range: ClosedRange<Value>
    
    private var minValueLabel: (Value) -> MinValueLabel
    private var maxValueLabel: (Value) -> MaxValueLabel
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            minValueLabel(updatingValue ?? value)
            slider()
            maxValueLabel(updatingValue ?? value)
        }
    }
    
    @ViewBuilder private func slider() -> some View {
        let knobDiameter: CGFloat = 13
        
        GeometryReader { geometry in
            let currentValue = updatingValue ?? value
            let rangeWidth = range.upperBound - range.lowerBound
            let relativeValue = rangeWidth > 0 ? CGFloat(currentValue/rangeWidth) : CGFloat(0)
            let barValue = geometry.size.width * relativeValue
            let knobValue = geometry.size.width * relativeValue - knobDiameter/2.0
            let currentKnobColor = highlighted ? highlightedKnobColor : knobColor
            
            let drag = DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged { gesture in
                var newValue = Value(gesture.location.x/geometry.size.width) * rangeWidth + range.lowerBound
                newValue = min(max(newValue, range.lowerBound), range.upperBound)
                
                withAnimation(.linear(duration: 0.01)) {
                    updatingValue = newValue
                }
            }.onEnded { gesture in
                value = updatingValue ?? value
                updatingValue = nil
            }
            .updating($highlighted) { _, highlighted, _ in
                highlighted = true
            }
            
            HStack(alignment: .center) {
                ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                    HStack(spacing: 0) {
                        Rectangle()
                            .foregroundColor(barForegroundColor)
                            .frame(width: barValue)
                        Rectangle()
                            .foregroundColor(barBackgroundColor)
                            .frame(width: max(0, geometry.size.width-barValue))
                    }
                    .mask(WaveformView(with: waveform))
                    Circle()
                        .strokeBorder(knobBorderColor, lineWidth: 1)
                        .background(Circle().foregroundColor(currentKnobColor))
                        .frame(width: knobDiameter, height: knobDiameter)
                        .offset(x: knobValue)
                }
            }.gesture(drag)
        }
    }
    
    private var knobColor: Color { colorScheme == .light ? .white : Color(hex: 0x1A1A1A) }
    
    private var highlightedKnobColor: Color { colorScheme == .light ? Color(hex: 0xE5E5E5) : Color(hex: 0x3E3E3E) }
    
    private var knobBorderColor: Color { colorScheme == .light ? Color(hex: 0xBFBFBF) : Color(hex: 0x5A5A5A) }
    
    private var barForegroundColor: Color { colorScheme == .light ? Color(hex: 0xBFBFBF) : Color(hex: 0x5F5F5F) }
    
    private var barBackgroundColor: Color { colorScheme == .light ? Color(hex: 0xF2F2F2) : Color(hex: 0x2C2C2C) }
    
    init(waveform: Waveform?, value: Binding<Value>, in range: ClosedRange<Value>, @ViewBuilder minValueLabel: @escaping (Value) -> MinValueLabel, @ViewBuilder maxValueLabel: @escaping (Value) -> MaxValueLabel) {
        self.waveform = waveform
        self._value = value
        self.range = range
        self.minValueLabel = minValueLabel
        self.maxValueLabel = maxValueLabel
    }
    
}

//struct WaveformSlider_Previews: PreviewProvider {
//    static var previews: some View {
//        let half = Array(1...50)
//        let samples = half.reversed() + half
//        let waveform = Waveform(width: 100, height: 50, samples: samples)
//        WaveformSlider(waveform: waveform)
//            .frame(width: 400, height: 100)
//    }
//}
