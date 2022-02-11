//
//  Menu.swift
//  RxSwift+MVVM
//
//  Created by Jun Bang on 2022/02/11.
//  Copyright © 2022 iamchiwon. All rights reserved.
//

import Foundation

struct Menu {
    var id: Int
    var name: String
    var price: Int
    var count: Int
}

extension Menu {
    static func convert(from item: MenuItem, id: Int) -> Menu {
        return Menu(id: id, name: item.name, price: item.price, count: 0)
    }
}
