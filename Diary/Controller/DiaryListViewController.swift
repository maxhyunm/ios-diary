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
    private let container = CoreDataManager.shared.persistentContainer
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
    }
}

extension DiaryListViewController: DiaryListDelegate {
    func readCoreData() {
        do {
            diaryList = try container.viewContext.fetch(Diary.fetchRequest())
            tableView.reloadData()
        } catch {
            // TODO : AlertController Error
        }
    }
}
