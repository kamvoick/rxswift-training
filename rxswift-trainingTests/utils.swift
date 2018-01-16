//
//  utils.swift
//  rxswift-trainingTests
//
//  Created by Łukasz Andrzejewski on 15.01.2018.
//  Copyright © 2018 Inbright Łukasz Andrzejewski. All rights reserved.
//

import Foundation

func snippet(name: String, code: () -> Void) {
    print("\n###", name, "####")
    code()
    print("###################################################################################")
}
