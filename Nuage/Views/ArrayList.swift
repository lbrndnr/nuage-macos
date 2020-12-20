//
//  ArrayList.swift
//  Nuage
//
//  Created by Laurin Brandner on 15.12.20.
//

import Combine
import SwiftUI
import SoundCloud

private let subjectSubcription = -1
private let initialSliceSubscription = 0

//struct ArrayList<Element: Decodable&Identifiable, RowElement: Decodable, ElementView: View>: View {
//    
//    var elements: [Element]
//    @State private var rowElements = [RowElement]()
//    private var elementView: ([RowElement], Int) -> ElementView
//    
//    private var slicePublisher: ([Element]) -> AnyPublisher<[RowElement], Error>
//    private var subject = PassthroughSubject<[RowElement], Error>()
//    @State private var subscriptions = [Int: AnyCancellable]()
//    
//    var body: some View {
//        return List(0..<rowElements.count, id: \.self) { idx -> AnyView in
//            let view = elementView(rowElements, idx)
//            if idx == rowElements.count/2 { return AnyView(view.onAppear(perform: getNextSlice)) }
//            else { return AnyView(view) }
//        }.onAppear {
//            let range = 0..<min(16, elements.count)
//            let publisher = slicePublisher(Array(elements[range]))
//            
//            publisher.subscribe(subject)
//                .store(in: &subscriptions, key: subjectSubcription)
//            
//            self.subject.receive(on: RunLoop.main)
//                .sink(receiveCompletion: { _ in }, receiveValue: { slice in
//                    self.slices.append(slice)
//                })
//                .store(in: &self.subscriptions, key: initialSliceSubscription)
//        }
//    }
//    
//    init(elements: [Element],
//         slicePublisher: @escaping ([Element]) -> AnyPublisher<[RowElement], Error>,
//         @ViewBuilder elementView: @escaping ([RowElement], Int) -> ElementView) {
//        self.elements = elements
//        self.slicePublisher = slicePublisher
//        self.elementView = elementView
//    }
//    
//    func getNextSlice() {
//        guard subscriptions[self.elements.count] == nil else { return }
//        
//        let limit = (self.slices.last?.collection.count ?? initialSliceSubscription) * 2
//        let currentSlicePublisher = slices.publisher
//            .last()
//            .mapError{ $0 as Error }
//        
//        subject.merge(with: currentSlicePublisher)
//            .receive(on: RunLoop.main)
//            .first()
//            .flatMap { SoundCloud.shared.get(next: $0, limit: limit) }
//            .sink(receiveCompletion: { _ in }, receiveValue: { slice in
//                self.slices.append(slice)
//            })
//            .store(in: &subscriptions, key: self.elements.count)
//    }
//    
//}
