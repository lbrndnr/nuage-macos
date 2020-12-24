//
//  InfinteList.swift
//  Nuage
//
//  Created by Laurin Brandner on 15.12.20.
//

import SwiftUI
import Combine
import SoundCloud

enum InfinitePublisher<Element: Decodable&Identifiable&Filterable> {
    case slice(AnyPublisher<Slice<Element>, Error>)
    case array(AnyPublisher<[Int], Error>, ([Int]) -> AnyPublisher<[Element], Error>)
}

struct InfinteList<Element: Decodable&Identifiable&Filterable, Row: View>: View {
    
    @State private var tracks = [Track]()
    private var publisher: InfinitePublisher<Element>
    private var row: ([Element], Int) -> Row
    @State private var filter = ""
    
    var body: some View {
        if case let .slice(publisher) = publisher {
            SliceView(publisher: publisher, content: list)
        }
        else if case let .array(arrayPublisher, slicePublisher) = publisher {
            ArrayView(arrayPublisher: arrayPublisher, slicePublisher: slicePublisher, content: list)
        }
    }
    
    @ViewBuilder func list(for elements: [Element], getNextSlice: @escaping () -> ()) -> some View {
        let displayedElmeents = (filter.count > 0) ? elements.filter { $0.contains(filter) } : elements
        
        VStack {
            TextField("Filter", text: $filter)
                .onChange(of: filter, perform: { _ in
                    getNextSlice()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            List(0..<displayedElmeents.count, id: \.self) { idx in
                row(displayedElmeents, idx).onAppear {
                    if idx == elements.count/2 {
                        getNextSlice()
                    }
                }
            }
        }
    }
    
    init(publisher: InfinitePublisher<Element>,
         @ViewBuilder row: @escaping ([Element], Int) -> Row) {
        self.publisher = publisher
        self.row = row
    }
    
    init(publisher: AnyPublisher<Slice<Element>, Error>,
         @ViewBuilder row: @escaping ([Element], Int) -> Row) {
        self.publisher = .slice(publisher)
        self.row = row
    }
    
    init(arrayPublisher: AnyPublisher<[Int], Error>,
         slicePublisher: @escaping ([Int]) -> AnyPublisher<[Element], Error>,
         @ViewBuilder row: @escaping ([Element], Int) -> Row) {
        self.publisher = .array(arrayPublisher, slicePublisher)
        self.row = row
    }

}
