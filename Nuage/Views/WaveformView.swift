//
//  WaveformView.swift
//  Nuage
//
//  Created by Laurin Brandner on 14.01.21.
//

import SwiftUI
import Combine
import SoundCloud

private let spacing: CGFloat = 3
private let barWidth: CGFloat = 3
private let emptyWaveform = Waveform(samples: Array(repeating: 2, count: 100))

struct WaveformView: View {
    
    var waveform: Waveform
    
    var body: some View {
        GeometryReader { geometry in
            let numberOfBars = CGFloat(geometry.size.width+spacing)/CGFloat(spacing+barWidth)
            let samplesPerBar = floor(CGFloat(waveform.samples.count)/numberOfBars)
            let bars = Array(0..<Int(numberOfBars))
                .map { bar -> CGFloat in
                    let idx = CGFloat(bar)*samplesPerBar
                    let sample = interpolate(from: idx, to: idx+samplesPerBar)/CGFloat(waveform.maxHeight)
                    return CGFloat(pow(sample, 3))
                }
            let shouldScale = (self.waveform != emptyWaveform)
            let maxBar = bars.max() ?? 1.0
            
            HStack(alignment: .center, spacing: spacing) {
                ForEach(Array(bars.enumerated()), id: \.offset) { _, bar in
                    let height = shouldScale ? (bar / maxBar) * geometry.size.height : bar
                    
                    Rectangle()
                        .frame(width: barWidth, height: height)
                        .cornerRadius(barWidth/2)
                }
            }
            .frame(minHeight: 0, maxHeight: .infinity)
        }
    }
    
    private func interpolate(from: CGFloat, to: CGFloat) -> CGFloat {
        let lhs = max(Int(round(from)), 0)
        let rhs = min(Int(round(to)), waveform.samples.count-1)
        let sum = waveform.samples[lhs...rhs].reduce(0, +)
        let cnt = rhs-lhs+1

        return CGFloat(sum)/CGFloat(cnt)
    }
    
    init(with waveform: Waveform?) {
        self.waveform = waveform ?? emptyWaveform
    }
    
}

struct WaveformView_Previews: PreviewProvider {
    static var previews: some View {
        let half = Array(1...50)
        let samples = half.reversed() + half
        let waveform = Waveform(samples: samples)
        WaveformView(with: waveform)
            .frame(width: 400, height: 100)
            .foregroundColor(.accentColor)
    }
}
