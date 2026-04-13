//
//  WebViewRepresentable.swift
//  Wraply
//
//  Created by Michael Fluharty on 4/7/26.
//


  //                                                        
  //  WebViewRepresentable.swift
  //  Wraply
  //

  import SwiftUI
  import WebKit

  struct WebViewRepresentable: UIViewRepresentable {
      let webView: WKWebView
                                                                                                                        
      func makeUIView(context: Context) -> WKWebView {
          webView.allowsBackForwardNavigationGestures = true                                                            
          return webView                                    
      }

      func updateUIView(_ uiView: WKWebView, context: Context) {                                                        
          // SwiftUI calls this when state changes.
          // We handle loading in ContentView, so nothing needed here.                                                  
      }                                                     
  }
