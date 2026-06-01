import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        // This is called after the user taps Post. Make sure to call super.didSelectPost() when you're done. Return any errors encountered here.
        
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else {
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            return
        }
        
        for item in items {
            guard let attachments = item.attachments else { continue }
            
            for attachment in attachments {
                if attachment.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                    attachment.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil) { (data, error) in
                        if let url = data as? URL {
                            self.saveImage(url: url)
                        } else if let image = data as? UIImage {
                            // Handle UIImage if necessary (e.g. save to temporary file)
                        }
                    }
                }
            }
        }
        
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    private func saveImage(url: URL) {
        // Use App Groups to share data between the main app and the extension
        let sharedDefaults = UserDefaults(suiteName: "group.app.dreamroom")
        
        // Load existing clips
        var clipsData = sharedDefaults?.data(forKey: "dreamroom.clips") ?? Data()
        // In a real implementation, we would decode, add, and re-encode
        
        print("Saving image from share extension: \(url.absoluteString)")
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
}
