//
//  Navigation.swift
//  iosApp
//
//  Created by Jared Warren on 10/18/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import Foundation
import SwiftUI

class Navigation: ObservableObject {
    static let shared = Navigation()
    @Published var _selectedTab = FunnelMinkTab.today
    // navigation stack for each tab
    @Published var _0 = [Segue]()
    @Published var _1 = [Segue]()
    @Published var _2 = [Segue]()
    @Published var _3 = [Segue]()
    @Published var _4 = [Segue]()
    // navigation stack when not logged in
    @Published var _unauthenticated = [UnauthenticatedSegue]()
    
    @Published var _sheet: Modal?
    @Published var _fullscreen: Modal?
    
    // TODO: @Published var _toast: Toast?
    // TODO: @Published var _modalToast: Toast?
    
    @Published var _onModalDismiss: (() -> Void)?
    
    func _path(for tab: FunnelMinkTab) -> Binding<[Segue]> {
        switch tab.rawValue {
        case 0: return Binding(get: { self._0 }, set: { self._0 = $0 } )
        case 1: return Binding(get: { self._1 }, set: { self._1 = $0 } )
        case 2: return Binding(get: { self._2 }, set: { self._2 = $0 } )
        case 3: return Binding(get: { self._3 }, set: { self._3 = $0 } )
        case 4: return Binding(get: { self._4 }, set: { self._4 = $0 } )
        default: fatalError("Tried to access a tab that doesn't exist")
        }
    }
    
    func performSegue(_ segue: Segue) {
        switch _selectedTab.rawValue {
        case 0: _0.append(segue)
        case 1: _1.append(segue)
        case 2: _2.append(segue)
        case 3: _3.append(segue)
        case 4: _4.append(segue)
        default: break
        }
    }
    
    func popSegue() {
        switch _selectedTab.rawValue {
        case 0: _0.removeLast()
        case 1: _1.removeLast()
        case 2: _2.removeLast()
        case 3: _3.removeLast()
        case 4: _4.removeLast()
        default: break
        }
    }
    
    func popToRoot() {
        switch _selectedTab.rawValue {
        case 0: _0 = []
        case 1: _1 = []
        case 2: _2 = []
        case 3: _3 = []
        case 4: _4 = []
        default: break
        }
    }
    
    // TODO: presentToast(_ message: String, type: ToastType = .info) { check if a modal is presented }
    
    func presentSheet(_ modal: Modal, onDismiss: (() -> Void)? = nil) {
        _fullscreen = nil
        _sheet = modal
        _onModalDismiss = { onDismiss?(); self._onModalDismiss = nil }
    }
    
    func presentFullscreen(_ modal: Modal, onDismiss: (() -> Void)? = nil) {
        _sheet = nil
        _fullscreen = modal
        _onModalDismiss = { onDismiss?(); self._onModalDismiss = nil }
    }
    
    func dismissModal() {
        _sheet = nil
        _fullscreen = nil
    }
    
    func externalDeeplink(to deeplink: ExternalDeeplink) {
        if let url = deeplink.url,
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

protocol NavigationSegue: Hashable, Equatable {}

extension NavigationSegue {
    var rawValue: String { "\(self)" }

    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

extension Modal: Hashable, Equatable {
    var id: String { rawValue }
    var rawValue: String { "\(self)" }

    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}
