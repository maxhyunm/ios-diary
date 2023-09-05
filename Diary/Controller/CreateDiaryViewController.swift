//
//  CreateDiaryViewController.swift
//  Diary
//
//  Created by Maxhyunm, Hamg on 2023/08/29.
//

import UIKit

final class CreateDiaryViewController: UIViewController, AlertDisplayable {
    private let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .preferredFont(forTextStyle: .body)
        
        return textView
    }()
    
    weak var delegate: DiaryListDelegate?
    var diaryToEdit: Diary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDiary()
        configureUI()
        setupNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveDiary()
        delegate?.readCoreData()
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        self.title = DateFormatter().formatToString(from: Date(), with: "YYYY년 MM월 dd일")
        
        if let diaryEdit = diaryToEdit {
            textView.text = "\(diaryEdit.title ?? "")\n\(diaryEdit.body ?? "")"
        }
        
        setupTextViewLayout()
        
        let moreButton = UIBarButtonItem(title: "더보기", style: .plain, target: self, action: #selector(showMoreOptions))
        navigationItem.rightBarButtonItem = moreButton
    }
    
    private func setupTextViewLayout() {
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil
        )
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil
        )
    }
    
    private func showShareActivity() {
        let textToShare = "일기 내용을 여기에 넣으세요."
        let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)

        present(activityViewController, animated: true, completion: nil)
    }
    
    private func showDeleteConfirmation() {
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.performDelete()
        }
        
        showAlert(title: "진짜요?", message: "정말로 삭제하시겠습니까?", actions: [cancelAction, deleteAction])
    }
    
    private func createDiary() {
        if diaryToEdit == nil {
            diaryToEdit = CoreDataManager.shared.createDiary()
        }
    }
    
    private func saveDiary() {
        guard let diary = diaryToEdit else { return }
    
        CoreDataManager.shared.saveDiary(diary, textView.text)
    }
    
    private func deleteDiary(_ diary: Diary?) {
        if let diary = diary {
            CoreDataManager.shared.deleteDiary(diary)
        }
    }
    
    private func performDelete() {
       deleteDiary(diaryToEdit)
        navigationController?.popViewController(animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: @objc Code
extension CreateDiaryViewController {
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                as? CGRect else { return }
        
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.size.height, right: 0)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        textView.contentInset = .zero
        saveDiary()
    }
    
    @objc private func showMoreOptions() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let shareAction = UIAlertAction(title: "Shared", style: .default) { [weak self] _ in
            self?.showShareActivity()
        }
        alertController.addAction(shareAction)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.showDeleteConfirmation()
        }
        alertController.addAction(deleteAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
}
