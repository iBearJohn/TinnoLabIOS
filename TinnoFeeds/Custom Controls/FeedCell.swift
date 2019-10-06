//
//  FeedCell.swift
//  TinnoFeeds
//
//  Created by John Wong Chon Yong on 06/10/2019.
//  Copyright © 2019 TinnoLab. All rights reserved.
//

import UIKit

class FeedCell: UITableViewCell {

    @IBOutlet weak var lblCreatedBy: UILabel!
    @IBOutlet weak var lblCreatedDate: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var btnUpVote: UIButton!
    @IBOutlet weak var btnDownVote: UIButton!
    
    var upVoteAction : (() -> Void)? = nil
    var downVoteAction : (() -> Void)? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func upVoteButtonAction(_ sender: UIButton) {
        if let upVote = upVoteAction {
            upVote()
        }
    }
    @IBAction func downVoteButtonAction(_ sender: UIButton) {
        if let downVote = downVoteAction {
            downVote()
        }
    }
    
    
}
