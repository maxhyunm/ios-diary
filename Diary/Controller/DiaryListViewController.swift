//
//  Diary - DiaryListViewController.swift
//  Created by yagom.
//  Copyright © yagom. All rights reserved.
//  Last modified by Maxhyunm, Hamg.

import UIKit
import CoreLocation

final class DiaryListViewController: UIViewController {
    private var locationManager = CLLocationManager()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .singleLine
        
        return tableView
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        
        return formatter
    }()

    var coreDataManager: CoreDataManager?
    private var diaryList = [Diary]()
    
    private var latitude: Double?
    private var longitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        updateLocation()
        configureUI()
        setupNavigationBarButton()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        readCoreData()
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        self.title = NSLocalizedString("titleLabel", comment: "")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func setupNavigationBarButton() {
        let addDiary = UIAction(image: UIImage(systemName: "plus")) { [weak self] _ in
            guard let self, let coreDataManager else { return }
            let createDiaryView = DiaryDetailViewController(latitude: self.latitude,
                                                            longitude: self.longitude,
                                                            coreDataManager: coreDataManager)
            self.navigationController?.pushViewController(createDiaryView, animated: true)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(primaryAction: addDiary)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DiaryListTableViewCell.self, forCellReuseIdentifier: DiaryListTableViewCell.identifier)
    }

    private func readCoreData() {
        guard let coreDataManager else { return }
        
        do {
            guard let fetchedDiaries = try coreDataManager.fetchEntity(sortBy: "createdAt") as? [Diary] else {
                throw CoreDataError.unknown
            }
            
            diaryList = fetchedDiaries.filter { $0.title != nil }
            tableView.reloadData()
        } catch CoreDataError.dataNotFound {
            let alertBuilder = AlertBuilder(viewController: self, prefferedStyle: .alert)
            alertBuilder.setType(.coreDataError(error: .dataNotFound))
            alertBuilder.addAction(.confirm)
            alertBuilder.show()
        } catch {
            let alertBuilder = AlertBuilder(viewController: self, prefferedStyle: .alert)
            alertBuilder.setType(.coreDataError(error: .unknown))
            alertBuilder.addAction(.confirm)
            alertBuilder.show()
        }
    }
}

extension DiaryListViewController: UITableViewDataSource {
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
              let body = diaryEntity.body?.split(separator: "\n").joined(separator: "\n") else {
            return UITableViewCell()
        }
        let date = dateFormatter.string(from: createdAt)
        cell.setModel(title: title, date: date, body: body, icon: diaryEntity.weatherIcon)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        
        return searchBar
    }
}

extension DiaryListViewController: UITableViewDelegate, ShareDisplayable {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let diaryToEdit = diaryList[indexPath.row]
        
        guard let coreDataManager else { return }
        
        let createVC = DiaryDetailViewController(diaryToEdit, coreDataManager: coreDataManager)
        
        navigationController?.pushViewController(createVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) ->
    UISwipeActionsConfiguration? {
        guard let coreDataManager else { return nil }
        
        let delete = UIContextualAction(style: .normal, title: "") { (_, _, success: @escaping (Bool) -> Void) in
            let selectedDiary = self.diaryList[indexPath.row]
            do {
                try coreDataManager.deleteEntity(selectedDiary)
                self.readCoreData()
                success(true)
            } catch CoreDataError.deleteFailure {
                let alertBuilder = AlertBuilder(viewController: self, prefferedStyle: .alert)
                alertBuilder.setType(.coreDataError(error: .deleteFailure))
                alertBuilder.addAction(.confirm)
                alertBuilder.show()
            } catch {
                let alertBuilder = AlertBuilder(viewController: self, prefferedStyle: .alert)
                alertBuilder.setType(.coreDataError(error: .unknown))
                alertBuilder.addAction(.confirm)
                alertBuilder.show()
            }
        }
        
        let share = UIContextualAction(style: .normal, title: "") { (_, _, success: @escaping (Bool) -> Void) in
            let selectedDiary = self.diaryList[indexPath.row]
            
            self.shareDiary(selectedDiary)
            success(true)
        }
        
        delete.backgroundColor = .systemRed
        delete.image = UIImage(systemName: "trash.fill")
        share.backgroundColor = .systemBlue
        share.image = UIImage(systemName: "square.and.arrow.up")
        
        return UISwipeActionsConfiguration(actions: [delete, share])
    }
}

extension DiaryListViewController: CLLocationManagerDelegate {
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func updateLocation() {
        let locationStatus: [CLAuthorizationStatus] = [.authorizedAlways, .authorizedWhenInUse]
        
        guard locationStatus.contains(locationManager.authorizationStatus) else { return }
        
        locationManager.startUpdatingLocation()
        
        guard let location: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }
        
        latitude = location.latitude
        longitude = location.longitude
        
        locationManager.stopUpdatingLocation()
    }
}

extension DiaryListViewController: UISearchBarDelegate {
    func searchDiary(with keyword: String) {
        guard let coreDataManager else { return }
        
        if keyword.count > 0 {
            do {
                let predicate = "title CONTAINS[cd] %@ OR body CONTAINS[cd] %@"
                guard let fetchedDiaries = try coreDataManager.filterEntity(keyword,
                                                                            predicate: predicate,
                                                                            sortBy: "createdAt") as? [Diary] else {
                    throw CoreDataError.unknown
                }
                
                diaryList = fetchedDiaries.filter { $0.title != nil }
                tableView.reloadData()
            } catch CoreDataError.dataNotFound {
                let alertBuilder = AlertBuilder(viewController: self, prefferedStyle: .alert)
                alertBuilder.setType(.coreDataError(error: .dataNotFound))
                alertBuilder.addAction(.confirm)
                alertBuilder.show()
            } catch {
                let alertBuilder = AlertBuilder(viewController: self, prefferedStyle: .alert)
                alertBuilder.setType(.coreDataError(error: .unknown))
                alertBuilder.addAction(.confirm)
                alertBuilder.show()
            }
        }
        
        if keyword.count == 0 {
            readCoreData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchDiary(with: searchText)
    }
}
