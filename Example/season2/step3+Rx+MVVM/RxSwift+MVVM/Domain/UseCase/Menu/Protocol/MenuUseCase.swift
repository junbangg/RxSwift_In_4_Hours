//
//  MenuUseCase.swift
//  RxSwift+MVVM
//
//  Created by Jun Bang on 2022/05/21.
//  Copyright © 2022 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift

protocol MenuUseCase {
    var fetchMenus: AnyObserver<Void> { get set }
    var clearSelections: AnyObserver<Void> { get set }
    var makeOrder: AnyObserver<Void> { get set }
//    var increaseMenuCount: AnyObserver<(menu: ViewMenu, inc: Int)> { get set }
    
    var fetching: PublishSubject<Void> { get set}
    var clearing: PublishSubject<Void> { get set }
    var ordering: PublishSubject<Void> { get set }
    var increasing: PublishSubject<(menu: ViewMenu, inc: Int)> { get set }

    var menus: BehaviorSubject<[ViewMenu]> { get set }
    var activating: BehaviorSubject<Bool> { get set }
    var error: PublishSubject<Error> { get set }
    
    func execute()
}
