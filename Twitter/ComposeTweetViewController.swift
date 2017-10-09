//
//  ComposeTweetViewController.swift
//  Twitter
//
//  Created by Deepthy on 9/28/17.
//  Copyright © 2017 Deepthy. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class ComposeTweetViewController: UIViewController {
   
    @IBOutlet weak var composeTextView: UITextView!
    @IBOutlet var mainPushUpView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var ScreeName: UILabel!
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var ReplyToLabel: TTTAttributedLabel!
    
    fileprivate var topCounterLabel:UILabel!
    fileprivate var bottomCounterLabel: UILabel!
    
    fileprivate var replyButton: UIButton!
    fileprivate var isReadyToTweet = false
    
    var replyingTweet: Tweet?
    
    let user = User.currentUser
    
    var initialY: CGFloat!
    var offset: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialY = mainPushUpView.frame.origin.y
        offset = -50
        
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main) { (notification: Notification) in
           
            if self.replyingTweet == nil {
                self.keyboardWillShow()
            }
        }
        setupNavbar()
        self.automaticallyAdjustsScrollViewInsets = false

        composeTextView.placeholder = "What's happening?"
        composeTextView.delegate = self

        setupCustomBottomBar()

        if replyingTweet != nil {
            composeTextView.placeholder = "Tweet your reply"
            let replyText = "Replying to @\((replyingTweet!.tweeter?.screenname!)!)" + " "
            ReplyToLabel.text = replyText

            ReplyToLabel.enabledTextCheckingTypes = NSTextCheckingAllTypes
        
            composeTextView.placeholder = ""
            setCountdownLabels(left: 140)
            setReplyButton(ready: true)
            
            if let user = replyingTweet?.tweetCreater {
                
                profileImage?.layer.cornerRadius = 3.0
                profileImage?.layer.masksToBounds = true
                
                profileImage?.layer.cornerRadius = (profileImage?.frame.size.width)!/2
                profileImage?.clipsToBounds = true
                
                if let normalImageUrl = user.profileImageUrl {
                    
                    let largeImageUrl = normalImageUrl.replacingOccurrences(of: "normal", with: "200x200")

                    if let url = URL(string: largeImageUrl) {
                        
                        profileImage?.setImageWith(url)
                    }
                }
                
                
                if let name = user.name {
                    ScreeName?.text = name
                }
                
                if let screenname = user.screenname {
                    userName?.text = "@\(screenname)"
                    let range = ReplyToLabel.text?.range(of: "@\(screenname)")
                    let nsrange = ReplyToLabel.text?.nsRange(from: range!)
                    let url = URL(string: "http:// ")
                    
                    self.ReplyToLabel.linkAttributes = [NSForegroundColorAttributeName: UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 0.5)]

                    self.ReplyToLabel.addLink(to: url, with: nsrange!)

                }
                
            }
        }
        else {
            
            ReplyToLabel.isHidden = true
            userName.isHidden = true
            ScreeName.isHidden = true
            keyboardWillShow()
           
        }
        //composeTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        topCounterLabel.removeFromSuperview()

    }
    
    func keyboardWillShow() {
        
        mainPushUpView.frame.origin.y = initialY + offset
    }
    
    func setupNavbar() {
        if replyingTweet != nil {
            
            let composeImageView = UIImageView(image: UIImage(named: "compose"))
            composeImageView.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
            let composeTap = UITapGestureRecognizer(target: self, action: #selector(composeTweet))
            composeTap.numberOfTapsRequired = 1
            composeImageView.addGestureRecognizer(composeTap)
            let rightBarButton = UIBarButtonItem.init(customView: composeImageView)
            self.navigationItem.rightBarButtonItem = rightBarButton

        }
        else {

            if let profileImageUrl = user?.profileImageUrl {
                let largeImageUrl = profileImageUrl.replacingOccurrences(of: "normal", with: "200x200")
            
                if let url = URL(string: largeImageUrl) {
                    let profileImage = UIImage()
                    let profileImageView = UIImageView(image: profileImage)
                    profileImageView.setImageWith(url)
                    profileImageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                
                    profileImageView.layer.cornerRadius = (profileImageView.frame.size.width)/2
                    profileImageView.clipsToBounds = true
                    let profileImageTap = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
                    profileImageTap.numberOfTapsRequired = 1
                    profileImageView.isUserInteractionEnabled = true
                    profileImageView.addGestureRecognizer(profileImageTap)

                    let leftbarButton = UIBarButtonItem.init(customView: profileImageView)
                    self.navigationItem.leftBarButtonItem = leftbarButton
            
               
                }
            
            
            }
            
            let cancelImageView = UIImageView(image: UIImage(named: "cancel"))
            cancelImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
       
        }
        
        if let navigationBar = self.navigationController?.navigationBar {
            let navBarWidth = navigationBar.frame.width
            
            let frame = CGRect(x: navBarWidth - 75, y: 0, width: 35, height: navigationBar.frame.height)
            
            topCounterLabel = UILabel(frame: frame)
            topCounterLabel.textColor = UIColor.black
            topCounterLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16)
            
            navigationBar.addSubview(topCounterLabel)
        }

        
    }
    
    
    func profileImageTapped() {
        
        let  accountAlert = UIAlertAction.init(title: "\((user?.name)!) \n \((user?.screenname)!)", style: .default, image: UIImage(named: "user")!)
        let profileImageAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
 
        profileImageAlert.addAction(accountAlert)

        self.present(profileImageAlert, animated: true, completion: nil)
        
    }


    func setupCustomBottomBar() {
        
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 50))

        customView.backgroundColor = UIColor.white
        customView.layer.borderColor = UIColor(red: 170/255, green: 184/255, blue: 194/255, alpha: 1).cgColor
        
        customView.layer.borderWidth = 0.3
        composeTextView.inputAccessoryView = customView
        
        self.view.addSubview(composeTextView)
        let screenWidth = UIScreen.main.bounds.width
        
        bottomCounterLabel = UILabel()
        bottomCounterLabel.frame = CGRect(x: screenWidth - 120, y: 0, width: 30, height: 50)
        bottomCounterLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        setCountdownLabels(left: 140)
        
        customView.addSubview(bottomCounterLabel)
        
        replyButton = UIButton()
        replyButton.frame = CGRect(x: screenWidth - 80, y: 10, width: 70, height: 30)
        replyButton.setTitle("Reply", for: .normal)
        replyButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        replyButton.layer.cornerRadius = replyButton.frame.height / 2
        replyButton.clipsToBounds = true
        replyButton.layer.masksToBounds = true
        setReplyButton(ready: isReadyToTweet)
        customView.addSubview(replyButton)
        
        replyButton.addTarget(self, action: #selector(sendTweet), for: .touchUpInside)
        
    }

    @IBAction func onCancelButto(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func composeTweet() {
        setCountdownLabels(left: 140)
        performSegue(withIdentifier: "ComposeFromTweet", sender: self)
    }

    func cancelTapped() {
        composeTextView.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ComposeFromTweet" {
            
            if let composeTweetViewController = segue.destination as? ComposeTweetViewController {
                    composeTweetViewController.replyingTweet = self.replyingTweet

            }
        }
    }

    func setCountdownLabels(left: Int) {
       
        topCounterLabel.text = "\(left)"
        bottomCounterLabel.text = "\(left)"

        if (left > 20) {
            topCounterLabel.textColor = UIColor(red: 101/255, green: 119/255, blue: 134/255, alpha: 1)
            bottomCounterLabel.textColor = UIColor(red: 101/255, green: 119/255, blue: 134/255, alpha: 1)
        } else {
            topCounterLabel.textColor = UIColor.red
            bottomCounterLabel.textColor = UIColor.red
        }
    }
    
    func setReplyButton(ready: Bool) {
        
        replyButton.setTitleColor(UIColor.white, for: .normal)
        replyButton.layer.borderWidth = 0
        isReadyToTweet = ready
        replyButton.isUserInteractionEnabled = ready


        if (!ready) {
            replyButton.backgroundColor = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 0.5)
            //tweetButton.setTitleColor(UIColor(red: 101/255, green: 119/255, blue: 134/255, alpha: 1), for: .normal) // grey
            //tweetButton.layer.borderColor = UIColor(red: 101/255, green: 119/255, blue: 134/255, alpha: 1).cgColor //dary grey
        } else {
            replyButton.backgroundColor = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1)
        }
    }
    
    func sendTweet() {
        composeTextView.resignFirstResponder()
        
        TwitterClient.sharedInstance.update(status: composeTextView.text, inReplyToStatusId: replyingTweet?.remoteIdStr,            success: { (tweet: Tweet?) in
            if let newTweet = tweet {
                let userInfo:[String: Tweet] = ["tweet": newTweet]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newTweet"), object: nil, userInfo: userInfo)
            }
        }) { (error: Error) in
            print("error \(error.localizedDescription)")
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tweetViewController = storyboard.instantiateViewController(withIdentifier: "Homeline") as! UINavigationController
        self.navigationController?.pushViewController(tweetViewController.topViewController!, animated: true)
    }
}

extension ComposeTweetViewController : UITextViewDelegate {
    
    // MARK: - Text View delegate methods
    func textViewDidChange(_ textView: UITextView) {
        
        let currentCount = textView.text.characters.count
        
        if (currentCount > 0) {
            textView.placeholder = ""
        }
        else{
            textView.placeholder = "What's happening?"
        }
        
        let charactersLeft = 140 - currentCount
        setCountdownLabels(left: charactersLeft)
        
        if (isReadyToTweet) {
            if (charactersLeft < 0 || charactersLeft > 139) {
                setReplyButton(ready: false)
            }
        } else {
            if (charactersLeft < 140 && charactersLeft > -1) {
                setReplyButton(ready: true)
            }
        }
    }
    
}

extension UITextView: UITextViewDelegate {
    
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {

        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The UITextView placeholder text
    public var placeholder: String? {

        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {

        let placeholderLabel = UILabel()
        placeholderLabel.frame = CGRect(x: 8, y: 9, width: 280, height: 30)

        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = UIFont(name: "HelveticaNeue-Light", size: 17)
        placeholderLabel.textColor = UIColor(red: 170/255, green: 184/255, blue: 194/255, alpha: 1)
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = self.text.characters.count > 0
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self

    }
    
}


extension String {
    func nsRange(from range: Range<Index>) -> NSRange {
        let lower = UTF16View.Index(range.lowerBound, within: utf16)
        let upper = UTF16View.Index(range.upperBound, within: utf16)
        return NSRange(location: utf16.startIndex.distance(to: lower), length: lower.distance(to: upper))
    }
}

extension UIAlertAction {
    convenience init(title: String?, style: UIAlertActionStyle, image: UIImage, handler: ((UIAlertAction) -> Void)? = nil) {
        self.init(title: title, style: style, handler: handler)
        self.actionImage = image
    }
    
    convenience init?(title: String?, style: UIAlertActionStyle, imageNamed imageName: String, handler: ((UIAlertAction) -> Void)? = nil) {
        if let image = UIImage(named: imageName) {
            self.init(title: title, style: style, image: image, handler: handler)
        } else {
            return nil
        }
    }
    
    var actionImage: UIImage {
        get {
            return self.value(forKey: "image") as? UIImage ?? UIImage()
        }
        set(image) {
            self.setValue(image, forKey: "image")
        }
    }
}
