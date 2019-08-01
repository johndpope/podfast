//
//  DiscoveryScreenViewController.swift
//  PodFast
//
//  Created by Orestis on 30/07/2019.
//  Copyright © 2019 Orestis Papadopoulos. All rights reserved.
//

import UIKit

protocol DiscoveryViewDelegate: NSObjectProtocol {
    func reloadData()
    func playBackStarted()
}

class DiscoveryScreenViewController: UIViewController, DiscoveryViewDelegate {

    @IBOutlet weak var podcastCollection: UICollectionView!

    private weak var collidedCell: PodcastCollectionViewCell?

    private let presenter = DiscoveryScreenPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        podcastCollection.dataSource = self
        podcastCollection.delegate = self
        podcastCollection.decelerationRate = UIScrollViewDecelerationRateFast


        presenter.setViewDelegate(discoveryViewDelegate: self)
        presenter.viewDidLoad()

        let frame = self.podcastCollection.frame
        let lineView = UIView(frame: CGRect(x: frame.width/2,
                                            y: frame.minY, width: 2.0, height: frame.height))
        lineView.backgroundColor = .red
        self.view.addSubview(lineView)
    }

    func reloadData() {
        podcastCollection.reloadData()
    }

    // TODO Not working at the moment
    func playBackStarted() {
        collidedCell?.isHighlighted = false
        collidedCell?.titleLabel.textColor = .green
    }

}

extension DiscoveryScreenViewController: UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.getCategoriesCount()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = podcastCollection.dequeueReusableCell(
            withReuseIdentifier: "podcast",
            for: indexPath
        ) as! PodcastCollectionViewCell

        cell.titleLabel.text = presenter.getCategoryName(forRow: indexPath.row) ?? " "
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didSelectCategory(atRow: indexPath.row)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let center = self.view.center
        for cell in podcastCollection.visibleCells.map({$0 as! PodcastCollectionViewCell}) {
            // detect collision
            let cellFrame = podcastCollection.convert(cell.frame, to: self.view)
            cell.titleLabel.textColor = .black
            if cellFrame.contains(center) {
                cell.titleLabel.isHighlighted = true
                if(collidedCell != cell){
                    collidedCell = cell
                    collisionDetected(forCell: cell)
                    presenter.didSelectCategory(atRow: podcastCollection.indexPath(for: cell)!.row)
                }
            } else {
                cell.titleLabel.isHighlighted = false
            }
        }
    }

    func collisionDetected(forCell cell: PodcastCollectionViewCell){
        print("Collision of cell \(cell.titleLabel.text)")
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let center = self.view.center
//        for cell in podcastCollection.visibleCells.map({$0 as! PodcastCollectionViewCell}) {
//            // detect collision
//            let cellFrame = podcastCollection.convert(cell.frame, to: self.view)
//            if cellFrame.contains(center) {
//                cell.titleLabel.isHighlighted = false
//                cell.titleLabel.textColor = .green
//            } else {
//                cell.titleLabel.isHighlighted = false
//            }
//        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        let center = self.view.center
//        for cell in podcastCollection.visibleCells.map({$0 as! PodcastCollectionViewCell}) {
//            // detect collision
//            let cellFrame = podcastCollection.convert(cell.frame, to: self.view)
//            if cellFrame.contains(center) {
//                cell.titleLabel.isHighlighted = false
//                cell.titleLabel.textColor = .green
//            } else {
//                cell.titleLabel.isHighlighted = false
//            }
//        }
    }
}
