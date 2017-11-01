//
//  ListViewController.swift
//  StreamingVideo
//
//  Created by huydoquang on 10/30/17.
//  Copyright © 2017 huydoquang. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {

    private var viewModel: (ListViewModelInterface & ListViewModelProvider)!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    private func setupData() {
        viewModel = ListViewModel()
        viewModel?.result.bind(listener: { (result) in
            switch result {
            case .error(let error):
                self.updateUIWhenError(with: error)
            case .success:
                self.collectionView.reloadData()
            default:
                break
            }
        })
        viewModel.fetchListVideos()
    }
    
    private func setupUI() {
        collectionView.collectionViewLayout = ListCollectionViewLayout()
    }
    
    private func updateUIWhenError(with error: Error?) {
        
    }
    
    private func updateUIWhenSuccess(with video: [Video]) {
        
    }
    
    deinit {
        self.viewModel.cancelRequest()
    }
}

extension ListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel!.numberOfRow(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ListCollectionViewCell.self), for: indexPath) as! ListCollectionViewCell
        cell.configure(with: self.viewModel.video(at: indexPath))
        return cell
    }
}

extension ListViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
    }
}
