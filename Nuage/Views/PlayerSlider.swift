//
//  PlayerSlider.swift
//  Nuage
//
//  Created by Laurin Brandner on 01.02.21.
//

import SwiftUI

struct PlayerSlider<Value : BinaryFloatingPoint>: View {
    
    @Binding private var value: Value
    private var range: ClosedRange<Value>
    private var continuousUpdate: Bool
    
    var body: some View {
        let knobRadius: CGFloat = 13
        
        GeometryReader { geometry in
            let relativeValue = range.upperBound > 0 ? CGFloat(value/range.upperBound) : CGFloat(0)
            let barValue = geometry.size.width * relativeValue
            let knobValue = (geometry.size.width - knobRadius) * relativeValue
            
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                HStack {
                    Rectangle()
                        .foregroundColor(Color(NSColor.tertiaryLabelColor))
                        .frame(width: barValue)
                    Rectangle()
                        .foregroundColor(Color(NSColor.underPageBackgroundColor))
                        .frame(width: geometry.size.width-barValue)
                }
                .cornerRadius(1.5)
                .frame(height: 3)
                Circle()
                    .strokeBorder(Color(NSColor.tertiaryLabelColor), lineWidth: 1)
                    .background(Circle().foregroundColor(Color(NSColor.windowBackgroundColor)))
                    .frame(width: knobRadius, height: knobRadius)
                    .offset(x: knobValue)
            }
        }.frame(height: knobRadius)
    }

    init(value: Binding<Value>, in range: ClosedRange<Value>, continuousUpdate: Bool = true) {
        self._value = value
        self.range = range
        self.continuousUpdate = continuousUpdate
    }

}

struct PlayerSlider_Previews: PreviewProvider {
    
    static var previews: some View {
        let value = Binding<Float>(get: { return 0.8 },
                                   set: { _ in })
        PlayerSlider(value: value, in: 0...1)
    }
    
}
