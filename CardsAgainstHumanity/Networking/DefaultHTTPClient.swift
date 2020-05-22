//
//  RESTClient.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-22.
//  Copyright © 2020 Cyon. All rights reserved.
//

import Foundation
import Combine

final class DefaultHTTPClient {
    typealias Error = HTTPError
    
    let baseUrl: URL
    
    private let jsonDecoder: JSONDecoder
    private let dataFetcher: DataFetcher
    
    private var cancellables = Set<AnyCancellable>()
    
    static let shared = DefaultHTTPClient()
    
    init(
        baseURL: URL = SecretServer.url,
        dataFetcher: DataFetcher = .usingURLSession(),
        jsonDecoder: JSONDecoder = .init()
    ) {
        self.baseUrl = baseURL
        self.dataFetcher = dataFetcher
        self.jsonDecoder = jsonDecoder
    }
    
    deinit {
        print("💣 DEINIT HTTPClient")
    }
}

extension DefaultHTTPClient: HTTPClient {
    
    func data(_ request: URLRequest) -> AnyPublisher<Data, DataTaskError> {
        fatalError("implement me")
    }
    
    func decodedData<T: Decodable>(request: URLRequest) -> AnyPublisher<T, DataTaskError> {
        fatalError("implement me")
    }
}

// MARK: HTTPClient
extension DefaultHTTPClient {
    
    func perform(absoluteUrlRequest urlRequest: URLRequest) -> AnyPublisher<Data, HTTPError.NetworkingError> {
        return Combine.Deferred {
            return Future<Data, HTTPError.NetworkingError> { [weak self] promise in
                
                guard let self = self else {
                    promise(.failure(.clientWasDeinitialized))
                    return
                }
                
                self.dataFetcher.fetchData(request: urlRequest)
                    
                    .sink(
                        receiveCompletion: { completion in
                            guard case .failure(let error) = completion else { return }
                            promise(.failure(error))
                    },
                        receiveValue: { data in
                            promise(.success(data))
                    }
                ).store(in: &self.cancellables)
            }
        }.eraseToAnyPublisher()
    }
    
    func performRequest(pathRelativeToBase path: String) -> AnyPublisher<Data, HTTPError.NetworkingError> {
        let url = URL(string: path, relativeTo: baseUrl)!
        let urlRequest = URLRequest(url: url)
        return perform(absoluteUrlRequest: urlRequest)
    }
    
    func fetch<D>(urlRequest: URLRequest, decodeAs: D.Type) -> AnyPublisher<D, HTTPError> where D: Decodable {
        return perform(absoluteUrlRequest: urlRequest)
            .mapError { print("☢️ got networking error: \($0)"); return castOrKill(instance: $0, toType: HTTPError.NetworkingError.self) }
            .mapError { HTTPError.networkingError($0) }
            .decode(type: D.self, decoder: self.jsonDecoder)
            .mapError { print("☢️ 🚨 got decoding error: \($0)"); return castOrKill(instance: $0, toType: DecodingError.self) }
            .mapError { Error.serializationError(.decodingError($0)) }
            .eraseToAnyPublisher()
    }
    
}

protocol ErrorMessageFromDataMapper {
    func errorMessage(from data: Data) -> String?
}


enum HTTPError: Swift.Error {
    case failedToCreateRequest(String)
    case networkingError(NetworkingError)
    case serializationError(SerializationError)
}

extension HTTPError {
    enum NetworkingError: Swift.Error {
        case urlError(URLError)
        case invalidServerResponse(URLResponse)
        case invalidServerStatusCode(Int)
        case clientWasDeinitialized
    }
    
    enum SerializationError: Swift.Error {
        case decodingError(DecodingError)
        case inputDataNilOrZeroLength
        case stringSerializationFailed(encoding: String.Encoding)
    }
}

internal func castOrKill<T>(
    instance anyInstance: Any,
    toType expectedType: T.Type,
    _ file: String = #file,
    _ line: Int = #line
) -> T {
    
    guard let instance = anyInstance as? T else {
        let incorrectTypeString = String(describing: Mirror(reflecting: anyInstance).subjectType)
        fatalError("Expected variable '\(anyInstance)' (type: '\(incorrectTypeString)') to be of type `\(expectedType)`, file: \(file), line:\(line)")
    }
    return instance
}


final class DataFetcher {
    
    private let dataFromRequest:  (URLRequest) -> AnyPublisher<Data, HTTPError.NetworkingError>
    init(dataFromRequest: @escaping  (URLRequest) -> AnyPublisher<Data, HTTPError.NetworkingError>) {
        self.dataFromRequest = dataFromRequest
    }
    
    deinit {
        print("💣 DEINIT DataFetcher")
    }
}

extension DataFetcher {
    func fetchData(request: URLRequest) -> AnyPublisher<Data, HTTPError.NetworkingError> {
        dataFromRequest(request)
    }
}

// MARK: Convenience init
extension DataFetcher {
    
    static func urlResponse(
        errorMessageFromDataMapper: ErrorMessageFromDataMapper?,
        headerInterceptor: (([AnyHashable: Any]) -> Void)?,
        badStatusCodeInterceptor: ((UInt) -> Void)?,
        _ dataAndUrlResponsePublisher: @escaping (URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
    ) -> DataFetcher {
        
        DataFetcher { request in
            dataAndUrlResponsePublisher(request)
                .mapError { HTTPError.NetworkingError.urlError($0) }
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw HTTPError.NetworkingError.invalidServerResponse(response)
                    }
                    
                    headerInterceptor?(httpResponse.allHeaderFields)
                    
                    guard case 200...299 = httpResponse.statusCode else {
                        
                        badStatusCodeInterceptor?(UInt(httpResponse.statusCode))
                        
                        let dataAsErrorMessage = errorMessageFromDataMapper?.errorMessage(from: data) ?? "Failed to decode error from data"
                        print("⚠️ bad status code, error message: <\(dataAsErrorMessage)>, httpResponse: `\(httpResponse.debugDescription)`")
                        throw HTTPError.NetworkingError.invalidServerStatusCode(httpResponse.statusCode)
                    }
                    return data
            }
            .mapError { castOrKill(instance: $0, toType: HTTPError.NetworkingError.self) }
            .eraseToAnyPublisher()
            
        }
    }
    
    // MARK: From URLSession
    static func usingURLSession(
        urlSession: URLSession = .shared,
        errorMessageFromDataMapper: ErrorMessageFromDataMapper? = nil,
        headerInterceptor: (([AnyHashable: Any]) -> Void)? = nil,
        badStatusCodeInterceptor: ((UInt) -> Void)? = nil
    ) -> DataFetcher {
        
        .urlResponse(
            errorMessageFromDataMapper: errorMessageFromDataMapper,
            headerInterceptor: headerInterceptor,
            badStatusCodeInterceptor: badStatusCodeInterceptor
        ) { urlSession.dataTaskPublisher(for: $0).eraseToAnyPublisher() }
    }
}
