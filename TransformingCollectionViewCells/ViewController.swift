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
        _observers.appendUnique(ScrollViewObserverBox(observer: observer))
    }
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.decelerationRate = .fast
    }
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
        cell.isHidden = indexPath.row == 0 || indexPath.row == data.count - 1
        cell.label.text = "\(data[indexPath.row])"
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        observers.forEach {
            $0.scrollViewDidScroll(scrollView)
        }
    }
    
    private var index: CGFloat = 0
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let cellSize = self.cellSize(scrollView: scrollView)
        var targetIndex = (targetContentOffset.pointee.x + cellSize.width / 2) / cellSize.width
        targetIndex = velocity.x > 0 ? ceil(targetIndex) : floor(targetIndex)
        targetIndex = targetIndex.clamped(min: 0, max: CGFloat(data.count - 1))
        targetContentOffset.pointee.x = targetIndex * cellSize.width
        
        index = targetIndex
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize(scrollView: collectionView)
    }
    
    private func cellSize(scrollView: UIScrollView) -> CGSize {
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
    
    @IBOutlet weak var label: UILabel!
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
        let scale = 1 - abs(rotation)
        let translationPoint = CGPoint(x: view.convert(scrollView.center, from: scrollView.superview!).x - view.bounds.width / 2, y: view.convert(scrollView.center, from: scrollView.superview!).y + 150)
        
        transform = transform.concatenating(CGAffineTransform(translationX: -translationPoint.x, y: -translationPoint.y))
        transform = transform.concatenating(CGAffineTransform(rotationAngle: rotation))
        transform = transform.concatenating(CGAffineTransform(translationX: translationPoint.x, y: translationPoint.y))
        transform = transform.concatenating(CGAffineTransform(scaleX: scale, y: scale))
        
        view.transform = transform
        
        view.isHidden = scale < 0.5
    }
}

extension CGFloat {
    func clamped(min: CGFloat, max: CGFloat) -> CGFloat {
        return Swift.min(max, Swift.max(min, self))
    }
}

extension Array where Element == ScrollViewObserverBox {
    mutating func appendUnique(_ element: Element) {
        guard !contains(where: { $0.observer === element.observer }) else { return }
        append(element)
    }
}
