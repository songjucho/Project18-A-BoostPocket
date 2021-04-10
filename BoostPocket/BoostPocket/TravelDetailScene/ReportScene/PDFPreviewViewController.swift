//
//  PDFPreviewViewController.swift
//  BoostPocket
//
//  Created by 송주 on 2021/04/09.
//  Copyright © 2021 BoostPocket. All rights reserved.
//

import UIKit
import PDFKit

class PDFPreviewViewController: UIViewController {
    
    public var documentData: Data?
    @IBOutlet weak var PDFView: PDFView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = documentData {
            PDFView.document = PDFDocument(data: data)
            PDFView.autoScales = true
        }
    }
}
