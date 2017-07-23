//
//  ImagesBrowser.swift
//  DirectoryListner
//
//  Created by Andrey Mescheryakov on 18/06/2017.
//  Copyright © 2017 Andrey Mescheryakov. All rights reserved.
//

import Foundation
import Cocoa
import MtLruCache


public class ImagesBrowser {
    var files: [String] = []
    let cache: Cache = Cache(capacityLimit: 10)
    private var images: [NSImage?] = []
    private var currentIdx: Int? = nil
    public var currentImage: NSImage? = nil
    public var delegate: ImageBrowserProtocol? = nil

    public init(dir: String, delegate: ImageBrowserProtocol? = nil) {
        self.delegate = delegate

        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            let fm = FileManager()
            var n = 0
            if let items = try? fm.contentsOfDirectory(atPath: dir) {
                for fn in items {
                    if fn.hasSuffix(".JPG") {
                        print(fn)
                        let path = "\(dir)/\(fn)"
                        let image = self.loadImage(path: path)
                        n += 1

                        DispatchQueue.main.async {
                            self.addImage(path: path, image: image)
                            if self.files.count == 1 {
                                self.move(toIdx: 0)
                            }
                        }
                    }
                }
            }
        }
    }

    private func loadImage(path: String) -> NSImage? {
        let startTime = Date()
        let img = NSImage(contentsOfFile: path)
        let loadDuration = -startTime.timeIntervalSinceNow

        let resizeStartTime = Date()
        let resized = resize(image: img!, w: 740, h: 480)
        print("Load: [\(Int(loadDuration*1000))ms] [\(Int(-resizeStartTime.timeIntervalSinceNow*1000))ms]: \(path)")

        return resized
    }

    private func addImage(path: String, image: NSImage?) {
        print("Added photo: \(path)")
        files.append(path)
        images.append(image)
    }

    private func updateImage() {
        guard currentIdx != nil else {
            return
        }
//        let imagePath = files[currentIdx!]
//        currentImage = loadImage(path: imagePath)
        currentImage = images[currentIdx!]

        if delegate != nil {
            delegate?.onImageChanged(newImage: currentImage!)
        }
    }

    public func move(toIdx: Int) {
        guard files.count > 0 else {
            return
        }

        let prevIdx = currentIdx;

        if currentIdx == nil {
            currentIdx = 0
        }

        currentIdx = min(files.count - 1, max(0, toIdx))

        if (prevIdx == nil || prevIdx! != currentIdx!) {
            print("Moved to \(currentIdx! + 1) / \(files.count)")
            updateImage()
        }

    }

    public func move(delta: Int) {
        guard currentIdx != nil else {
            return
        }
        move(toIdx: currentIdx! + delta)
    }

}


public protocol ImageBrowserProtocol {
    func onImageChanged(newImage: NSImage)
}

// taken from https://gist.github.com/ericdke/1387b3b89938b6cf3732
//
func resize(image: NSImage, w: Int, h: Int) -> NSImage {
    let destSize = NSMakeSize(CGFloat(w), CGFloat(h))
    let newImage = NSImage(size: destSize)
    newImage.lockFocus()
    image.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height), from: NSMakeRect(0, 0, image.size.width, image.size.height), operation: NSCompositingOperation.sourceOver, fraction: CGFloat(1))
    newImage.unlockFocus()
    newImage.size = destSize
    return NSImage(data: newImage.tiffRepresentation!)!
}


