//
//  EmptyView.swift
//  iosApp
//
//  Created by Jeremy Warren on 1/20/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI
import UIKit

enum EmptyViewType {
    case today
    case contacts
    case funnels
}

struct CustomEmptyView: View {
    var type: EmptyViewType
    var lottieAnimation: String

    private var title: String {
        switch type {
        case .today:
            return "Tasks you have to complete will be shown here!"
        case .contacts:
            return "Your contacts will be displayed here"
        case .funnels:
            return "No Funnels Created"
        }
    }

    var body: some View {
        VStack {
//            LottieView(animationFileName: lottieAnimation, loopMode: .autoReverse)
//                .frame(width: 200, height: 200)
            Text(title)
                .font(.title)
                .foregroundStyle(.secondary)
        }
    }
}

//struct LottieView: UIViewRepresentable {
//    
//    var animationFileName: String
//    let loopMode: LottieLoopMode
//    
//    func updateUIView(_ uiView: UIViewType, context: Context) {
//        
//    }
//    
//    func makeUIView(context: Context) -> Lottie.LottieAnimationView {
//        let animationView = LottieAnimationView(name: animationFileName)
//        animationView.loopMode = loopMode
//        animationView.play()
//        animationView.contentMode = .scaleAspectFill
//        return animationView
//    }
//}
#Preview {
    CustomEmptyView(type: .contacts, lottieAnimation: "ContactsLottie")
}
