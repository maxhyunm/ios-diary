//
//  Diary - ViewController.swift
//  Created by yagom.
//  Copyright © yagom. All rights reserved.
//  Last modified by Maxhyunm, Hamg.

import UIKit

protocol DiaryListDelegate: AnyObject {
    func readCoreData()
}

final class DiaryListViewController: UIViewController {
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    private let dateFormatter = DateFormatter()
    private var diaryList = [Diary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        readCoreData()
        configureUI()
        setupTableView()
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        self.title = "일기장"
        
        let addDiary = UIAction(image: UIImage(systemName: "plus")) { [weak self] _ in
            guard let self else { return }
            let createDiaryView = CreateDiaryViewController()
            createDiaryView.delegate = self
            self.navigationController?.pushViewController(createDiaryView, animated: true)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(primaryAction: addDiary)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DiaryListTableViewCell.self, forCellReuseIdentifier: DiaryListTableViewCell.identifier)
    }
}

extension DiaryListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        diaryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DiaryListTableViewCell.identifier,
                                                       for: indexPath) as?
                DiaryListTableViewCell else { return UITableViewCell() }
        
        let diaryEntity = diaryList[indexPath.row]
        guard let title = diaryEntity.title,
              let createdAt = diaryEntity.createdAt,
              let body = diaryEntity.body else { return UITableViewCell() }
        let date = dateFormatter.formatToString(from: createdAt, with: "YYYY년 MM월 dd일")
        
        cell.setModel(title: title, date: date, body: body)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let diaryToEdit = diaryList[indexPath.row]
        let createVC = CreateDiaryViewController()
        
        createVC.delegate = self
        createVC.diaryToEdit = diaryToEdit
        navigationController?.pushViewController(createVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "삭제") { _, _, _ in
            let diaryToEdit = self.diaryList[indexPath.row]
        
            CoreDataManager.shared.deleteDiary(diaryToEdit)
            CoreDataManager.shared.saveContext()
            tableView.reloadData()
        }
        deleteAction.backgroundColor = .red
        
        let shared = UIContextualAction(style: .normal, title: "공유하기") { _, _, _ in
            let textToShare = "일기 내용을 여기에 넣으세요."
            let activityViewController = UIActivityViewController(activityItems: [textToShare],
                                                                  applicationActivities: nil)
            
            self.present(activityViewController, animated: true, completion: nil)
        }
        shared.backgroundColor = .blue
        
        return UISwipeActionsConfiguration(actions: [deleteAction, shared])
    }
}

extension DiaryListViewController: DiaryListDelegate {
    func readCoreData() {
        do {
            diaryList = try CoreDataManager.shared.persistentContainer.viewContext.fetch(Diary.fetchRequest())
            tableView.reloadData()
        } catch {
            let alertController = UIAlertController(title: "오류",
                                                    message: "데이터를 읽어오는 중 오류가 발생했습니다.",
                                                    preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }
}
