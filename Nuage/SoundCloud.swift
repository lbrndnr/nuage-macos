//
//  SoundCloud.swift
//  Nuage
//
//  Created by Laurin Brandner on 18.12.19.
//  Copyright © 2019 Laurin Brandner. All rights reserved.
//

import Foundation
import Combine

struct AuthenticationError: Error {}

class SoundCloud {
    
    static var shared = SoundCloud()
    
    @Published var user: User?
    var accessToken: String? {
        didSet {
            get(.me())
                .receive(on: RunLoop.main)
                .map { Optional($0) }
                .replaceError(with: user)
                .filter { $0 != nil }
                .assign(to: \.user, on: self)
                .store(in: &subscriptions)
        }
    }
    
    private var decoder: JSONDecoder
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
    }
    
    // MARK: - Authentication
    
    static func login(username: String, password: String) -> AnyPublisher<String, Error> {
        let vals = (0..<4).map { _ in arc4random_uniform(1000000) }
        let deviceID = String(format: "%06d-%06d-%06d-%06d", vals[0], vals[1], vals[2], vals[3])
        let credentials = ["identifier": username,
                           "password": password]
        let agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.1 Safari/605.1.15"
        let body = ["client_id": clientID,
                    "recaptcha_pubkey": "6Ld72JcUAAAAAItDloUGqg6H38KK5j08VuQlegV1",
                    "recaptcha_response": nil,
                    "credentials": credentials,
                    "signature": "8:1-1-16684-373-1296000-1280-8-8:98f9f2:3",
                    "device_id": deviceID,
                    "user_agent": agent] as [String : Any?]
        let jsonBody = try! JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        
        var components = URLComponents(string: "https://api-auth.soundcloud.com/web-auth/sign-in/password")!
        components.queryItems = [URLQueryItem(name: "client_id", value: clientID)]
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.httpBody = jsonBody
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { res in
                let payload = try JSONSerialization.jsonObject(with: res.data, options: .allowFragments) as! [String: Any]
                guard let session = payload["session"] as? [String: String] else { throw AuthenticationError() }
                guard let token = session["access_token"] else { throw AuthenticationError() }
                return token
            }
            .eraseToAnyPublisher()
    }
    
    internal func authorized<T>(_ request: APIRequest<T>, queryItems: [URLQueryItem] = []) -> URLRequest {
        let url = URL(string: "https://api-v2.soundcloud.com/\(request.path)")!
        var items = queryItems
        if let parameters = request.queryParameters {
            items += zip(parameters.keys, parameters.values).map { URLQueryItem(name: $0.0, value: $0.1)}
        }
        
        var req = URLRequest(url: authorized(url, queryItems: items))
        req.httpMethod = request.httpMethod
//        req.cachePolicy = .returnCacheDataElseLoad
        return req
    }
    
    private func authorized(_ url: URL, queryItems: [URLQueryItem] = []) -> URL {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let authItems =  [URLQueryItem(name: "oauth_token", value: accessToken!)]
        
        let explicitItems = authItems + queryItems
        let explicitKeys = explicitItems.map { $0.name }
        let urlItems = components.queryItems?.filter { !explicitKeys.contains($0.name) }
        components.queryItems = (urlItems ?? []) + explicitItems
        
        return components.url!
    }
    
    // MARK: - Requests
    
    func get<T: Decodable>(_ request: APIRequest<T>) -> AnyPublisher<T, Error> {
        if request.needsUserID && user == nil {
            return Fail(error: NoUserError())
                .eraseToAnyPublisher()
        }
        
        return get(authorized(request))
    }
    
    func get<T: Decodable>(_ request: APIRequest<Slice<T>>, limit: Int? = 16) -> AnyPublisher<Slice<T>, Error> {
        if request.needsUserID && user == nil {
            return Fail(error: NoUserError())
                .eraseToAnyPublisher()
        }
        
        let queryItems = limit.map { [URLQueryItem(name: "limit", value: String(min($0, 150)))] }
        return get(authorized(request, queryItems: queryItems ?? []))
    }
    
    func get<T: Decodable>(next slice: Slice<T>, limit: Int = 16) -> AnyPublisher<Slice<T>, Error> {
        guard let next = slice.next else {
            return Fail(error: NoNextSliceError())
                .eraseToAnyPublisher()
        }
        
        let queryItems = [URLQueryItem(name: "limit", value: String(min(limit, 150)))]
        let request = URLRequest(url: authorized(next, queryItems: queryItems))
        return get(request)
    }
    
    private func get<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    func getMediaURL(with url: URL) -> AnyPublisher<URL, URLError> {
        return URLSession.shared.dataTaskPublisher(for: authorized(url))
            .map { res in
                let payload = try! JSONSerialization.jsonObject(with: res.data, options: .allowFragments) as! [String: String]
                return URL(string: payload["url"]!)!
            }
            .eraseToAnyPublisher()
    }
    
    func perform(_ request: APIRequest<String>) -> AnyPublisher<Bool, Error> {
        return URLSession.shared.dataTaskPublisher(for: authorized(request))
            .map { $0.data }
            .decode(type: String.self, decoder: decoder)
            .map { $0 == "OK" }
            .eraseToAnyPublisher()
    }
    
}
