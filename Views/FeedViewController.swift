//
//  FeedViewController.swift
//  SocialFeed
//
//  Created by MacMy on 15.11.2025.
//

import UIKit

/// Главный экран с лентой постов
class FeedViewController: UIViewController {
  
  private let viewModel = FeedViewModel()
  
  /// Лента постов в виде таблицы.
  /// Используется `lazy`, чтобы отложить создание таблицы до первого обращения к ней.
  /// Это позволяет избежать лишних затрат ресурсов при инициализации контроллера.
  private lazy var tableView: UITableView = {
    let table = UITableView()
    table.translatesAutoresizingMaskIntoConstraints = false
    table.delegate = self
    table.dataSource = self
    table.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
    table.rowHeight = UITableView.automaticDimension
    table.estimatedRowHeight = 120
    table.separatorStyle = .singleLine
    return table
  }()
  
  private lazy var refreshControl: UIRefreshControl = {
    let refresh = UIRefreshControl()
    refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    return refresh
  }()
  
  private lazy var activityIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(style: .large)
    indicator.translatesAutoresizingMaskIntoConstraints = false
    indicator.hidesWhenStopped = true
    return indicator
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .red
    setupUI()
    setupBindings()
    viewModel.loadPosts()
  }
  
  private func setupUI() {
    title = "Лента"
    view.backgroundColor = .systemBackground
    
    // Добавляем tableView
    view.addSubview(tableView)
    tableView.refreshControl = refreshControl
    
    // Добавляем индикатор загрузки
    view.addSubview(activityIndicator)
    
    // AutoLayout
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }
  
  private func setupBindings() {
    // Обновление постов
    viewModel.onPostsUpdated = { [weak self] in
      DispatchQueue.main.async {
        self?.tableView.reloadData()
      }
    }
    
    // Обработка ошибок
    viewModel.onError = { [weak self] errorMessage in
      DispatchQueue.main.async {
        self?.showError(errorMessage)
      }
    }
    
    // Состояние загрузки
    viewModel.onLoadingStateChanged = { [weak self] isLoading in
      DispatchQueue.main.async {
        if isLoading && !self!.refreshControl.isRefreshing {
          self?.activityIndicator.startAnimating()
        } else {
          self?.activityIndicator.stopAnimating()
        }
      }
    }
  }
  
  /// Обрабатывает событие "pull-to-refresh" (потянуть для обновления).
  /// Загружает посты с сервера с принудительным обновлением (`forceRefresh: true`).
  /// Через 1 секунду останавливает анимацию обновления (`refreshControl.endRefreshing()`),
  /// чтобы пользователь видел, что процесс обновления завершён.
  /// @objc т.к. используется в #selector(handleRefresh),
  @objc private func handleRefresh() {
    viewModel.loadPosts(forceRefresh: true)
    
    // Останавливаем refresh control через секунду
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
      self?.refreshControl.endRefreshing()
    }
  }
  
  private func showError(_ message: String) {
    let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }
}

extension FeedViewController: UITableViewDataSource {
  
  /// Возвращает количество строк в секции таблицы.
  /// - Parameters:
  ///   - tableView: Таблица, для которой запрашивается количество строк.
  ///   - section: Индекс секции.
  /// - Returns: Количество строк, равное количеству постов в `viewModel`.
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.posts.count
  }
  
  /// Предоставляет ячейку для отображения поста в таблице.
  /// - Parameters:
  ///   - tableView: Таблица, запрашивающая ячейку.
  ///   - indexPath: Индекс строки и секции, для которой нужна ячейка.
  /// - Returns: Настроенная ячейка `PostTableViewCell` с данными поста.
  ///
  /// Метод пытается получить переиспользуемую ячейку типа `PostTableViewCell`.
  /// Если это не удается, возвращает пустую ячейку `UITableViewCell`.
  /// Затем конфигурирует ячейку данными поста из `viewModel`.
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as? PostTableViewCell else {
      return UITableViewCell()
    }
    
    let post = viewModel.posts[indexPath.row]
    cell.configure(with: post)
    
    return cell
  }
}

extension FeedViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
