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
        
        downloadJSON(from: MEMBER_LIST_URL)
            .subscribe { event in
                switch event {
                case .next(let json):
                    self.editView.text = json
                    self.setVisibleWithAnimation(self.activityIndicator, false)
                case .completed:
                    break
                case .error:
                    break
                }
                
            }
    }
}

// MARK: - Private Methods

extension ViewController {
    private func downloadJSON(from url: String) -> Observable<String?> {
        return Observable.create() { f in
            DispatchQueue.global().async {
                guard let url = URL(string: url) else {
                    return
                }
                do {
                    let data = try Data(contentsOf: url)
                    let json = String(data: data, encoding: .utf8)
                    DispatchQueue.main.async {
                        f.onNext(json)
                    }
                } catch {
                    print(error)
                }
            }
            
            return Disposables.create()
        }
    }
}



