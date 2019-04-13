//
//  ViewController.swift
//  China
//
//  Created by new torigoe on 2019/02/23.
//  Copyright © 2019 new torigoe. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    let wkWebView = WKWebView()
    
    var backButton: UIButton!
    var forwadButton: UIButton!
    var targetUrl = "https://plus.dokuzemi.com/?tmp_id=1"
    var navigationDelegate: WKNavigationDelegate?
    var urlRequest: URLRequest!
    var urlRequest2: URLRequest!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        wkWebView.frame = view.frame
        wkWebView.navigationDelegate = self
        wkWebView.uiDelegate = self
        
        
        // スワイプでの「戻る・すすむ」を有効にする
        wkWebView.allowsBackForwardNavigationGestures = true
        
        self.urlRequest = URLRequest(url:URL(string:targetUrl)!)
        urlRequest.addValue("appli", forHTTPHeaderField: "field")
        wkWebView.load(urlRequest)
        view.addSubview(wkWebView)
        
        createWebControlParts()
    }
    /// 戻る・すすむボタン作成
    private func createWebControlParts() {
        
        let buttonSize = CGSize(width:40,height:40)
        let offseetUnderBottom:CGFloat = 60
        let yPos = (UIScreen.main.bounds.height - offseetUnderBottom)
        let buttonPadding:CGFloat = 10
        
        let backButtonPos = CGPoint(x:buttonPadding, y:yPos)
        let forwardButtonPos = CGPoint(x:(buttonPadding + buttonSize.width + buttonPadding), y:yPos)
        
        backButton = UIButton(frame: CGRect(origin: backButtonPos, size: buttonSize))
        forwadButton = UIButton(frame: CGRect(origin:forwardButtonPos, size:buttonSize))
        
        backButton.setTitle("<", for: .normal)
        backButton.setTitle("< ", for: .highlighted)
        backButton.setTitleColor(.white, for: .normal)
        backButton.layer.backgroundColor = UIColor.black.cgColor
        backButton.layer.opacity = 0.6
        backButton.layer.cornerRadius = 5.0
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        backButton.isHidden = true
        view.addSubview(backButton)
        
        forwadButton.setTitle(">", for: .normal)
        forwadButton.setTitle(" >", for: .highlighted)
        forwadButton.setTitleColor(.white, for: .normal)
        forwadButton.layer.backgroundColor = UIColor.black.cgColor
        forwadButton.layer.opacity = 0.6
        forwadButton.layer.cornerRadius = 5.0
        forwadButton.addTarget(self, action: #selector(goForward), for: .touchUpInside)
        forwadButton.isHidden = true
        view.addSubview(forwadButton)
        
    }
    @objc private func goBack() {
        wkWebView.goBack()
    }
    
    @objc private func goForward() {
        wkWebView.goForward()
    }

}

extension ViewController: WKNavigationDelegate {
    // MARK: - 読み込み設定（リクエスト前）
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("リクエスト前")

        /*  これを設定しないとアプリがクラッシュする
         *  .allow  : 読み込み許可
         *  .cancel : 読み込みキャンセル
         */
        decisionHandler(.allow)
    }
    // ウェブのロード完了時に呼び出される
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        backButton.isHidden = (webView.canGoBack) ? false : true
        forwadButton.isHidden = (webView.canGoForward) ? false : true
        
        let cookieStorage = HTTPCookieStorage.shared.cookies
        dump(cookieStorage)
        let script = getJSCookiesString(for: cookieStorage!)
        dump(script)
    }
    public func getJSCookiesString(for cookies: [HTTPCookie]) -> String {
        var result = ""
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
        
        for cookie in cookies {
            result += "document.cookie='\(cookie.name)=\(cookie.value); domain=\(cookie.domain); path=\(cookie.path); "
            if let date = cookie.expiresDate {
                result += "expires=\(dateFormatter.string(from: date)); "
            }
            if (cookie.isSecure) {
                result += "secure; "
            }
            result += "'; "
        }
        return result
    }
}

// target=_blank対策
extension ViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        print("aaccess")
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        
        return nil
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        if let urlResponse = navigationResponse.response as? HTTPURLResponse,
            let url = urlResponse.url,
            let allHeaderFields = urlResponse.allHeaderFields as? [String : String] {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: allHeaderFields, for: url)
            print("aab")
            print(url.absoluteString)
            dump(urlRequest)
            
             if url.absoluteString != "https://plus.dokuzemi.com/?tmp_id=1" {
                //urlRequest = url as! URLRequest
                self.urlRequest = URLRequest(url:URL(string:url.absoluteString)!)
                print("ccc")
                //wkWebView.load(urlRequest)
                //decisionHandler(.allow)
                
            } else {
                decisionHandler(.allow)
                print("ddd")
            }
            
            print("aab")
            
            for cookie in cookies {
                if cookie.domain == "リクエストしたサーバーのドメイン"  {
                    // UserDefaultにCookie情報を保存する
                }
            }
        }
        
    }
    
    
}


