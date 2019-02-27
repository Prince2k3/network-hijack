//
//  String+PathComponents.swift
//  Network Hijack
//
//  Created by Prince Ugwuh on 2/27/19.
//  Copyright © 2019 Prince Ugwuh. All rights reserved.
//

import Foundation

extension String {
    var pathComponents: [String] {
        var path = self
        
        if path.first == "/" {
            path = String(path.dropFirst())
        }
        
        if path.last == "/" {
            path = String(path.dropLast())
        }
        
        return path.components(separatedBy: "/")
    }
}
