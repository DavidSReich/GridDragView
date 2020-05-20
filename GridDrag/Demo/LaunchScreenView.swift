//
//  LaunchScreenView.swift
//  GridDrag
//
//  Created by David S Reich on 15/5/20.
//  Copyright © 2020 StellarSoftware.
//  All rights reserved except as defined by MIT license - see LICENSE file for more info.
//

import SwiftUI

struct LaunchScreenView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            HStack {
                Image("ViewFactoryLarge")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Image("ArrayOfCellsLarge")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }

            Text("GridDrag")
                .font(.largeTitle)
                .bold()
            Text("Demo")
                .font(.title)
                .bold()
            Text("Copyright © 2020 Stellar Software Pty Ltd. All rights reserved.")
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .padding()
        .onAppear(perform: self.goAway)
    }

    private func goAway() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.isPresented = false
        }
    }
}

struct LaunchScreenView_Previews: PreviewProvider {
    @State static var showLaunch = true
    static var previews: some View {
        LaunchScreenView(isPresented: $showLaunch)
    }
}
