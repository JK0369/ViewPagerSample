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

    var dataSource: [MyCollectionViewModel] = []

    lazy var collectionView: UICollectionView = {

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 12
        flowLayout.scrollDirection = .horizontal

        let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.backgroundColor = .lightGray

        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDataSource()

        addSubviews()

        configure()

        setupDelegate()

        registerCell()
    }

    private func setupDataSource() {
        for i in 0...10 {
            let model = MyCollectionViewModel(title: i)
            dataSource += [model]
        }
    }

    private func addSubviews() {
        view.addSubview(collectionView)
    }

    private func configure() {
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(96)
        }
    }

    private func setupDelegate() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    private func registerCell() {
        collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: MyCollectionViewCell.id)
    }

    func didTapCell(to model: MyCollectionViewModel) {
        print(model)
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
                    guard let dataSource = self?.dataSource else { return }
                    self?.didTapCell(to: dataSource[indexPath.item])
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
