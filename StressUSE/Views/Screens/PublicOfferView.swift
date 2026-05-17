import SwiftUI
import WebKit

struct PublicOfferView: View {
    private let offerURL = URL(string: "https://github.com/vovaggri/StressUSE/blob/main/docs/%D0%94%D0%9E%D0%93%D0%9E%D0%92%D0%9E%D0%A0%20%D0%9F%D0%A3%D0%91%D0%9B%D0%98%D0%A7%D0%9D%D0%9E%D0%99%20%D0%9E%D0%A4%D0%95%D0%A0%D0%A2%D0%AB.pdf")!

    var body: some View {
        WebView(url: offerURL)
            .navigationTitle("Публичная оферта")
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(edges: .bottom)
    }
}

private struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard webView.url != url else { return }
        webView.load(URLRequest(url: url))
    }
}

#Preview {
    NavigationStack {
        PublicOfferView()
    }
}
