//
//  AddTopicViewController.swift
//  TinnoFeeds
//
//  Created by John Wong Chon Yong on 06/10/2019.
//  Copyright © 2019 TinnoLab. All rights reserved.
//

import UIKit

protocol AddTopicDelegate {
    func didDismissedWithNewTopic(topic:Topic)
}


class AddTopicViewController: CustomViewController {
    
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtContent: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var delegate:AddTopicDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        txtContent.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitButtonAction(_ sender: UIButton) {
        guard let titleText = self.txtTitle.text, titleText.count > 0 else {
            self.showAlertMessage(withTitle: "Add Failed!", msg: "Please enter a title.")
            return
        }
        guard let contentText = self.txtContent.text, contentText.count > 0 else {
            self.showAlertMessage(withTitle: "Add Failed!", msg: "Content cannot be empty.")
            return
        }
        self.dismiss(animated: true) {
            let newTopic = Topic(id: UUID().uuidString)
            newTopic.title = titleText
            newTopic.content = contentText
            newTopic.createdBy = "DemoIOSUSer"
            newTopic.createdDate = Date()
            newTopic.upVote = 0
            newTopic.downVote = 0
            self.delegate?.didDismissedWithNewTopic(topic: newTopic)
        }
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
}

extension AddTopicViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 255
    }
}
