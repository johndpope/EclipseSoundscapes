//
//  EclipseTimeGenerator.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 6/23/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//
//  Translated into Swift from:
//  Solar Eclipse Calculator for Google Maps (Xavier Jubier: http://xjubier.free.fr/)
//  Some of the code is inspired by Chris O'Byrne (http://www.chris.obyrne.com/)


import UIKit

class EclipseTimeGenerator {
    
    var R2D = 180.0 / Double.pi
    var D2R = Double.pi / 180
    
    var obsvconst = [Double](repeating: 0.0, count: 10)
    
    var elements  = [2457987.268521, 18.0, -4.0, 4.0, 68.4, -0.12957627, 0.54064089,
                     -0.00002930, -0.00000809, 0.48541746, -0.14163940, -0.00009049,
                     0.00000205, 11.86696720, -0.01362158, -0.00000249, 89.24544525,
                     15.00393677, 0.00000149, 0.54211175, 0.00012407, -0.00001177,
                     -0.00402530, 0.00012346, -0.00001172, 0.00462223, 0.00459921]
    
    var c1 = [Double](repeating: 0.0, count: 40)
    var c2 = [Double](repeating: 0.0, count: 40)
    var mid = [Double](repeating: 0.0, count: 40)
    var c3 = [Double](repeating: 0.0, count: 40)
    var c4 = [Double](repeating: 0.0, count: 40)
    
    init(latitude: Double, longitude: Double) {
        loc_circ(latitude, longitude)
    }
    
    // Populate the circumstances array with the time-only dependent circumstances (x, y, d, m, ...)
    func timedependent(_ circumstances : UnsafeMutablePointer<Double>) {
        let t = circumstances[1]
        
        var ans = elements[8] * t + elements[7]
        ans = ans * t + elements[6]
        ans = ans * t + elements[5]
        circumstances[2] = ans
        // dx
        ans = 3.0 * elements[8] * t + 2.0 * elements[7]
        ans = ans * t + elements[6]
        circumstances[10] = ans
        // y
        ans = elements[12] * t + elements[11]
        ans = ans * t + elements[10]
        ans = ans * t + elements[9]
        circumstances[3] = ans
        // dy
        ans = 3.0 * elements[12] * t + 2.0 * elements[11]
        ans = ans * t + elements[10]
        circumstances[11] = ans
        // d
        ans = elements[15] * t + elements[14]
        ans = ans * t + elements[13]
        ans = ans * D2R
        circumstances[4] = ans
        // sin d and cos d
        circumstances[5] = sin(ans)
        circumstances[6] = cos(ans)
        // dd
        ans = 2.0 * elements[15] * t + elements[14]
        ans = ans * D2R
        circumstances[12] = ans
        // m
        ans = elements[18] * t + elements[17]
        ans = ans * t + elements[16]
        if ans >= 360.0 {
            ans -= 360.0
        }
        ans = ans * D2R
        circumstances[7] = ans
        // dm
        ans = 2.0 * elements[18] * t + elements[17]
        ans = ans * D2R
        circumstances[13] = ans
        // l1 and dl1
        let type = circumstances[0]
        if type == -2 || type == 0 || type == 2 {
            ans = elements[21] * t + elements[20]
            ans = ans * t + elements[19]
            circumstances[8] = ans
            circumstances[14] = 2.0 * elements[21] * t + elements[20]
        }
        // l2 and dl2
        if type == -1 || type == 0 || type == 1 {
            ans = elements[24] * t + elements[23]
            ans = ans * t + elements[22]
            circumstances[9] = ans
            circumstances[15] = 2.0 * elements[24] * t + elements[23]
        }
    }
    
    // Populate the circumstances array with the time and location dependent circumstances
    func timelocaldependent(_ circumstances : UnsafeMutablePointer<Double>) {
        timedependent(circumstances)
        
        //h, sin h, cos h
        circumstances[16] = circumstances[7] - obsvconst[1] - (elements[4] / 13713.44)
        circumstances[17] = sin(circumstances[16])
        circumstances[18] = cos(circumstances[16])
        //xi
        circumstances[19] = obsvconst[5] * circumstances[17]
        //eta
        circumstances[20] = obsvconst[4] * circumstances[6] - obsvconst[5] * circumstances[18] * circumstances[5]
        //zeta
        circumstances[21] = obsvconst[4] * circumstances[5] + obsvconst[5] * circumstances[18] * circumstances[6]
        //dxi
        circumstances[22] = circumstances[13] * obsvconst[5] * circumstances[18]
        //deta
        circumstances[23] = circumstances[13] * circumstances[19] * circumstances[5] - circumstances[21] * circumstances[12]
        // u
        circumstances[24] = circumstances[2] - circumstances[19]
        // v
        circumstances[25] = circumstances[3] - circumstances[20]
        // a
        circumstances[26] = circumstances[10] - circumstances[22]
        // b
        circumstances[27] = circumstances[11] - circumstances[23]
        // l1'
        let type = circumstances[0]
        if type == -2 || type == 0 || type == 2 {
            circumstances[28] = circumstances[8] - circumstances[21] * elements[25]
        }
        // l2'
        if type == -1 || type == 0 || type == 1 {
            circumstances[29] = circumstances[9] - circumstances[21] * elements[26]
        }
        // n^2
        circumstances[30] = circumstances[26] * circumstances[26] + circumstances[27] * circumstances[27]
    }
    
    // Iterate on C1 or C4
    func c1c4iterate(_ circumstances : UnsafeMutablePointer<Double>) {
        var sign = 0.0
        var n  = 0.0
        
        timelocaldependent(circumstances)
        if circumstances[0] < 0 {
            sign = -1.0
        } else {
            sign = 1.0
        }
        var tmp = 1.0
        var iter = 0
        while (tmp > 0.000001 || tmp < -0.000001) && iter < 50 {
            n = sqrt(circumstances[30])
            tmp = circumstances[26] * circumstances[25] - circumstances[24] * circumstances[27]
            tmp = tmp / n / circumstances[28]
            tmp = sign * sqrt(1.0 - tmp * tmp) * circumstances[28] / n
            tmp = (circumstances[24] * circumstances[26] + circumstances[25] * circumstances[27]) / circumstances[30] - tmp
            circumstances[1] = circumstances[1] - tmp
            timelocaldependent(circumstances)
            iter += 1
        }
    }
    
    // Get C1 and C4 data
    //    Entry conditions -
    //    1. The mid array must be populated
    //    2. The magnitude at mid eclipse must be > 0.0
    func getc1c4() {
        let n = sqrt(mid[30])
        var tmp = mid[26] * mid[25] - mid[24] * mid[27]
        tmp = tmp / n / mid[28]
        tmp = sqrt(1.0 - tmp * tmp) * mid[28] / n
        c1[0] = -2
        c4[0] = 2
        c1[1] = mid[1] - tmp
        c4[1] = mid[1] + tmp
        c1c4iterate(&c1)
        c1c4iterate(&c4)
    }
    
    // Iterate on C2 or C3
    func c2c3iterate(_ circumstances : UnsafeMutablePointer<Double>) {
        var sign = 0.0
        var n  = 0.0
        
        timelocaldependent(circumstances)
        if circumstances[0] < 0 {
            sign = -1.0
        } else {
            sign = 1.0
        }
        if mid[29] < 0.0 {
            sign = -sign
        }
        var tmp = 1.0
        var iter = 0
        while (tmp > 0.000001 || tmp < -0.000001) && iter < 50 {
            n = sqrt(circumstances[30])
            tmp = circumstances[26] * circumstances[25] - circumstances[24] * circumstances[27]
            tmp = tmp / n / circumstances[29]
            tmp = sign * sqrt(1.0 - tmp * tmp) * circumstances[29] / n
            tmp = (circumstances[24] * circumstances[26] + circumstances[25] * circumstances[27]) / circumstances[30] - tmp
            circumstances[1] = circumstances[1] - tmp
            timelocaldependent(circumstances)
            iter += 1
        }
    }
    
    // Get C2 and C3 data
    //    Entry conditions -
    //    1. The mid array must be populated
    //    2. There must be either a total or annular eclipse at the location!
    func getc2c3() {
        let n = sqrt(mid[30])
        var tmp = mid[26] * mid[25] - mid[24] * mid[27]
        tmp = tmp / n / mid[29]
        tmp = sqrt(1.0 - tmp * tmp) * mid[29] / n
        c2[0] = -1
        c3[0] = 1
        if mid[29] < 0.0 {
            c2[1] = mid[1] + tmp
            c3[1] = mid[1] - tmp
        } else {
            c2[1] = mid[1] - tmp
            c3[1] = mid[1] + tmp
        }
        c2c3iterate(&c2)
        c2c3iterate(&c3)
    }
    
    // Get the observational circumstances
    func observational(_ circumstances : UnsafeMutablePointer<Double>) {
        
        // alt
        let sinlat = sin(obsvconst[0])
        let coslat = cos(obsvconst[0])
        circumstances[31] = asin(circumstances[5] * sinlat + circumstances[6] * coslat * circumstances[18])
        // azi
        circumstances[32] = atan2(-1.0 * circumstances[17] * circumstances[6],
                                  circumstances[5] * coslat - circumstances[18] * sinlat * circumstances[6])
        
    }
    
    // Calculate max eclipse
    func getmid() {
        mid[0] = 0
        mid[1] = 0.0
        var iter = 0
        var tmp = 1.0
        timelocaldependent(&mid)
        while (tmp > 0.000001 || tmp < -0.000001) && iter < 50 {
            tmp = (mid[24] * mid[26] + mid[25] * mid[27]) / mid[30]
            mid[1] = mid[1] - tmp
            iter += 1
            timelocaldependent(&mid)
        }
    }
    
    // Populate the c1, c2, mid, c3 and c4 arrays
    func getall() {
        getmid()
        observational(&mid)
        // m, magnitude and moon/sun ratio
        mid[33] = sqrt(mid[24]*mid[24] + mid[25]*mid[25])
        mid[34] = (mid[28] - mid[33]) / (mid[28] + mid[29])
        mid[35] = (mid[28] - mid[29]) / (mid[28] + mid[29])
        if mid[34] > 0.0 {
            getc1c4()
            if mid[33] < mid[29] || mid[33] < -mid[29] {
                getc2c3()
                if mid[29] < 0.0 {
                    mid[36] = 3 // Total solar eclipse
                } else {
                    mid[36] = 2 // Annular solar eclipse
                }
                observational(&c2)
                observational(&c3)
                c2[33] = 999.9
                c3[33] = 999.9
            } else {
                mid[36] = 1 // Partial eclipse
            }
            observational(&c1)
            observational(&c4)
        } else {
            mid[36] = 0 // No eclipse
        }
    }
    
    // Read the data, and populate the obsvconst array
    func readdata(_ lat : Double, _ lon : Double) {
        // Get the latitude
        obsvconst[0] = lat
        obsvconst[0] *= 1
        obsvconst[0] *= D2R
        
        // Get the longitude
        obsvconst[1] = lon
        obsvconst[1] *= -1
        obsvconst[1] *= D2R
        
        // Get the altitude (sea level by default)
        obsvconst[2] = 0
        
        // Get the time zone (UT by default)
        obsvconst[3] = 0
        
        // Get the observer's geocentric position
        let tmp = atan(0.99664719 * tan(obsvconst[0]))
        obsvconst[4] = 0.99664719 * sin(tmp) + (obsvconst[2] / 6378140.0) * sin(obsvconst[0])
        obsvconst[5] = cos(tmp) + (obsvconst[2] / 6378140.0 * cos(obsvconst[0]))
    }
    
    // This is used in getday()
    // Pads digits
    func padDigits(_ n : Double, _ totalDigits : Int ) -> String {
        var nString = String(n)
        
        var pd = ""
        if totalDigits > nString.characters.count {
            for _ in 0...(totalDigits - nString.characters.count) {
                pd.append("0")
            }
        }
        return "\(pd)\(nString)"
    }
    
    // Get the local date
    func getdate(_ circumstances : [Double]) -> String {
        /*
         var i
         var searchString = document.location.search
         
         // strip off the leading '?'
         searchString = searchString.substring(1)
         
         var nvPairs = searchString.split("&")
         
         for (i = 0  i < nvPairs.length  i++) {
         var nvPair = nvPairs[i].split("=")
         var name = nvPair[0]
         var value = nvPair[1]
         if (name == 'Ecl') {
         return value.substring(0, 4) + "/" + value.substring(4, 6) + "/" + value.substring(6, 8)
         }
         }
         */
        
        let jd = elements[0]
        
        // Calculate the local time.
        // Assumes JD > 0 (uses same algorithm as SKYCAL)
        var t = circumstances[1] + elements[1] - obsvconst[3] - (elements[4] - 0.05) / 3600.0
        if t < 0.0 {
            t += 24.0 // and jd-- below
        } else if t >= 24.0 {
            t -= 24.0 // and jd++ below
        }
        var a = 0.0
        var y = 0.0
        var m = 0.0
        var day = 0.0
        let jdm = jd + 0.5
        let z = floor(jdm)
        let f = jdm - z
        if z < 2299161 {
            a = z
        } else if z >= 2299161 {
            let alpha = floor((z - 1867216.25) / 36524.25)
            a = z + 1 + alpha - floor(alpha / 4)
        }
        let b = a + 1524
        let c = floor((b - 122.1) / 365.25)
        let d = floor(365.25 * c)
        let e = floor((b - d) / 30.6001)
        day = b - d - floor(30.6001 * e) + f
        
        if e < 14 {
            m = e - 1.0
        } else if e == 14 || e == 15 {
            m = e - 13.0
        }
        
        if m > 2 {
            y = c - 4716.0
        } else if m == 1 || m == 2 {
            y = c - 4715.0
        }
        let timediff = t - 24 * (day - floor(day)) // present time minus UT at GE
        if timediff < -12 {
            day += 1
        } else if timediff > 12 {
            day -= 1
        }
        
        return "\(padDigits(floor(y), 4))/\(padDigits(floor(m), 2))/\(padDigits(floor(day), 2))"
    }
    
    // Get the local time
    func gettime(_ circumstances: [Double]) -> String {
        var ans = ""
        
        var t = circumstances[1] + elements[1] - obsvconst[3] - (elements[4] - 0.05) / 3600.0
        if t < 0.0 {
            t += 24.0
        } else if t >= 24.0 {
            t -= 24.0
        }
        if t < 10.0 {
            ans.append("0")
        }
        ans.append("\(String(floor(t))):")
        t = (t * 60.0) - 60.0 * floor(t)
        if t < 10.0 {
            ans.append("0")
        }
        ans.append("\(String(floor(t))):")
        t = (t * 60.0) - 60.0 * floor(t)
        if t < 10.0 {
            ans.append("0")
        }
        ans.append(String(floor(t)))
        ans.append(".")
        ans.append(String(floor(10.0 * (t - floor(t)))))
        // Add an asterix if the altitude is less than zero
        if circumstances[31] <= 0.0 {
            ans.append("*")
        }
        
        return ans
    }
    
    // Display the information about 1st contact
    func displayc1() -> String {
        return "\(getdate(c1)) \(gettime(c1)) alt: \(getalt(c1))"
    }
    
    // Display the information about maximum eclipse
    func displaymid() -> String {
        return "\(getdate(mid)) \(gettime(mid)) alt: \(getalt(mid))"
    }
    // Display the information about 4th contact
    func displayc4() -> String {
        return "\(getdate(c4)) \(gettime(c4)) alt: \(getalt(c4))"
    }
    
    // Get the altitude
    func getalt(_ circumstances : [Double]) -> String {
        var ans = ""
        let t = circumstances[31] * R2D
        if abs(t) < 10.0 {
            if t >= 0.0 {
                ans += "0"
            } else {
                ans.append("-0")
            }
        }
        ans.append(String.init(format: "%.1f", abs(t)))
        return ans
    }
    
    //
    // Compute the local circumstances
    func loc_circ(_ lat : Double, _ lon : Double) {
        readdata(lat, lon)
        getall()
    }
}
