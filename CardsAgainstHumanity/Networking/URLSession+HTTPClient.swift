//
//  LiteHTTPClient.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-22.
//  Copyright © 2020 Cyon. All rights reserved.
//

import Foundation
import Combine

/// HTTPMethod types
public enum HTTPMethod {
    case GET, POST, PUT, PATCH, DELETE, COPY, HEAD, OPTIONS, LINK, UNLINK, PURGE, LOCK, UNLOCK, PROPFIND, VIEW
}

extension URLResponse {
    var httpResponse: HTTPURLResponse? {
        return self as? HTTPURLResponse
    }
}

extension URLRequest {
    /// The HTTP request method. The default HTTP method is “GET”.
    @discardableResult mutating func method(_ method: HTTPMethod) -> Self {
        self.httpMethod = String(describing: method)
        return self
    }
    
    /// The HTTP request method. The default HTTP method is “GET”.
    func with(method: HTTPMethod) -> Self {
        var copy = self
        copy.method(method)
        return copy
    }
    
    /// The data sent as the message body of a request, such as for an HTTP POST request.
    @discardableResult mutating func body(_ body: Data?) -> Self {
        self.httpBody = body
        return self
    }
    
    /// The HTTP headers sent with a request.
    @discardableResult mutating func headers(_ headers: [String:String]?) -> Self {
        self.allHTTPHeaderFields = headers
        return self
    }
    
    static func request(_ url: String, parameters: [String : Any]? = nil) throws -> URLRequest {
        var urlComponents = URLComponents(string: url)
        urlComponents?.queryItems = parameters?.map({ URLQueryItem(name: $0.key, value: String(describing:$0.value))})
        guard let url = urlComponents?.url else {
            throw  DataTaskError.urlCreate
        }
        return URLRequest(url: url)
    }
}

extension URLSession: HTTPClient {
    func data(_ request: URLRequest) -> AnyPublisher<Data, DataTaskError> {
        return URLSession.DataTaskPublisher(request: request, session: .shared)
            .tryMap { data, response in
                guard let httpResponse = response.httpResponse else {
                    throw DataTaskError.unknown
                }
                guard 200..<300 ~= httpResponse.statusCode else {
                    throw DataTaskError.status(httpResponse.statusCode, data)
                }
                return data
        }
        .mapError { error in
            if let error = error as? DataTaskError {
                return error
            } else {
                return DataTaskError.error(error.localizedDescription)
            }
        }
        .eraseToAnyPublisher()
    }
    
    func decodedData<T: Decodable>(request: URLRequest) -> AnyPublisher<T, DataTaskError> {
        return data(request)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError({ error -> DataTaskError in
                if let error = error as? DataTaskError {
                    return error
                } else {
                    return DataTaskError.error(error.localizedDescription)
                }
            })
            .eraseToAnyPublisher()
    }
}

// MOAR SUGARE

