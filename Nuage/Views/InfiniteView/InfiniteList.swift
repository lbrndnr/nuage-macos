//
//  InfiniteList.swift
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
    case array(AnyPublisher<[String], Error>, ([String]) -> AnyPublisher<[Element], Error>)
}

struct InfiniteList<Element: Decodable&Identifiable&Filterable, Row: View>: View {
    
    private var publisher: InfinitePublisher<Element>
    private var row: ([Element], Int) -> Row
    
    @State private var filter = ""
    @State private var isSearching = false
    
    @Environment(\.header) private var header: AnyView
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
            List(0..<displayedElements.count+1, id: \.self) { idx in
                if idx == 0 {
                    header
                }
                else {
                    row(displayedElements, idx-1)
                        .id(idx)
                        .onAppear {
                        if idx == elements.count/2 {
                            getNextSlice()
                        }
                    }
                }
            }
            .onReceive(commands.filter) { withAnimation { isSearching = true } }
            .onExitCommand(perform: stopFiltering)
        }
    }
    
    private func stopFiltering() {
        withAnimation {
            isSearching = false
            filter = ""
        }
    }
    
    init(publisher: InfinitePublisher<Element>, @ViewBuilder row: @escaping ([Element], Int) -> Row) {
        self.publisher = publisher
        self.row = row
    }

}

extension View {
    
    func header<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        self.environment(\.header, AnyView(content()))
    }
    
}

struct HeaderKey: EnvironmentKey {
    
    static let defaultValue = AnyView(EmptyView())
    
}

extension EnvironmentValues {
    
    var header: AnyView {
        get { self[HeaderKey.self] }
        set { self[HeaderKey.self] = newValue }
    }
    
}
