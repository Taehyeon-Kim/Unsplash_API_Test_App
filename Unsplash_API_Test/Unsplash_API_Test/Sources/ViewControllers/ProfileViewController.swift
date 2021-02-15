//
//  ProfileViewController.swift
//  iOS-api-test
//
//  Created by taehy.k on 2021/02/13.
//

import UIKit

import Kingfisher

class ProfileViewController: UIViewController {
    // MARK: Variables
    
    private var API_KEY: String = ""
    var userInfo: UserResponse!
    var userLikedPhotos: [Result] = []
    
    // MARK: - IBOutlets

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var bio: UILabel!
    @IBOutlet weak var followersCount: UILabel!
    @IBOutlet weak var totalDownloads: UILabel!
    @IBOutlet weak var totalLikes: UILabel!

    @IBOutlet weak var likedPhotoCollectionView: UICollectionView!
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupCollectionView()
//        fetchUserLikedPhoto()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserInfo()
        fetchUserLikedPhoto()
    }
    
    // MARK: - Custom Function
    
    func setupView() {
        fetchAPIKey()
        self.navigationController?.navigationBar.isHidden = true
        self.profileImage.layer.cornerRadius = self.profileImage.layer.frame.width/2
    }
    
    func fetchUserInfo() {
        UserInfoService.shared.getUserInfo(clientID: API_KEY, username: "taeeehyeon") { (result) -> (Void) in
            switch result {
            case .success(let data):
                self.userInfo = nil
                if let response = data as? UserResponse {
                    self.userInfo = response
                }
                let url = URL(string: self.userInfo.profile_image.large)
                DispatchQueue.main.async {
                    self.profileImage.kf.setImage(with: url)
                    self.username.text = self.userInfo.username
                    self.bio.text = self.userInfo.bio
                    self.followersCount.text = String(self.userInfo.followers_count)
                    self.totalDownloads.text = String(self.userInfo.downloads)
                }
            case .requestErr(let msg):
                print(msg)
            case .pathErr:
                print("path Err")
            case .serverErr:
                print("server Err")
            case .networkFail:
                print("network Fail")
            }
        }
    }
    
    func fetchUserLikedPhoto() {
        UserLikedPhotoService.shared.getUserLikedPhoto(clientID: API_KEY, username: "taeeehyeon") { (result) -> (Void) in
            switch result {
            case .success(let data):
                self.userLikedPhotos = []
                if let response = data as? [Result] {
                    self.userLikedPhotos = response
                }
                self.likedPhotoCollectionView.reloadData()
            case .requestErr(let msg):
                print(msg)
            case .pathErr:
                print("path Err!!")
            case .serverErr:
                print("server Err")
            case .networkFail:
                print("network Fail")
            }
        }
    }

    /// Info.plist에 있는 API_KEY값 가져오기
    func fetchAPIKey(){
        if let infoDic: [String:Any] = Bundle.main.infoDictionary {
            if let UNSPLASH_API_KEY = infoDic["UNSPLASH_API_KEY"] as? String {
                API_KEY = UNSPLASH_API_KEY
            }
        }
    }

}

extension ProfileViewController {
    func setupCollectionView() {
        likedPhotoCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        likedPhotoCollectionView.dataSource = self
        likedPhotoCollectionView.delegate = self
//        likedPhotoCollectionView.isScrollEnabled = false
        
        // 셀 등록
        likedPhotoCollectionView.register(LikedPhotoCVC.self, forCellWithReuseIdentifier: LikedPhotoCVC.identifier)
        
        // 콤포지셔널 레이아웃 등록
        likedPhotoCollectionView.collectionViewLayout = createCompositionalLayout()
    }
    
    fileprivate func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            // 아이템에 대한 사이즈
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            
            // 아이템 사이즈로 아이템 만들기
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 5, bottom: 5, trailing: 5)
            
            // 그룹 사이즈
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1/2))
            
            // 그룹 사이즈로 그룹 만들기
            /// count는 subitem의 개수이다
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
            
            // 그룹으로 섹션 만들기
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 15, leading: 10, bottom: 15, trailing: 10)
            return section
        }
        return layout
    }
}

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = DetailViewController(nibName: "DetailViewController", bundle: nil)
        if let url = URL(string: self.userLikedPhotos[indexPath.row].urls.full) {
            detailVC.setData(url: url)
        }
        detailVC.modalPresentationStyle = .fullScreen
        detailVC.photoID = userLikedPhotos[indexPath.row].id
        self.present(detailVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.totalLikes.text = String(self.userLikedPhotos.count)
        return self.userLikedPhotos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = likedPhotoCollectionView.dequeueReusableCell(withReuseIdentifier: LikedPhotoCVC.identifier, for: indexPath) as? LikedPhotoCVC else { return UICollectionViewCell() }
        cell.configure(with: userLikedPhotos[indexPath.row].urls.full)
        return cell
    }
}
