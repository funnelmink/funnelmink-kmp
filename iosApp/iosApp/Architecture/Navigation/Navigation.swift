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
    private init() {
        _state._selectedTab = .init(rawValue: UserDefaults.standard.integer(forKey: "Navigation._state._selectedTab")) ?? .today
    }
    
    @Published var _state = State()
    var _onModalDismiss: (() -> Void)?
    
    struct State: Hashable, Equatable {
        var _dismissTask: Task<Void, Error>?
        var _selectedTab = FunnelMinkTab.today
        
        // navigation stack for each tab
        var _0 = [Segue]()
        var _1 = [Segue]()
        var _2 = [Segue]()
        var _3 = [Segue]()
        var _4 = [Segue]()
        
        // navigation stack when not logged in
        var _unauthenticated = [UnauthenticatedSegue]()
        
        var _sheet: Modal?
        var _fullscreen: Modal?
        
        var _toast: Toast?
        var _modalToast: Toast?
        
    }
    
    func _path(for tab: FunnelMinkTab) -> Binding<[Segue]> {
        switch tab.rawValue {
        case 0: return Binding(get: { self._state._0 }, set: { self._state._0 = $0 } )
        case 1: return Binding(get: { self._state._1 }, set: { self._state._1 = $0 } )
        case 2: return Binding(get: { self._state._2 }, set: { self._state._2 = $0 } )
        case 3: return Binding(get: { self._state._3 }, set: { self._state._3 = $0 } )
        case 4: return Binding(get: { self._state._4 }, set: { self._state._4 = $0 } )
        default: fatalError("Tried to access a tab that doesn't exist")
        }
    }
    
    func segue(_ segue: Segue) {
        switch _state._selectedTab.rawValue {
        case 0: _state._0.append(segue)
        case 1: _state._1.append(segue)
        case 2: _state._2.append(segue)
        case 3: _state._3.append(segue)
        case 4: _state._4.append(segue)
        default: break
        }
    }
    
    func popSegue() {
        switch _state._selectedTab.rawValue {
        case 0: _state._0.removeLast()
        case 1: _state._1.removeLast()
        case 2: _state._2.removeLast()
        case 3: _state._3.removeLast()
        case 4: _state._4.removeLast()
        default: break
        }
    }
    
    func popSegueToRoot() {
        switch _state._selectedTab.rawValue {
        case 0: _state._0 = []
        case 1: _state._1 = []
        case 2: _state._2 = []
        case 3: _state._3 = []
        case 4: _state._4 = []
        default: break
        }
    }
    
    func modalSheet(_ modal: Modal, onDismiss: (() -> Void)? = nil) {
        var state = _state
        state._fullscreen = nil
        state._sheet = modal
        _onModalDismiss = { onDismiss?(); self._onModalDismiss = nil }
        _state = state
    }
    
    func modalFullscreen(_ modal: Modal, onDismiss: (() -> Void)? = nil) {
        var state = _state
        state._sheet = nil
        state._fullscreen = modal
        _onModalDismiss = { onDismiss?(); self._onModalDismiss = nil }
        _state = state
    }
    
    func dismissModal() {
        var state = _state
        state._sheet = nil
        state._fullscreen = nil
        _state = state
    }
    
    func externalDeeplink(to deeplink: ExternalDeeplink) {
        if let url = deeplink.url,
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func externalDeeplink(to url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func externalDeeplink(to string: String) {
        if let url = URL(string: string),
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
