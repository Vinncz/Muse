// Copyright © 2023 Apple Inc.

import Foundation
import os

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    #if os(watchOS)
    static let shared = Logger(subsystem: subsystem, category: "WatchfulMuse")
    #else
    static let shared = Logger(subsystem: subsystem, category: "Muse")
    #endif
}
