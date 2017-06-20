//
//  AudioQueue.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 5/30/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//
//  Implementation from Swift Algorithm Club
//  
/// Source:
///    Swift Algorithm Club,swift-algorithm-club/Queue/Queue-Optimized.swift, (2017), GitHub repository
///    https://github.com/raywenderlich/swift-algorithm-club/blob/master/Queue/Queue-Optimized.swift

/*
 First-in first-out queue (FIFO)
 
 New elements are added to the end of the queue. Dequeuing pulls elements from
 the front of the queue.
 
 Enqueuing and dequeuing are O(1) operations.
 */
public struct AudioQueue<T> {
    fileprivate var minQueueSize = 1//5
    fileprivate var array = [T?]()
    fileprivate var head = 0
    
    public var isEmpty: Bool {
        return self.count == 0 // swiftlint:disable:this empty_count
    }
    
    public var count: Int {
        return array.count - head
    }
    
    public mutating func enqueue(_ element: T) {
        array.append(element)
    }
    
    public mutating func dequeue() -> T? {
        guard head < array.count, let element = array[head] else { return nil }
        
        array[head] = nil
        head += 1
        
        let percentage = Double(head)/Double(array.count)
        if array.count > 50 && percentage > 0.25 {
            array.removeFirst(head)
            head = 0
        }
        
        return element
    }
    
    public var front: T? {
        if isEmpty {
            return nil
        } else {
            return array[head]
        }
    }
}
