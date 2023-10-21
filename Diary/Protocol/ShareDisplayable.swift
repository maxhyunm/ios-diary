//
//  ShareDiary.swift
//  Diary
//
//  Created by Max, Hemg on 2023/09/05.
//

import UIKit

protocol ShareDisplayable {
    func shareDiary(_ diary: Diary?)
}

extension ShareDisplayable where Self: UIViewController {
    func shareDiary(_ diary: Diary?) {
        guard let diary,
              let title = diary.title,
              let createdAt = diary.createdAt,
              let body = diary.body else {
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        let date = dateFormatter.string(from: createdAt)
        let shareText = """
                        제목: \(title)
                        작성일자: \(date)
                        내용: \(body)
                        """
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        self.present(activityViewController, animated: true, completion: nil)
    }
}
