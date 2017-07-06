// CountdownViewModel.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2016 apegroup
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

/**
The view model all logic for the framework.
*/
class CountdownViewModel {
    
    var isActive = false
    var timer : DispatchSourceTimer?
    
    func observe(_ endDate: Date, handler : @escaping (CountdownTimeLeft, Bool) -> Void) {
        let queue = DispatchQueue.global(qos: .default)
        timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: queue)
        timer?.scheduleRepeating(deadline: DispatchTime.now(), interval: .seconds(1), leeway: .seconds(0))
        
        timer?.setEventHandler(handler: {
            if self.isCountdownCompleted(endDate) {
                DispatchQueue.main.async {
                    handler(self.parseCountdownTimeLeft(endDate), true)
                }
                self.isActive = false
                self.timer?.cancel()
                self.timer = nil
            } else {
                DispatchQueue.main.async {
                   handler(self.parseCountdownTimeLeft(endDate), false)
                }
                
            }
        })
        timer?.resume()
        isActive = true
        
    }
    
    func stop() {
        timer?.cancel()
        timer = nil
        isActive = false
    }
    
    /**
     Parse time left before the countdown ends.
     
     - parameter endDate when counter should end.
     - returns: Days, hours, minutes and seconds left before countdown ends.
    */
    fileprivate func parseCountdownTimeLeft(_ endDate: Date) -> CountdownTimeLeft {
        let currentDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: currentDate, to: endDate)
        
        var countdownTimeLeft = CountdownTimeLeft()
        
        if components.second ?? -1 < 0 {
            countdownTimeLeft.day1 = "0"
            countdownTimeLeft.day2 = "0"
            
            countdownTimeLeft.hour1 = "0"
            countdownTimeLeft.hour2 = "0"
            
            countdownTimeLeft.min1 = "0"
            countdownTimeLeft.min2 = "0"
            
            countdownTimeLeft.sec1 = "0"
            countdownTimeLeft.sec2 = "0"
        } else {
            if let day = components.day {
                let days = String(format: "%02d", day)
                countdownTimeLeft.day1 = days.getFirstChar()
                countdownTimeLeft.day2 = days.getLastChar()
            }
            
            if let hour = components.hour {
                
                let hours = String(format: "%02d", hour)
                countdownTimeLeft.hour1 = hours.getFirstChar()
                countdownTimeLeft.hour2 = hours.getLastChar()
            }
            
            if let minute = components.minute {
                let minutes = String(format: "%02d", minute)
                countdownTimeLeft.min1 = minutes.getFirstChar()
                countdownTimeLeft.min2 = minutes.getLastChar()
            }
            
            if let second = components.second {
                let seconds = String(format: "%02d", second)
                countdownTimeLeft.sec1 = seconds.getFirstChar()
                countdownTimeLeft.sec2 = seconds.getLastChar()
            }
        }
        
        return countdownTimeLeft
    }
    
    /**
     Determine if the end date is completed.

     - returns: Completed or not
    */
    fileprivate func isCountdownCompleted(_ endDate: Date) -> Bool {
        let currentDate = Date()
        return currentDate.compare(endDate as Date) == .orderedDescending
    }
}
