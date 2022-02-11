//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import RxSwift
import SwiftyJSON
import UIKit

fileprivate let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

final class ViewController: UIViewController {
    // MARK: - IBOutlet
    
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var disposables = DisposeBag()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }

    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }
    
    
    // MARK: - IBActions
    
    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)
        
        let jsonObservable = downloadJSON(from: MEMBER_LIST_URL)
        let helloObservable = Observable.just("Hello World")
        
        Observable.zip(jsonObservable, helloObservable) { $1 + "\n" + $0}
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { json in
            self.editView.text = json
            self.setVisibleWithAnimation(self.activityIndicator, false)
        })
        .disposed(by: disposables)
        // 2. Observable로 오는 데이터를 받아서 처리하는 방법
        
//        observable
//            .map { $0?.count ?? 0 }
//            .filter { count in count > 0 }
//            .map { "\($0)" }
//            .observeOn(MainScheduler.instance)
//            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
//            .subscribe(onNext: { json in
//                self.editView.text = json
//                self.setVisibleWithAnimation(self.activityIndicator, false)
//            })
//            .dispose()
//        let disposable = observable.subscribe { event in
//            switch event {
//            case .next(let json):
//                self.editView.text = json
//                break
//            case .error(let error):
//                print(error)
//                break
//            case .completed:
//                break
//            }
//
//        }
        // disposable.dispose()
    }
}

// MARK: - Private Methods

extension ViewController {
    
    private func downloadJSON(from url: String) -> Observable<String> {
//        return Observable.from(["Hello", "World"])
//        return Observable.create { emitter in
//            emitter.onNext("hello")
//            emitter.onNext("world")
//            return Disposables.create()
//        }
        // 1. 비동기로 생기는 데이터를 Observable 로 감싸서 리턴하는 방법
        return Observable.create { emitter in
            let url = URL(string: url)!
            let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
                guard error == nil else {
                    emitter.onError(error!)
                    return
                }

                if let data = data,
                   let json = String(data: data, encoding: .utf8) {
                    emitter.onNext(json)
                }

                emitter.onCompleted()
            }

            task.resume()

            return Disposables.create() {
                task.cancel()
            }
        }
        /// 이전
//        return Observable.create() { f in
//            DispatchQueue.global().async {
//                guard let url = URL(string: url) else {
//                    return
//                }
//                do {
//                    let data = try Data(contentsOf: url)
//                    let json = String(data: data, encoding: .utf8)
//                    DispatchQueue.main.async {
//                        f.onNext(json)
//                        f.onCompleted()
//                    }
//                } catch {
//                    print(error)
//                }
//            }
//
//            return Disposables.create()
//        }
    }
}










