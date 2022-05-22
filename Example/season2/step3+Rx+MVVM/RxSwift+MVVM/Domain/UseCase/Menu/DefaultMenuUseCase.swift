//
//  DefaultMenuUseCase.swift
//  RxSwift+MVVM
//
//  Created by Jun Bang on 2022/05/21.
//  Copyright © 2022 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift

final class DefaultMenuUseCase: MenuUseCase {
    // Private
    private let repository: MenuFetchable
    private let disposeBag = DisposeBag()
    private let fetching = PublishSubject<Void>()
    private let clearing = PublishSubject<Void>()
    private let increasing = PublishSubject<(menu: ViewMenu, inc: Int)>()
    
    //  INPUT ->
    var fetchMenus: AnyObserver<Void>
    var clearSelections: AnyObserver<Void>
    var makeOrder: AnyObserver<Void>
    var increaseMenu: AnyObserver<(menu: ViewMenu, inc: Int)>
    var ordering = PublishSubject<Void>()
    // Output
    var menus = BehaviorSubject<[ViewMenu]>(value: [])
    var activating = BehaviorSubject<Bool>(value: false)
    var error = PublishSubject<Error>()
    
    // MARK: - Initializer
    
    init(repository: MenuFetchable) {
        self.repository = repository
        
        fetchMenus = fetching.asObserver()
        clearSelections = clearing.asObserver()
        makeOrder = ordering.asObserver()
        increaseMenu = increasing.asObserver()
    }
    
    func execute() {
        observeForFetchMenus()
        observeForClearMenus()
        observeForIncreaseMenuCount()
    }
}

// MARK: - Observing Methods

extension DefaultMenuUseCase {
    private func observeForFetchMenus() {
        fetching
            .do(onNext: { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.activating.onNext(true)
            })
            .flatMap(repository.fetchMenus) // -> MenuItem(name, price)
            .map { $0.map { ViewMenu($0) } }
            .do(onNext: { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.activating.onNext(false)
            })
            .do(onError: { [weak self] err in
                guard let self = self else {
                    return
                }
                self.error.onNext(err)
            })
            .bind(to: menus)
            .disposed(by: disposeBag)
    }
    
    private func observeForClearMenus() {
        clearing.withLatestFrom(menus)
            .map { $0.map { $0.countUpdated(0) } }
            .bind(to: menus)
            .disposed(by: disposeBag)
    }
    
    private func observeForIncreaseMenuCount() {
        increasing.map { $0.menu.countUpdated(
            max(0, $0.menu.count + $0.inc)
        ) }
        .withLatestFrom(menus) { (updated, originals) -> [ViewMenu] in
            originals.map {
                guard $0.name == updated.name else {
                    return $0
                }
                return updated
            }
        }
        .bind(to: menus)
        .disposed(by: disposeBag)
    }
}
