

import SwiftUI
import Combine

class ImageCache {
    static let shared = ImageCache()
    private var cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default

    private init() {}

    func getImage(forKey key: String) -> UIImage? {
        if let image = cache.object(forKey: key as NSString) {
            return image
        }

        // Attempt to load image from local storage
        if let localImage = loadImageFromDisk(key: key) {
            cache.setObject(localImage, forKey: key as NSString)
            return localImage
        }

        return nil
    }

    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
        saveImageToDisk(image: image, key: key)
    }

    func downloadImage(from url: URL, completion: @escaping (String?) -> Void) {
        if let cachedImage = getImage(forKey: url.absoluteString) {
            completion(saveImageToDisk(image: cachedImage, key: url.absoluteString))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data), error == nil else {
                DispatchQueue.main.async {
                    completion(nil) // Signal failure properly
                }
                return
            }

            self.setImage(image, forKey: url.absoluteString)
            DispatchQueue.main.async {
                completion(self.saveImageToDisk(image: image, key: url.absoluteString))
            }
        }.resume()
    }


    private func saveImageToDisk(image: UIImage, key: String) -> String? {
        guard let data = image.jpegData(compressionQuality: 1.0) else { return nil }
        let fileName = "\(key.hashValue).jpg"
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            return fileName
        } catch {
            print("Failed to save image to disk: \(error.localizedDescription)")
            return nil
        }
    }

    private func loadImageFromDisk(key: String) -> UIImage? {
        let fileName = "\(key.hashValue).jpg"
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)

        if let data = try? Data(contentsOf: fileURL), let image = UIImage(data: data) {
            return image
        }

        return nil
    }

     func getDocumentsDirectory() -> URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
