//
//  ViewController.swift
//  TinnoFeeds
//
//  Created by John Wong Chon Yong on 06/10/2019.
//  Copyright © 2019 TinnoLab. All rights reserved.
//

import UIKit

class ViewController: CustomViewController, UITableViewDataSource, UITableViewDelegate, AddTopicDelegate {
    
    @IBOutlet weak var tblFeeds: UITableView!
    @IBOutlet weak var btnAdd: UIButton!
    

    
    var loadedTopics:[Topic]?
    var defaultCell:UITableViewCell {
        get {
            let cell = self.tblFeeds.dequeueReusableCell(withIdentifier: "defaultCell")
            cell!.textLabel?.text = "Invalid Cell"
            cell!.selectionStyle = UITableViewCell.SelectionStyle.blue
            cell!.backgroundColor = UIColor.darkGray
            return cell!
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblFeeds.delegate = self
        tblFeeds.dataSource = self
        tblFeeds.estimatedRowHeight = tblFeeds.rowHeight
        tblFeeds.rowHeight = UITableView.automaticDimension
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        retrieveTopics()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddTopicViewController {
            vc.delegate = self
        }
    }
    
    @IBAction func btnAddAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "SHOWADD", sender: self)
    }
    
    func retrieveTopics() {
        DispatchQueue.main.async {
            self.showLoadingOverlay(inViewController: self, withMsg: "Reloading Topics...", alertDidAppeared: {
                Topic.getAllTopics { (result) in
                    self.closeLoadingOverlay {
                        switch result {
                        case .success(let topics):
                            self.loadedTopics = topics.sorted(by: { $0.upVote > $1.upVote })
                            DispatchQueue.main.async {
                                self.tblFeeds.reloadData()
                            }
                        case .failure(let err):
                            self.showAlertMessage(withTitle: "Error", msg: err.localizedDescription)
                        }
                    }
                }
            })
        }
    }
    
    func didDismissedWithNewTopic(topic: Topic) {
        DispatchQueue.main.async {
            self.showLoadingOverlay(inViewController: self, withMsg: "Submiting topic...", alertDidAppeared: {
                topic.submitTopic(requestCompleted: { (result) in
                    DispatchQueue.main.async {
                        self.closeLoadingOverlay {
                            switch result {
                            case .success:
                                self.retrieveTopics()
                            case .failure(let err):
                                self.showAlertMessage(withTitle: "Error", msg: err.localizedDescription)
                            }
                        }
                    }
                })
            })
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let topics = loadedTopics else {
            return 0
        }
        return topics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let topics = loadedTopics else {
            return defaultCell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as? FeedCell else {
            return defaultCell
        }
        cell.lblTitle.text = topics[indexPath.row].title
        cell.lblContent.text = topics[indexPath.row].content
        cell.lblCreatedBy.text = topics[indexPath.row].createdBy
        cell.lblCreatedDate.text = "\(topics[indexPath.row].createdDate)"
        cell.btnUpVote.setTitle("Up Vote (\(topics[indexPath.row].upVote))", for: .normal)
        cell.btnDownVote.setTitle("Down Vote (\(topics[indexPath.row].downVote))", for: .normal)
        cell.contentView.backgroundColor = UIColor.darkGray
        
        cell.upVoteAction = {
            DispatchQueue.main.async {
                self.showLoadingOverlay(inViewController: self, withMsg: "Updating Vote...", alertDidAppeared: {
                    topics[indexPath.row].upVoteTopic(requestCompleted: { (result) in
                        DispatchQueue.main.async {
                            self.closeLoadingOverlay {
                                switch result {
                                case .success:
                                    self.retrieveTopics()
                                case .failure(let err):
                                    self.showAlertMessage(withTitle: "Error", msg: err.localizedDescription)
                                }
                            }
                        }
                    })
                })
            }
        }
        cell.downVoteAction = {
            DispatchQueue.main.async {
                self.showLoadingOverlay(inViewController: self, withMsg: "Updating Vote...", alertDidAppeared: {
                    topics[indexPath.row].downVoteTopic(requestCompleted: { (result) in
                        DispatchQueue.main.async {
                            self.closeLoadingOverlay {
                                switch result {
                                case .success:
                                    self.retrieveTopics()
                                case .failure(let err):
                                    self.showAlertMessage(withTitle: "Error", msg: err.localizedDescription)
                                }
                            }
                        }
                    })
                })
            }
        }
        
        return cell
    }
    
}

