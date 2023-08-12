//
//  PageView.swift
//  Nuage
//
//  Created by Laurin Brandner on 03.12.20.
//  Copyright © 2020 Laurin Brandner. All rights reserved.
//

import Combine
import SwiftUI
import SoundCloud

private let subjectSubcription = -1
private let initialPageSubscription = 0

struct PageView<Element: Decodable&Identifiable, ContentView: View>: View {
    
    var elements: [Element] {
        return pages.map { $0.collection }
            .reduce([], +)
    }
    @State private var pages = [Page<Element>]()
    
    private var publisher: AnyPublisher<Page<Element>, Error>
    @State private var subscriptions = [Int: AnyCancellable]()
    
    private var content: ([Element], @escaping () -> ()) -> ContentView
    
    var body: some View {
        Group {
            if elements.isEmpty {
                ProgressView()
                    .progressViewStyle(.circular)
            }
            else {
                content(elements, getNextPage)
            }
        }
        .onAppear {
            publisher.receive(on: RunLoop.main)
                .sink(receiveCompletion: { _ in }, receiveValue: { page in
                    pages.append(page)
                })
                .store(in: &subscriptions, key: initialPageSubscription)
        }
    }
    
    init(publisher: AnyPublisher<Page<Element>, Error>,
         @ViewBuilder content: @escaping ([Element], @escaping () -> ()) -> ContentView) {
        self.publisher = publisher
        self.content = content
    }
    
    private func getNextPage() {
        guard subscriptions[elements.count] == nil else { return }

        let currentPagePublisher = pages.publisher
            .last()
            .mapError{ $0 as Error }

        publisher.merge(with: currentPagePublisher)
            .first()
            .flatMap { SoundCloud.shared.get(next: $0) }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { page in
                pages.append(page)
            })
            .store(in: &subscriptions, key: elements.count)
    }
    
}
