//  The MIT License (MIT)
//
//  Copyright (c) 2016 Adam Cumiskey
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//
//  BlockTableDataSource.swift
//
//  Created by Adam Cumiskey on 6/16/15.
//  Copyright (c) 2015 adamcumiskey. All rights reserved.
//

import UIKit


public typealias IndexPathBlock = (_ indexPath: IndexPath) -> Void
public typealias ReorderBlock = (_ sourceIndex: IndexPath, _ destinationIndex: IndexPath) -> Void
public typealias ScrollBlock = (_ scrollView: UIScrollView) -> Void


// MARK: - TableRow

public struct TableRow {
    
    var cellClass: UITableViewCell.Type
    var reuseIdentifier: String { return String(describing: cellClass) }
    
    var configure: (UITableViewCell) -> ()
    public var onSelect: IndexPathBlock?
    public var onDelete: IndexPathBlock?
    public var selectionStyle = UITableViewCellSelectionStyle.none
    public var reorderable = false
    
    public init<Cell: UITableViewCell>(selectionStyle: UITableViewCellSelectionStyle = .none, reorderable: Bool = true, configure: @escaping (Cell) -> Void) {
        self.selectionStyle = selectionStyle
        self.reorderable = reorderable
        
        self.cellClass = Cell.self
        self.configure = { cell in
            configure(cell as! Cell)
        }
    }
    
    public init<Cell: UITableViewCell>(configure: @escaping (Cell) -> Void, onSelect: IndexPathBlock? = nil, onDelete: IndexPathBlock? = nil, selectionStyle: UITableViewCellSelectionStyle = .none, reorderable: Bool = true) {
        self.onSelect = onSelect
        self.onDelete = onDelete
        self.selectionStyle = selectionStyle
        self.reorderable = reorderable
        
        self.cellClass = Cell.self
        self.configure = { cell in
            configure(cell as! Cell)
        }
    }
}


// MARK: - TableSection

public struct TableSection {
    
    public enum HeaderFooter {
        case label(String)
        case customView(UIView, height: CGFloat)
        
        var text: String? {
            switch self {
            case let .label(text):
                return text
            default:
                return nil
            }
        }
        
        var view: UIView? {
            switch self {
            case let .customView(view, _):
                return view
            default:
                return nil
            }
        }
    }
    
    public var header: HeaderFooter?
    public var rows: [TableRow]
    public var footer: HeaderFooter?
    
    public init(header: HeaderFooter? = nil, rows: [TableRow], footer: HeaderFooter? = nil) {
        self.header = header
        self.rows = rows
        self.footer = footer
    }
    
    public init(header: HeaderFooter? = nil, row: TableRow, footer: HeaderFooter? = nil) {
        self.header = header
        self.rows = [row]
        self.footer = footer
    }
}


// MARK: - BlockTableDataSource

public class BlockTableDataSource: NSObject {
    public var sections: [TableSection]
    public var onReorder: ReorderBlock?
    public var onScroll: ScrollBlock?
    
    public override init() {
        self.sections = [TableSection]()
        super.init()
    }
    
    public init(sections: [TableSection], onReorder: ReorderBlock? = nil, onScroll: ScrollBlock? = nil) {
        self.sections = sections
        self.onReorder = onReorder
        self.onScroll = onScroll
    }
    
    public init(section: TableSection, onReorder: ReorderBlock? = nil, onScroll: ScrollBlock? = nil) {
        self.sections = [section]
        self.onReorder = onReorder
        self.onScroll = onScroll
    }
    
    public init(rows: [TableRow], onReorder: ReorderBlock? = nil, onScroll: ScrollBlock? = nil) {
        self.sections = [TableSection(rows: rows)]
        self.onReorder = onReorder
        self.onScroll = onScroll
    }
}


// MARK: - Reusable Registration

public extension BlockTableDataSource {
    @objc(registerReuseIdentifiersToTableView:)
    public func registerReuseIdentifiers(to tableView: UITableView) {
        for section in sections {
            for row in section.rows {
                if let _ = Bundle.main.path(forResource: row.reuseIdentifier, ofType: "nib") {
                    let nib = UINib(nibName: row.reuseIdentifier, bundle: Bundle.main)
                    tableView.register(nib, forCellReuseIdentifier: row.reuseIdentifier)
                } else {
                    tableView.register(row.cellClass, forCellReuseIdentifier: row.reuseIdentifier)
                }
            }
        }
    }
}


// MARK: - UITableViewDataSource

extension BlockTableDataSource: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionAtIndex(section)?.rows.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rowAtIndexPath(indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier, for: indexPath)
        cell.selectionStyle = row.selectionStyle
        row.configure(cell)
        return cell
    }
}


// MARK: - UITableViewDelegate

extension BlockTableDataSource: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = rowAtIndexPath(indexPath)
        if let onSelect = row.onSelect {
            onSelect(indexPath)
        }
    }
    
    @nonobjc public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionAtIndex(section)?.header?.text
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionAtIndex(section)?.header?.view
    }
    
    @nonobjc public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sectionAtIndex(section)?.footer?.text
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return sectionAtIndex(section)?.footer?.view
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let header = sectionAtIndex(section)?.header else { return UITableViewAutomaticDimension }
        switch header {
        case .label(_):
            return UITableViewAutomaticDimension
        case let .customView(_, height):
            return height
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let footer = sectionAtIndex(section)?.footer else { return UITableViewAutomaticDimension }
        switch footer {
        case .label(_):
            return UITableViewAutomaticDimension
        case let .customView(_, height):
            return height
        }
    }
    
    @nonobjc public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let row = rowAtIndexPath(indexPath)
        return row.onDelete != nil || row.reorderable == true
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        let row = rowAtIndexPath(indexPath)
        guard let _ = row.onDelete else { return .none }
        return .delete
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let row = rowAtIndexPath(indexPath)
            if let onDelete = row.onDelete {
                onDelete(indexPath)
                sections[indexPath.section].rows.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            }
        }
    }
    
    @nonobjc public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        let row = rowAtIndexPath(indexPath)
        return row.reorderable
    }
    
    public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        let destination = rowAtIndexPath(proposedDestinationIndexPath)
        if destination.reorderable {
            return proposedDestinationIndexPath
        } else {
            return sourceIndexPath
        }
    }
    
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let reorder = onReorder {
            reorder(sourceIndexPath, destinationIndexPath)
        }
    }
}


// MARK: - UIScrollViewDelegate

extension BlockTableDataSource {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let onScroll = onScroll {
            onScroll(scrollView)
        }
    }
}


// MARK: - Helpers

extension BlockTableDataSource {
    fileprivate func rowAtIndexPath(_ indexPath: IndexPath) -> TableRow {
        let section = sections[indexPath.section]
        return section.rows[indexPath.row]
    }
    
    fileprivate func sectionAtIndex(_ index: Int) -> TableSection? {
        guard sections.count > index else { return nil }
        return sections[index]
    }
}
