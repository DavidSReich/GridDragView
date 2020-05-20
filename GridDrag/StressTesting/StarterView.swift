//
//  StarterView.swift
//  GridDrag
//
//  Created by David S Reich on 15/5/20.
//  Copyright © 2020 StellarSoftware. All rights reserved.
//

import SwiftUI

struct StarterView: View {
    var body: some View {
        TestGridDragView(cellSize: 50, rows: 5, cols: 4)
    }
}

struct StarterView_Previews: PreviewProvider {
    static var previews: some View {
        StarterView()
    }
}
