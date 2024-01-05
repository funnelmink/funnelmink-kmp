//
//  CGFloat+.swift
//  funnelmink
//
//  Created by Jared Warren on 11/28/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import Foundation

extension CGFloat {
    /// Theoretical  max width that can easily be read without forcing a user to move their head on iPad - https://developer.apple.com/documentation/uikit/uiview/1622644-readablecontentguide
    static var maximumReadableWidth: CGFloat { 672 } // Behind the scenes, it never exceeds 672
}
