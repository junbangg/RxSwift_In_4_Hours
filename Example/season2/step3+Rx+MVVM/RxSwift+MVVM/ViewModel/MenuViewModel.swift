//
//  MenuViewModel.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 13/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

final class MenuViewModel {
    // MARK: - Input / Output
    
    struct Input {
        let firstLoad: Observable<Void>
        let reload: Observable<Void>
        let viewDidAppear: Observable<Void>
        let clearButtonTapped: Observable<Void>
        let orderButtonTapped: Observable<Void>
    }
    
    struct Output {
        let activated: Observable<Bool>
        let errorMessage: Observable<NSError>
        let allMenus: Observable<[ViewMenu]>
        let totalSelectedCountText: Observable<String>
        let totalPriceText: Observable<String>
        let showOrderPage: Observable<[ViewMenu]>
    }
    
    // MARK: - Properties
    
    private let useCase: MenuUseCase
    
    // MARK: - Initializer
    
    init(domain: MenuFetchable = MenuStore()) {
        self.useCase = DefaultMenuUseCase(repository: domain)
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        configureInput(input, disposeBag: disposeBag)
        
        return createOutput(from: self.useCase, disposeBag: disposeBag)
    }
}

// MARK: - Transform Methods

extension MenuViewModel {
    private func configureInput(_ input: Input, disposeBag: DisposeBag) {
        Observable.merge([input.firstLoad, input.reload])
            .bind(to: useCase.fetchMenus)
            .disposed(by: disposeBag)
        
        Observable.merge([input.viewDidAppear, input.clearButtonTapped])
            .bind(to: useCase.clearSelections)
            .disposed(by: disposeBag)
        
        useCase.execute()
    }
    
    private func createOutput(from useCase: MenuUseCase, disposeBag: DisposeBag) -> Output {
        let allMenus = useCase.menus
        
        let activated = useCase.activating.distinctUntilChanged()
        
        let errorMessage = useCase.error.map { $0 as NSError }
        
        let totalSelectedCountText = useCase.menus
            .map { $0.map { $0.count }.reduce(0, +) }
            .map { "\($0)" }
        
        let totalPriceText = useCase.menus
            .map { $0.map { $0.price * $0.count }.reduce(0, +) }
            .map { $0.currencyKR() }
        
        let showOrderPage = useCase.ordering
            .withLatestFrom(useCase.menus)
            .map { $0.filter { $0.count > 0 } }
            .do(onNext: { items in
                if items.count == 0 {
                    let err = NSError(domain: "No Orders", code: -1, userInfo: nil)
                    useCase.error
                        .onNext(err)
                }
            })
                .filter { $0.count > 0 }
        let output = Output(
            activated: activated,
            errorMessage: errorMessage,
            allMenus: allMenus,
            totalSelectedCountText: totalSelectedCountText,
            totalPriceText: totalPriceText,
            showOrderPage: showOrderPage
        )
        
        return output
    }
}
