//
//  utils.swift
//  rxswift-trainingTests
//
//  Created by Łukasz Andrzejewski on 15.01.2018.
//  Copyright © 2018 Inbright Łukasz Andrzejewski. All rights reserved.
//

import RxSwift
import RxCocoa

func snippet(name: String, code: () -> Void) {
    print("\n###", name, "####")
    code()
    print("###################################################################################")
}

func get<T: Decodable>(url: URL?) -> Observable<T?> {
    return Observable.of(url)
        .flatMap(ignoreIfNil)
        .flatMap(request)
        .filter(statusOk)
        .map(toModel)
}

func ignoreIfNil<T>(element: T?) -> Observable<T> {
    return element.map { Observable.just($0) } ?? Observable.empty()
}

private func request(url: URL) -> Observable<(response: HTTPURLResponse, data: Data)> {
    let request = URLRequest(url: url)
    return URLSession.shared.rx.response(request: request)
}

private func statusOk(_ response: HTTPURLResponse, data: Data) -> Bool {
    return 200..<300 ~= response.statusCode
}

private func toModel<T: Decodable>(_ response: HTTPURLResponse, data: Data) -> T? {
    return try? JSONDecoder().decode(T.self, from: data)
}
