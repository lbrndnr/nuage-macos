//
//  SliceList.swift
//  Nuage
//
//  Created by Laurin Brandner on 15.12.20.
//

import SwiftUI
import Combine

struct SliceList<Element: Decodable&Identifiable, ViewElement, Row: View>: View {
    
    @State private var tracks = [Track]()
    private var publisher: AnyPublisher<Slice<Element>, Error>
    private var transform: (Element) -> ViewElement?
    private var row: ([ViewElement], Int) -> Row
    
    var body: some View {
        SliceView(publisher: publisher, transform: transform) { elements, getNextSlice in
            List(0..<elements.count, id: \.self) { idx in
                row(elements, idx).onAppear {
                    if idx == elements.count/2 {
                        getNextSlice()
                    }
                }
            }
        }
    }
    
    init(publisher: AnyPublisher<Slice<Element>, Error>,
         transform: @escaping (Element) -> ViewElement?,
         @ViewBuilder row: @escaping ([ViewElement], Int) -> Row) {
        self.publisher = publisher
        self.transform = transform
        self.row = row
    }
    
}
