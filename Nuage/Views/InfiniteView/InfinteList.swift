//
//  InfinteList.swift
//  Nuage
//
//  Created by Laurin Brandner on 15.12.20.
//

import SwiftUI
import Combine
import Introspect
import AppKit
import SoundCloud

enum InfinitePublisher<Element: Decodable&Identifiable&Filterable> {
    case slice(AnyPublisher<Slice<Element>, Error>)
    case array(AnyPublisher<[Int], Error>, ([Int]) -> AnyPublisher<[Element], Error>)
}

struct InfinteList<Element: Decodable&Identifiable&Filterable, Row: View>: View {
    
    private var publisher: InfinitePublisher<Element>
    private var row: ([Element], Int) -> Row
    @State private var filter = ""
    @State private var isSearching = false
    
    @EnvironmentObject private var commands: Commands
    
    var body: some View {
        if case let .slice(publisher) = publisher {
            SliceView(publisher: publisher, content: list)
        }
        else if case let .array(arrayPublisher, slicePublisher) = publisher {
            ArrayView(arrayPublisher: arrayPublisher, slicePublisher: slicePublisher, content: list)
        }
    }
    
    @ViewBuilder func list(for elements: [Element], getNextSlice: @escaping () -> ()) -> some View {
        let displayedElements = (filter.count > 0) ? elements.filter { $0.contains(filter) } : elements
        
        VStack {
            if isSearching {
                TextField("Filter", text: $filter)
                    .onChange(of: filter, perform: { _ in
                        getNextSlice()
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .introspectTextField { $0.becomeFirstResponder() }
                    .onExitCommand(perform: stopFiltering)
            }
            List(0..<displayedElements.count, id: \.self) { idx in
                row(displayedElements, idx)
                    .id(idx)
                    .onAppear {
                    if idx == elements.count/2 {
                        getNextSlice()
                    }
                }
            }
            .onReceive(commands.filter) { withAnimation { isSearching = true } }
            .onExitCommand(perform: stopFiltering)
        }
    }
    
    init(publisher: InfinitePublisher<Element>, @ViewBuilder row: @escaping ([Element], Int) -> Row) {
        self.publisher = publisher
        self.row = row
    }
    
    private func stopFiltering() {
        withAnimation {
            isSearching = false
            filter = ""
        }
    }

}
