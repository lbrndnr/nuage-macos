//
//  WaveformView.swift
//  Nuage
//
//  Created by Laurin Brandner on 14.01.21.
//

import SwiftUI

struct WaveformView: View {
    
    var waveform: Waveform
    
    var body: some View {
        let spacing: CGFloat = 2
        let barWidth: CGFloat = 3
        
        GeometryReader { geometry in
            let numberOfBars = CGFloat(geometry.size.width+spacing)/CGFloat(spacing+barWidth)
            let samplesPerBar = CGFloat(waveform.samples.count-1)/numberOfBars
            let heightMultiplier = geometry.size.height/CGFloat(waveform.height)
            
            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(0..<Int(numberOfBars), id: \.self) { bar in
                    let idx = CGFloat(bar)*samplesPerBar
                    let sample = interpolate(from: idx, to: idx+samplesPerBar)
                    
                    Rectangle()
                        .frame(width: barWidth, height: CGFloat(sample)*heightMultiplier)
                        .cornerRadius(1)
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
    
    private func interpolate(from: CGFloat, to: CGFloat) -> CGFloat {
        let lhs = Int(from)+1
        let rhs = Int(to)
        let sum = waveform.samples[lhs...rhs].reduce(0, +)
        let cnt = rhs-lhs+1
        return CGFloat(sum)/CGFloat(cnt)
    }
    
}

struct WaveformView_Previews: PreviewProvider {
    static var previews: some View {
        let half = Array(1...50)
        let samples = half.reversed() + half
        let waveform = Waveform(width: 100, height: 50, samples: samples)
        WaveformView(waveform: waveform)
            .frame(width: 400, height: 100)
    }
}
