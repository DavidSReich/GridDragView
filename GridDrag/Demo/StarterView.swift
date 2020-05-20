//
//  StarterView.swift
//  GridDrag
//
//  Created by David S Reich on 15/5/20.
//  Copyright © 2020 StellarSoftware.
//  All rights reserved except as defined by MIT license - see LICENSE file for more info.
//

import SwiftUI

struct StarterView: View {
    @State private var showLaunchScreen = true

    var body: some View {
        Group {
            if showLaunchScreen {
                LaunchScreenView(isPresented: $showLaunchScreen)
            } else {
                MainView()
            }
        }
        .animation(.easeInOut)
    }
}

struct StarterView_Previews: PreviewProvider {
    static var previews: some View {
        StarterView()
    }
}
