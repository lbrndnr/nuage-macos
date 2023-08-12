//
//  ArrayView.swift
//  Nuage
//
//  Created by Laurin Brandner on 15.12.20.
//

import Combine
import SwiftUI

private let idSubcription = -1

struct ArrayView<ID, Element: Decodable&Identifiable, ContentView: View>: View {
    
    @State private var ids = [ID]()
    @State private var elements = [Element]()
    @State private var elementRange = 0..<16
    
    private var arrayPublisher: AnyPublisher<[ID], Error>
    private var slicePublisher: ([ID]) -> AnyPublisher<[Element], Error>
    @State private var subscriptions = [Int: AnyCancellable]()
    
    private var content: ([Element], @escaping () -> ()) -> ContentView
    
    var body: some View {
        Group {
            if elements.isEmpty {
                ProgressView()
                    .progressViewStyle(.circular)
            }
            else {
                content(elements, getNextSlice)
            }
        }
        .onAppear {
            arrayPublisher.receive(on: RunLoop.main)
                .replaceError(with: [])
                .sink { elementIDs in
                    ids = elementIDs
                    getNextSlice()
                }
                .store(in: &subscriptions, key: idSubcription)
            
            getNextSlice()
        }
    }
    
    init(arrayPublisher: AnyPublisher<[ID], Error>,
         slicePublisher: @escaping ([ID]) -> AnyPublisher<[Element], Error>,
         @ViewBuilder content: @escaping ([Element], @escaping () -> ()) -> ContentView) {
        self.arrayPublisher = arrayPublisher
        self.slicePublisher = slicePublisher
        self.content = content
    }
    
    private func getNextSlice() {
        let range = elementRange.clamped(to: 0..<ids.count)
        guard !ids.isEmpty && range.count > 0 else { return }
        guard subscriptions[elements.count] == nil else { return }
        
        let slice = Array(ids[range])
        
        slicePublisher(slice)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { slice in
                elements.insert(contentsOf: slice, at: range.startIndex)
                elementRange = range.endIndex..<min(ids.count, range.endIndex+min(range.count*2, 50))
            })
            .store(in: &subscriptions, key: elements.count)
    }
    
}
