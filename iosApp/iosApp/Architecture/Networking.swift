//
//  Networking.swift
//  funnelmink
//
//  Created by Jared Warren on 11/27/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import Foundation
import Shared

class Networking {
    // TODO: mink api takes a closure that's called when the user is not authenticated. Plus any other hooks we need
    static let api: API = {
        let fmapi = FunnelminkAPI(
            baseURL: Properties.baseURL
        )
        
        // TODO: initialize all 5 closures. Use if DEV to intercept some of the ugly ones (like 500s)
        
        
        return fmapi
    }()
}

