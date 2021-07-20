//
//  ViewController.swift
//  ViewPagerSample
//
//  Created by 김종권 on 2021/07/20.
//

import UIKit
import RxGesture
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    var currentPage: Int = 0 {
        didSet {
            bind(oldValue: oldValue, newValue: currentPage)
        }
    }

    var dataSource: [MyCollectionViewModel] = []
    var dataSourceVC: [UIViewController] = []

    lazy var collectionView: UICollectionView = {

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 12
        flowLayout.scrollDirection = .horizontal

        let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.backgroundColor = .lightGray

        return view
    }()

    lazy var pageViewController: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

        return vc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDataSource()

        setupViewControllers()

        addSubviews()

        configure()

        setupDelegate()

        registerCell()

        setViewControllersInPageVC()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        currentPage = 0
    }

    private func setupDataSource() {
        for i in 0...10 {
            let model = MyCollectionViewModel(title: i)
            dataSource += [model]
        }
    }

    private func setupViewControllers() {

        var i = 0
        dataSource.forEach { _ in
            let vc = UIViewController()
            let red = CGFloat(arc4random_uniform(256)) / 255
            let green = CGFloat(arc4random_uniform(256)) / 255
            let blue = CGFloat(arc4random_uniform(256)) / 255

            vc.view.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1)

            let label = UILabel()
            label.text = "\(i)"
            label.font = .systemFont(ofSize: 56, weight: .bold)
            i += 1

            vc.view.addSubview(label)
            label.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            dataSourceVC += [vc]
        }
    }

    private func addSubviews() {
        view.addSubview(collectionView)
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
    }

    private func configure() {
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(96)
        }

        pageViewController.view.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        pageViewController.didMove(toParent: self)
    }

    private func setupDelegate() {
        collectionView.delegate = self
        collectionView.dataSource = self

        pageViewController.delegate = self
        pageViewController.dataSource = self
    }

    private func registerCell() {
        collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: MyCollectionViewCell.id)
    }

    private func setViewControllersInPageVC() {
        if let firstVC = dataSourceVC.first {
            pageViewController.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
    }

    private func bind(oldValue: Int, newValue: Int) {

        // collectionView 에서 선택한 경우
        let direction: UIPageViewController.NavigationDirection = oldValue < newValue ? .forward : .reverse
        pageViewController.setViewControllers([dataSourceVC[currentPage]], direction: direction, animated: true, completion: nil)

        // pageViewController에서 paging한 경우
        collectionView.selectItem(at: IndexPath(item: currentPage, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }

    func didTapCell(at indexPath: IndexPath) {
        currentPage = indexPath.item
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.id, for: indexPath)
        if let cell = cell as? MyCollectionViewCell {
            cell.model = dataSource[indexPath.item]

            cell.contentsView.rx.tapGesture(configuration: .none)
                .when(.recognized)
                .asDriver { _ in .never() }
                .drive(onNext: { [weak self] _ in
                    self?.didTapCell(at: indexPath)
                }).disposed(by: cell.bag)

        }
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: collectionView.frame.height)
    }
}

extension ViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = dataSourceVC.firstIndex(of: viewController) else { return nil }
        let previousIndex = index - 1
        if previousIndex < 0 {
            return nil
        }
        return dataSourceVC[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = dataSourceVC.firstIndex(of: viewController) else { return nil }
        let nextIndex = index + 1
        if nextIndex == dataSourceVC.count {
            return nil
        }
        return dataSourceVC[nextIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let currentVC = pageViewController.viewControllers?.first,
              let currentIndex = dataSourceVC.firstIndex(of: currentVC) else { return }
        currentPage = currentIndex
        print(currentIndex)
    }
}
