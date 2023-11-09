/// Copyright (c) 2022 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

// Custom AsyncSequence from Getting Started course
struct Typewriter: AsyncSequence {
    typealias AsyncIterator = TypewriterIterator
    typealias Element = String
    let phrase: String

    func makeAsyncIterator() -> TypewriterIterator {
        return TypewriterIterator(phrase)
    }
}

struct TypewriterIterator: AsyncIteratorProtocol {
    typealias Element = String
    let phrase: String
    var index: String.Index

    init(_ phrase: String) {
        self.phrase = phrase
        self.index = phrase.startIndex
    }

    mutating func next() async throws -> String? {
        guard index < phrase.endIndex else { return nil }
//    try await Task.sleep(until: .now + .seconds(1), clock: .continuous)
        try await Task.sleep(nanoseconds: 1_000_000_000)
        defer { index = phrase.index(after: index) }
        return String(phrase[phrase.startIndex...index])
    }
}

// Comment out this Task before running AsyncStreams
// Task {
//  for try await item in Typewriter(phrase: "Hello, world!") {
//    print(item)
//  }
//  print("AsyncSequence Done")
// }
//: ## Two Kinds of AsyncStream
let phrase = "Hello, world!"
var index = phrase.startIndex
// Typewriter with push-based AsyncStream

let streamPush = AsyncStream<String> { continueation in
    Task {
        while index < phrase.endIndex {
            do {
                try await Task.sleep(until: .now + .seconds(1), clock: .continuous)
                continueation.yield(String(phrase[phrase.startIndex...index]))
                index = phrase.index(after: index)
            } catch {
                continueation.finish()
            }
        }
        continueation.finish()
    }
}

// Task {
//    for try await item in streamPush {
//        print(item)
//    }
//    print("Push AsyncStream done")
// }

// Typewriter with pull-based AsyncStream
let streamPull = AsyncStream<String> {
    guard index < phrase.endIndex else { return nil }
    do {
        try await Task.sleep(until: .now + .seconds(1), clock: .continuous)
    } catch {
        return nil
    }
    defer { index = phrase.index(after: index) }
    return String(phrase[phrase.startIndex...index])
}

// Task {
//    for try await item in streamPull {
//        print(item)
//    }
//    print("Pull AsyncStream done")
// }
