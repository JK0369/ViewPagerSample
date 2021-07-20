//
//  MyCollectionViewCell.swift
//  ViewPagerSample
//
//  Created by 김종권 on 2021/07/20.
//

import UIKit
import SnapKit
import RxSwift

class MyCollectionViewCell: UICollectionViewCell {

    static var id: String { NSStringFromClass(Self.self).components(separatedBy: ".").last ?? "" }
    var bag = DisposeBag()

    var model: MyCollectionViewModel? { didSet { bind() } }

    lazy var contentsView: UIView = {
        let view = UIView()
        view.backgroundColor = .orange.withAlphaComponent(0.5)

        return view
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubviews()

        configure()
    }

    override var isSelected: Bool {
        didSet {
            contentsView.backgroundColor = isSelected ? .orange : .orange.withAlphaComponent(0.5)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        bag = DisposeBag()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    private func addSubviews() {
        addSubview(contentsView)
        contentsView.addSubview(titleLabel)
    }

    private func configure() {
        backgroundColor = .brown

        contentsView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(20)
            make.leading.trailing.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func bind() {
        titleLabel.text = "\((model?.title ?? 0))"
    }
}
