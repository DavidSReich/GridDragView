//
//  GridDragViewModelStress.swift
//  GridDrag
//
//  Created by David S Reich on 9/5/20.
//  Copyright © 2020 StellarSoftware. All rights reserved.
//

import UIKit

class GridDragViewModelStress: GridDragViewModel {

    @Published var running = false

    private var timer: Timer?

    func run(rows: Int, cols: Int, cellSize: CGFloat) {
        //do this each time to reset
        resetCellOffsets()

        running = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true, block: {_ in
            self.randomDrag()
        })

        timer?.fire()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        running = false
    }

    private func randomDrag() {
        let boardHeight = CGFloat(rows + 1) * cellSize
        let boardWidth = CGFloat(cols + 1) * cellSize

        let moveLarge = Bool.random()
        let moveVertical = Bool.random()

        let height = moveVertical ? CGFloat.random(in: -cellSize...boardHeight) : 0
        let height2 = moveVertical ? CGFloat.random(in: height...boardHeight) : 0
        let width = moveVertical ? 0 : CGFloat.random(in: -cellSize...boardWidth)
        let width2 = moveVertical ? 0 : CGFloat.random(in: width...boardWidth)

        let directionMultiplier = CGFloat(moveLarge ? 1 : -1)

        let translationFirst = CGSize(width: directionMultiplier * width, height: directionMultiplier * height)
        let translationSecond = CGSize(width: directionMultiplier * width2, height: directionMultiplier * height2)

        moveViews(index: 0, translation: translationFirst)
        dragging = true

        moveViews(index: 0, translation: translationSecond)
        dragging = false

        snapToGrid()
    }
}
