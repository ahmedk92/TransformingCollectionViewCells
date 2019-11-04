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
        return CGSize(width: collectionView.bounds.width / 3, height: collectionView.bounds.height)
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.clipsToBounds = false
    }
    
    // MARK: ScrollViewObserver
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let convertedViewCenter = scrollView.superview!.convert(view.center, from: view.superview!)
        
        var transform = CGAffineTransform.identity
        
        let rotation: CGFloat = (convertedViewCenter.x - scrollView.center.x) * 1 / scrollView.bounds.width
        let translationPoint = CGPoint(x: view.convert(scrollView.center, from: scrollView.superview!).x, y: view.convert(scrollView.center, from: scrollView.superview!).y + 100)
        
        transform = transform.concatenating(CGAffineTransform(translationX: -translationPoint.x, y: -translationPoint.y))
        transform = transform.concatenating(CGAffineTransform(rotationAngle: rotation))
        transform = transform.concatenating(CGAffineTransform(translationX: translationPoint.x, y: translationPoint.y))
        view.transform = transform
    }
}

extension CGFloat {
    func clamped(min: CGFloat, max: CGFloat) -> CGFloat {
        return Swift.min(max, Swift.max(min, self))
    }
}
