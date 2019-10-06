//
//  CustomViewController.swift
//  TinnoFeeds
//
//  Created by John Wong Chon Yong on 06/10/2019.
//  Copyright © 2019 TinnoLab. All rights reserved.
//

import UIKit

class CustomViewController: UIViewController {
    
    var activeAlert:UIAlertController?
    
    // MARK: - FUNCTIONS - Popups
    
    /**
     shows a Alert Pop Up
     - Parameters:
     - title: title for the pop up window.
     - msg: message for the pop up window.
     - onDismiss: function to run after the pop up is dismissed.
     */
    func showAlertMessage(withTitle title:String, msg:String, onDismiss:(() -> ())? = nil) {
        DispatchQueue.main.async {
            self.closeLoadingOverlay {
                self.activeAlert = UIAlertController(title: title, message:
                    msg, preferredStyle: UIAlertController.Style.alert)
                self.activeAlert!.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.cancel,handler: {
                    (action:UIAlertAction!) -> Void in
                    onDismiss?()
                    self.activeAlert = nil
                }))
                self.present(self.activeAlert!, animated: true, completion: nil)
            }
        }
    }
    
    /**
     shows a Yes/No decision Alert Pop Up
     - Parameters:
     - title: title for the pop up window.
     - msg: message for the pop up window.
     - onYes: function to run after the pop up is dismissed if Yes is selected.
     - onNo: function to run after the pop up is dismissed if No is selected.
     */
    func showYesNoAlertMessage(withTitle title:String, msg:String, onYes:(() -> ())? = nil, onNo:(() -> ())? = nil) {
        DispatchQueue.main.async {
            self.closeLoadingOverlay {
                self.activeAlert = UIAlertController(title: title, message:
                    msg, preferredStyle: UIAlertController.Style.alert)
                self.activeAlert!.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default,handler: {
                    (action:UIAlertAction!) -> Void in
                    onYes?()
                    self.activeAlert = nil
                }))
                self.activeAlert!.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel,handler: {
                    (action:UIAlertAction!) -> Void in
                    onNo?()
                    self.activeAlert = nil
                }))
                self.present(self.activeAlert!, animated: true, completion: nil)
            }
        }
    }
    
    /**
     shows an overlay for stopping user action on loading items.
     - Parameters:
     - viewController: view controller to launch the loading view.
     - msg: message for the pop up window.
     - alertDidAppeared: function to run after the the loading view appeared.
     */
    func showLoadingOverlay(inViewController viewController:UIViewController, withMsg msg:String, alertDidAppeared:@escaping () -> ()) {
        DispatchQueue.main.async {
            self.closeLoadingOverlay {
                self.activeAlert = UIAlertController(title: nil, message: "\t\(msg)", preferredStyle: .alert)
                self.activeAlert!.view.tintColor = UIColor.black
                let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
                loadingIndicator.hidesWhenStopped = true
                loadingIndicator.style = UIActivityIndicatorView.Style.gray
                loadingIndicator.startAnimating()
                
                self.activeAlert!.view.addSubview(loadingIndicator)
                viewController.present(self.activeAlert!, animated: true) {
                    alertDidAppeared()
                }
            }
        }
    }
    
    /**
     close the active loading view.
     - Parameters:
     - alertDidDismissed: function to run after the the loading view appeared.
     */
    func closeLoadingOverlay(alertDidDismissed:@escaping () -> ()) {
        DispatchQueue.main.async {
            if let a = self.activeAlert {
                a.dismiss(animated: true, completion: {
                    alertDidDismissed()
                })
                self.activeAlert = nil
            }
            else {
                alertDidDismissed()
            }
        }
    }
}
