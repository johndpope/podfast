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
}

class DiscoveryScreenViewController: UIViewController, DiscoveryViewDelegate {

    @IBOutlet weak var podcastCollection: UICollectionView!

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

}

extension DiscoveryScreenViewController: UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.getPodcastCount()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let podcast = presenter.getPodcast(forRow: indexPath.row)
        let cell = podcastCollection.dequeueReusableCell(
            withReuseIdentifier: "podcast",
            for: indexPath
        ) as! PodcastCollectionViewCell

        cell.titleLabel.text = podcast.categories.first?.name
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.selectedPodcast(atRow: indexPath.row)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let center = self.view.center
        for cell in podcastCollection.visibleCells.map({$0 as! PodcastCollectionViewCell}) {
            // detect collision
            let cellFrame = podcastCollection.convert(cell.frame, to: self.view)
            cell.titleLabel.textColor = .black
            cell.titleLabel.isHighlighted = cellFrame.contains(center) ? true : false
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let center = self.view.center
        for cell in podcastCollection.visibleCells.map({$0 as! PodcastCollectionViewCell}) {
            // detect collision
            let cellFrame = podcastCollection.convert(cell.frame, to: self.view)
            if cellFrame.contains(center) {
                cell.titleLabel.isHighlighted = false
                cell.titleLabel.textColor = .green
            } else {
                cell.titleLabel.isHighlighted = false
            }
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let center = self.view.center
        for cell in podcastCollection.visibleCells.map({$0 as! PodcastCollectionViewCell}) {
            // detect collision
            let cellFrame = podcastCollection.convert(cell.frame, to: self.view)
            if cellFrame.contains(center) {
                cell.titleLabel.isHighlighted = false
                cell.titleLabel.textColor = .green
            } else {
                cell.titleLabel.isHighlighted = false
            }
        }
    }
}
