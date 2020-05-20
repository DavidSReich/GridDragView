//
//  GridDragViewModel.swift
//  GridDrag
//
//  Created by David S Reich on 9/5/20.
//  Copyright © 2020 StellarSoftware.
//  All rights reserved except as defined by MIT license - see LICENSE file for more info.
//

import SwiftUI

protocol ViewFactoryProtocol {
    func makeView(row: Int, col: Int) -> AnyView
}

class GridDragViewModel: ObservableObject {
    struct GridCell: View {
        var cell: AnyView

        var body: some View {
            cell
        }
    }

    //this must be @Published, otherwise the observing View is not refreshed
    @Published private var cellOffsets: [CGPoint] = []

    var dragging = false

    var cellSize: CGFloat
    let rows: Int
    let cols: Int

    private var origin: CGPoint

    private var draggingCellIndexes = [Int]()
    private var isHorizontal = false
    private var lastDragTranslation = CGSize.zero

    private let viewFactory: ViewFactoryProtocol?
    private let cells: [GridCell]?

    init(rows: Int, cols: Int, cellSize: CGFloat, viewFactory: ViewFactoryProtocol?, cells: [GridCell]?) {
        self.rows = rows
        self.cols = cols
        self.cellSize = cellSize
        self.viewFactory = viewFactory
        self.cells = cells

        let originXOffset = cellSize * CGFloat(cols - 1) / 2
        let originYOffset = cellSize * CGFloat(rows - 1) / 2
        self.origin = CGPoint(x: -originXOffset, y: -originYOffset)

        if self.viewFactory == nil && self.cells == nil {
            fatalError("One of viewFactory or cells MUST be non-nil!!")
        } else if let cells = self.cells {
            if cells.count != rows * cols {
                fatalError("Number of cells MUST equal rows x cols!!")
            }
        }

        resetCellOffsets()
    }

    func getCellView(row: Int, col: Int) -> AnyView {
        let cellIndex = (row * cols) + col
        if let cells = self.cells {
            return AnyView(cells[cellIndex])
        } else if let viewFactory = self.viewFactory {
            return viewFactory.makeView(row: row, col: col)
        }

        return AnyView(EmptyView())
    }
}

// dragging functions
extension GridDragViewModel {
    func moveViews(index: Int, translation: CGSize) {
        guard index < cellOffsets.count else {
            return
        }

        if !dragging {
            //set direction
            isHorizontal = abs(translation.width) > abs(translation.height)
            lastDragTranslation = .zero

            //get cells in the appropriate row or col
            draggingCellIndexes = getDraggingCells(index: index)
        }

        //find and move only views in the appropriate row or col

        if isHorizontal {
            let deltaX = translation.width - lastDragTranslation.width

            for index in draggingCellIndexes {
                cellOffsets[index].x = wrapDrag(value: cellOffsets[index].x, delta: deltaX)
            }
        } else {
            let deltaY = translation.height - lastDragTranslation.height

            for index in draggingCellIndexes {
                cellOffsets[index].y = wrapDrag(value: cellOffsets[index].y, delta: deltaY)
            }
        }

        lastDragTranslation = translation
    }

    //    sort draggingCellIndexes by x|y
    //    then just snap them into rows|cols 0, 1, ...

    func snapToGrid() {
        if isHorizontal {
            let sortedDraggingIndexes = draggingCellIndexes.sorted {
                cellOffsets[$0].x < cellOffsets[$1].x
            }

            for index in 0..<sortedDraggingIndexes.count {
                let cellOffsetIndex = sortedDraggingIndexes[index]
                cellOffsets[cellOffsetIndex].x = origin.x + (CGFloat(index) * cellSize)
            }
        } else {
            let sortedDraggingIndexes = draggingCellIndexes.sorted {
                cellOffsets[$0].y < cellOffsets[$1].y
            }

            for index in 0..<sortedDraggingIndexes.count {
                let cellOffsetIndex = sortedDraggingIndexes[index]
                cellOffsets[cellOffsetIndex].y = origin.y + (CGFloat(index) * cellSize)
            }
        }
    }

    private func getDraggingCells(index: Int) -> [Int] {
        var draggingCells = [Int]()

        let draggingCellOffset = cellOffsets[index]

        if isHorizontal {
            let currentRow = currentCellRow(y: draggingCellOffset.y)
            for index in 0..<cellOffsets.count {
                if currentCellRow(y: cellOffsets[index].y) == currentRow {
                    draggingCells.append(index)
                }
            }
        } else {
            let currentCol = currentCellCol(x: draggingCellOffset.x)
            for index in 0..<cellOffsets.count {
                if currentCellCol(x: cellOffsets[index].x) == currentCol {
                    draggingCells.append(index)
                }
            }
        }

        return draggingCells
    }

    private func wrapDrag(value: CGFloat, delta: CGFloat) -> CGFloat {
        var newValue = value + delta

        if isHorizontal {
            let newCol = currentCellCol(x: newValue)
            if newCol < 0 {
                //shift to the end
                newValue += (CGFloat(cols) * cellSize)
            } else if newCol >= cols {
                //shift to the beginning
                newValue -= (CGFloat(cols) * cellSize)
            }
        } else {
            let newRow = currentCellRow(y: newValue)
            if newRow < 0 {
                //shift to the end
                newValue += (CGFloat(rows) * cellSize)
            } else if newRow >= rows {
                //shift to the beginning
                newValue -= (CGFloat(rows) * cellSize)
            }
        }

        return newValue
    }

    private func currentCellRow(y: CGFloat) -> Int {
        let rowFloat = (y - origin.y) / cellSize
        return Int(rowFloat.rounded())
    }

    private func currentCellCol(x: CGFloat) -> Int {
        let colFloat = (x - origin.x) / cellSize
        return Int(colFloat.rounded())
    }
}

// offset functions
extension GridDragViewModel {
    func resetCellOffsets() {
        cellOffsets = makeCellOffsets()
    }

    func resizeCells(newCellSize: CGFloat) {
        cellOffsets = recalcOffsets(newCellSize: newCellSize)
    }

    func getCurrentOffset(index: Int) -> CGSize {
        return index < cellOffsets.count ? CGSize(width: cellOffsets[index].x, height: cellOffsets[index].y) :
            CGSize(width: origin.x, height: origin.y)
    }

    private func makeCellOffsets() -> [CGPoint] {
        var cellOffsets = [CGPoint]()

        for row in 0..<rows {
            for col in 0..<cols {
                cellOffsets.append(CGPoint(x: origin.x + CGFloat(col) * cellSize,
                                           y: origin.y + CGFloat(row) * cellSize))
            }
        }

        return cellOffsets
    }

    private func calcOrigin(cellSize: CGFloat) -> CGPoint {
        let originXOffset = cellSize * CGFloat(cols - 1) / 2
        let originYOffset = cellSize * CGFloat(rows - 1) / 2
        return CGPoint(x: -originXOffset, y: -originYOffset)
    }

    private func recalcOffsets(newCellSize: CGFloat) -> [CGPoint] {

        // first time with a non-zero size - just makeCellOffsets
        guard cellSize != 0 else {
            self.cellSize = newCellSize
            self.origin = self.calcOrigin(cellSize: newCellSize)
            return makeCellOffsets()
        }

        // if no changes, just return current offsets
        guard cellSize != newCellSize else {
            return self.cellOffsets
        }

        var cellOffsets = [CGPoint]()

        let newOrigin = calcOrigin(cellSize: newCellSize)

        for index in 0..<self.cellOffsets.count {
            let rowCol = getCellRowCol(index: index)
            cellOffsets.append(CGPoint(x: newOrigin.x + CGFloat(rowCol.col) * newCellSize,
                                       y: newOrigin.y + CGFloat(rowCol.row) * newCellSize))
        }

        cellSize = newCellSize
        origin = newOrigin
        return cellOffsets
    }

    private func getCellRowCol(index: Int) -> (row: Int, col: Int) {
        let row = currentCellRow(y: cellOffsets[index].y)
        let col = currentCellCol(x: cellOffsets[index].x)
        return (row, col)
    }
}
