//
//  MenuListViewModel.swift
//  RxSwift+MVVM
//
//  Created by Jun Bang on 2022/02/11.
//  Copyright © 2022 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class MenuListViewModel {
    
    lazy var menuObservable = BehaviorRelay<[Menu]>(value: [])
    
    lazy var itemsCount = menuObservable.map {
        $0.map { $0.count }
        .reduce(0, +)
    }
    
    lazy var totalPrice = menuObservable
        .map {
            $0.map { $0.count * $0.price }
            .reduce(0, +)
        }
    
    func clearAllItemSelections() {
        menuObservable
            .map { menus in
                menus.map { m in
                    Menu(id: m.id, name: m.name, price: m.price, count: 0)
                }
            }
            .take(1)
            .subscribe(onNext: {
                self.menuObservable.accept($0)
            })
    }
    
    func onOrder() {
        
    }
    
    func changeCount(for item: Menu, by amount: Int) {
        _ = menuObservable
            .map { menus in
                menus.map { m in
                    var newCount = m.count
                    if m.id == item.id {
                        newCount += amount
                    }
                    return Menu(id: m.id, name: m.name, price: m.price, count: max(0, newCount))
                }
            }
            .take(1)
            .subscribe(onNext: {
                self.menuObservable.accept($0)
            })
    }
    

    init() {
        APIService.fetchAllMenusRX()
            .map { data -> [MenuItem] in
                struct Response: Decodable {
                    let menus: [MenuItem]
                }
                
                let response = try! JSONDecoder().decode(Response.self, from: data)
                
                return response.menus
            }
            .map { menuItems -> [Menu] in
                var menus: [Menu] = []
                menuItems.enumerated().forEach { (index, item) in
                    let menu = Menu.convert(from: item, id: index)
                    menus.append(menu)
                }
                return menus
            }
        
            .take(1)
            .bind(to: menuObservable)
    }
}
