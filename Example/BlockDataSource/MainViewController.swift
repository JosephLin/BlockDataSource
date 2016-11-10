//
//  MainViewController.swift
//  BlockDataSource
//
//  Created by Adam Cumiskey on 11/10/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import BlockDataSource


class MainViewController: BlockTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = BlockDataSource(
            sections: [
                Section(
                    rows: [
                        Row(
                            cellClass: Cell.self,
                            configure: { cell in
                                cell.textLabel?.text = "Examples"
                            },
                            onSelect: { [unowned self] indexPath in
                                let testVC = CellExamplesViewController(style: .Grouped)
                                testVC.title = "Examples"
                                self.navigationController?.pushViewController(testVC, animated: true)
                            }
                        ),
                        Row(
                            cellClass: Cell.self,
                            configure: { cell in
                                cell.textLabel?.text = "Editing"
                            },
                            onSelect: { [unowned self] indexPath in
                                let reorderVC = EditingViewController(style: .Grouped)
                                reorderVC.title = "Editing"
                                self.navigationController?.pushViewController(reorderVC, animated: true)
                            }
                        ),
                        Row(
                            cellClass: Cell.self,
                            configure: { cell in
                                
                            }
                        ),
                        Row(
                            cellClass: Cell.self,
                            configure: { cell in
                                
                            }
                        ),
                        Row(
                            cellClass: Cell.self,
                            configure: { cell in
                                
                            }
                        ),
                    ]
                )
            ]
        )
    }
}
