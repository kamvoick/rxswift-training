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
    
    func toWikipediaSearchUrl(query: String) -> URL? {
        return URL(string: "https://en.wikipedia.org/w/api.php?action=query&format=json&list=search&srsearch=\(query)")
    }
    
    func getTitles(url: URL?) -> Observable<Response?> {
        return get(url: url)
    }
    
    func toTitle(response: Response) -> Observable<String> {
        return Observable.of(response)
            .map { $0.query.search }
            .flatMap { Observable.from($0) }
            .map { $0.title }
    }
    
    func searchForTitles(query: String) -> Observable<String> {
        return Observable.of(query)
            .map(toWikipediaSearchUrl)
            .flatMap(getTitles)
            .flatMap(ignoreIfNil)
            .flatMap(toTitle)
    }
    
    func testWikipediaSearch() {
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        
        let firstQuery = Observable.of("m","a","c")
            .scan("", accumulator: +)
            .delay(5.0, scheduler: scheduler)
            .debounce(5.0, scheduler: scheduler)
            .flatMap(searchForTitles)
        
        let secondQuery = searchForTitles(query: "iOS")
            .take(5)
         
        Observable.merge(firstQuery, secondQuery)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    
    
       Thread.sleep(forTimeInterval: 10.0)
    }

}
