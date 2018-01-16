//
//  wikipediaSearchTest.swift
//  rxswift-trainingTests
//
//  Created by Łukasz Andrzejewski on 15.01.2018.
//  Copyright © 2018 Inbright Łukasz Andrzejewski. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

@testable import rxswift_training

class wikipediaSearchTest: XCTestCase {
    
    let disposeBag = DisposeBag()
    
    func queryToWikipediaSearchUrl(query: String) -> URL? {
        return URL(string: "https://en.wikipedia.org/w/api.php?action=query&format=json&list=search&srsearch=\(query)")
    }
    
    func ignoreIfNil<A>(x: A?) -> Observable<A> {
        return x.map { Observable.just($0) } ?? Observable.empty()
    }
    
    func okResponse(_ response: HTTPURLResponse, data: Data) -> Bool {
        return 200..<300 ~= response.statusCode
    }
    
    func httpGet(url: URL) -> Observable<(response: HTTPURLResponse, data: Data)> {
        let urlRequest = URLRequest(url: url);
        return URLSession.shared.rx.response(request: urlRequest)
    }
    
    func dataToResponse(_ response: HTTPURLResponse, data: Data) -> Response? {
        return try? JSONDecoder().decode(Response.self, from: data)
    }
    
    func searchForTitle(query: String) -> Observable<String> {
        return Observable.of(query)
            .map(queryToWikipediaSearchUrl)
            .flatMap(ignoreIfNil)
            .flatMap(httpGet)
            .filter(okResponse)
            .map(dataToResponse)
            .flatMap(ignoreIfNil)
            .map { $0.query.search }
            .flatMap { Observable.from($0) }
            .take(5)
            .map { $0.title }
    }
    
    func testWikipediaSearch() {
        let scheduler = SerialDispatchQueueScheduler(qos: .default)
        let firstSearch = Observable.of("s", "w", "i", "f", "t")
            .scan("", accumulator: +)
            .debounce(5.0, scheduler: scheduler)
            .flatMap(searchForTitle)
        let secondSearch = searchForTitle(query: "bmw")
        let trigger = PublishSubject<Int>()
            
        Observable
            .merge(firstSearch, secondSearch)
            .withLatestFrom(trigger) { (string, observable) in return string }
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)

        trigger.onNext(1)
        Thread.sleep(forTimeInterval: 10.0)
    }
    
}
