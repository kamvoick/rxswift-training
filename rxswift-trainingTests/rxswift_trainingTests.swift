//
//  rxswift_trainingTests.swift
//  rxswift-trainingTests
//
//  Created by Łukasz Andrzejewski on 15.01.2018.
//  Copyright © 2018 Inbright Łukasz Andrzejewski. All rights reserved.
//

import XCTest
import RxSwift

@testable import rxswift_training

class rxswift_trainingTests: XCTestCase {
    
    let disposeBag = DisposeBag()
    
    func testBasics() {
        snippet(name: "Observable.from") {
            let subscription = Observable.from([1, 2, 3, 4])
                .subscribe(
                    onNext: { value in
                        print(value)
                    },
                    onCompleted: {
                        print("Completed")
                    },
                    onDisposed: {
                        print("Disposed")
                    }
                )
            
            subscription.dispose()
        }
        
        snippet(name: "DisposeBag") {
            Observable.range(start: 1, count: 10)
                .subscribe(
                    { event in
                        if let element = event.element {
                            print(element)
                        } else {
                             print(event.debugDescription)
                        }
                    }
                ).disposed(by: disposeBag)
        }
        
        snippet(name: "Deferred") {
            var value = 0;
            let observableFactory = Observable<Int>.deferred {
                value += 1
                return Observable.of(value)
            }
            
            for _ in 1 ... 5 {
                observableFactory
                    .debug()
                    .do(onNext: { value in
                        print("Value:", value * 2)
                    })
                    .subscribe(onNext: {
                        print($0)
                    })
                    .disposed(by: disposeBag)
            }
        }
        
        snippet(name: "Custom Single") {
            enum IOError: Error {
                case fileNotFound, readFailed
            }
            
            func load(textFile: String) -> Single<String> {
                return Single.create { single in
                    let disposable = Disposables.create();
                    guard let path = Bundle.main.path(forResource: textFile, ofType: "txt") else {
                        single(.error(IOError.fileNotFound))
                        return disposable
                    }
                    guard let data = FileManager.default.contents(atPath: path) else {
                        single(.error(IOError.readFailed))
                        return disposable
                    }
                    guard let text = String(data: data, encoding: .utf8) else {
                        single(.error(IOError.readFailed))
                        return disposable
                    }
                    single(.success(text))
                    return disposable
                }
            }
            
            load(textFile: "data")
                .subscribe(
                    onSuccess: {
                        print($0)
                    },
                    onError: { error in
                        print(error)
                    }
                )
                .disposed(by: disposeBag)
        }
    }
    
    func testSubjects() {
        snippet(name: "PublishSubject") {
            let subject = PublishSubject<Int>()
            subject.onNext(1)
            subject.subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
            subject.onNext(2)
        }
        
        snippet(name: "BehaviorSubject") {
            let subject = BehaviorSubject(value: 1)
            subject.subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
            subject.onNext(2)
        }
        
        snippet(name: "BehaviorSubject") {
            let subject = ReplaySubject<Int>.create(bufferSize: 3)
            subject.onNext(1)
            subject.onNext(2)
            subject.onNext(3)
            subject.onNext(4)
            subject
                .asObservable() // optional casting
                .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
            subject.onNext(5)
            subject.subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
        }
        
        snippet(name: "Variable") {
            let variable = Variable(1)
            variable.asObservable().subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
            variable.value = 2;
        }
    }
    
    func testOperators() {
        snippet(name: "Filter") {
            Observable.of(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
                .filter({ $0 % 2 == 0 })
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
        }
        
        snippet(name: "Element at") {
            Observable.of(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
                .elementAt(1)
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
        }
        
        snippet(name: "Ignore elements") {
            Observable.of(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
                .ignoreElements()
                .subscribe(onCompleted: { print("Completed") })
                .disposed(by: disposeBag)
        }
        
        snippet(name: "Skip") {
            Observable.of(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
                .skip(5)
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
        }
        
        snippet(name: "Skip while") {
            Observable.of(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
                .skipWhile({ $0 < 5 })
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
        }
        
        snippet(name: "Skip until") {
            let subject = PublishSubject<Int>()
            let trigger = PublishSubject<String>()
            
            subject.skipUntil(trigger)
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
            
            subject.onNext(1)
            subject.onNext(2)
            trigger.onNext("start")
            subject.onNext(3)
        }
        
        snippet(name: "Take") {
            Observable.of(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
                .take(5)
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
        }
        
        snippet(name: "Take while") {
            Observable.of(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
                .takeWhile({ $0 < 5 })
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
        }
        
        snippet(name: "Take until") {
            let subject = PublishSubject<Int>()
            let trigger = PublishSubject<String>()
            
            subject.takeUntil(trigger)
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
            
            subject.onNext(1)
            subject.onNext(2)
            trigger.onNext("start")
            subject.onNext(3)
        }
        
        snippet(name: "Distinct until changed") {
            Observable.of(1, 2, 2, 3, 4, 5, 6, 7, 8, 9, 10)
                .distinctUntilChanged()
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
        }
        
        snippet(name: "To array") {
            Observable.of(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
                .toArray()
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
        }
        
        snippet(name: "Map") {
            Observable.of(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
                .map({ $0 * 3 })
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
        }
        
        snippet(name: "Flat map on array") {
            Observable.of([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
                .flatMap { Observable.from($0) }
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
        }
        
        snippet(name: "Flat map") {
            let left = PublishSubject<Int>()
            let right = PublishSubject<Int>()
            let subject = PublishSubject<Observable<Int>>()
            
            subject
                //.flatMap { $0 }
                .flatMapLatest { $0 }
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
            
            subject.onNext(left)
            subject.onNext(right)
            
            left.onNext(1)
            left.onNext(2)
            right.onNext(3)
            left.onNext(4)
            right.onNext(5)
        }
        
        snippet(name: "Start with") {
            Observable.of(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
                .startWith(0)
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
        }
        
        snippet(name: "Concat") {
            Observable.of(1, 1, 1, 1, 1)
                .concat(Observable.of(2, 2, 2, 2, 2))
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
        }
        
        snippet(name: "Concat map") {
            let sequences = [
                "a" : Observable.of(1, 3, 5, 7),
                "b" : Observable.of(2, 4, 6, 8)
            ]
            
            Observable.of("a", "b")
                .concatMap { sequences[$0] ?? .empty() }
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
        }
        
        snippet(name: "Merge") {
            let left = PublishSubject<Int>()
            let right = PublishSubject<Int>()
            
            Observable.merge(left, right) // Observable.of(left, right).merge()
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
            
            left.onNext(1)
            left.onNext(1)
            right.onNext(2)
            left.onNext(1)
        }
        
        snippet(name: "Combine latest") {
            let left = PublishSubject<Int>()
            let right = PublishSubject<Int>()
            
            Observable.combineLatest(left, right) { "\($0)\($1)" }
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
            
            left.onNext(1)
            left.onNext(2)
            right.onNext(3)
            left.onNext(4)
        }
        
        snippet(name: "Zip") {
            let left = PublishSubject<Int>()
            let right = PublishSubject<Int>()
            
            Observable.zip(left, right) { "\($0)\($1)" }
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
            
            left.onNext(1)
            left.onNext(2)
            right.onNext(3)
            left.onNext(4)
        }
        
        snippet(name: "With latest from") {
            let left = PublishSubject<Int>()
            let right = PublishSubject<Int>()
            
            //left.withLatestFrom(right)
            left.sample(right)
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
            
            right.onNext(2)
            right.onNext(2)
            left.onNext(1)
            right.onNext(2)
            left.onNext(1)
            left.onNext(1)
        }
        
        snippet(name: "Amg") {
            let left = PublishSubject<Int>()
            let right = PublishSubject<Int>()
            
            left.amb(right)
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
            
            right.onNext(2)
            left.onNext(1)
        }
        
        snippet(name: "Switch latest") {
            let left = PublishSubject<Int>()
            let right = PublishSubject<Int>()
            let subject = PublishSubject<Observable<Int>>()
            
            subject
                .switchLatest()
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
            
            subject.onNext(left)
            subject.onNext(right)
            
            right.onNext(2)
            left.onNext(1)
            right.onNext(2)
            right.onNext(2)
            left.onNext(1)
        }
        
        
        snippet(name: "Reduce") {
            Observable.of(1, 1, 1, 1, 1)
                .reduce(0, accumulator: +)
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
        }
        
        snippet(name: "Scan") {
            Observable.of(1, 1, 1, 1, 1)
                .scan(0, accumulator: +)
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)
        }
        
        snippet(name: "Interval") {
            let scheduler = SerialDispatchQueueScheduler(qos: .default)
            Observable<Int>.interval(0.3, scheduler: scheduler)
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
            Thread.sleep(forTimeInterval: 10.0)
        }
    }
    
}
