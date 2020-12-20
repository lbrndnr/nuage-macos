//
//  SliceList.swift
//  Nuage
//
//  Created by Laurin Brandner on 15.12.20.
//

import SwiftUI
import Combine

struct SliceList<Element: Decodable&Identifiable, Row: View>: View {
    
    @State private var tracks = [Track]()
    private var publisher: AnyPublisher<Slice<Element>, Error>
    private var row: ([Element], Int) -> Row
    
    var body: some View {
        SliceView(publisher: publisher) { elements, getNextSlice in
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
         @ViewBuilder row: @escaping ([Element], Int) -> Row) {
        self.publisher = publisher
        self.row = row
    }
    
}
