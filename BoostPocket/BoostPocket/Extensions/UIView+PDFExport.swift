//
//  UIView+PDFExport.swift
//  BoostPocket
//
//  Created by 송주 on 2021/04/10.
//  Copyright © 2021 BoostPocket. All rights reserved.
//

import UIKit

extension UIView {
    func PDFWithScrollView() -> Data {
        guard let scrollview = self as? UIScrollView else { return Data() }
        let pageDimensions = scrollview.bounds
        let pageSize = pageDimensions.size
        let totalSize = scrollview.contentSize
        
        let numberOfPagesThatFitHorizontally = Int(ceil(totalSize.width / pageSize.width))
        let numberOfPagesThatFitVertically = Int(ceil(totalSize.height / pageSize.height))
        let outputData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(outputData, pageDimensions, nil)
        let savedContentOffset = scrollview.contentOffset
        let savedContentInset = scrollview.contentInset
        
        scrollview.contentInset = UIEdgeInsets.zero
        
        if let context = UIGraphicsGetCurrentContext() {
            for indexHorizontal in 0 ..< numberOfPagesThatFitHorizontally {
                for indexVertical in 0 ..< numberOfPagesThatFitVertically {
                    UIGraphicsBeginPDFPage()
                    
                    let offsetHorizontal = CGFloat(indexHorizontal) * pageSize.width
                    let offsetVertical = CGFloat(indexVertical) * pageSize.height
                    
                    scrollview.contentOffset = CGPoint(x: offsetHorizontal, y: offsetVertical)
                    context.translateBy(x: -offsetHorizontal, y: -offsetVertical) // NOTE: Negative offsets
                    scrollview.layer.render(in: context)
                }
            }
        }
        UIGraphicsEndPDFContext()
        
        scrollview.contentInset = savedContentInset
        scrollview.contentOffset = savedContentOffset

        return outputData as Data
    }
    
    func viewToPDF() -> String {
        let data = PDFWithScrollView()
        return self.saveViewPdf(data: data)
    }
    
    // Save pdf file in document directory
    func saveViewPdf(data: Data) -> String {
        guard let data = data as? NSMutableData else { return "Failed" }
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docDirectoryPath = paths[0]
        let pdfPath = docDirectoryPath.appendingPathComponent("viewPdf.pdf")

        if data.write(to: pdfPath, atomically: true) {
            return pdfPath.path
        } else {
            return ""
        }
    }
}
