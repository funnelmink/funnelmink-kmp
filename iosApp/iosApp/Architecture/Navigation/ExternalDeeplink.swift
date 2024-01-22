//
//  ExternalDeeplink.swift
//  iosApp
//
//  Created by Jared Warren on 10/19/23.
//  Copyright © 2023 FunnelMink. All rights reserved.
//

import UIKit

enum ExternalDeeplink {
    case notificationSettings
    case settings
    
    var url: URL? {
        switch self {
        case .notificationSettings: URL(string: UIApplication.openNotificationSettingsURLString)
        case .settings: URL(string: UIApplication.openSettingsURLString)
        }
    }
}
