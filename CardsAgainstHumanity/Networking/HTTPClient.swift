//
//  HTTPClient.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-22.
//  Copyright © 2020 Cyon. All rights reserved.
//

import Foundation
import Combine

/// Error localized description
enum DataTaskError : Error {
    case unknown
    case urlCreate
    case status(Int, Data?)
    case error(String)
}

protocol HTTPClient {
    func data(_ request: URLRequest) -> AnyPublisher<Data, DataTaskError>
    func decodedData<T: Decodable>(request: URLRequest) -> AnyPublisher<T, DataTaskError>
}

extension HTTPClient {
    func postFireForget(path: String) -> AnyPublisher<Void, Never> {
        self.data(
            request(path: path)
                .with(method: .POST)
        ).assertNoFailure()
            .eraseMapToVoid()
    }
    
    func postDecode<D>(path: String) -> AnyPublisher<D, Never>  where D: Decodable {
        postDecode(path: path, decodeAs: D.self)
    }
    
    func postDecode<D>(path: String, decodeAs _: D.Type) -> AnyPublisher<D, Never>  where D: Decodable {
        self.decodedData(request:
            request(path: path)
                .with(method: .POST)
        )
        .assertNoFailure()
        .eraseToAnyPublisher()
    }
    
    func getDecode<D>(path: String) -> AnyPublisher<D, Never>  where D: Decodable {
        getDecode(path: path, decodeAs: D.self)
    }
    
    func getDecode<D>(path: String, decodeAs _: D.Type) -> AnyPublisher<D, Never>  where D: Decodable {
        self.decodedData(request:
            request(path: path)
                .with(method: .GET)
        )
            .assertNoFailure()
            .eraseToAnyPublisher()
    }
}

private func request(path: String) -> URLRequest {
    try! URLRequest.request(SecretServer.url + path)
}
