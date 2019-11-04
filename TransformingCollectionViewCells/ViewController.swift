//
//  ViewController.swift
//  TransformingCollectionViewCells
//
//  Created by Ahmed Khalaf on 11/4/19.
//  Copyright © 2019 Ahmed Khalaf. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private lazy var data = Array(0..<100)
    private var _observers: [ScrollViewObserverBox] = []
    private var observers: [ScrollViewObserver] {
        _observers = _observers.filter({ $0.observer != nil })
        return _observers.compactMap({ $0.observer })
    }
    private func addScrollViewObserver(_ observer: ScrollViewObserver) {
        _observers.append(ScrollViewObserverBox(observer: observer))
    }
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: Overrides
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollViewDidScroll(collectionView)
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! Cell
        addScrollViewObserver(cell)
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        observers.forEach {
            $0.scrollViewDidScroll(scrollView)
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.height, height: collectionView.bounds.height)
    }
}

protocol ScrollViewObserver: AnyObject {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
}

struct ScrollViewObserverBox {
    weak var observer: ScrollViewObserver?
}

class Cell: UICollectionViewCell, ScrollViewObserver {
    
    @IBOutlet private weak var view: UIView!
    @IBOutlet private weak var viewContainerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.clipsToBounds = false
        
//        contentView.backgroundColor = .blue
//        contentView.layer.borderWidth = 1
    }
    
    // MARK: ScrollViewObserver
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let convertedViewCenter = scrollView.superview!.convert(view.center, from: view.superview!)
//        let scale: CGFloat = (1 - abs(convertedViewCenter.x - scrollView.center.x) * 0.005).clamped(min: 0, max: 1)
//        view.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        var transform = CGAffineTransform.identity
        
        let rotation: CGFloat = (convertedViewCenter.x - scrollView.center.x) * 4 / scrollView.bounds.width
//        let translation: CGFloat = (view.bounds.width / 2)
//        let xSign: CGFloat = rotation < 0 ? -1 : 1
        
//        transform = transform.concatenating(CGAffineTransform(translationX: translation * xSign, y: -translation))
        transform = transform.concatenating(CGAffineTransform(rotationAngle: rotation))
//        transform = transform.concatenating(CGAffineTransform(translationX: translation, y: translation))
        viewContainerView.transform = transform
    }
}

extension CGFloat {
    func clamped(min: CGFloat, max: CGFloat) -> CGFloat {
        return Swift.min(max, Swift.max(min, self))
    }
}
