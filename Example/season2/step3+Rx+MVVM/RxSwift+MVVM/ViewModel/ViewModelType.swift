//
//  ViewModelType.swift
//  RxSwift+MVVM
//
//  Created by Jun Bang on 2022/05/21.
//  Copyright © 2022 iamchiwon. All rights reserved.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
